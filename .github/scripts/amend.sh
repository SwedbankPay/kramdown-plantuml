#!/bin/bash
set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage: echo $me

Checks out the pull request where an '/amend' comment is made and amends its
latest commit with the credentials of the user who wrote the '/amend' comment.

GITHUB_CONTEXT: An environment variable containing a JSON string of the GitHub
                context object. Typically generated with \${{ toJson(github) }}."

main() {
    github_context_json="$GITHUB_CONTEXT"

    if [[ -z "$github_context_json" ]]; then
        echo "Missing or empty GITHUB_CONTEXT environment variable." >&2
        echo "$help_message"
        exit 1
    fi

    pr_url=$(echo "$github_context_json" | jq --raw-output .event.issue.pull_request.html_url)
    username=$(echo "$github_context_json" | jq --raw-output .event.sender.login)
    user_url=$(echo "$github_context_json" | jq --raw-output .event.sender.url)
    repo_url=$(echo "$github_context_json" | jq --raw-output .event.repository.html_url)
    collaborators_url=$(echo "$github_context_json" | jq --raw-output .event.repository.collaborators_url)

    if [[ -z "$pr_url" ]]; then
        echo "No 'event.issue.pull_request.html_url' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$username" ]]; then
        echo "No 'event.sender.login' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$user_url" ]]; then
        echo "No 'event.sender.url' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$repo_url" ]]; then
        echo "No 'event.repository.html_url' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$collaborators_url" ]]; then
        echo "No 'event.repository.collaborators_url' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    user_json=$(gh api -X GET "$user_url")

    if [[ -z "$user_json" ]]; then
        echo "The request for '$user_url' failed." >&2
        echo "$help_message"
        exit 1
    fi

    name=$(echo "$user_json" | jq --raw-output .name)
    email=$(echo "$user_json" | jq --raw-output .email)

    if [[ -z "$name" ]]; then
        echo "No 'name' found in '$user_url'." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$email" ]]; then
        echo "No 'email' found in '$user_url'." >&2
        echo "$help_message"
        exit 1
    fi

    # Replace the template part of the URL with the username (collaborator).
    # https://api.github.com/repos/asbjornu/test/collaborators{/collaborator}
    collaborator_url="${collaborators_url/\{\/collaborator\}//$username}"

    # If the request for </repos/{owner}/{repo}/collaborators/{username}>
    # fails (404 not found), `gh` should return 1 and thus fail the entire
    # script. For more information, see:
    # https://docs.github.com/en/rest/reference/repos#check-if-a-user-is-a-repository-collaborator
    if gh api -X GET "$collaborator_url" > /dev/null; then
        amend
    else
        echo "'$username' does not have access to the repository <$repo_url>."
    fi
}

amend() {
    gh pr checkout "$pr_url"
    git config --global user.name "$name"
    git config --global user.email "$email"
    git commit --amend --no-edit
    git push --force
}

main "$@"
