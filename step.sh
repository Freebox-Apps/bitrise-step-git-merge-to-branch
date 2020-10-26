#!/bin/bash
set -e

echo "|\t\t Opening auto-merge MR for Source branche: ${branch_source_name} into target: ${branch_target_name}"

report_branch=report_${branch_source_name}
git checkout -b ${report_branch}

title="Report ${branch_source_name} into ${branch_target_name}"
git push --set-upstream origin ${report_branch} -o merge_request.create -o merge_request.target=${branch_target_name} -o merge_request.title=${title} -o merge_request.merge_when_pipeline_succeeds
echo -e "|\t\t Created and pushed branch : ${report_branch}"
echo -e "|\t\t MR is now opened and will be merge automatically if there is no conflict"
