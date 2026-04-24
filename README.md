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

## Usage

1. Start the database.

```bash
task db:run
```

2. Run the ***server***:

```bash
task server
```

3. Run the ***client*** app to connect to the HTTP API (adding two widgets):

```bash
task client -- herp derp
```

4. Run the ***demo*** app to connect to the database directly (adding three widgets).

```bash
task demo -- huey dewey louie
```

5. Kill the database with

```bash
task db:stop
```