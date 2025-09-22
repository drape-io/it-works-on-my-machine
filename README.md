# It Works On My Machine 🤷‍♂️

> A monorepo of intentionally flaky tests for demonstrating testing tools and methodologies across Python, Go, and TypeScript.

[![Tests](https://img.shields.io/badge/tests-14%20flaky%20tests-red)](#test-suites)
[![Languages](https://img.shields.io/badge/languages-Python%20%7C%20Go%20%7C%20TypeScript-blue)](#test-suites)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

## Overview

This repository contains **14 intentionally flaky tests** across 3 languages, designed to help test:
- Testing frameworks and tools
- CI/CD retry mechanisms
- Flakiness detection systems
- Test result analysis tools

The flakiness is built into utility classes using probability-based failures, making the tests simple while demonstrating realistic failure patterns.

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
def test_moderate_success_80_percent():
    """Passes 80% of the time - moderate flakiness."""
    assert random_success(0.80)
```

```go
// Go
func TestModerateSuccess80Percent(t *testing.T) {
    success, err := probability.RandomSuccess(0.80)
    if err != nil {
        t.Fatalf("Error in RandomSuccess: %v", err)
    }
    if !success {
        t.Fatalf("Random failure at 80%% success rate")
    }
}
```

```typescript
// TypeScript
test('moderate success 80% - moderate flakiness', () => {
  expect(randomSuccess(0.80)).toBe(true);
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

## Automated Flaky Test Demonstration

This repository includes automated PR creation that demonstrates flaky test behavior:

- **Scheduled PRs**: Created every 30 minutes via GitHub Actions
- **Automated Testing**: Each PR triggers flaky tests with retry logic
- **Auto-merge**: PRs merge when all tests eventually pass
- **Data Collection**: Tracks retry patterns and success rates over time

### Manual Testing
```bash
# Run tests multiple times to see flakiness
just test-flaky python 5
just test-flaky go 10
just test-flaky ts 3

# Run until success (with Ctrl+C support)
just run-until-success python
```

## Contributing

1. **Maintain Probability Patterns**: Keep tests simple with flakiness in utilities
2. **Test Across Languages**: Ensure consistent behavior in Python, Go, and TypeScript
3. **Verify Flakiness**: Run `just test-flaky <language> 10` to confirm realistic failure rates
4. **Update Documentation**: Keep README accurate with actual test counts

## Troubleshooting

### Common Issues

**Tests are too flaky/not flaky enough**
- Adjust probability rates in utility functions (e.g., change 0.80 to 0.85)
- Current rates: 90%, 80%, 70% for realistic CI behavior

**Dependencies not installing**
- Python: Ensure `uv` is installed and updated
- Go: Check Go version (1.21+ required)
- TypeScript: Verify Node.js version (20+ required)

**Tests not showing flakiness**
- Verify random number generation is working
- Run tests multiple times: `just test-flaky python 10`

### Getting Help

- Use `just help` for available commands
- Check GitHub Actions for automated PR examples
- Review test logs for retry patterns

## License

MIT License - see [LICENSE](./LICENSE) file for details.

---

> **"It works on my machine"** - Every developer, at some point 😄

*Built with ❤️ for the testing community*