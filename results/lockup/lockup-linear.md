## Benchmarks for the LockupLinear model

| Function                 | Configuration                              | Gas Usage |
| :----------------------- | :----------------------------------------- | :-------- |
| `burn`                   | N/A                                        | 15,982    |
| `cancel`                 | N/A                                        | 64,736    |
| `createWithDurationsLL`  | no cliff                                   | 132,636   |
| `createWithDurationsLL`  | with cliff                                 | 168,124   |
| `createWithTimestampsLL` | no cliff                                   | 121,085   |
| `createWithTimestampsLL` | with cliff                                 | 165,661   |
| `renounce`               | N/A                                        | 21,673    |
| `withdraw`               | vesting ongoing && called by recipient     | 22,756    |
| `withdraw`               | vesting completed && called by recipient   | 29,202    |
| `withdraw`               | vesting ongoing && called by third-party   | 23,551    |
| `withdraw`               | vesting completed && called by third-party | 29,434    |
