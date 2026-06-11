#!/bin/bash
set -e

# Import test lib
source dev-container-features-test-lib

# Tests
check "pi cli installed" command -v pi
check "pi version" pi --version

reportResults
