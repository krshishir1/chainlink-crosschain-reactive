// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IPriceFeed.sol";

contract PriceFeedConsumer is IPriceFeed {
    AggregatorV3Interface private immutable i_priceFeed;

    constructor(address _feed) {
        i_priceFeed = AggregatorV3Interface(_feed); // => deployed in sepolia
    }

    function getLatestPrice() external view returns (int256) {
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        return price;
    }

    function getLatestPriceData()
        external
        view
        returns (PriceData memory data)
    {
        (
            data.roundId,
            data.answer,
            data.startedAt,
            data.updatedAt,
            data.answeredInRound
        ) = i_priceFeed.latestRoundData();
    }
}
