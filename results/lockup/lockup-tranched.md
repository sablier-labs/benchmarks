With USDC as the streaming token.

| Function                 | Tranches | Configuration                              | Gas Usage |
| :----------------------- | :------- | :----------------------------------------- | :-------- |
| `burn`                   | 2        | N/A                                        | 8381      |
| `cancel`                 | 2        | N/A                                        | 41,824    |
| `renounce`               | 2        | N/A                                        | 4378      |
| `createWithDurationsLT`  | 2        | N/A                                        | 199,668   |
| `createWithTimestampsLT` | 2        | N/A                                        | 194,757   |
| `withdraw`               | 2        | vesting ongoing && called by recipient     | 20,597    |
| `withdraw`               | 2        | vesting completed && called by recipient   | 20,880    |
| `withdraw`               | 2        | vesting ongoing && called by third-party   | 20,829    |
| `withdraw`               | 2        | vesting completed && called by third-party | 21,112    |
| `createWithDurationsLT`  | 10       | N/A                                        | 412,191   |
| `createWithTimestampsLT` | 10       | N/A                                        | 394,798   |
| `withdraw`               | 10       | vesting ongoing && called by recipient     | 27,497    |
| `withdraw`               | 10       | vesting completed && called by recipient   | 25,412    |
| `withdraw`               | 10       | vesting ongoing && called by third-party   | 27,729    |
| `withdraw`               | 10       | vesting completed && called by third-party | 25,644    |
| `createWithDurationsLT`  | 100      | N/A                                        | 2,806,419 |
| `createWithTimestampsLT` | 100      | N/A                                        | 2,646,865 |
| `withdraw`               | 100      | vesting ongoing && called by recipient     | 105,349   |
| `withdraw`               | 100      | vesting completed && called by recipient   | 76,624    |
| `withdraw`               | 100      | vesting ongoing && called by third-party   | 105,581   |
| `withdraw`               | 100      | vesting completed && called by third-party | 76,856    |
