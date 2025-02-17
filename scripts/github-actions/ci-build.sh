#!/usr/bin/env bash

set -eufo pipefail
# We want to see what's going on
set -x

# Fail the build if the format script needs to be re-run
./scripts/format.sh
git diff --exit-code

# We want to use a pre-built Ruby version
echo 'RUBY_VERSION = "jruby-9.4.2.0"' >rb/ruby_version.bzl

# The NPM repository rule wants to write to the HOME directory
# but that's configured for the remote build machines, so run
# that repository rule first so that the subsequent remote
# build runs successfully. We don't care what the output is.
bazel query @npm//:all >/dev/null

# Now run the tests. The engflow build uses pinned browsers
# so this should be fine
bazel test --config=remote-ci --keep_going //java/...
