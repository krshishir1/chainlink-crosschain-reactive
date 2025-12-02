// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import "@reactive/contracts/interfaces/IReactive.sol";
import "@reactive/contracts/abstract-base/AbstractPausableReactive.sol";

import {IPriceFeed} from "./interfaces/IPriceFeed.sol";

struct PriceUpdate {
    uint80 roundId;
    int256 answer;
    uint256 startedAt;
    uint256 updatedAt;
    uint80 answeredInRound;
}

contract PriceFeedReactive is IReactive, AbstractPausableReactive {
    event RoundStarted(uint80 indexed roundId, uint256 timestamp);

    // cast keccak256 "AnswerUpdated(int256,uint256,uint256)"
    uint256 public constant ANSWER_UPDATED_TOPIC0 =
        0x0559884fd3a460db3073b7fc896cc77986f16e378210ded43186175bf646fc5f;

    // cast keccak256 "NewRound(uint256,address,uint256)"
    uint256 public constant NEW_ROUND_TOPIC0 =
        0x0109fc6f55cf40689f02fbaad7af7fe7bbac8a3d2186600afc7d3e10cac60271;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    uint256 private immutable i_originChainId;
    address private immutable i_originFeed;
    address private immutable i_feedProxyUpdater;

    mapping(uint80 => uint256) private startedAtForRound;
    uint80 private startRoundId;

    constructor(
        uint256 _originChainId,
        address _originFeed,
        address _feedDestination
    ) payable {
        paused = false;
        owner = msg.sender;

        i_originChainId = _originChainId;
        i_originFeed = _originFeed;
        i_feedProxyUpdater = _feedDestination;

        if (!vm) {
            service.subscribe(
                _originChainId,
                _originFeed,
                NEW_ROUND_TOPIC0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );

            service.subscribe(
                _originChainId,
                _originFeed,
                ANSWER_UPDATED_TOPIC0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function getPausableSubscriptions()
        internal
        view
        override
        returns (Subscription[] memory)
    {
        Subscription[] memory result = new Subscription[](2);
        result[0] = Subscription(
            i_originChainId,
            i_originFeed,
            NEW_ROUND_TOPIC0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        result[1] = Subscription(
            i_originChainId,
            i_originFeed,
            ANSWER_UPDATED_TOPIC0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        return result;
    }

    // Methods specific to ReactVM instance of the contract
    function react(LogRecord calldata log) external vmOnly {
        // Note that we cannot directly check the `paused` variable, because the state of the contract
        // in reactive network is not shared with ReactVM state.

        if (log._contract == i_originFeed && log.topic_0 == NEW_ROUND_TOPIC0) {
            uint80 roundId = uint80(log.topic_1);
            uint256 startedAt = abi.decode(log.data, (uint256));

            startRoundId = roundId;
            emit RoundStarted(roundId, startedAt);
        }

        if (
            log._contract == i_originFeed &&
            log.topic_0 == ANSWER_UPDATED_TOPIC0
        ) {
            int256 emittedAnswer = int256(log.topic_1);
            uint80 emittedRoundId = uint80(log.topic_2);
            uint256 updatedAt = abi.decode(log.data, (uint256));

            if (emittedRoundId < startRoundId) {
                return;
            }

            bytes memory payload = abi.encodeWithSignature(
                "callback(address,(uint80,int256,uint256,uint256,uint80))",
                address(0), // placeholder, overwritten by ReactVM id
                PriceUpdate({
                    roundId: startRoundId,
                    answer: emittedAnswer,
                    startedAt: startedAtForRound[startRoundId],
                    updatedAt: updatedAt,
                    answeredInRound: emittedRoundId
                })
            );

            emit Callback(
                log.chain_id,
                i_feedProxyUpdater,
                CALLBACK_GAS_LIMIT,
                payload
            );
        }
    }
}
