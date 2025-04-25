With USDC as the streaming token.

| Lockup Model | Function                 | Batch Size | Segments/Tranches | Gas Usage  |
| :----------- | :----------------------- | :--------- | :---------------- | :--------- |
| Linear       | `createWithDurationsLL`  | 5          | N/A               | 964,419    |
| Linear       | `createWithTimestampsLL` | 5          | N/A               | 915,036    |
| Dynamic      | `createWithDurationsLD`  | 5          | 24                | 4,137,927  |
| Dynamic      | `createWithTimestampsLD` | 5          | 24                | 3,909,737  |
| Tranched     | `createWithDurationsLT`  | 5          | 24                | 4,029,210  |
| Tranched     | `createWithTimestampsLT` | 5          | 24                | 3,838,847  |
| Linear       | `createWithDurationsLL`  | 10         | N/A               | 1,769,052  |
| Linear       | `createWithTimestampsLL` | 10         | N/A               | 1,775,515  |
| Dynamic      | `createWithDurationsLD`  | 10         | 24                | 8,228,267  |
| Dynamic      | `createWithTimestampsLD` | 10         | 24                | 7,766,966  |
| Tranched     | `createWithDurationsLT`  | 10         | 24                | 8,002,520  |
| Tranched     | `createWithTimestampsLT` | 10         | 24                | 7,625,502  |
| Linear       | `createWithDurationsLL`  | 20         | N/A               | 3,485,878  |
| Linear       | `createWithTimestampsLL` | 20         | N/A               | 3,499,590  |
| Dynamic      | `createWithDurationsLD`  | 20         | 24                | 16,427,770 |
| Dynamic      | `createWithTimestampsLD` | 20         | 24                | 15,487,263 |
| Tranched     | `createWithDurationsLT`  | 20         | 24                | 15,948,064 |
| Tranched     | `createWithTimestampsLT` | 20         | 24                | 15,204,669 |
| Linear       | `createWithDurationsLL`  | 50         | N/A               | 8,647,895  |
| Linear       | `createWithTimestampsLL` | 50         | N/A               | 8,687,018  |
| Dynamic      | `createWithDurationsLD`  | 50         | 12                | 24,333,619 |
| Dynamic      | `createWithTimestampsLD` | 50         | 12                | 23,139,537 |
| Tranched     | `createWithDurationsLT`  | 50         | 12                | 23,718,623 |
| Tranched     | `createWithTimestampsLT` | 50         | 12                | 22,807,262 |
