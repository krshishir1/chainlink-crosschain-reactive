// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import "@reactive/contracts/interfaces/IReactive.sol";
import "@reactive/contracts/abstract-base/AbstractPausableReactive.sol";

// cast keccak256 "AnswerUpdated(int256,uint256,uint256)"

struct PriceUpdate {
    address sourceFeed;
    uint80 roundId;
    int256 answer;
    uint256 updatedAt;
}

contract PriceFeedReactive is IReactive, AbstractPausableReactive {
    uint256 public constant ANSWER_UPDATED_TOPIC0 =
        0x0559884fd3a460db3073b7fc896cc77986f16e378210ded43186175bf646fc5f;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    uint256 private immutable i_originChainId;
    address private immutable i_originFeed;
    address private immutable i_feedProxyUpdater;
    uint256 public lastRoundId;

    // address private

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
        Subscription[] memory result = new Subscription[](1);
        result[0] = Subscription(
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

        if (
            log._contract == i_originFeed &&
            log.topic_0 == ANSWER_UPDATED_TOPIC0
        ) {
            int256 answer = int256(log.topic_1);
            uint80 roundId = uint80(log.topic_2);
            uint256 updatedAt = abi.decode(log.data, (uint256));

            if (lastRoundId <= roundId) {
                return;
            }

            lastRoundId = roundId;

            bytes memory payload = abi.encodeWithSignature(
                "callback(address,(address,uint80,int256,uint256))",
                address(0), // placeholder, overwritten by ReactVM id
                PriceUpdate({
                    sourceFeed: i_originFeed,
                    roundId: roundId,
                    answer: answer,
                    updatedAt: updatedAt
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
