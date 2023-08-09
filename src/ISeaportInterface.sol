pragma solidity ^0.8.0;
import {
    Execution,
    Fulfillment,
    Order
} from "seaport-types/src/lib/ConsiderationStructs.sol";

interface ISeaportContract {
  function matchOrdersWithLucky(
        /**
         * @custom:name orders
         */
        Order[] calldata,
        /**
         * @custom:name fulfillments
         */
        Fulfillment[] calldata,
        uint256 numerator,
        uint256 denominator
    ) external payable returns (Execution[] memory /* executions */ );
}