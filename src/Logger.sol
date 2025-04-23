// SPDX-License-Identifier: UNLICENSED
// solhint-disable no-console
pragma solidity >=0.8.22;

import { console2 } from "forge-std/src/console2.sol";
import { StdStyle } from "forge-std/src/StdStyle.sol";

/// @notice A collection of logging functions for the benchmark suites.
/// @dev The logs are not displayed during the execution process.
/// See https://github.com/foundry-rs/foundry/issues/5352
abstract contract Logger {
    /// @notice Logs a message in blue color
    /// @param message The message to log
    function logBlue(string memory message) internal pure {
        console2.log(StdStyle.blue(message));
    }

    /// @notice Logs a message in green color with a ✓ checkmark
    /// @param message The message to log
    function logGreen(string memory message) internal pure {
        console2.log(StdStyle.green(string.concat(unicode"✓ ", message)));
    }
}
