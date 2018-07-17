pragma solidity ^0.4.24;

import "contracts/utils/ExtendsOwnable.sol";

/**
 * @title Council contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */
contract Council is ExtendsOwnable {
    uint256 public cdRate;
    uint256 public depositRate;
    uint256 public initialDeposit;
    uint256 public userPaybackRate;
    uint256 public reportRegistrationFee;
    address public userPaybackPool;
    address public token;
    address public roleManager;
    address public contentsManager;
    address public pixelDistributor;

    modifier validRange(uint256 _value) {
        require(_value > 0);
        _;
    }

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    constructor(
        uint256 _cdRate,
        uint256 _depositRate,
        uint256 _initialDeposit,
        uint256 _userPaybackRate,
        uint256 _reportRegistrationFee,
        address _token)
        public
        validRange(_cdRate)
        validRange(_depositRate)
        validRange(_initialDeposit)
        validRange(_userPaybackRate)
        validRange(_reportRegistrationFee)
        validAddress(_token)
    {
        cdRate = _cdRate;
        depositRate = _depositRate;
        initialDeposit = _initialDeposit;
        userPaybackRate = _userPaybackRate;
        reportRegistrationFee = _reportRegistrationFee;
        token = _token;

        emit RegisterCouncil(msg.sender, _cdRate, _depositRate, _initialDeposit, _userPaybackRate, _reportRegistrationFee, _token);
    }

    function setCdRate(uint256 _cdRate) external onlyOwner validRange(_cdRate) {
        cdRate = _cdRate;

        emit ChangeDistributionRate(msg.sender, "cd rate", _cdRate);
    }

    function setDepositRate(uint256 _depositRate) external onlyOwner validRange(_depositRate) {
        depositRate = _depositRate;

        emit ChangeDistributionRate(msg.sender, "deposit rate", _depositRate);
    }

    function setInitialDeposit(uint256 _initialDeposit) external onlyOwner validRange(_initialDeposit) {
        initialDeposit = _initialDeposit;

        emit ChangeDistributionRate(msg.sender, "initial deposit", _initialDeposit);
    }

    function setUserPaybackRate(uint256 _userPaybackRate) external onlyOwner validRange(_userPaybackRate) {
        userPaybackRate = _userPaybackRate;

        emit ChangeDistributionRate(msg.sender, "user payback rate", _userPaybackRate);
    }

    function setReportRegistrationFee(uint256 _reportRegistrationFee) external onlyOwner validRange(_reportRegistrationFee) {
        reportRegistrationFee = _reportRegistrationFee;

        emit ChangeDistributionRate(msg.sender, "report registration fee", _reportRegistrationFee);
    }

    function setUserPaybackPool(address _userPaybackPool) external onlyOwner validAddress(_userPaybackPool) {
        userPaybackPool = _userPaybackPool;

        emit ChangeAddress(msg.sender, "user payback pool", _userPaybackPool);
    }

    function setRoleManager(address _roleManager) external onlyOwner validAddress(_roleManager) {
        roleManager = _roleManager;

        emit ChangeAddress(msg.sender, "role manager", _roleManager);
    }

    function setContentsManager(address _contentsManager) external onlyOwner validAddress(_contentsManager) {
        contentsManager = _contentsManager;

        emit ChangeAddress(msg.sender, "contents manager", _contentsManager);
    }

    function setPixelDistributor(address _pixelDistributor) external onlyOwner validAddress(_pixelDistributor) {
        pixelDistributor = _pixelDistributor;

        emit ChangeAddress(msg.sender, "pixel distributor", _pixelDistributor);
    }

    event RegisterCouncil(address _sender, uint256 _cdRate, uint256 _deposit, uint256 _initialDeposit, uint256 _userPaybackRate, uint256 _reportRegistrationFee, address _token);
    event ChangeDistributionRate(address _sender, string _name, uint256 _value);
    event ChangeAddress(address _sender, string addressName, address _addr);
}
