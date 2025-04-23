# Benchmarks

This repo contains [Solidity code](/contracts) for generating gas benchmark table for Sablier Lockup, Sablier Flow, and
Sablier Airdrops smart contracts.

The resulting benchmark tables are located in the [results](/results) folder.

## Commands

To generate the benchmark table for [Sablier Lockup](https://github.com/sablier-labs/lockup), run the following command:

```bash
bun run benchmark:lockup
```

To generate the benchmark table for [Sablier Flow](https://github.com/sablier-labs/flow), run the following command:

```bash
bun run benchmark:flow
```

## License

This repo is licensed under GPL 3.0 or later.
