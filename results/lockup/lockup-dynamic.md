| Function                 | Segments | Configuration                              | Gas Usage |
| :----------------------- | :------- | :----------------------------------------- | :-------- |
| `burn`                   | 2        | N/A                                        | 15,982    |
| `cancel`                 | 2        | N/A                                        | 64,736    |
| `renounce`               | 2        | N/A                                        | 21,673    |
| `createWithDurationsLD`  | 2        | N/A                                        | 210,784   |
| `createWithTimestampsLD` | 2        | N/A                                        | 196,445   |
| `withdraw`               | 2        | vesting ongoing && called by recipient     | 19,088    |
| `withdraw`               | 2        | vesting completed && called by recipient   | 19,088    |
| `withdraw`               | 2        | vesting ongoing && called by third-party   | 19,320    |
| `withdraw`               | 2        | vesting completed && called by third-party | 19,320    |
| `createWithDurationsLD`  | 10       | N/A                                        | 418,196   |
| `createWithTimestampsLD` | 10       | N/A                                        | 398,091   |
| `withdraw`               | 10       | vesting ongoing && called by recipient     | 35,562    |
| `withdraw`               | 10       | vesting completed && called by recipient   | 36,346    |
| `withdraw`               | 10       | vesting ongoing && called by third-party   | 35,794    |
| `withdraw`               | 10       | vesting completed && called by third-party | 36,578    |
| `createWithDurationsLD`  | 100      | N/A                                        | 2,894,408 |
| `createWithTimestampsLD` | 100      | N/A                                        | 2,701,418 |
| `withdraw`               | 100      | vesting ongoing && called by recipient     | 93,315    |
| `withdraw`               | 100      | vesting completed && called by recipient   | 94,099    |
| `withdraw`               | 100      | vesting ongoing && called by third-party   | 93,547    |
| `withdraw`               | 100      | vesting completed && called by third-party | 94,331    |
