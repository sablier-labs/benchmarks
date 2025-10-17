With USDC as the streaming token.

| Function                 | Configuration                              | Gas Usage |
| :----------------------- | :----------------------------------------- | :-------- |
| `burn`                   | N/A                                        | 8455      |
| `cancel`                 | N/A                                        | 41,207    |
| `renounce`               | N/A                                        | 4434      |
| `createWithDurationsLL`  | no cliff                                   | 124,829   |
| `createWithDurationsLL`  | with cliff                                 | 164,893   |
| `createWithTimestampsLL` | no cliff                                   | 124,183   |
| `createWithTimestampsLL` | with cliff                                 | 164,019   |
| `withdraw`               | vesting ongoing && called by recipient     | 32,191    |
| `withdraw`               | vesting completed && called by recipient   | 32,217    |
| `withdraw`               | vesting ongoing && called by third-party   | 32,423    |
| `withdraw`               | vesting completed && called by third-party | 32,449    |
