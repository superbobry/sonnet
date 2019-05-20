#!/bin/bash
# Copyright 2019 The Sonnet Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or  implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

# Pip installs the relevant dependencies and runs the Sonnet tests on CPU

set -e
set -x

virtualenv -p python3 .
source bin/activate
python3 --version

# Run setup.py, this installs the python dependencies
python3 setup.py install

N_JOBS=$(grep -c ^processor /proc/cpuinfo)

echo ""
echo "Bazel will use ${N_JOBS} concurrent job(s)."
echo ""

# Python test dependencies.
python3 -m pip install -r requirements-test.txt

python3 -m pip install --upgrade tf-nightly-2.0-preview==2.0.0.dev20190517
python3 -c 'import tensorflow as tf; print(tf.__version__)'

# Run bazel test command. Double test timeouts to avoid flakes.
bazel test --jobs=${N_JOBS} --test_timeout 300,450,1200,3600 \
    --build_tests_only --test_output=errors \
    --cache_test_results=no \
    -- //sonnet/...

deactivate
