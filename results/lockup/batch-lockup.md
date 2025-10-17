With USDC as the streaming token.

| Lockup Model | Function                 | Batch Size | Segments/Tranches | Gas Usage  |
| :----------- | :----------------------- | :--------- | :---------------- | :--------- |
| Linear       | `createWithDurationsLL`  | 5          | N/A               | 960,416    |
| Linear       | `createWithTimestampsLL` | 5          | N/A               | 898,070    |
| Dynamic      | `createWithDurationsLD`  | 5          | 24                | 4,140,686  |
| Dynamic      | `createWithTimestampsLD` | 5          | 24                | 3,906,075  |
| Tranched     | `createWithDurationsLT`  | 5          | 24                | 4,017,169  |
| Tranched     | `createWithTimestampsLT` | 5          | 24                | 3,829,431  |
| Linear       | `createWithDurationsLL`  | 10         | N/A               | 1,746,067  |
| Linear       | `createWithTimestampsLL` | 10         | N/A               | 1,740,109  |
| Dynamic      | `createWithDurationsLD`  | 10         | 24                | 8,231,557  |
| Dynamic      | `createWithTimestampsLD` | 10         | 24                | 7,757,389  |
| Tranched     | `createWithDurationsLT`  | 10         | 24                | 7,976,429  |
| Tranched     | `createWithTimestampsLT` | 10         | 24                | 7,604,351  |
| Linear       | `createWithDurationsLL`  | 20         | N/A               | 3,437,860  |
| Linear       | `createWithTimestampsLL` | 20         | N/A               | 3,426,512  |
| Dynamic      | `createWithDurationsLD`  | 20         | 24                | 16,429,026 |
| Dynamic      | `createWithTimestampsLD` | 20         | 24                | 15,463,495 |
| Tranched     | `createWithDurationsLT`  | 20         | 24                | 15,892,561 |
| Tranched     | `createWithTimestampsLT` | 20         | 24                | 15,157,514 |
| Linear       | `createWithDurationsLL`  | 50         | N/A               | 8,521,406  |
| Linear       | `createWithTimestampsLL` | 50         | N/A               | 8,496,648  |
| Dynamic      | `createWithDurationsLD`  | 50         | 12                | 24,264,467 |
| Dynamic      | `createWithTimestampsLD` | 50         | 12                | 23,014,426 |
| Tranched     | `createWithDurationsLT`  | 50         | 12                | 23,537,869 |
| Tranched     | `createWithTimestampsLT` | 50         | 12                | 22,642,055 |
