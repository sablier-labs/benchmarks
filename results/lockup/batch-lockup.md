## Benchmarks for BatchLockup

| Lockup Model | Function                 | Batch Size | Segments/Tranches | Gas Usage  |
| :----------- | :----------------------- | :--------- | :---------------- | :--------- |
| Linear       | `createWithDurationsLL`  | 5          | N/A               | 943,556    |
| Linear       | `createWithTimestampsLL` | 5          | N/A               | 902,673    |
| Dynamic      | `createWithDurationsLD`  | 5          | 24                | 4,125,564  |
| Dynamic      | `createWithTimestampsLD` | 5          | 24                | 3,897,374  |
| Tranched     | `createWithDurationsLT`  | 5          | 24                | 4,016,847  |
| Tranched     | `createWithTimestampsLT` | 5          | 24                | 3,826,484  |
| Linear       | `createWithDurationsLL`  | 10         | N/A               | 1,747,819  |
| Linear       | `createWithTimestampsLL` | 10         | N/A               | 1,754,282  |
| Dynamic      | `createWithDurationsLD`  | 10         | 24                | 8,207,034  |
| Dynamic      | `createWithTimestampsLD` | 10         | 24                | 7,745,733  |
| Tranched     | `createWithDurationsLT`  | 10         | 24                | 7,981,287  |
| Tranched     | `createWithTimestampsLT` | 10         | 24                | 7,604,269  |
| Linear       | `createWithDurationsLL`  | 20         | N/A               | 3,446,905  |
| Linear       | `createWithTimestampsLL` | 20         | N/A               | 3,460,617  |
| Dynamic      | `createWithDurationsLD`  | 20         | 24                | 16,388,797 |
| Dynamic      | `createWithTimestampsLD` | 20         | 24                | 15,448,290 |
| Tranched     | `createWithDurationsLT`  | 20         | 24                | 15,909,091 |
| Tranched     | `createWithTimestampsLT` | 20         | 24                | 15,165,696 |
| Linear       | `createWithDurationsLL`  | 50         | N/A               | 8,555,702  |
| Linear       | `createWithTimestampsLL` | 50         | N/A               | 8,594,825  |
| Dynamic      | `createWithDurationsLD`  | 50         | 12                | 24,241,426 |
| Dynamic      | `createWithTimestampsLD` | 50         | 12                | 23,047,344 |
| Tranched     | `createWithDurationsLT`  | 50         | 12                | 23,626,430 |
| Tranched     | `createWithTimestampsLT` | 50         | 12                | 22,715,069 |
