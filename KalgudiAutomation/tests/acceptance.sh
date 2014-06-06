#!/bin/bash
# acceptance.sh: Regression test runner; runs acceptance tests against staging or production.
# See bigcommerce-labs/regret for more information.

set -e # Explode on error

function silent() {
  "$@" >/dev/null 2>/dev/null
}
PREREQ_ERROR=86

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # This script's directory.
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$SCRIPT_DIR/Acceptance"
REPORTS_DIR="$TESTS_DIR/reports"
PY_TEST="$ROOT_DIR/env/bin/py.test"
PIP="$ROOT_DIR/env/bin/pip"
NPM="npm"

### Args check ###
if [[ -z "$BROWSER" ]]; then
  BROWSER=headless
fi
if [[ -z "$STORE_URL" || -z "$EMAIL" || -z "$PASSWORD" ]]; then
  echo "Usage: env STORE_URL=<https-store-url> EMAIL=<admin-email> PASSWORD=<admin-password> $0 [Acceptance/tests/to/run.py Acceptance/tests/to/also/run.py]"
  echo "   eg. env STORE_URL=https://store-abc123.bcapp.dev EMAIL=foo@example.org PASSWORD=somepassword9 $0"
  echo "       env STORE_URL=https://store-abc123.bcapp.dev EMAIL=foo@example.org PASSWORD=somepassword9 $0 Acceptance/ui/test_coupon_crud.py"
  exit $ARGERROR
fi

## Tool check
if ! silent which virtualenv; then
  echo "Requires virtualenv; run 'pip install virtualenv' (OS X) or 'sudo apt-get install python-pip && pip install virtualenv' (Linux)."
  exit $PREREQ_ERROR
fi
if ! silent which npm; then
  echo "Requires npm (bundled with Node.js); run 'brew install node' (OS X), or see https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#debian-lmde (Debian Linux)."
  exit $PREREQ_ERROR
fi

## Cleanup from previous run
for DIR in "$REPORTS_DIR" "$TESTS_DIR/screenshot_on_failure"; do
  echo "Cleaning up $DIR"
  mkdir -p "$DIR"
  rm -rf "$DIR"/*
done

## Dependencies
pushd $ROOT_DIR
  # Node dependencies, for PhantomJS
  $NPM install
  # HACK: PhantomJS binary sometimes installed without executable permissions.
  #       Suggestions very welcome.
  if [ -f "$ROOT_DIR/node_modules/phantomjs/lib/phantom/bin/phantomjs" ]; then
    chmod a+x "$ROOT_DIR/node_modules/phantomjs/lib/phantom/bin/phantomjs"
  fi

  # Python dependencies
  virtualenv env # Set up a container for Python libraries to be installed into.
  $PIP install -r "$TESTS_DIR/requirements.txt" &> ./pip-install.log # There is a *lot* of noise to sift through.
popd

## Collect the tests to run.
if [ "$#" -eq 0 ]; then
  echo "Running all tests..."
  TESTS=$(find "$TESTS_DIR/api" "$TESTS_DIR/ui" -name "test_*.py" ! -name "*_parallel.py" -type f)
else
  echo "Running tests from args:"
  TESTS=$(find "$@" -name "test_*.py" -type f)
  for TEST in $TESTS; do
    echo "- $TEST"
  done
fi

# Get the store token and store it in the environment for use below.
API_CREDENTIALS=( $(env "$ROOT_DIR/env/bin/python" "$TESTS_DIR/api_token.py") ) # Runs api_token.py, splits result into array
USERNAME=${API_CREDENTIALS[0]}
AUTH_TOKEN=${API_CREDENTIALS[1]}
echo "Using API username: $USERNAME"
echo "Using API auth token: $AUTH_TOKEN"

# Run the rest of the tests one by one. In order to run these tests in parallel, we'd
# need to:
# - Have test suites (files) not interfere with each other (like flipping feature flags), or
# - Have a number of stores spun up we can run tests on in parallel; with four stores, for
#   example, we could have four parallel processes running tests, with each process running
#   a group of tests in series. (Each store would need its own $AUTH_TOKEN.)
#
# (Splitting into tests/api/ and tests/ui/ runs doesn't work, because the tests from each
#  interfere with each other when run simultaneously.)

set +e
echo "Starting tests..."
trap ctrl_c INT
function ctrl_c() {
  echo "Cancelling..."
  exit 1
}
for TEST in $TESTS; do
  TEST_FILE="${TEST##*/}"
  $PY_TEST "$TEST" \
    --junitxml="$REPORTS_DIR/${TEST_FILE%%.py}.xml" \
    --url="$STORE_URL" \
    --username="$USERNAME" \
    --email="$EMAIL" \
    --password="$PASSWORD" \
    --browser="$BROWSER" \
    --auth_token="$AUTH_TOKEN" \
    -vx
done
TESTS_RET=$? # Capture the errors here, then use them later to exit with.
set -e

# Print out the tests results in summarised form.
echo; $ROOT_DIR/env/bin/python "$TESTS_DIR/reports.py" "$REPORTS_DIR"

# Exit with the test's exit code; this is the number of failing tests.
# eg. 0 failing (:. success), 1 failing, ...
exit "$TESTS_RET"
