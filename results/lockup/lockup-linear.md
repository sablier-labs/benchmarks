With USDC as the streaming token.

| Function                 | Configuration                              | Gas Usage |
| :----------------------- | :----------------------------------------- | :-------- |
| `burn`                   | N/A                                        | 8381      |
| `cancel`                 | N/A                                        | 41,247    |
| `renounce`               | N/A                                        | 4378      |
| `createWithDurationsLL`  | no cliff                                   | 122,317   |
| `createWithDurationsLL`  | with cliff                                 | 167,105   |
| `createWithTimestampsLL` | no cliff                                   | 122,865   |
| `createWithTimestampsLL` | with cliff                                 | 167,445   |
| `withdraw`               | vesting ongoing && called by recipient     | 20,020    |
| `withdraw`               | vesting completed && called by recipient   | 20,073    |
| `withdraw`               | vesting ongoing && called by third-party   | 20,252    |
| `withdraw`               | vesting completed && called by third-party | 20,305    |
