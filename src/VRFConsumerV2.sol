// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {ISeaportContract} from "./ISeaportInterface.sol";
import {
    Execution,
    Fulfillment,
    Order,
    ReceivedItem
} from "seaport-types/src/lib/ConsiderationStructs.sol";
import {
    AccumulatorDisarmed
} from "seaport-types/src/lib/ConsiderationConstants.sol";
import {Executor} from "seaport-core/lib/Executor.sol";
/**
 * @title The VRFConsumerV2 contract
 * @notice A contract that gets random values from Chainlink VRF V2
 */
contract VRFConsumerV2 is VRFConsumerBaseV2, Executor {
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;
    ISeaportContract immutable Seaport;

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
    uint32 immutable s_callbackGasLimit = 1000000;

    // The default is 3, but you can set this higher.
    uint16 immutable s_requestConfirmations = 3;


    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 public immutable s_numWords = 1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;


    uint256 immutable precision = 1000;
    uint256[] public numerators;
    uint256 immutable demonator = 10000;

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
        bytes32 keyHash,
        address conduitController
    ) VRFConsumerBaseV2(vrfCoordinator)
      Executor(conduitController) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_keyHash = keyHash;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        Seaport = ISeaportContract(0x1eb1858BAE239a80e13F02B67dec7c9243944AB4);

        initLookups();
    }

    /**
     * @notice Requests randomness
     * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
     */
    function requestRandomWords() external returns (uint256) {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            s_numWords
        );
        return s_requestId;
    }

    //     /**
    //  * @notice Requests randomness
    //  * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
    //  */
    // function transferPremium(        /**
    //      * @custom:name orders
    //      */
    //     Order[] calldata orders
    // ) external {
    //     ReceivedItem memory premium;
    //     premium.itemType = orders[0].parameters.consideration[0].itemType;
    //     premium.token = orders[0].parameters.consideration[0].token;
    //     premium.identifier = orders[0].parameters.consideration[0].identifierOrCriteria;
    //     premium.recipient = orders[0].parameters.consideration[0].recipient;
    //     premium.amount += orders[0].parameters.consideration[0].startAmount;
    //     bytes memory accumulator = new bytes(AccumulatorDisarmed);
    //     _transfer(premium, orders[1].parameters.offerer, orders[1].parameters.conduitKey, accumulator);
    //     _triggerIfArmed(accumulator);
    // }

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
        Seaport.execute(requestId, x, y);
    }

    // modifier onlyOwner() {
    //     require(msg.sender == s_owner);
    //     _;
    // }

    function betainv(uint256 x) internal returns (uint256, uint256) {

        // x已经调整到0-1000范围,直接查表
        uint256 mod_x = x % precision;

        // 添加取余运算限定精度
        return (numerators[mod_x], demonator); 
    }

    function initLookups() internal {
        numerators = [475, 603, 693, 766, 828, 882, 931, 976, 1017, 1056, 1092, 1126, 1159, 1190, 1220, 1248, 1275, 1302, 1327, 1352, 1376, 1399, 1422, 1444, 1466, 1487, 1507, 1528, 1547, 1566, 1585, 1604, 1622, 1640, 1658, 1675, 1692, 1709, 1725, 1741, 1757, 1773, 1789, 1804, 1819, 1834, 1849, 1863, 1878, 1892, 1906, 1920, 1934, 1947, 1961, 1974, 1987, 2001, 2013, 2026, 2039, 2052, 2064, 2076, 2089, 2101, 2113, 2125, 2137, 2148, 2160, 2172, 2183, 2195, 2206, 2217, 2228, 2239, 2250, 2261, 2272, 2283, 2294, 2304, 2315, 2325, 2336, 2346, 2356, 2367, 2377, 2387, 2397, 2407, 2417, 2427, 2437, 2446, 2456, 2466, 2475, 2485, 2495, 2504, 2514, 2523, 2532, 2542, 2551, 2560, 2569, 2578, 2587, 2596, 2605, 2614, 2623, 2632, 2641, 2650, 2659, 2667, 2676, 2685, 2693, 2702, 2710, 2719, 2727, 2736, 2744, 2753, 2761, 2769, 2778, 2786, 2794, 2802, 2811, 2819, 2827, 2835, 2843, 2851, 2859, 2867, 2875, 2883, 2891, 2899, 2907, 2914, 2922, 2930, 2938, 2945, 2953, 2961, 2968, 2976, 2984, 2991, 2999, 3006, 3014, 3021, 3029, 3036, 3044, 3051, 3059, 3066, 3073, 3081, 3088, 3095, 3103, 3110, 3117, 3124, 3132, 3139, 3146, 3153, 3160, 3167, 3175, 3182, 3189, 3196, 3203, 3210, 3217, 3224, 3231, 3238, 3245, 3252, 3259, 3265, 3272, 3279, 3286, 3293, 3300, 3307, 3313, 3320, 3327, 3334, 3340, 3347, 3354, 3361, 3367, 3374, 3381, 3387, 3394, 3400, 3407, 3414, 3420, 3427, 3433, 3440, 3447, 3453, 3460, 3466, 3473, 3479, 3486, 3492, 3498, 3505, 3511, 3518, 3524, 3530, 3537, 3543, 3550, 3556, 3562, 3569, 3575, 3581, 3588, 3594, 3600, 3606, 3613, 3619, 3625, 3631, 3638, 3644, 3650, 3656, 3662, 3669, 3675, 3681, 3687, 3693, 3699, 3706, 3712, 3718, 3724, 3730, 3736, 3742, 3748, 3754, 3760, 3766, 3772, 3778, 3785, 3791, 3797, 3803, 3809, 3815, 3821, 3827, 3832, 3838, 3844, 3850, 3856, 3862, 3868, 3874, 3880, 3886, 3892, 3898, 3904, 3909, 3915, 3921, 3927, 3933, 3939, 3945, 3950, 3956, 3962, 3968, 3974, 3980, 3985, 3991, 3997, 4003, 4009, 4014, 4020, 4026, 4032, 4037, 4043, 4049, 4055, 4060, 4066, 4072, 4077, 4083, 4089, 4095, 4100, 4106, 4112, 4117, 4123, 4129, 4134, 4140, 4146, 4151, 4157, 4163, 4168, 4174, 4180, 4185, 4191, 4196, 4202, 4208, 4213, 4219, 4225, 4230, 4236, 4241, 4247, 4252, 4258, 4264, 4269, 4275, 4280, 4286, 4291, 4297, 4303, 4308, 4314, 4319, 4325, 4330, 4336, 4341, 4347, 4352, 4358, 4363, 4369, 4374, 4380, 4385, 4391, 4396, 4402, 4407, 4413, 4418, 4424, 4429, 4435, 4440, 4446, 4451, 4457, 4462, 4467, 4473, 4478, 4484, 4489, 4495, 4500, 4506, 4511, 4517, 4522, 4527, 4533, 4538, 4544, 4549, 4554, 4560, 4565, 4571, 4576, 4582, 4587, 4592, 4598, 4603, 4609, 4614, 4619, 4625, 4630, 4636, 4641, 4646, 4652, 4657, 4662, 4668, 4673, 4679, 4684, 4689, 4695, 4700, 4705, 4711, 4716, 4722, 4727, 4732, 4738, 4743, 4748, 4754, 4759, 4764, 4770, 4775, 4781, 4786, 4791, 4797, 4802, 4807, 4813, 4818, 4823, 4829, 4834, 4839, 4845, 4850, 4855, 4861, 4866, 4871, 4877, 4882, 4887, 4893, 4898, 4903, 4909, 4914, 4919, 4925, 4930, 4935, 4941, 4946, 4951, 4957, 4962, 4967, 4973, 4978, 4983, 4989, 4994, 5000, 5005, 5010, 5016, 5021, 5026, 5032, 5037, 5042, 5048, 5053, 5058, 5064, 5069, 5074, 5080, 5085, 5090, 5096, 5101, 5106, 5112, 5117, 5122, 5128, 5133, 5138, 5144, 5149, 5154, 5160, 5165, 5170, 5176, 5181, 5186, 5192, 5197, 5202, 5208, 5213, 5218, 5224, 5229, 5235, 5240, 5245, 5251, 5256, 5261, 5267, 5272, 5277, 5283, 5288, 5294, 5299, 5304, 5310, 5315, 5320, 5326, 5331, 5337, 5342, 5347, 5353, 5358, 5363, 5369, 5374, 5380, 5385, 5390, 5396, 5401, 5407, 5412, 5417, 5423, 5428, 5434, 5439, 5445, 5450, 5455, 5461, 5466, 5472, 5477, 5482, 5488, 5493, 5499, 5504, 5510, 5515, 5521, 5526, 5532, 5537, 5542, 5548, 5553, 5559, 5564, 5570, 5575, 5581, 5586, 5592, 5597, 5603, 5608, 5614, 5619, 5625, 5630, 5636, 5641, 5647, 5652, 5658, 5663, 5669, 5674, 5680, 5685, 5691, 5696, 5702, 5708, 5713, 5719, 5724, 5730, 5735, 5741, 5747, 5752, 5758, 5763, 5769, 5774, 5780, 5786, 5791, 5797, 5803, 5808, 5814, 5819, 5825, 5831, 5836, 5842, 5848, 5853, 5859, 5865, 5870, 5876, 5882, 5887, 5893, 5899, 5904, 5910, 5916, 5922, 5927, 5933, 5939, 5944, 5950, 5956, 5962, 5967, 5973, 5979, 5985, 5990, 5996, 6002, 6008, 6014, 6019, 6025, 6031, 6037, 6043, 6049, 6054, 6060, 6066, 6072, 6078, 6084, 6090, 6095, 6101, 6107, 6113, 6119, 6125, 6131, 6137, 6143, 6149, 6155, 6161, 6167, 6172, 6178, 6184, 6190, 6196, 6202, 6208, 6214, 6221, 6227, 6233, 6239, 6245, 6251, 6257, 6263, 6269, 6275, 6281, 6287, 6293, 6300, 6306, 6312, 6318, 6324, 6330, 6337, 6343, 6349, 6355, 6361, 6368, 6374, 6380, 6386, 6393, 6399, 6405, 6411, 6418, 6424, 6430, 6437, 6443, 6449, 6456, 6462, 6469, 6475, 6481, 6488, 6494, 6501, 6507, 6513, 6520, 6526, 6533, 6539, 6546, 6552, 6559, 6566, 6572, 6579, 6585, 6592, 6599, 6605, 6612, 6618, 6625, 6632, 6638, 6645, 6652, 6659, 6665, 6672, 6679, 6686, 6692, 6699, 6706, 6713, 6720, 6727, 6734, 6740, 6747, 6754, 6761, 6768, 6775, 6782, 6789, 6796, 6803, 6810, 6817, 6824, 6832, 6839, 6846, 6853, 6860, 6867, 6875, 6882, 6889, 6896, 6904, 6911, 6918, 6926, 6933, 6940, 6948, 6955, 6963, 6970, 6978, 6985, 6993, 7000, 7008, 7015, 7023, 7031, 7038, 7046, 7054, 7061, 7069, 7077, 7085, 7092, 7100, 7108, 7116, 7124, 7132, 7140, 7148, 7156, 7164, 7172, 7180, 7188, 7197, 7205, 7213, 7221, 7230, 7238, 7246, 7255, 7263, 7272, 7280, 7289, 7297, 7306, 7314, 7323, 7332, 7340, 7349, 7358, 7367, 7376, 7385, 7394, 7403, 7412, 7421, 7430, 7439, 7448, 7457, 7467, 7476, 7485, 7495, 7504, 7514, 7524, 7533, 7543, 7553, 7562, 7572, 7582, 7592, 7602, 7612, 7622, 7632, 7643, 7653, 7663, 7674, 7684, 7695, 7705, 7716, 7727, 7738, 7749, 7760, 7771, 7782, 7793, 7804, 7816, 7827, 7839, 7851, 7862, 7874, 7886, 7898, 7910, 7923, 7935, 7947, 7960, 7973, 7986, 7998, 8012, 8025, 8038, 8052, 8065, 8079, 8093, 8107, 8121, 8136, 8150, 8165, 8180, 8195, 8210, 8226, 8242, 8258, 8274, 8290, 8307, 8324, 8341, 8359, 8377, 8395, 8414, 8433, 8452, 8471, 8492, 8512, 8533, 8555, 8577, 8600, 8623, 8647, 8672, 8697, 8724, 8751, 8779, 8809, 8840, 8873, 8907, 8943, 8982, 9023, 9068, 9117, 9171, 9233, 9306, 9396, 9524, 10000];
    }
}
