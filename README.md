# Benchmarks

This repo contains [solidity code](/contracts) to generate gas benchmark table for Lockup, Flow and Airdrops smart
contracts.

The resulting benchmark table is located in [results](/results) folder.

## Commands

To generate the benchmark table for [Lockup contract](https://github.com/sablier-labs/lockup), run the following
command:

```bash
bun run benchmark:lockup
```

To generate the benchmark table for [Flow contract](https://github.com/sablier-labs/flow), run the following command:

```bash
bun run benchmark:flow
```

## License

This repo is licensed under GPL 3.0 or later.
