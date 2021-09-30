#!/usr/bin/env bash
set -o errexit # Abort if any command fails

me=$(basename "$0")
help_message="\
Usage:
  ${me} [--ref <ref>] [--verbose]
  ${me} --help
Arguments:
  -r, --ref         The Git reference that is being built.
  -h, --help        Displays this help screen.
  -v, --verbose     Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "${help_message}"
            return 0
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        elif [[ $1 = "-r" || $1 = "--ref" ]]; then
            ref=${2// }

            if [[ "${ref}" = "--"* ]]; then
                ref=""
                shift 1
            else
                shift 2
            fi
        else
            break
        fi
    done
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ "${verbose}" = true ]; then
        set -o xtrace
        set +o verbose
        export VERBOSE=true
    fi
}

add_coverage() {
    # If we're not building a tag, bootstrap code coverage.
    if [[ "${ref}" != "refs/tags/"* ]]; then
        [[ "${verbose}" = true ]] && echo "Bootstrapping code coverage."
        export COVER=true
        export COVERAGE=true
        printf "require 'simplecov'\nSimpleCov.start\n" >> lib/kramdown-plantuml.rb
    elif [[ "${verbose}" = true ]]; then
        echo "Skipping coverage report since a tag ref was pushed."
    fi
}

build_gem() {
    gem_build_name=$(gem build kramdown-plantuml.gemspec | awk '/File/ {print $2}')

    [[ "${verbose}" = true ]] && echo "Gem filename: '${gem_build_name}'"

    echo "::set-output name=name::${gem_build_name}"
}

main() {
    parse_args "$@"
    enable_expanded_output
    add_coverage
    build_gem
}

main "$@"
