#!/bin/bash
set -e

echo -e "fetching ${branch_target_name}"
git fetch origin $branch_target_name

branch_source_name=$(git rev-parse --abbrev-ref HEAD)

echo -e "start diff for Source branche: ${branch_source_name} with target: ${branch_target_name}"
diff=$(git diff $branch_source_name origin/$branch_target_name)

if [ -z "$diff" ]
then
    echo -e "|\t Nothing to merge"
else
    echo -e "|\t Opening auto-merge MR"

    report_branch=report_${branch_source_name}
    git checkout -b ${report_branch} &> /dev/null

    echo -e "|\t Opening MR for ${report_branch} into ${branch_target_name}"
    
    title="Report ${branch_source_name} into ${branch_target_name}"
    git push --set-upstream origin ${report_branch} -o merge_request.create -o merge_request.target=${branch_target_name} -o merge_request.title="${title}" -o merge_request.merge_when_pipeline_succeeds -o merge_request.remove_source_branch &> /dev/null

    echo -e "|\t MR is now opened and will be merge automatically if there is no conflict"
fi
