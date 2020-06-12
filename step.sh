#!/bin/bash
set -ex

echo "This is the value specified for the input 'branch_source_name': ${branch_source_name}"
echo "This is the value specified for the input 'branch_target_name': ${branch_target_name}"

git checkout ${branch_target_name} 2>/dev/null || git checkout -b ${branch_target_name}

git merge ${branch_source_name}
git push origin ${branch_target_name}
















#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
