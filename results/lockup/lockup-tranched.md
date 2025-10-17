With USDC as the streaming token.

| Function                 | Tranches | Configuration                              | Gas Usage |
| :----------------------- | :------- | :----------------------------------------- | :-------- |
| `burn`                   | 2        | N/A                                        | 8455      |
| `cancel`                 | 2        | N/A                                        | 41,415    |
| `renounce`               | 2        | N/A                                        | 4434      |
| `createWithDurationsLT`  | 2        | N/A                                        | 196,380   |
| `createWithTimestampsLT` | 2        | N/A                                        | 191,943   |
| `withdraw`               | 2        | vesting ongoing && called by recipient     | 32,399    |
| `withdraw`               | 2        | vesting completed && called by recipient   | 32,751    |
| `withdraw`               | 2        | vesting ongoing && called by third-party   | 32,631    |
| `withdraw`               | 2        | vesting completed && called by third-party | 32,983    |
| `createWithDurationsLT`  | 10       | N/A                                        | 409,246   |
| `createWithTimestampsLT` | 10       | N/A                                        | 392,330   |
| `withdraw`               | 10       | vesting ongoing && called by recipient     | 37,377    |
| `withdraw`               | 10       | vesting completed && called by recipient   | 34,577    |
| `withdraw`               | 10       | vesting ongoing && called by third-party   | 37,609    |
| `withdraw`               | 10       | vesting completed && called by third-party | 34,809    |
| `createWithDurationsLT`  | 100      | N/A                                        | 2,807,339 |
| `createWithTimestampsLT` | 100      | N/A                                        | 2,648,369 |
| `withdraw`               | 100      | vesting ongoing && called by recipient     | 93,451    |
| `withdraw`               | 100      | vesting completed && called by recipient   | 55,191    |
| `withdraw`               | 100      | vesting ongoing && called by third-party   | 93,683    |
| `withdraw`               | 100      | vesting completed && called by third-party | 55,423    |
