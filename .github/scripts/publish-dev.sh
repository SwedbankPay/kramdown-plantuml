#!/usr/bin/env bash
set -o errexit # Abort if any command fails

me=$(basename "$0")

help_message="\
Usage:
  $me --token <token> --owner <owner> --gem <gem-path> [--verbose]
  $me --help
Arguments:
  -t, --token <token>       The GitHub token to use for publishing the gem
                            to the GitHub Package Registry.
  -o, --owner <owner>       The path to the working directory.
  -g, --gem <gem-path>      The path to directory of the Gem file to test.
  -h, --help                Displays this help screen.
  -v, --verbose             Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        elif [[ $1 = "-g" || $1 = "--gem" ]]; then
            gem=$2
            shift 2
        elif [[ $1 = "-t" || $1 = "--token" ]]; then
            token=$2
            shift 2
        elif [[ $1 = "-o" || $1 = "--owner" ]]; then
            owner=$2
            shift 2
        else
            break
        fi
    done

    if [[ -z "$token" ]]; then
        echo "Missing required argument: --token <token>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$owner" ]]; then
        echo "Missing required argument: --owner <owner>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$gem" ]]; then
        echo "Missing required argument: --gem <gem>."
        echo "$help_message"
        return 1
    fi
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

publish_gem() {
    gem_home="$HOME/.gem"
    credentials_file="$gem_home/credentials"

    mkdir -p "$gem_home"
    touch "$credentials_file"
    chmod 0600 "$credentials_file"
    printf -- "---\n:github: Bearer %s\n" "$token" > "$credentials_file"

    set -e
    gem push \
        --KEY github \
        --host "https://rubygems.pkg.github.com/$owner" \
        "$gem" \
        || echo "push failed ($?) probably due to version '$gem' already existing in GPR."
}

main() {
    parse_args "$@"
    enable_expanded_output
    publish_gem
}

main "$@"
