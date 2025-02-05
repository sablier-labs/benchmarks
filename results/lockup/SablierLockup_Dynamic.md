# Benchmarks for the Lockup Dynamic model

| Implementation                                               | Gas Usage |
| ------------------------------------------------------------ | --------- |
| `burn`                                                       | 16103     |
| `cancel`                                                     | 66857     |
| `renounce`                                                   | 23794     |
| `createWithDurationsLD` (2 segments) (Broker fee set)        | 216952    |
| `createWithDurationsLD` (2 segments) (Broker fee not set)    | 200529    |
| `createWithTimestampsLD` (2 segments) (Broker fee set)       | 197820    |
| `createWithTimestampsLD` (2 segments) (Broker fee not set)   | 192695    |
| `withdraw` (2 segments) (After End Time) (by Recipient)      | 41161     |
| `withdraw` (2 segments) (Before End Time) (by Recipient)     | 30079     |
| `withdraw` (2 segments) (After End Time) (by Anyone)         | 19351     |
| `withdraw` (2 segments) (Before End Time) (by Anyone)        | 30168     |
| `createWithDurationsLD` (10 segments) (Broker fee set)       | 422367    |
| `createWithDurationsLD` (10 segments) (Broker fee not set)   | 417257    |
| `createWithTimestampsLD` (10 segments) (Broker fee set)      | 402293    |
| `createWithTimestampsLD` (10 segments) (Broker fee not set)  | 397194    |
| `withdraw` (10 segments) (After End Time) (by Recipient)     | 24343     |
| `withdraw` (10 segments) (Before End Time) (by Recipient)    | 37366     |
| `withdraw` (10 segments) (After End Time) (by Anyone)        | 24454     |
| `withdraw` (10 segments) (Before End Time) (by Anyone)       | 37455     |
| `createWithDurationsLD` (100 segments) (Broker fee set)      | 2898731   |
| `createWithDurationsLD` (100 segments) (Broker fee not set)  | 2894626   |
| `createWithTimestampsLD` (100 segments) (Broker fee set)     | 2706809   |
| `createWithTimestampsLD` (100 segments) (Broker fee not set) | 2702728   |
| `withdraw` (100 segments) (After End Time) (by Recipient)    | 82096     |
| `withdraw` (100 segments) (Before End Time) (by Recipient)   | 119779    |
| `withdraw` (100 segments) (After End Time) (by Anyone)       | 82185     |
| `withdraw` (100 segments) (Before End Time) (by Anyone)      | 119868    |
