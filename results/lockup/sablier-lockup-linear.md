# Benchmarks for the LockupLinear model

| Implementation                              | Gas Usage |
| ------------------------------------------- | --------- |
| `createWithDurationsLL` (no cliff)          | 154037    |
| `createWithDurationsLL` (with cliff)        | 165322    |
| `createWithTimestampsLL` (no cliff)         | 121086    |
| `createWithTimestampsLL` (with cliff)       | 165667    |
| `withdraw` (After End Time) (by Recipient)  | 51561     |
| `withdraw` (Before End Time) (by Recipient) | 34818     |
| `withdraw` (After End Time) (by Others)     | 52544     |
| `withdraw` (Before End Time) (by Others)    | 22991     |
| `renounce`                                  | 24271     |
| `cancel`                                    | 56651     |
| `burn`                                      | 11197     |
