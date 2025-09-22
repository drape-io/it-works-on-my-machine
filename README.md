# It Works On My Machine 🤷‍♂️

> A monorepo of intentionally flaky tests for demonstrating testing tools and methodologies across Python, Go, and TypeScript.

[![Tests](https://img.shields.io/badge/tests-14%20flaky%20tests-red)](#test-suites)
[![Languages](https://img.shields.io/badge/languages-Python%20%7C%20Go%20%7C%20TypeScript-blue)](#test-suites)
[![License](https://img.shields.io/badge/license-Apache%202.0-green)](./LICENSE)

## Overview

This repository contains **14 intentionally flaky tests** across 3 languages, designed to help test:
- Testing frameworks and tools
- CI/CD retry mechanisms
- Flakiness detection systems
- Test result analysis tools

The flakiness is built into utility classes, making the tests themselves simple while demonstrating various failure patterns.

## Quick Start

### Prerequisites

- **Python 3.11+** with [uv](https://docs.astral.sh/uv/) package manager
- **Go 1.21+**
- **Node.js 20+** with npm
- **[just](https://github.com/casey/just)** command runner (optional but recommended)

### Installation

```bash
# Install just (command runner)
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# Install all dependencies
just install

# Or install manually:
cd python && uv sync
cd go && go mod tidy
cd typescript && npm install
```

## Running Tests

### Using Just (Recommended)

```bash
# Run all tests
just test-all

# Run tests by language
just test-python
just test-go
just test-ts

# Run with coverage
just test-python-coverage
just test-go-coverage
just test-ts-coverage

# Run for CI (with full reporting)
just test-ci

# Generate comprehensive reports
just generate-reports

# Run tests multiple times to see flakiness
just test-flaky python 5
just test-flaky go 3

# Run specific test file
just test-file python test_probability.py
just test-file go probability_test.go
just test-file ts probability.test.ts
```

### Manual Commands

#### Python Tests
```bash
cd python

# Basic test run
uv run pytest -v

# With coverage and reports
uv run pytest --cov --cov-report=html --cov-report=xml --junitxml=../reports/python/junit.xml

# Run specific test file
uv run pytest tests/test_probability.py -v
```

#### Go Tests
```bash
cd go

# Basic test run
go test -v ./tests/...

# With coverage
go test -v -cover -coverprofile=coverage.out ./tests/...
go tool cover -html=coverage.out -o coverage.html

# With gotestsum (if installed)
gotestsum --format testname --junitfile ../reports/go/junit.xml -- -cover ./tests/...
```

#### TypeScript Tests
```bash
cd typescript

# Basic test run
npm test

# With coverage
npm run test:coverage

# For CI
npm run test:ci
```

## Test Suites

### 🐍 Python Tests (4 tests)
- **Framework**: pytest with pytest-cov
- **File**: `python/tests/test_probability.py`
- **Utilities**: Probability functions in `python/src/it_works_on_my_machine/`

### 🐹 Go Tests (5 tests)
- **Framework**: Standard `testing` package
- **File**: `go/tests/probability_test.go`
- **Utilities**: Probability package in `go/pkg/probability/`

### 📘 TypeScript Tests (5 tests)
- **Framework**: Jest with coverage
- **File**: `typescript/tests/probability.test.ts`
- **Utilities**: Probability functions in `typescript/src/probability.ts`

## Flaky Test Categories

All languages implement these consistent probability-based patterns:

### 🟢 Reliable Baseline Test
- **Always passes** (100% success rate)
- Ensures CI pipeline health
- Simple assertion that always succeeds

### 🎲 Probability-Based Tests
- **High Success** (90% pass rate) - Occasional failures
- **Moderate Success** (80% pass rate) - Moderate flakiness
- **Low Success** (70% pass rate) - Noticeable flakiness
- **Dice Roll Simulation** (~83% pass rate) - Passes if roll ≥ 2

### 🔄 Automated Retry Demonstration
- Tests use crypto-secure randomness for realistic failure patterns
- CI configured with up to 10 retry attempts using `nick-fields/retry@v3`
- Demonstrates real-world flaky test behavior and retry strategies

## Utility Commands

```bash
# View test statistics
just test-stats

# Clean up artifacts
just clean

# Lint all code
just lint

# Fix linting issues
just lint-fix

# Build all projects
just build

# Generate comprehensive reports
just generate-reports

# Generate summary report only
just generate-summary

# Check dependencies
just deps

# Environment info
just env

# Security scans
just security

# Help
just help
```

## CI/CD Integration

### Test Reports
All languages generate JUnit XML and coverage reports:
- **Python**: `reports/python/junit.xml` + HTML coverage
- **Go**: `reports/go/junit.xml` + HTML coverage
- **TypeScript**: `reports/typescript/junit.xml` + lcov coverage

### GitHub Actions Example
```yaml
name: Flaky Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: just install
      - name: Run tests with retries
        uses: nick-fields/retry@v3
        with:
          timeout_minutes: 30
          max_attempts: 5
          command: just test-ci
```

## Understanding the Architecture

### Flakiness Design
- **Utility Classes** contain all randomness/flakiness logic
- **Test Methods** are simple calls with assertions
- **No Configuration** files needed - failure rates are in code

### Example Pattern
```python
# Python
def test_network_timeout():
    """Fails ~30% due to built-in timeout simulation"""
    result = NetworkSimulator.simulate_request(failure_rate=30, timeout_ms=1000)
    assert result['status'] == 200
```

```go
// Go
func TestNetworkTimeout(t *testing.T) {
    result, err := network.SimulateRequest(30, 1000, "https://api.example.com")
    if err != nil {
        t.Fatal(err)
    }
    assert.Equal(t, 200, result.Status)
}
```

```typescript
// TypeScript
test('network timeout - fails ~30% due to simulation', async () => {
  const result = await NetworkSimulator.simulateRequest(30, 1000);
  expect(result.status).toBe(200);
});
```

## Repository Structure

```
it-works-on-my-machine/
├── python/                    # Python flaky tests (4 tests)
│   ├── src/it_works_on_my_machine/  # Probability utility functions
│   ├── tests/                 # test_probability.py
│   └── pyproject.toml         # uv configuration
├── go/                        # Go flaky tests (5 tests)
│   ├── pkg/probability/       # Probability utility package
│   ├── tests/                 # probability_test.go
│   └── go.mod                 # Go module
├── typescript/                # TypeScript flaky tests (5 tests)
│   ├── src/                   # probability.ts utility functions
│   ├── tests/                 # probability.test.ts
│   └── package.json           # npm configuration
├── .github/workflows/         # Automated PR creation and testing
├── runs.txt                   # Automated run counter
├── justfile                   # Command runner recipes
└── README.md                  # This file
```

## Contributing

1. **Add New Test Categories**: Implement in all 3 languages consistently
2. **Maintain Patterns**: Keep utility classes containing flakiness, tests simple
3. **Update Documentation**: Keep README and `flakytests.md` in sync
4. **Test Your Changes**: Run `just test-all` before submitting

## Troubleshooting

### Common Issues

**Tests are too flaky/not flaky enough**
- Adjust failure rates in utility class methods
- Modify probability thresholds in test logic

**Dependencies not installing**
- Python: Ensure `uv` is installed and updated
- Go: Check Go version (1.21+ required)
- TypeScript: Verify Node.js version (20+ required)

**Tests hanging or timing out**
- Check for deadlock simulation tests
- Adjust timeout values in network simulation

### Getting Help

- Check `just env` for environment setup
- Review `just test-stats` for test counts
- Use `just help` for available commands

## License

Apache License 2.0 - see [LICENSE](./LICENSE) file for details.

---

> **"It works on my machine"** - Every developer, at some point 😄

*Built with ❤️ for the testing community*