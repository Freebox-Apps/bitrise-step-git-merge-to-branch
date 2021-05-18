#!/bin/bash
set -e

branch_source_name=$(git rev-parse --abbrev-ref HEAD)

diff=$(git diff $branch_source_name origin/$branch_target_name)

if [ -z "$diff" ]
then
    echo -e "|\t Nothing to merge between ${branch_source_name} and ${branch_target_name}"
else
    echo -e "|\t Opening auto-merge MR for Source branche: ${branch_source_name} into target: ${branch_target_name}"

    report_branch=report_${branch_source_name}
    git checkout -b ${report_branch} &> /dev/null

    echo -e "|\t Opening MR for ${report_branch} into ${branch_target_name}"
    
    title="Report ${branch_source_name} into ${branch_target_name}"
    git push --set-upstream origin ${report_branch} -o merge_request.create -o merge_request.target=${branch_target_name} -o merge_request.title="${title}" -o merge_request.merge_when_pipeline_succeeds -o merge_request.remove_source_branch &> /dev/null

    echo -e "|\t MR is now opened and will be merge automatically if there is no conflict"
fi
