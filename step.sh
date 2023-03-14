#!/bin/bash
set -e

branch_target_name="dev"
branch_source_name="alpha"

echo -e "fetching ${branch_target_name}"
git fetch origin $branch_target_name

source_commit=$(git rev-parse --abbrev-ref HEAD)

echo -e "start diff for Source branche: ${source_commit} with target: origin/${branch_target_name}"
diff=$(git diff $source_commit origin/$branch_target_name)



if [ -z "$diff" ]
then
    echo -e "|\t Nothing to merge"
else
    oldest_commit=$(git merge-base --octopus origin/$branch_source_name origin/$branch_target_name)
    commit_lines=$(git log --pretty=%b $oldest_commit..origin/$branch_source_name | perl -nle'print $& while m{(resolve|end) (#\d+,?)+}g')

    git merge --no-commit --no-ff origin/$branch_target_name
    result=$(git diff --cached)
    if [ -z "$result" ]
    then
       git commit -m "chore(merge): merge $branch_source_name into $branch_target_name

$commit_lines"
    else
       git merge --abort
    fi

    echo -e "|\t Opening auto-merge MR"

    report_branch="report/${branch_source_name}_into_${branch_target_name}"
    git checkout -b ${report_branch}

    echo -e "|\t Opening MR for ${report_branch} into ${branch_target_name}"

    title="Report ${branch_source_name} into ${branch_target_name}"

    echo "desc: ${commit_lines}"

    git push --set-upstream origin ${report_branch} -o merge_request.create -o merge_request.target=${branch_target_name} -o merge_request.title="${title}" -o merge_request.merge_when_pipeline_succeeds -o merge_request.remove_source_branch

    echo -e "|\t MR is now opened and will be merge automatically if there is no conflict"
fi
