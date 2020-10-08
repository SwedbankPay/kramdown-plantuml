#!/usr/bin/env bash
set -e # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --gem <gem> [--verbose]
  $me --help
Arguments:
  -g, --gem <gem>   The path to the Gem file to inspect.
  -h, --help        Displays this help screen.
  -v, --verbose     Increase verbosity. Useful for debugging."

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
        else
            break
        fi
    done

    if [[ -z "$gem" ]]; then
        echo "Missing required argument: --gem <gem>."
        echo "$help_message"
        return 1
    fi
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        echo "Verbose mode enabled."
        set -o xtrace
        set +o verbose
    fi
}

inspect_gem() {
    gem unpack "$gem"
    gem_dir="${gem%.*}"

    if [ $verbose ]; then
        echo "Files in '$gem_dir':"
        find "$gem_dir"
    fi

    if [[ ! -d "$gem_dir/bin" ]]; then
        echo "ERROR! 'bin' folder missing from '$gem'."
        return 1
    fi

    if ! (find "$gem_dir" -iname "plantuml*.jar" | grep -q .); then
        echo "ERROR! 'plantuml.jar' missing from '$gem'."
        return 1
    fi
}

main() {
    parse_args "$@"
    enable_expanded_output
    inspect_gem
}

main "$@"
