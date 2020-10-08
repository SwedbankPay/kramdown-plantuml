#!/usr/bin/env bash
set -e # Abort if any command fails

me=$(basename "$0")

help_message="\
Usage:
  $me --gem <gem-path> --token <token> [--owner <owner>] [--verbose]
  $me --help
Arguments:
  -g, --gem <gem-path>      The path of the Gem to publish.
  -t, --token <token>       The access token to use for publishing the gem to
                            the specified registry.
  -o, --owner <owner>       The owner to use when publishing to the GitHub
                            Package Registry. If empty, will publish to
                            RubyGems.org.
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

    if [[ -z "$gem" ]]; then
        echo "Missing required argument: --gem <gem>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$token" ]]; then
        echo "Missing required argument: --token <token>."
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

    if [[ -n "$owner" ]]; then
        auth_header="github: Bearer"
        host="https://rubygems.pkg.github.com/$owner"
    else
        auth_header="rubygems_api_key:"
    fi

    mkdir -p "$gem_home"
    touch "$credentials_file"
    chmod 0600 "$credentials_file"
    printf -- "---\n:%s %s\n" "$auth_header" "$token" > "$credentials_file"

    if [[ -n "$host" ]]; then
        gem push --KEY github --host "$host" "$gem"
    else
        gem push "$gem"
    fi
}

main() {
    parse_args "$@"
    enable_expanded_output
    publish_gem
}

main "$@"
