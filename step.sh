#!/bin/bash
set -ex

echo "This is the value specified for the input 'branch_source_name': ${branch_source_name}"
echo "This is the value specified for the input 'branch_target_name': ${branch_target_name}"

git checkout ${branch_target_name} 2>/dev/null || git checkout -b ${branch_target_name}

git merge ${branch_source_name}
git push origin ${branch_target_name}
