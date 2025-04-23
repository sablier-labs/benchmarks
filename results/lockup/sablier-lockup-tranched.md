# Benchmarks for the LockupTranched model

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `createWithDurationsLT` (2 tranches)                       | 231388    |
| `createWithTimestampsLT` (2 tranches)                      | 192974    |
| `createWithDurationsLT` (10 tranches)                      | 410377    |
| `createWithTimestampsLT` (10 tranches)                     | 392983    |
| `createWithDurationsLT` (100 tranches)                     | 2804209   |
| `createWithTimestampsLT` (100 tranches)                    | 2644644   |
| `withdraw` (2 tranches) (After End Time) (by Recipient)    | 40862     |
| `withdraw` (2 tranches) (Before End Time) (by Recipient)   | 18679     |
| `withdraw` (2 tranches) (After End Time) (by Others)       | 42951     |
| `withdraw` (2 tranches) (Before End Time) (by Others)      | 18768     |
| `withdraw` (10 tranches) (After End Time) (by Recipient)   | 23494     |
| `withdraw` (10 tranches) (Before End Time) (by Recipient)  | 25579     |
| `withdraw` (10 tranches) (After End Time) (by Others)      | 23619     |
| `withdraw` (10 tranches) (Before End Time) (by Others)     | 25668     |
| `withdraw` (100 tranches) (After End Time) (by Recipient)  | 74706     |
| `withdraw` (100 tranches) (Before End Time) (by Recipient) | 103431    |
| `withdraw` (100 tranches) (After End Time) (by Others)     | 74795     |
| `withdraw` (100 tranches) (Before End Time) (by Others)    | 103520    |
| `renounce`                                                 | 25561     |
| `cancel`                                                   | 57951     |
| `burn`                                                     | 11197     |
