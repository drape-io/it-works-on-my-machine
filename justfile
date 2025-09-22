# Justfile for flaky tests monorepo
# Run with `just <command>` (install just: https://github.com/casey/just)

# Default recipe - show available commands
default:
    @just --list

# Install dependencies for all languages
install:
    @echo "📦 Installing dependencies for all languages..."
    just install-python
    just install-go
    just install-ts

# Install Python dependencies using uv
install-python:
    @echo "🐍 Installing Python dependencies with uv..."
    cd python && uv sync

# Install Go dependencies
install-go:
    @echo "🐹 Installing Go dependencies..."
    cd go && go mod tidy

# Install TypeScript dependencies
install-ts:
    @echo "📘 Installing TypeScript dependencies..."
    cd typescript && npm install

# Run all tests for all languages
test-all:
    @echo "🧪 Running all tests..."
    just test-python
    just test-go
    just test-ts

# Run Python tests
test-python:
    @echo "🐍 Running Python tests..."
    cd python && uv run pytest -v

# Run Python tests with coverage
test-python-coverage:
    @echo "🐍 Running Python tests with coverage..."
    cd python && uv run pytest --cov --cov-report=html --cov-report=xml --cov-report=term

# Run Go tests
test-go:
    @echo "🐹 Running Go tests..."
    cd go && go test -v -count=1 ./tests/...

# Run Go tests with coverage
test-go-coverage:
    @echo "🐹 Running Go tests with coverage..."
    cd go && go test -v -cover -coverprofile=coverage.out ./pkg/... ./tests/... && go tool cover -html=coverage.out -o coverage.html

# Run Go tests with gotestsum (if installed)
test-go-sum:
    @echo "🐹 Running Go tests with gotestsum..."
    cd go && gotestsum --format testname --junitfile ../reports/go/junit.xml -- -cover ./tests/...

# Run TypeScript tests
test-ts:
    @echo "📘 Running TypeScript tests..."
    cd typescript && npm test

# Run TypeScript tests with coverage
test-ts-coverage:
    @echo "📘 Running TypeScript tests with coverage..."
    cd typescript && npm run test:coverage

# Run TypeScript tests for CI
test-ts-ci:
    @echo "📘 Running TypeScript tests for CI..."
    cd typescript && npm run test:ci

# Clean all build artifacts and reports
clean:
    @echo "🧹 Cleaning up..."
    rm -rf reports/python/* reports/go/* reports/typescript/*
    rm -rf python/.pytest_cache python/htmlcov python/.coverage
    rm -rf go/coverage.out go/coverage.html
    rm -rf typescript/coverage typescript/node_modules/.cache
    find . -name "*.tmp" -delete
    find . -name "*_counter.json" -delete

# Create reports directories
setup-reports:
    @echo "📊 Setting up reports directories..."
    mkdir -p reports/python reports/go reports/typescript

# Run tests with full reporting (CI-style)
test-ci:
    @echo "🤖 Running tests with full CI reporting..."
    just setup-reports
    just test-python-coverage
    just test-go-coverage  
    just test-ts-ci
    @echo "✅ CI testing completed!"
    @echo ""
    @echo "📊 Coverage reports generated:"
    @echo "  Python:     reports/python/htmlcov/index.html"
    @echo "  Go:         reports/go/coverage.html" 
    @echo "  TypeScript: reports/typescript/coverage/lcov-report/index.html"

# Generate comprehensive reports for all languages (internal use)
_generate-reports:
    @echo "📊 Generating comprehensive test reports..."
    just setup-reports
    @echo "🐍 Generating Python reports..."
    cd python && uv run pytest \
        --cov=it_works_on_my_machine \
        --cov-report=html:../reports/python/htmlcov \
        --cov-report=xml:../reports/python/coverage.xml \
        --cov-report=term \
        --junitxml=../reports/python/junit.xml \
        --html=../reports/python/pytest_report.html \
        --self-contained-html
    @echo "🐹 Generating Go reports..."
    cd go && go test -v -cover -coverprofile=../reports/go/coverage.out ./pkg/... ./tests/... > ../reports/go/test_output.txt 2>&1
    cd go && go tool cover -html=../reports/go/coverage.out -o ../reports/go/coverage.html
    @if command -v gotestsum >/dev/null 2>&1; then \
        echo "Using gotestsum for enhanced Go reporting..."; \
        cd go && gotestsum --format testname --junitfile ../reports/go/junit.xml -- -cover -coverprofile=../reports/go/coverage_gotestsum.out ./tests/...; \
    else \
        echo "gotestsum not found, skipping enhanced reporting"; \
    fi
    @echo "📘 Generating TypeScript reports..."
    cd typescript && npm run test:ci
    @echo "✅ Report generation completed!"


# Run a specific test file (usage: just test-file python test_probability.py)
test-file language file:
    @echo "🎯 Running specific test file: {{file}} in {{language}}"
    @if [ "{{language}}" = "python" ]; then \
        cd python && uv run pytest tests/{{file}} -v; \
    elif [ "{{language}}" = "go" ]; then \
        cd go && go test -v ./tests/{{file}}; \
    elif [ "{{language}}" = "ts" ] || [ "{{language}}" = "typescript" ]; then \
        cd typescript && npm test -- {{file}}; \
    else \
        echo "❌ Unknown language: {{language}}. Use python, go, or ts"; \
        exit 1; \
    fi

# Run tests multiple times to observe flakiness (usage: just test-flaky python 5)
test-flaky language count="3":
    @echo "🎲 Running {{language}} tests {{count}} times to observe flakiness..."
    @for i in $(seq 1 {{count}}); do \
        echo "--- Run $i/{{count}} ---"; \
        just test-{{language}} || echo "❌ Run $i failed"; \
    done

# Run tests until success (usage: just test-until-success python)
test-until-success language:
    #!/usr/bin/env bash
    set -e
    trap 'echo ""; echo "🛑 Interrupted by user"; exit 130' INT
    echo "🎯 Running {{language}} tests until success (max 50 attempts)..."
    echo "💡 Press Ctrl+C to stop"
    attempt=1
    while [ $attempt -le 50 ]; do
        echo "--- Attempt $attempt ---"
        if just test-{{language}}; then
            echo "✅ Success! Tests passed on attempt $attempt"
            break
        else
            echo "❌ Attempt $attempt failed, trying again..."
            attempt=$((attempt + 1))
            if [ $attempt -gt 50 ]; then
                echo "⚠️  Stopped after 50 attempts - tests may be too flaky"
                echo "💡 Try: just clean && just test-until-success {{language}}"
                exit 1
            fi
        fi
    done

# Run tests until success with quick attempts (usage: just test-until-success-quick python)
test-until-success-quick language:
    #!/usr/bin/env bash
    set -e
    trap 'echo ""; echo "🛑 Interrupted by user"; exit 130' INT
    echo "🎯 Running {{language}} tests until success (quick mode - max 10 attempts)..."
    echo "💡 Press Ctrl+C to stop"
    attempt=1
    while [ $attempt -le 10 ]; do
        echo "--- Attempt $attempt ---"
        if just test-{{language}}; then
            echo "✅ Success! Tests passed on attempt $attempt"
            break
        else
            echo "❌ Attempt $attempt failed, trying again..."
            attempt=$((attempt + 1))
            if [ $attempt -gt 10 ]; then
                echo "⚠️  Stopped after 10 attempts - tests are demonstrably flaky!"
                echo "💡 This shows the flakiness problem - try 'just test-until-success {{language}}' for more attempts"
                exit 1
            fi
        fi
    done

# Show test statistics
test-stats:
    @echo "📈 Test Statistics:"
    @echo "Python tests: $(find python/tests -name 'test_*.py' | wc -l | tr -d ' ') files"
    @echo "Go tests: $(find go/tests -name '*_test.go' | wc -l | tr -d ' ') files"  
    @echo "TypeScript tests: $(find typescript/tests -name '*.test.ts' | wc -l | tr -d ' ') files"
    @echo ""
    @echo "Total test count (approximate):"
    @echo "Python: $(grep -r 'def test_' python/tests/ | wc -l | tr -d ' ') tests"
    @echo "Go: $(grep -r 'func Test' go/tests/ | wc -l | tr -d ' ') tests"
    @echo "TypeScript: $(grep -r "test('" typescript/tests/ | wc -l | tr -d ' ') tests"

# Lint all code
lint:
    @echo "🔍 Linting all code..."
    just lint-python
    just lint-go  
    just lint-ts

# Lint Python code
lint-python:
    @echo "🐍 Linting Python code..."
    cd python && uv run black --check src/ tests/
    cd python && uv run isort --check-only src/ tests/
    cd python && uv run flake8 src/ tests/

# Lint Go code  
lint-go:
    @echo "🐹 Linting Go code..."
    cd go && go fmt ./...
    cd go && go vet ./...

# Lint TypeScript code
lint-ts:
    @echo "📘 Linting TypeScript code..."
    cd typescript && npm run lint

# Fix linting issues
lint-fix:
    @echo "🔧 Fixing linting issues..."
    cd python && uv run black src/ tests/
    cd python && uv run isort src/ tests/
    cd go && go fmt ./...
    cd typescript && npm run lint:fix

# Build all projects
build:
    @echo "🔨 Building all projects..."
    cd python && uv run python -m build
    cd go && go build ./...
    cd typescript && npm run build

# Show dependency info
deps:
    @echo "📋 Dependency Information:"
    @echo ""
    @echo "Python (uv):"
    @cd python && uv tree || echo "Run 'just install-python' first"
    @echo ""
    @echo "Go:"
    @cd go && go list -m all || echo "Run 'just install-go' first"
    @echo ""
    @echo "TypeScript:"
    @cd typescript && npm list --depth=0 || echo "Run 'just install-ts' first"

# Run security checks
security:
    @echo "🔒 Running security checks..."
    @echo "Python security scan:"
    cd python && uv run pip-audit || echo "Install pip-audit: uv add --dev pip-audit"
    @echo "Go security scan:"
    cd go && go list -json -deps ./... | nancy sleuth || echo "Install nancy: go install github.com/sonatypeoss/nancy@latest"
    @echo "TypeScript security scan:"
    cd typescript && npm audit

# Show environment info
env:
    @echo "🌍 Environment Information:"
    @echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"
    @echo "Go: $(go version 2>/dev/null || echo 'Not installed')"
    @echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    @echo "npm: $(npm --version 2>/dev/null || echo 'Not installed')"
    @echo "uv: $(uv --version 2>/dev/null || echo 'Not installed - install from https://docs.astral.sh/uv/')"
    @echo "just: $(just --version 2>/dev/null || echo 'Not installed - install from https://github.com/casey/just')"

# Help command
help:
    @echo "🚀 Flaky Tests Monorepo"
    @echo ""
    @echo "Common commands:"
    @echo "  just install        - Install all dependencies"
    @echo "  just test-all       - Run all tests"
    @echo "  just test-python    - Run Python tests"
    @echo "  just test-go        - Run Go tests"  
    @echo "  just test-ts        - Run TypeScript tests"
    @echo "  just test-ci        - Run tests with full reporting"
    @echo "  just clean          - Clean up artifacts"
    @echo "  just lint           - Lint all code"
    @echo ""
    @echo "For more commands: just --list"
