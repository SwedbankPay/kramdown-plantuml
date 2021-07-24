#!/bin/bash
set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage: echo $me <version>
Generates variables based on the provided environment variable GITHUB_CONTEXT
and <version> argument.
GITHUB_CONTEXT: An environment variable containing a JSON string of the GitHub
                context object. Typically generated with \${{ toJson(github) }}.
     <version>: The version number corresponding to the current Git commit."

initialize() {
    github_context_json="$GITHUB_CONTEXT"
    version="$1"

    if [[ -z "$github_context_json" ]]; then
        echo "Missing or empty GITHUB_CONTEXT environment variable." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$version" ]]; then
        echo "No version specified." >&2
        echo "$help_message"
        exit 1
    fi

    sha=$(echo "$github_context_json" | jq --raw-output .sha)
    ref=$(echo "$github_context_json" | jq --raw-output .ref)

    if [[ -z "$sha" ]]; then
        echo "No 'sha' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$ref" ]]; then
        echo "No 'ref' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi
}

generate_variables() {
    # Replace '+'' in the version number with '.'.
    version="${version//+/.}"
    # Replace '-' in the version number with '.'.
    version="${version//-/.}"

    if [[ "$ref" == refs/tags/* ]]; then
        # Override GitVersion's version on tags, just to be sure.
        version="${ref#refs/tags/}"
    fi

    # Convert the version number to all-lowercase because GPR only supports lowercase version numbers.
    version=$(echo "$version" | tr '[:upper:]' '[:lower:]')

    echo "Ref: $ref"
    echo "Sha: $sha"
    echo "Version: $version"
    echo "::set-output name=ref::$ref"
    echo "::set-output name=sha::$sha"
    echo "::set-output name=version::$version"
}

main() {
    initialize "$@"
    generate_variables
}

main "$@"
