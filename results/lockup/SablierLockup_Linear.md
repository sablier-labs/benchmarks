# Benchmarks for the Lockup Linear model

| Implementation                                                | Gas Usage |
| ------------------------------------------------------------- | --------- |
| `burn`                                                        | 16103     |
| `cancel`                                                      | 66857     |
| `renounce`                                                    | 23794     |
| `createWithDurationsLL` (Broker fee set) (cliff not set)      | 138817    |
| `createWithDurationsLL` (Broker fee not set) (cliff not set)  | 122355    |
| `createWithDurationsLL` (Broker fee set) (cliff set)          | 169503    |
| `createWithDurationsLL` (Broker fee not set) (cliff set)      | 164342    |
| `createWithTimestampsLL` (Broker fee set) (cliff not set)     | 125268    |
| `createWithTimestampsLL` (Broker fee not set) (cliff not set) | 120106    |
| `createWithTimestampsLL` (Broker fee set) (cliff set)         | 169850    |
| `createWithTimestampsLL` (Broker fee not set) (cliff set)     | 164682    |
| `withdraw` (After End Time) (by Recipient)                    | 51262     |
| `withdraw` (Before End Time) (by Recipient)                   | 34818     |
| `withdraw` (After End Time) (by Anyone)                       | 28644     |
| `withdraw` (Before End Time) (by Anyone)                      | 23568     |
