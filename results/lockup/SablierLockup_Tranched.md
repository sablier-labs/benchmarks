# Benchmarks for the Lockup Tranched model

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `burn`                                                     | 16103     |
| `cancel`                                                   | 62980     |
| `renounce`                                                 | 26377     |
| `createWithDurationsLT` (2 tranches)                       | 209990    |
| `createWithTimestampsLT` (2 tranches)                      | 192973    |
| `withdraw` (2 tranches) (After End Time) (by Recipient)    | 51273     |
| `withdraw` (2 tranches) (Before End Time) (by Recipient)   | 18679     |
| `withdraw` (2 tranches) (After End Time) (by Anyone)       | 19063     |
| `withdraw` (2 tranches) (Before End Time) (by Anyone)      | 18768     |
| `createWithDurationsLT` (10 tranches)                      | 410384    |
| `createWithTimestampsLT` (10 tranches)                     | 392990    |
| `withdraw` (10 tranches) (After End Time) (by Recipient)   | 18962     |
| `withdraw` (10 tranches) (Before End Time) (by Recipient)  | 25579     |
| `withdraw` (10 tranches) (After End Time) (by Anyone)      | 23599     |
| `withdraw` (10 tranches) (Before End Time) (by Anyone)     | 25668     |
| `createWithDurationsLT` (100 tranches)                     | 2804299   |
| `createWithTimestampsLT` (100 tranches)                    | 2644747   |
| `withdraw` (100 tranches) (After End Time) (by Recipient)  | 23494     |
| `withdraw` (100 tranches) (Before End Time) (by Recipient) | 103431    |
| `withdraw` (100 tranches) (After End Time) (by Anyone)     | 74795     |
| `withdraw` (100 tranches) (Before End Time) (by Anyone)    | 103520    |
