With USDC as the streaming token.

| Function                 | Segments | Configuration                              | Gas Usage |
| :----------------------- | :------- | :----------------------------------------- | :-------- |
| `burn`                   | 2        | N/A                                        | 8455      |
| `cancel`                 | 2        | N/A                                        | 52,775    |
| `renounce`               | 2        | N/A                                        | 4434      |
| `createWithDurationsLD`  | 2        | N/A                                        | 198,804   |
| `createWithTimestampsLD` | 2        | N/A                                        | 192,951   |
| `withdraw`               | 2        | vesting ongoing && called by recipient     | 43,762    |
| `withdraw`               | 2        | vesting completed && called by recipient   | 32,674    |
| `withdraw`               | 2        | vesting ongoing && called by third-party   | 43,994    |
| `withdraw`               | 2        | vesting completed && called by third-party | 32,906    |
| `createWithDurationsLD`  | 10       | N/A                                        | 419,140   |
| `createWithTimestampsLD` | 10       | N/A                                        | 398,038   |
| `withdraw`               | 10       | vesting ongoing && called by recipient     | 48,862    |
| `withdraw`               | 10       | vesting completed && called by recipient   | 34,862    |
| `withdraw`               | 10       | vesting ongoing && called by third-party   | 49,094    |
| `withdraw`               | 10       | vesting completed && called by third-party | 35,094    |
| `createWithDurationsLD`  | 100      | N/A                                        | 2,904,652 |
| `createWithTimestampsLD` | 100      | N/A                                        | 2,708,660 |
| `withdraw`               | 100      | vesting ongoing && called by recipient     | 106,392   |
| `withdraw`               | 100      | vesting completed && called by recipient   | 59,632    |
| `withdraw`               | 100      | vesting ongoing && called by third-party   | 106,624   |
| `withdraw`               | 100      | vesting completed && called by third-party | 59,864    |
