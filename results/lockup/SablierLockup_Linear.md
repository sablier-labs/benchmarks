# Benchmarks for the Lockup Linear model

| Implementation                              | Gas Usage |
| ------------------------------------------- | --------- |
| `burn`                                      | 16103     |
| `cancel`                                    | 62980     |
| `renounce`                                  | 26377     |
| `createWithDurationsLL` (cliff not set)     | 132638    |
| `createWithDurationsLL` (cliff set)         | 168126    |
| `createWithTimestampsLL` (cliff not set)    | 121087    |
| `createWithTimestampsLL` (cliff set)        | 165668    |
| `withdraw` (After End Time) (by Recipient)  | 51548     |
| `withdraw` (Before End Time) (by Recipient) | 22902     |
| `withdraw` (After End Time) (by Anyone)     | 29451     |
| `withdraw` (Before End Time) (by Anyone)    | 34907     |
