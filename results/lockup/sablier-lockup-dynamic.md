# Benchmarks for the LockupDynamic model

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `createWithDurationsLD` (2 segments)                       | 232180    |
| `createWithDurationsLD` (2 segments)                       | 232180    |
| `createWithTimestampsLD` (2 segments)                      | 193636    |
| `createWithDurationsLD` (10 segments)                      | 418157    |
| `createWithDurationsLD` (10 segments)                      | 418157    |
| `createWithTimestampsLD` (10 segments)                     | 398052    |
| `createWithDurationsLD` (100 segments)                     | 2893859   |
| `createWithDurationsLD` (100 segments)                     | 2893859   |
| `createWithTimestampsLD` (100 segments)                    | 2700876   |
| `withdraw` (2 segments) (After End Time) (by Recipient)    | 41148     |
| `withdraw` (2 segments) (Before End Time) (by Recipient)   | 30079     |
| `withdraw` (2 segments) (After End Time) (by Others)       | 43237     |
| `withdraw` (2 segments) (Before End Time) (by Others)      | 30168     |
| `withdraw` (10 segments) (After End Time) (by Recipient)   | 24343     |
| `withdraw` (10 segments) (Before End Time) (by Recipient)  | 37366     |
| `withdraw` (10 segments) (After End Time) (by Others)      | 24474     |
| `withdraw` (10 segments) (Before End Time) (by Others)     | 37455     |
| `withdraw` (100 segments) (After End Time) (by Recipient)  | 82096     |
| `withdraw` (100 segments) (Before End Time) (by Recipient) | 119779    |
| `withdraw` (100 segments) (After End Time) (by Others)     | 82185     |
| `withdraw` (100 segments) (Before End Time) (by Others)    | 119868    |
| `renounce`                                                 | 25561     |
| `cancel`                                                   | 57951     |
| `burn`                                                     | 11197     |
