// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PriceUpdateLib {
    struct PriceUpdate {
        address sourceFeed;
        uint80 roundId;
        int256 answer;
        uint256 updatedAt;
    }

    // Example helper function
    function isStale(
        PriceUpdate memory self,
        uint256 maxAge
    ) internal view returns (bool) {
        return block.timestamp - self.updatedAt > maxAge;
    }

    function isValid(PriceUpdate memory self) internal pure returns (bool) {
        return self.answer > 0;
    }
}
