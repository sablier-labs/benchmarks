# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 5          | 943559    |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 5          | 902677    |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 5          | 4125583   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 5          | 3897412   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 5          | 4016881   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 5          | 3826507   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 10         | 1747847   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 10         | 1754312   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 10         | 8207097   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 10         | 7745816   |
