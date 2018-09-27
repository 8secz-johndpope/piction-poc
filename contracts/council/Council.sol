pragma solidity ^0.4.24;

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IReport.sol";
import "contracts/interface/IDepositPool.sol";

import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable, ValidValue, ICouncil {

    struct PictionValue {
        uint256 initialDeposit;
        uint256 reportRegistrationFee;
    }

    struct PictionRate {
        uint256 cdRate;
        uint256 depositRate;
        uint256 userPaybackRate;
        uint256 reportRewardRate;
        uint256 marketerDefaultRate;
    }

    struct PictionAddress {
        address userPaybackPool;
        address depositPool;
        address supporterPool;
        address pixelDistributor;
        address marketer;
        address report;
    }

    struct ManagerAddress {
        address contentsManager;
        address fundManager;
        address accountManager;
    }

    struct ApiAddress {
        address apiContents;
        address apiReport;
        address apiFund;
    }

    address token;
    PictionValue pictionValue;
    PictionRate pictionRate;
    PictionAddress pictionAddress;
    ManagerAddress managerAddress;
    ApiAddress apiAddress;

    mapping (address => bool) members;

    constructor(
        address _token)
        public
        validAddress(_token)
    {
        token = _token;
        members[msg.sender] = true;

        emit RegisterCouncil(msg.sender, _token);
    }

    function setMember(address _member, bool _allow) external onlyOwner {
        members[_member] = _allow;

        emit SetMember(_member, _allow);
    }

    function isMember(address _member) external view returns(bool allow_) {
        allow_ = members[_member];
    }

    function initialValue(
        uint256 _initialDeposit,
        uint256 _reportRegistrationFee)
        external onlyOwner
        validRange(_initialDeposit)
        validRange(_reportRegistrationFee) {

        pictionValue = PictionValue(_initialDeposit, _reportRegistrationFee);

        emit InitialValue(_initialDeposit, _reportRegistrationFee);
    }

    function initialRate(
        uint256 _cdRate,
        uint256 _depositRate,
        uint256 _userPaybackRate,
        uint256 _reportRewardRate,
        uint256 _marketerDefaultRate)
        external onlyOwner
        validRange(_cdRate)
        validRange(_depositRate)
        validRange(_userPaybackRate)
        validRange(_reportRewardRate)
        validRange(_marketerDefaultRate) {

        pictionRate = PictionRate(_cdRate, _depositRate, _userPaybackRate, _reportRewardRate, _marketerDefaultRate);

        emit InitialRate(_cdRate, _depositRate, _userPaybackRate, _reportRewardRate, _marketerDefaultRate);
    }

    function initialPictionAddress(
        address _userPaybackPool,
        address _depositPool,
        address _supporterPool,
        address _pixelDistributor,
        address _marketer,
        address _report)
        external onlyOwner
        validAddress(_userPaybackPool)
        validAddress(_depositPool)
        validAddress(_supporterPool)
        validAddress(_pixelDistributor)
        validAddress(_marketer)
        validAddress(_report) {

        pictionAddress = PictionAddress(_userPaybackPool, _depositPool, _supporterPool, _pixelDistributor, _marketer, _report);

        emit InitialAddress(_userPaybackPool, _depositPool, _supporterPool, _pixelDistributor, _marketer, _report);
    }

    function initialManagerAddress(
        address _contentsManager,
        address _fundManager,
        address _accountManager)
        external onlyOwner
        validAddress(_contentsManager)
        validAddress(_fundManager)
        validAddress(_accountManager)
    {

        managerAddress = ManagerAddress(_contentsManager, _fundManager, _accountManager);

        emit InitialManagerAddress(_contentsManager, _fundManager, _accountManager);
    }

    function initialApiAddress(
        address _apiContents,
        address _apiReport,
        address _apiFund
    )
        external
        onlyOwner
        validAddress(_apiContents) validAddress(_apiReport) validAddress(_apiFund)
    {
        apiAddress = ApiAddress(_apiContents, _apiReport, _apiFund);

        emit InitialApiAddress(_apiContents, _apiReport, _apiFund);
    }

    /**
    * @dev 위원회 등록된 전체 정보 조회
    * @return address pxlAddress_ pxl token address
    * @return uint256[] pictionValue_ 상황 별 deposit token 수량
    * @return uint256[] pictionRate_ 작품 판매시 분배 될 고정 비율 정보
    * @return address[] pictionAddress_ piction network에서 사용되는 컨트랙트 주소
    * @return address[] managerAddress_ 매니저 성격의 컨트랙트 주소
    * @return address[] apiAddress_ piction network API 컨트랙트 주소
    */
    function getPictionConfig()
        external
        view
        returns (address pxlAddress_, uint256[] pictionValue_, uint256[] pictionRate_,
             address[] pictionAddress_, address[] managerAddress_, address[] apiAddress_)
    {
        pictionValue_ = new uint256[](2);
        pictionRate_ = new uint256[](5);
        pictionAddress_ = new address[](5);
        managerAddress_ = new address[](3);
        apiAddress_ = new address[](3);

        pxlAddress_ = token;

        // 배열의 순서는 구조체 선언 순서
        pictionValue_[0] = pictionValue.initialDeposit;
        pictionValue_[1] = pictionValue.reportRegistrationFee;

        pictionRate_[0] = pictionRate.cdRate;
        pictionRate_[1] = pictionRate.depositRate;
        pictionRate_[2] = pictionRate.userPaybackRate;
        pictionRate_[3] = pictionRate.reportRewardRate;
        pictionRate_[4] = pictionRate.marketerDefaultRate;

        pictionAddress_[0] = pictionAddress.userPaybackPool;
        pictionAddress_[1] = pictionAddress.depositPool;
        pictionAddress_[2] = pictionAddress.pixelDistributor;
        pictionAddress_[3] = pictionAddress.marketer;
        pictionAddress_[4] = pictionAddress.report;

        managerAddress_[0] = managerAddress.contentsManager;
        managerAddress_[1] = managerAddress.fundManager;
        managerAddress_[2] = managerAddress.accountManager;

        apiAddress_[0] = apiAddress.apiContents;
        apiAddress_[1] = apiAddress.apiReport;
        apiAddress_[2] = apiAddress.apiFund;
    }

    /**
    * @dev Report 목록의 신고를 처리함
    * @param _index Report의 reports 인덱스 값
    * @param _content Content의 주소
    * @param _reporter Reporter의 주소
    * @param _deductionRate 신고자의 RegFee를 차감시킬 비율, 0이면 Reward를 지급함, 50(논의)이상이면 block처리함
    */
    function judge(uint256 _index, address _content, address _reporter, uint256 _deductionRate) external {
        require(apiAddress.apiReport == msg.sender);

        uint256 resultAmount;
        bool valid;
        if (_deductionRate > 0) {
            resultAmount = IReport(pictionAddress.report).deduction(_reporter, _deductionRate, (_deductionRate/(10 ** 16)) >= 50 ? true:false);
            valid = false;
        } else {
            resultAmount = IDepositPool(pictionAddress.depositPool).reportReward(_content, _reporter);
            valid = true;
        }

        IReport(pictionAddress.report).completeReport(_index, valid, resultAmount);

        emit Judge(_index, _content, _reporter, _deductionRate);
    }


    function getToken() external view returns (address token_) {
        return token;
    }

    function getInitialDeposit() external view returns (uint256 initialDeposit_) {
        return pictionValue.initialDeposit;
    }

    function getReportRegistrationFee() view external returns (uint256 reportRegistrationFee_) {
        return pictionValue.reportRegistrationFee;
    }

    function getCdRate() external view returns (uint256 cdRate_) {
        return pictionRate.cdRate;
    }

    function getDepositRate() external view returns (uint256 depositRate_) {
        return pictionRate.depositRate;
    }

    function getUserPaybackRate() external view returns (uint256 userPaybackRate_) {
        return pictionRate.userPaybackRate;
    }

    function getReportRewardRate() view external returns (uint256 reportRewardRate_) {
        return pictionRate.reportRewardRate;
    }

    function getMarketerDefaultRate() view external returns (uint256 marketerDefaultRate_) {
        return pictionRate.marketerDefaultRate;
    }

    function getUserPaybackPool() external view returns (address userPaybackPool_) {
        return pictionAddress.userPaybackPool;
    }

    function getDepositPool() external view returns (address depositPool_) {
        return pictionAddress.depositPool;
    }

    function getSupporterPool() external view returns (address supporterPool_) {
        return pictionAddress.supporterPool;
    }

    function getContentsManager() external view returns (address contentsManager_) {
        return managerAddress.contentsManager;
    }

    function getFundManager() external view returns (address fundManager_) {
        return managerAddress.fundManager;
    }

    function getAccountManager() external view returns (address accountManager_) {
        return managerAddress.accountManager;
    }

    function getPixelDistributor() external view returns (address pixelDistributor_) {
        return pictionAddress.pixelDistributor;
    }

    function getMarketer() external view returns (address marketer_) {
        return pictionAddress.marketer;
    }

    function getReport() external view returns (address report_) {
        return pictionAddress.report;
    }

    function getApiContents() external view returns (address apiContents_) {
        return apiAddress.apiContents;
    }

    function getApiReport() external view returns (address apiReport_) {
        return apiAddress.apiReport;
    }

    function getApiFund() external view returns (address apiFund_) {
        return apiAddress.apiFund;
    }
}
