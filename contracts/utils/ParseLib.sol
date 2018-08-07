pragma solidity ^0.4.24;

import "contracts/utils/JsmnSolLib.sol";

library ParseLib {

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    function parseAddr(string _a) internal pure returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i + 1]);
            if ((b1 >= 97) && (b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65) && (b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48) && (b1 <= 57)) b1 -= 48;
            if ((b2 >= 97) && (b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65) && (b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48) && (b2 <= 57)) b2 -= 48;
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10 ** _b;
        return mint;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function addressToString(address x) internal pure returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2 ** (8 * (19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return strConcat('0x', string(s));
    }

    function char(byte b) internal pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }

    function getJsonToCdAddr(JsmnSolLib.Token[] _tokens, string _jsonData)
        internal
        pure
        returns (address)
    {
        return parseAddr(getTokenToValue(_tokens, _jsonData, 2));
    }

    function getJsonToContentAddr(JsmnSolLib.Token[] _tokens, string _jsonData)
        internal
        pure
        returns (address)
    {
        return parseAddr(getTokenToValue(_tokens, _jsonData, 4));
    }

    function getJsonToEpisodeIndex(JsmnSolLib.Token[] _tokens, string _jsonData)
        internal
        pure
        returns (uint256)
    {
        return uint256(parseInt(getTokenToValue(_tokens, _jsonData, 6)));
    }

    function getJsonToMarketerAddr(JsmnSolLib.Token[] _tokens, string _jsonData)
        internal
        pure
        returns (address)
    {
        return parseAddr(getTokenToValue(_tokens, _jsonData, 8));
    }

    function getJsonToValue(string  _jsonData, uint256 _arrayLength, uint256 _valueIndex)
        internal
        pure
        returns (string)
    {
        uint256 returnValue;
        JsmnSolLib.Token[] memory tokens;

        (returnValue, tokens) = getJsonToTokens(_jsonData, _arrayLength);

        return getTokenToValue(tokens, _jsonData, _valueIndex);
    }

    function getJsonToTokens(string _jsonData, uint256 _arrayLength)
        internal
        pure
        returns (uint256, JsmnSolLib.Token[])
    {
        uint256 returnValue;
        uint256 actualNum;
        JsmnSolLib.Token[] memory tokens;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(_jsonData, _arrayLength);

        return (returnValue, tokens);
    }

    function getTokenToValue(JsmnSolLib.Token[] _tokens, string  _jsonData, uint256 _index)
        internal
        pure
        returns (string)
    {
        JsmnSolLib.Token memory t = _tokens[_index];

        return JsmnSolLib.getBytes(_jsonData, t.start, t.end);
    }
}
