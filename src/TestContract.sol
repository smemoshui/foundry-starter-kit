//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ITestInterface.sol";

contract TestContract is ITestContract {

    // 定义事件
    event Log(address sender, uint256 x, uint256 y);

    // 可接受外部调用的函数
    function testFunction(uint256 x, uint256 y) external override {

        // 触发事件 
        emit Log(msg.sender, x, y);
    }
}