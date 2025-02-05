# Benchmarks for the Lockup Tranched model

| Implementation                                               | Gas Usage |
| ------------------------------------------------------------ | --------- |
| `burn`                                                       | 16103     |
| `cancel`                                                     | 66857     |
| `renounce`                                                   | 23794     |
| `createWithDurationsLT` (2 tranches) (Broker fee set)        | 216162    |
| `createWithDurationsLT` (2 tranches) (Broker fee not set)    | 199736    |
| `createWithTimestampsLT` (2 tranches) (Broker fee set)       | 197156    |
| `createWithTimestampsLT` (2 tranches) (Broker fee not set)   | 192032    |
| `withdraw` (2 tranches) (After End Time) (by Recipient)      | 40875     |
| `withdraw` (2 tranches) (Before End Time) (by Recipient)     | 18679     |
| `withdraw` (2 tranches) (After End Time) (by Anyone)         | 19065     |
| `withdraw` (2 tranches) (Before End Time) (by Anyone)        | 18768     |
| `createWithDurationsLT` (10 tranches) (Broker fee set)       | 414579    |
| `createWithDurationsLT` (10 tranches) (Broker fee not set)   | 409462    |
| `createWithTimestampsLT` (10 tranches) (Broker fee set)      | 397207    |
| `createWithTimestampsLT` (10 tranches) (Broker fee not set)  | 392100    |
| `withdraw` (10 tranches) (After End Time) (by Recipient)     | 23494     |
| `withdraw` (10 tranches) (Before End Time) (by Recipient)    | 25579     |
| `withdraw` (10 tranches) (After End Time) (by Anyone)        | 23603     |
| `withdraw` (10 tranches) (Before End Time) (by Anyone)       | 25668     |
| `createWithDurationsLT` (100 tranches) (Broker fee set)      | 2808820   |
| `createWithDurationsLT` (100 tranches) (Broker fee not set)  | 2804221   |
| `createWithTimestampsLT` (100 tranches) (Broker fee set)     | 2649827   |
| `createWithTimestampsLT` (100 tranches) (Broker fee not set) | 2645245   |
| `withdraw` (100 tranches) (After End Time) (by Recipient)    | 74706     |
| `withdraw` (100 tranches) (Before End Time) (by Recipient)   | 103431    |
| `withdraw` (100 tranches) (After End Time) (by Anyone)       | 74795     |
| `withdraw` (100 tranches) (Before End Time) (by Anyone)      | 103520    |
