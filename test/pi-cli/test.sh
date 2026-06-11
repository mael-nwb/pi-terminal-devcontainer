#!/bin/bash
set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "node version" node --version
check "npm version" npm --version
check "pi cli installed" command -v pi
check "pi version" pi --version

# Report results
reportResults
