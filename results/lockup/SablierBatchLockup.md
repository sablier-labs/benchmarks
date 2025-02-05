# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 5          | 943549    |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 5          | 902666    |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 5          | 4125527   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 5          | 3897362   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 5          | 4016855   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 5          | 3826467   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 10         | 1747805   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 10         | 1754266   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 10         | 8206860   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 10         | 7745669   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 10         | 7981297   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 10         | 7604252   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 20         | 3446836   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 20         | 3460517   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 20         | 16388250  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 20         | 15448117  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 20         | 15909120  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 20         | 15165601  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 30         | 5145209   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 30         | 5174542   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 30         | 24613986  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 30         | 23167636  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 30         | 23837815  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 30         | 22744253  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 50         | 8564294   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 50         | 8613871   |
| `createWithDurationsLD`  | Lockup Dynamic  | 12                | 50         | 24299499  |
| `createWithTimestampsLD` | Lockup Dynamic  | 12                | 50         | 23083307  |
| `createWithDurationsLT`  | Lockup Tranched | 12                | 50         | 23642773  |
| `createWithTimestampsLT` | Lockup Tranched | 12                | 50         | 22750586  |
