#!/usr/bin/env bash
# shellcheck disable=3000-SC4000

set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  ${me} --workdir <workdir> [--gemdir <gemdir> | --version <version> --token <token>] [--verbose] [--theme <name> [--theme-directory <path>]]
  ${me} --help
Arguments:
  -w, --workdir <workdir>       The path to the working directory.
  -g, --gemdir <gemdir>         The path to directory of the Gem file to test.
  -v, --version <version>       The version of the Gem to test.
  -t, --token <token>           The GitHub token to use for retrieving the gem
                                from the GitHub Package Registry.
  -T, --theme-name <name>       The theme name to use for the test.
  -p, --theme-directory <path>  The directory in which the [--theme-name] is placed.
  -h, --help                    Displays this help screen.
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "${help_message}"
            return 0
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        elif [[ $1 = "-g" || $1 = "--gemdir" ]]; then
            gemdir=${2// }

            if [[ "${gemdir}" = "--"* ]]; then
                gemdir=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-v" || $1 = "--version" ]]; then
            version=${2// }

            if [[ "${version}" = "--"* ]]; then
                version=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-t" || $1 = "--token" ]]; then
            token=${2// }

            if [[ "${token}" = "--"* ]]; then
                token=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-T" || $1 = "--theme-name" ]]; then
            theme_name=${2// }

            if [[ "${theme_name}" = "--"* ]]; then
                theme_name=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-p" || $1 = "--theme-directory" ]]; then
            theme_directory=${2// }

            if [[ "${theme_directory}" = "--"* ]]; then
                theme_directory=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-w" || $1 = "--workdir" ]]; then
            workdir=${2// }

            if [[ "${workdir}" = "--"* ]]; then
                workdir=""
                shift 1
            else
                shift 2
            fi
        else
            break
        fi
    done

    if [[ -z "${workdir}" ]]; then
        echo "Missing required argument: --workdir <workdir>." >&2
        echo "${help_message}" >&2
        return 1
    fi

    if [[ (-z "${gemdir}" && -z "${token}") || (-n "${gemdir}" && -n "${token}") ]]; then
        echo "Missing or invalid required arguments: --gemdir <gem-path> or --token <token>." >&2
        echo "Either [--gemdir] or [--token] needs to be provided, but not both." >&2
        echo "${help_message}"
        return 1
    fi

    if [[ (-n "${version}" && -z "${token}") || (-z "${version}" && -n "${token}") ]]; then
        echo "Missing or invalid required arguments: --version <gem-path> and --token <token>." >&2
        echo "When either argument is present, both must be." >&2
        echo "${help_message}" >&2
        return 1
    fi

    if [[ -z "${theme_name}" && -n "${theme_directory}" ]]; then
        echo "Missing or invalid required arguments: --theme-name <name>." >&2
        echo "[--theme-name] is required when [--theme-directory] is provided." >&2
        echo "${help_message}" >&2
        return 1
    fi
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ "${verbose}" = true ]; then
        set -o xtrace
        set +o verbose
        export VERBOSE=true
    fi
}

test_gem() {
    local jekyll_build_args=()

    cd "${workdir}"

    # Recreate Gemfile
    printf "# frozen_string_literal: true\nsource 'https://rubygems.org'\ngem 'jekyll'\ngem 'simplecov'\n" > Gemfile

    if [[ -n "${token}" ]]; then
        # A non-empty $token means we should install the Gem from GPR
        repository="https://rubygems.pkg.github.com/swedbankpay"
        bundle config "${repository}" "SwedbankPay:${token}"
        printf "source '%s' do\n\tgem 'kramdown-plantuml', '%s'\nend\n" "${repository}" "${version}" >> Gemfile
    else
        printf "gem 'kramdown-plantuml', path: '%s'\n" "${gemdir}" >> Gemfile
    fi

    # Recreate _config.yml
    printf "plugins:\n- kramdown-plantuml\n" > _config.yml

    if [[ -n "${theme_name}" ]]; then
        printf "kramdown:\n  plantuml:\n    theme:\n      name: %s\n" "${theme_name}" >> _config.yml
        class="plantuml theme-${theme_name}"
    else
        class='plantuml'
    fi

    if [[ -n "${theme_directory}" ]]; then
        printf "      directory: %s\n" "${theme_directory}" >> _config.yml
    fi

    if [[ "${verbose}" = true ]]; then
        printf "\nGemfile:\n"
        cat Gemfile
        printf "\n_config.yml\n"
        cat _config.yml
        jekyll_build_args+=(--verbose)
    fi

    bundle install
    bundle exec jekyll build "${jekyll_build_args[@]}"


    file="${workdir}/_site/index.html"

    file_contains "${file}" "class=\"${class}\""
    file_contains "${file}" "<svg"
    file_contains "${file}" "<ellipse"
    file_contains "${file}" "<polygon"
    file_contains "${file}" "<path"
}

file_contains() {
    file=$1
    contents=$2

    if [[ -z "${file}" ]]; then
        echo "file_contains missing required argument <file>."
        return 1
    fi

    if [[ -z "${contents}" ]]; then
        echo "file_contains missing required argument <contents>."
        return 1
    fi

    if [[ ! -f "${file}" ]]; then
        echo "file_contains <file> not found: '${file}'."
        return 1
    fi

    if grep --quiet --fixed-strings "${contents}" "${file}"; then
        echo "Success! '${contents}' found in '${file}'."
    else
        echo "Failed! '${contents}' not found in '${file}'."

        if [ "${verbose}" = true ]; then
            cat "${file}"
        fi

        return 1
    fi
}

main() {
    parse_args "$@"
    enable_expanded_output
    test_gem
}

main "$@"
