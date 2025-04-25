With USDC as the streaming token.

| Function                 | Segments | Configuration                              | Gas Usage |
| :----------------------- | :------- | :----------------------------------------- | :-------- |
| `burn`                   | 2        | N/A                                        | 8381      |
| `cancel`                 | 2        | N/A                                        | 53,217    |
| `renounce`               | 2        | N/A                                        | 4378      |
| `createWithDurationsLD`  | 2        | N/A                                        | 200,463   |
| `createWithTimestampsLD` | 2        | N/A                                        | 195,419   |
| `withdraw`               | 2        | vesting ongoing && called by recipient     | 31,997    |
| `withdraw`               | 2        | vesting completed && called by recipient   | 21,166    |
| `withdraw`               | 2        | vesting ongoing && called by third-party   | 32,229    |
| `withdraw`               | 2        | vesting completed && called by third-party | 21,398    |
| `createWithDurationsLD`  | 10       | N/A                                        | 419,984   |
| `createWithTimestampsLD` | 10       | N/A                                        | 399,880   |
| `withdraw`               | 10       | vesting ongoing && called by recipient     | 39,284    |
| `withdraw`               | 10       | vesting completed && called by recipient   | 26,261    |
| `withdraw`               | 10       | vesting ongoing && called by third-party   | 39,516    |
| `withdraw`               | 10       | vesting completed && called by third-party | 26,493    |
| `createWithDurationsLD`  | 100      | N/A                                        | 2,896,308 |
| `createWithTimestampsLD` | 100      | N/A                                        | 2,703,319 |
| `withdraw`               | 100      | vesting ongoing && called by recipient     | 121,697   |
| `withdraw`               | 100      | vesting completed && called by recipient   | 84,014    |
| `withdraw`               | 100      | vesting ongoing && called by third-party   | 121,929   |
| `withdraw`               | 100      | vesting completed && called by third-party | 84,246    |
