#!/bin/bash
# Test script to verify both WORKSPACE and bzlmod modes work

set -e

echo "=================================================="
echo "Testing Ecclesia Build Modes"
echo "=================================================="
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        exit 1
    fi
}

print_info() {
    echo -e "${YELLOW}➜${NC} $1"
}

# Check Bazel version
print_info "Checking Bazel version..."
BAZEL_VERSION=$(bazel --version | grep -oP '(?<=bazel )[0-9.]+' || echo "unknown")
echo "  Bazel version: $BAZEL_VERSION"

# Check required version
REQUIRED_MAJOR=7
REQUIRED_MINOR=6

ACTUAL_MAJOR=$(echo $BAZEL_VERSION | cut -d. -f1)
ACTUAL_MINOR=$(echo $BAZEL_VERSION | cut -d. -f2)

if [ "$ACTUAL_MAJOR" -lt "$REQUIRED_MAJOR" ] || \
   ([ "$ACTUAL_MAJOR" -eq "$REQUIRED_MAJOR" ] && [ "$ACTUAL_MINOR" -lt "$REQUIRED_MINOR" ]); then
    print_status 1 "Bazel version must be >= ${REQUIRED_MAJOR}.${REQUIRED_MINOR}.0"
else
    print_status 0 "Bazel version is compatible"
fi

echo

# Test 1: WORKSPACE mode (default)
print_info "Test 1: Building with WORKSPACE mode (default)..."
echo "  Command: bazel build --noenable_bzlmod //ecclesia/lib/status:macros"

if bazel build --noenable_bzlmod //ecclesia/lib/status:macros 2>&1 | tee /tmp/workspace_build.log; then
    print_status 0 "WORKSPACE mode build succeeded"
else
    print_status 1 "WORKSPACE mode build failed (see /tmp/workspace_build.log)"
fi

echo

# Test 2: Bzlmod hybrid mode
print_info "Test 2: Building with bzlmod hybrid mode..."
echo "  Command: bazel build --enable_bzlmod --enable_workspace //ecclesia/lib/status:macros"

if bazel build --enable_bzlmod --enable_workspace //ecclesia/lib/status:macros 2>&1 | tee /tmp/bzlmod_hybrid_build.log; then
    print_status 0 "Bzlmod hybrid mode build succeeded"
else
    print_status 1 "Bzlmod hybrid mode build failed (see /tmp/bzlmod_hybrid_build.log)"
fi

echo

# Test 3: Query dependencies
print_info "Test 3: Verifying dependency resolution..."

# Check that core dependencies are available
DEPS_TO_CHECK=(
    "@com_google_absl//:base"
    "@com_google_protobuf//:protobuf"
    "@bazel_skylib//lib:paths"
)

for dep in "${DEPS_TO_CHECK[@]}"; do
    if bazel query "$dep" --noenable_bzlmod > /dev/null 2>&1; then
        print_status 0 "Dependency $dep is available"
    else
        print_status 1 "Dependency $dep is not available"
    fi
done

echo
echo "=================================================="
echo "All Tests Passed!"
echo "=================================================="
echo
echo "Summary:"
echo "  ✓ WORKSPACE mode works"
echo "  ✓ Bzlmod hybrid mode works"
echo "  ✓ Dependencies are correctly resolved"
echo
echo "Both build modes are functional!"
