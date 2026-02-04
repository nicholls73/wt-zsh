#!/usr/bin/env zsh
# Test suite for wt

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Get script directory
SCRIPT_DIR="${0:A:h}"
WT_SCRIPT="${SCRIPT_DIR}/../wt"

# Test helper functions
pass() {
    echo "${GREEN}✓${NC} $1"
    ((PASSED++)) || true
}

fail() {
    echo "${RED}✗${NC} $1"
    ((FAILED++)) || true
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"

    if [[ "$output" == *"$expected"* ]]; then
        pass "$test_name"
    else
        fail "$test_name (expected '$expected' in output)"
        echo "    Got: $output"
    fi
}

assert_exit_code() {
    local actual="$1"
    local expected="$2"
    local test_name="$3"

    if [[ "$actual" == "$expected" ]]; then
        pass "$test_name"
    else
        fail "$test_name (expected exit code $expected, got $actual)"
    fi
}

# Setup test environment
setup() {
    export WT_BASE_DIR=$(mktemp -d)
    TEST_REPO=$(mktemp -d)

    # Create a test git repo
    cd "$TEST_REPO"
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "test" > README.md
    git add README.md
    git commit -m "Initial commit" --quiet
}

# Cleanup test environment
cleanup() {
    rm -rf "$WT_BASE_DIR" 2>/dev/null || true
    rm -rf "$TEST_REPO" 2>/dev/null || true
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

echo "Running wt tests..."
echo ""

# ============================================
# Test: Help command
# ============================================
echo "Testing help command..."

output=$("$WT_SCRIPT" help 2>&1)
assert_contains "$output" "Git Worktree Manager" "help shows title"
assert_contains "$output" "wt new" "help shows new command"
assert_contains "$output" "wt switch" "help shows switch command"

# ============================================
# Test: Init command
# ============================================
echo ""
echo "Testing init command..."

output=$("$WT_SCRIPT" --init 2>&1)
assert_contains "$output" "wt()" "init outputs wrapper function"
assert_contains "$output" "__WT_CD__" "init includes cd handling"
assert_contains "$output" "compdef" "init includes zsh completion"

# ============================================
# Test: Unknown command
# ============================================
echo ""
echo "Testing error handling..."

output=$("$WT_SCRIPT" unknown-command 2>&1) || true
assert_contains "$output" "Unknown subcommand" "unknown command shows error"

# ============================================
# Test: New worktree (requires git repo)
# ============================================
echo ""
echo "Testing worktree creation..."

setup

cd "$TEST_REPO"
output=$("$WT_SCRIPT" new test-branch --none 2>&1) || true
assert_contains "$output" "Successfully created worktree" "new creates worktree"
assert_contains "$output" "test-branch" "new shows branch name"

# Verify worktree exists
if [[ -d "$WT_BASE_DIR/$(basename $TEST_REPO)/test-branch" ]]; then
    pass "worktree directory exists"
else
    fail "worktree directory should exist"
fi

# ============================================
# Test: List worktrees
# ============================================
echo ""
echo "Testing list command..."

output=$("$WT_SCRIPT" list 2>&1)
assert_contains "$output" "Git Worktrees" "list shows header"
assert_contains "$output" "test-branch" "list shows created worktree"

# ============================================
# Test: Status command
# ============================================
echo ""
echo "Testing status command..."

output=$("$WT_SCRIPT" status 2>&1)
assert_contains "$output" "Worktree Status" "status shows header"
assert_contains "$output" "Branch:" "status shows branch"

# ============================================
# Test: Switch outputs cd instruction
# ============================================
echo ""
echo "Testing switch command..."

output=$("$WT_SCRIPT" switch test-branch 2>&1)
assert_contains "$output" "__WT_CD__:" "switch outputs cd instruction"
assert_contains "$output" "Switched to worktree" "switch shows success message"

# ============================================
# Test: Duplicate branch error
# ============================================
echo ""
echo "Testing duplicate branch error..."

output=$("$WT_SCRIPT" new test-branch --none 2>&1) || true
assert_contains "$output" "already exists" "duplicate branch shows error"

# ============================================
# Test: Not in git repo error
# ============================================
echo ""
echo "Testing not-in-repo error..."

cd /tmp
output=$("$WT_SCRIPT" new some-branch --none 2>&1) || true
assert_contains "$output" "Not in a git repository" "shows error outside git repo"

# ============================================
# Summary
# ============================================
echo ""
echo "================================"
echo "Tests completed: $((PASSED + FAILED))"
echo "${GREEN}Passed: $PASSED${NC}"
if [[ $FAILED -gt 0 ]]; then
    echo "${RED}Failed: $FAILED${NC}"
    exit 1
else
    echo "Failed: $FAILED"
fi
