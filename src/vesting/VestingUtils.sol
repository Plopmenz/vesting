// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library VestingUtils {
    // From Openzeppelin VestingWallet (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/finance/VestingWallet.sol)
    function linearVesting(uint64 start, uint64 duration, uint96 totalAllocation, uint64 timestamp)
        internal
        pure
        returns (uint96)
    {
        if (timestamp < start) {
            return 0;
        } else if (timestamp >= (start + duration)) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}
