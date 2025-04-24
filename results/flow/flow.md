With USDC as the streaming token.

| Function              | Stream Solvency | Gas Usage |
| :-------------------- | :-------------- | :-------- |
| `adjustRatePerSecond` | N/A             | 44,186    |
| `create`              | N/A             | 124,326   |
| `deposit`             | N/A             | 37,540    |
| `pause`               | N/A             | 7822      |
| `refund`              | Solvent         | 25,221    |
| `refundMax`           | Solvent         | 26,144    |
| `restart`             | N/A             | 7164      |
| `void`                | Solvent         | 10,241    |
| `void`                | Insolvent       | 37,742    |
| `withdraw`            | Insolvent       | 77,618    |
| `withdraw`            | Solvent         | 40,985    |
| `withdrawMax`         | Solvent         | 54,760    |
