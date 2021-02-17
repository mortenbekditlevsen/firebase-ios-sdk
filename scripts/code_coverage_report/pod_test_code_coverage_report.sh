# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

SDK="$1"
platform="$2"
default_output_path="/Users/runner/${SDK}-${platform}.xcresult"
output_path="${3:-${default_output_path}}"
if [ -d "/Users/runner/Library/Developer/Xcode/DerivedData" ]; then
rm -r /Users/runner/Library/Developer/Xcode/DerivedData/*
fi

# Setup for pod unit tests
if [ $SDK == "FirebasePerformance" ]; then
  scripts/setup_bundler.sh
  scripts/third_party/travis/retry.sh scripts/build.sh Performance ${platform} unit
elif [ $SDK == "FirebaseFirestore" ]; then
  scripts/install_prereqs.sh Firestore ${platform} xcodebuild
  scripts/third_party/travis/retry.sh scripts/build.sh Firestore ${platform} xcodebuild
else
  # Run unit tests of pods and put xcresult bundles into output_path, which
  # should be a targeted dir of actions/upload-artifact in workflows.
  # In code coverage workflow, files under output_path will be uploaded to
  # Github Actions.
  scripts/third_party/travis/retry.sh scripts/pod_lib_lint.rb "${SDK}".podspec --platforms="$(tr '[:upper:]' '[:lower:]'<<<${platform})" --test-specs=unit
fi

find /Users/runner/Library/Developer/Xcode/DerivedData -type d -regex ".*/.*\.xcresult" -execdir cp -R '{}' "${output_path}" \;
