
ifndef GOLANGCI_LINT_MK_INCLUDED

TOOLS_DIR := $(CURDIR)/.tools
GOLANGCI_LINT := $(TOOLS_DIR)/golangci-lint
GOLANGCI_LINT_VERSION ?= v1.60.1
GITLEAKS := $(TOOLS_DIR)/gitleaks
GITLEAKS_VERSION ?= v8.21.2

export GOLANGCI_LINT
export GITLEAKS

$(GOLANGCI_LINT):
	@echo "==> Installing golangci-lint into $(TOOLS_DIR)..."
	@mkdir -p $(TOOLS_DIR)
	@curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TOOLS_DIR) $(GOLANGCI_LINT_VERSION)

$(GITLEAKS):
	@echo "==> Installing gitleaks into $(TOOLS_DIR)..."
	@mkdir -p $(TOOLS_DIR)
	@curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/$(GITLEAKS_VERSION)/gitleaks_$(GITLEAKS_VERSION:v%=%)_linux_x64.tar.gz | tar -xzC $(TOOLS_DIR) gitleaks

.PHONY: lint-tools
lint-tools: $(GOLANGCI_LINT)

.PHONY: secret-tools
secret-tools: $(GITLEAKS)

.PHONY: lint
lint: lint-tools ## Run static analysis via golangci-lint
	@echo "==> Checking source code against linters..."
	$(GOLANGCI_LINT) run -v ./...

.PHONY: secrets
secrets: secret-tools ## Check for secrets using gitleaks
	@echo "==> Checking for secrets using gitleaks..."
	$(GITLEAKS) detect --config .gitleaks.toml --verbose --no-git

.PHONY: secrets-baseline
secrets-baseline: secret-tools ## Create a secrets baseline (scan entire git history)
	@echo "==> Creating secrets baseline..."
	$(GITLEAKS) detect --config .gitleaks.toml --verbose --report-format json --report-path .secrets.baseline.json || true

gofmt: ## Format Go source code in 'internal/provider' using gofmt.
	@echo "==> Format code using gofmt..."
	gofmt -s -w internal/provider

GOLANGCI_LINT_MK_INCLUDED := 1
endif
