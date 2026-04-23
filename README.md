# Web-HS

A simple Haskell web server using Scotty, PostgreSQL with connection pooling, and YAML configuration.

## Requirements

- [Cabal](https://www.haskell.org/cabal/)
- [GHC](https://www.haskell.org/ghc/)
- [PostgreSQL](https://www.postgresql.org/) development libraries (e.g., `libpq-dev` on Debian/Ubuntu).
- [Taskfile](https://taskfile.dev/) (optional)

***nb*** If the compiler baulks at libpq, try this:
```zsh
sudo apt-get update && sudo apt-get install -y libpq-dev zlib1g-dev
```

## Installation

```bash
task build
```

## Usage

1. Start the database.

```zsh
task -d database run
```

2. Run the server:

```bash
task run
```

3. Use the `route` command to test:

```bash
./route hello
# Initially empty.
./route get
# Accepts multiple names to put.
./route put herp derp
./route get
```
