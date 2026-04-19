#!/bin/bash
# Generates different CI failure types by pushing branches with intentional breakage.
# Run from inside the opsai-test-repo directory.
#
# Usage:
#   bash ../opsai/scripts/break_things.sh <failure_type>
#
# Types:
#   import      - ModuleNotFoundError (missing dependency)
#   assertion   - AssertionError (wrong return value)
#   syntax      - SyntaxError (bad Python)
#   timeout     - slow test that hangs
#   lint        - ruff lint failure
#   all         - push all of them sequentially (makes a lot of CI runs)

FAILURE=${1?"Usage: $0 <import|assertion|syntax|lint|all>"}

push_branch() {
    local branch=$1
    local file=$2
    local content=$3
    local msg=$4

    git checkout main
    git checkout -b "break/$branch" 2>/dev/null || git checkout "break/$branch"
    echo "$content" > "$file"
    git add "$file"
    git commit -m "break: $msg" --allow-empty
    git push origin "break/$branch" --force
    echo "✓ Pushed break/$branch — CI run starting"
    git checkout main
}

case "$FAILURE" in
  import)
    push_branch "import-error" "tests/unit/test_auth.py" \
'import pytest
from myapp.auth import get_user
from myapp.cache import RedisCache  # this module does not exist

def test_get_user():
    cache = RedisCache()
    user = get_user(token="abc12345")
    assert user["id"] == 1
' \
"import nonexistent cache module"
    ;;

  assertion)
    push_branch "assertion-error" "tests/unit/test_auth.py" \
'import pytest
from myapp.auth import get_user

def test_get_user_returns_dict():
    user = get_user(token="abc12345")
    assert user["id"] == 999  # wrong expected value

def test_email_format():
    user = get_user(token="abc12345")
    assert user["email"].endswith("@company.com")  # wrong domain
' \
"wrong assertions in auth tests"
    ;;

  syntax)
    push_branch "syntax-error" "myapp/auth.py" \
'def get_user(token: str) -> dict
    if not token:
        raise ValueError("token required"
    return {"id": 1, "email": "test@example.com"}
' \
"syntax error in auth module"
    ;;

  lint)
    push_branch "lint-error" "myapp/payments.py" \
'import os, sys, json  # unused imports
import requests

def calculate_total(items):
    x=0  # bad spacing
    for i in items:
        x=x+i["price"]*i["qty"]
    return x

def apply_discount(total,pct):
    return total*(1-pct/100)  # no validation, bad spacing
' \
"messy payments module with lint errors"
    ;;

  timeout)
    push_branch "slow-test" "tests/integration/test_basic.py" \
'import time
import pytest

def test_environment_has_requests():
    import requests
    assert requests.__version__ is not None

def test_slow_external_call():
    """Simulates a test that hangs waiting for a service that is down"""
    time.sleep(400)  # will hit GitHub Actions 6min job timeout
    assert True
' \
"add slow test that will timeout"
    ;;

  all)
    echo "Pushing all failure types — this will create 5 CI runs"
    bash "$0" import
    sleep 3
    bash "$0" assertion
    sleep 3
    bash "$0" syntax
    sleep 3
    bash "$0" lint
    echo "Skipping timeout — takes too long to complete"
    echo "Done. Watch your opsai terminal."
    ;;

  *)
    echo "Unknown failure type: $FAILURE"
    echo "Usage: $0 <import|assertion|syntax|lint|timeout|all>"
    exit 1
    ;;
esac
