# Benchmarks for the Lockup Dynamic model

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `burn`                                                     | 16103     |
| `cancel`                                                   | 62980     |
| `renounce`                                                 | 26377     |
| `createWithDurationsLD` (2 segments)                       | 210778    |
| `createWithDurationsLD` (2 segments)                       | 210778    |
| `createWithTimestampsLD` (2 segments)                      | 193635    |
| `withdraw` (2 segments) (After End Time) (by Recipient)    | 51274     |
| `withdraw` (2 segments) (Before End Time) (by Recipient)   | 30079     |
| `withdraw` (2 segments) (After End Time) (by Anyone)       | 19349     |
| `withdraw` (2 segments) (Before End Time) (by Anyone)      | 30168     |
| `createWithDurationsLD` (10 segments)                      | 418171    |
| `createWithDurationsLD` (10 segments)                      | 418171    |
| `createWithTimestampsLD` (10 segments)                     | 398062    |
| `withdraw` (10 segments) (After End Time) (by Recipient)   | 19248     |
| `withdraw` (10 segments) (Before End Time) (by Recipient)  | 37366     |
| `withdraw` (10 segments) (After End Time) (by Anyone)      | 24449     |
| `withdraw` (10 segments) (Before End Time) (by Anyone)     | 37455     |
| `createWithDurationsLD` (100 segments)                     | 2894004   |
| `createWithDurationsLD` (100 segments)                     | 2894004   |
| `createWithTimestampsLD` (100 segments)                    | 2701027   |
| `withdraw` (100 segments) (After End Time) (by Recipient)  | 24343     |
| `withdraw` (100 segments) (Before End Time) (by Recipient) | 119779    |
| `withdraw` (100 segments) (After End Time) (by Anyone)     | 82185     |
| `withdraw` (100 segments) (Before End Time) (by Anyone)    | 119868    |
