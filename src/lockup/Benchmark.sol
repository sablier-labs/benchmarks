// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierBatchLockup } from "@sablier/lockup/src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";
import { Defaults } from "@sablier/lockup/tests/utils/Defaults.sol";
import { Users } from "@sablier/lockup/tests/utils/Types.sol";
import { Utils } from "@sablier/lockup/tests/utils/Utils.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

/// @notice Base contract with common logic needed to get gas benchmarks for Lockup streams.
abstract contract LockupBenchmark is StdCheats, Utils {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal immutable AMOUNT_PER_SEGMENT = 100e18;
    uint128 internal immutable AMOUNT_PER_TRANCHE = 100e18;

    /// @dev The directory where the benchmark files are stored.
    string internal benchmarkResults = "results/lockup/";

    /// @dev The path to the file where the benchmark results are stored.
    string internal benchmarkResultsFile;

    /// @dev A variable used to store the content to append to the results file.
    string internal contentToAppend;

    uint256[7] internal streamIds = [50, 51, 52, 53, 54, 55, 56];

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ISablierBatchLockup internal batchLockup;
    IERC20 internal dai;
    Defaults internal defaults;
    ISablierLockup internal lockup;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Fork Ethereum Mainnet at the latest block.
        vm.createSelectFork("mainnet");

        // Load deployed addresses from Ethereum mainnet.
        // See https://docs.sablier.com/guides/lockup/deployments
        batchLockup = ISablierBatchLockup(0x3F6E8a8Cffe377c4649aCeB01e6F20c60fAA356c);
        lockup = ISablierLockup(0x7C01AA3783577E15fD7e272443D44B92d5b21056);

        // Load DAI token.
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

        // Create some users.
        users.alice = payable(makeAddr("alice"));
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));

        deal({ token: address(dai), to: users.sender, give: type(uint128).max });
        resetPrank({ msgSender: users.sender });
        dai.approve(address(batchLockup), type(uint128).max);
        dai.approve(address(lockup), type(uint128).max);

        defaults = new Defaults();
        defaults.setToken(dai);
        defaults.setUsers(users);

        // Create the first streams in each Lockup contract to initialize all the variables.
        _createFewStreams();
    }

    /*//////////////////////////////////////////////////////////////////////////
                      GAS FUNCTIONS FOR SHARED IMPLEMENTATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasBurn() internal {
        // Set the caller to the Recipient for `burn` and change timestamp to the end time.
        resetPrank({ msgSender: users.recipient });

        lockup.withdrawMax(streamIds[0], users.recipient);

        uint256 initialGas = gasleft();
        lockup.burn(streamIds[0]);
        string memory gasUsed = vm.toString(initialGas - gasleft());

        contentToAppend = string.concat("| `burn` | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCancel() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time
        resetPrank({ msgSender: users.sender });

        uint256 initialGas = gasleft();
        lockup.cancel(streamIds[1]);
        string memory gasUsed = vm.toString(initialGas - gasleft());

        contentToAppend = string.concat("| `cancel` | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasRenounce() internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        uint256 initialGas = gasleft();
        lockup.renounce(streamIds[2]);
        string memory gasUsed = vm.toString(initialGas - gasleft());

        contentToAppend = string.concat("| `renounce` | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasWithdraw(uint256 streamId, address caller, address to, string memory extraInfo) internal {
        resetPrank({ msgSender: caller });

        uint128 withdrawAmount = lockup.withdrawableAmountOf(streamId);

        uint256 initialGas = gasleft();
        lockup.withdraw(streamId, to, withdrawAmount);
        string memory gasUsed = vm.toString(initialGas - gasleft());

        // Check if caller is recipient or not.
        bool isCallerRecipient = caller == users.recipient;

        string memory s = isCallerRecipient
            ? string.concat("| `withdraw` ", extraInfo, " (by Recipient) | ")
            : string.concat("| `withdraw` ", extraInfo, " (by Anyone) | ");
        contentToAppend = string.concat(s, gasUsed, " |");

        // Append the data to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasWithdraw_AfterEndTime(uint256 streamId, address caller, address to, string memory extraInfo) internal {
        extraInfo = string.concat(extraInfo, " (After End Time)");

        uint256 warpTime = lockup.getEndTime(streamId) + 1;
        vm.warp({ newTimestamp: warpTime });

        gasWithdraw(streamId, caller, to, extraInfo);
    }

    function gasWithdraw_BeforeEndTime(
        uint256 streamId,
        address caller,
        address to,
        string memory extraInfo
    )
        internal
    {
        extraInfo = string.concat(extraInfo, " (Before End Time)");

        uint256 warpTime = lockup.getEndTime(streamId) - 1;
        vm.warp({ newTimestamp: warpTime });

        gasWithdraw(streamId, caller, to, extraInfo);
    }

    function gasWithdraw_ByAnyone(uint256 streamId1, uint256 streamId2, string memory extraInfo) internal {
        gasWithdraw_AfterEndTime(streamId1, users.sender, users.recipient, extraInfo);
        gasWithdraw_BeforeEndTime(streamId2, users.sender, users.recipient, extraInfo);
    }

    function gasWithdraw_ByRecipient(uint256 streamId1, uint256 streamId2, string memory extraInfo) internal {
        gasWithdraw_AfterEndTime(streamId1, users.recipient, users.alice, extraInfo);
        gasWithdraw_BeforeEndTime(streamId2, users.recipient, users.alice, extraInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a line to the file at given path.
    function _appendToFile(string memory path, string memory line) internal {
        vm.writeLine({ path: path, data: line });
    }

    /// @dev Internal function to creates a few streams in each Lockup contract.
    function _createFewStreams() internal {
        for (uint128 i = 0; i < 100; ++i) {
            lockup.createWithTimestampsLD(defaults.createWithTimestamps(), defaults.segments());
            lockup.createWithTimestampsLL(
                defaults.createWithTimestamps(), defaults.unlockAmounts(), defaults.CLIFF_TIME()
            );
            lockup.createWithTimestampsLT(defaults.createWithTimestamps(), defaults.tranches());
        }
    }
}
