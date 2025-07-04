#!/bin/bash
set -e

echo -e "|\t fetching ${branch_target_name}..."
git fetch origin $branch_target_name

source_commit=$(git rev-parse --abbrev-ref HEAD)

echo -e "|\t start diff for Source branche: ${source_commit} with target: origin/${branch_target_name}"
diff=$(git diff $source_commit origin/$branch_target_name)


if [ -z "$diff" ]
then
    echo -e "|\t Nothing to merge"
else
    oldest_commit=$(git merge-base --octopus origin/$branch_source_name origin/$branch_target_name)
    commit_lines=$(git log --pretty=%b $oldest_commit..origin/$branch_source_name | perl -nle'print $& while m{(resolve|end) (#\d+,?)+}g')

    echo -e "|\t Opening auto-merge MR"

    report_branch="report/${branch_source_name}_into_${branch_target_name}_$(date +%Y-%m-%d_%H-%M)"
    git checkout -b ${report_branch}

    echo -e "|\t Opening MR for ${report_branch} into ${branch_target_name}"

    title="Report ${branch_source_name} into ${branch_target_name}"

    echo -e "|\t desc: ${commit_lines}"

    if [ -z "$repo_type" ] || [ "$repo_type" = "gitlab" ]; then
        git push --set-upstream origin ${report_branch} -o merge_request.create -o merge_request.target=${branch_target_name} -o merge_request.title="${title}" -o merge_request.merge_when_pipeline_succeeds -o merge_request.remove_source_branch
    elif [ "$repo_type" = "github" ]; then
    
        # Set GH_TOKEN environment variable
        old_gh_token="$GH_TOKEN"
        if [ -n "$github_app_token" ]; then
            envman add --key GH_TOKEN --value $github_app_token
        fi

        # test GitHub authentication status
        gh auth status

        #install gh
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y

        # push and create PR
        git push origin ${report_branch}
        gh pr create --base ${branch_target_name} --head ${report_branch} --title "${title}" --body "${commit_lines}"
        gh pr merge --auto -m --body "${commit_lines}"

        # Restoring previous GH_TOKEN value
        envman add --key GH_TOKEN --value $old_gh_token
    fi

    echo -e "|\t MR is now opened and will be merged automatically if there is no conflict"
fi
