// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./ITestInterface.sol";

/**
 * @title The VRFConsumerV2 contract
 * @notice A contract that gets random values from Chainlink VRF V2
 */
contract VRFConsumerV2 is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;
    ITestContract immutable Test;

    // Your subscription ID.
    uint64 immutable s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 immutable s_keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 immutable s_callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 immutable s_requestConfirmations = 3;


    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 public immutable s_numWords = 2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;


    uint256 immutable precision = 100;
    uint256[] public numerators;
    uint256 immutable demonator = 1000000;


    event ReturnedRandomness(uint256[] randomWords);

    /**
     * @notice Constructor inherits VRFConsumerBaseV2
     *
     * @param subscriptionId - the subscription ID that this contract uses for funding requests
     * @param vrfCoordinator - coordinator, check https://docs.chain.link/docs/vrf-contracts/#configurations
     * @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to
     */
    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        address link,
        bytes32 keyHash
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_keyHash = keyHash;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        Test = ITestContract(0xc1c34d7AaB5770cEBbEF4f16dE82fE34591cea96);

        initLookups();
    }

    /**
     * @notice Requests randomness
     * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
     */
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            s_numWords
        );
    }

    /**
     * @notice Callback function used by VRF Coordinator
     *
     * @param requestId - id of the request
     * @param randomWords - array of random results from VRF Coordinator
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        s_randomWords = randomWords;
        emit ReturnedRandomness(randomWords);
        
        (uint256 x, uint256 y) = betainv(randomWords[0]);
        Test.testFunction(x, y);

        (x, y) = betainv(randomWords[1]);
        Test.testFunction(x, y);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function betainv(uint256 x) internal returns (uint256, uint256) {

        // x已经调整到0-1000范围,直接查表
        uint256 mod_x = x % precision;

        // 添加取余运算限定精度
        return (numerators[mod_x], demonator); 
    }

    function initLookups() internal {
        numerators = [0, 5012, 10050, 15114, 20204, 25320, 30464, 35634, 40833, 46060, 51316, 56601, 61916, 67262, 72638, 78045, 83484, 88956, 94461, 100000, 105572, 111180, 116823, 122503, 128220, 133974, 139767, 145599, 151471, 157385, 163339, 169337, 175378, 181464, 187596, 193774, 199999, 206274, 212599, 218975, 225403, 231885, 238422, 245016, 251668, 258380, 265153, 271989, 278889, 285857, 292893, 300000, 307179, 314434, 321767, 329179, 336675, 344256, 351925, 359687, 367544, 375500, 383558, 391723, 399999, 408392, 416904, 425543, 434314, 443223, 452277, 461483, 470849, 480384, 490098, 500000, 510102, 520416, 530958, 541742, 552786, 564110, 575735, 587689, 600000, 612701, 625834, 639444, 653589, 668337, 683772, 700000, 717157, 735424, 755051, 776393, 799999, 826794, 858578, 899999];
    }
}
