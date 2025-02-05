# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 5          | 939792    |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 5          | 901709    |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 5          | 4124570   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 5          | 3896405   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 5          | 4015898   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 5          | 3825510   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 10         | 1746848   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 10         | 1753309   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 10         | 8205903   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 10         | 7744712   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 10         | 7980340   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 10         | 7603295   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 20         | 3445879   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 20         | 3459560   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 20         | 16387293  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 20         | 15447160  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 20         | 15908163  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 20         | 15164644  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 30         | 5144252   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 30         | 5173585   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 30         | 24613029  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 30         | 23166679  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 30         | 23836858  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 30         | 22743296  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 50         | 8563337   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 50         | 8612914   |
