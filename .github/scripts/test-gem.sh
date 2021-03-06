#!/usr/bin/env bash
set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --workdir <workdir> [--gemdir <gemdir> | --version <version> --token <token>] [--verbose]
  $me --help
Arguments:
  -w, --workdir <workdir>       The path to the working directory.
  -g, --gemdir <gemdir>         The path to directory of the Gem file to test.
  -v, --version <version>       The version of the Gem to test.
  -t, --token <token>           The GitHub token to use for retrieving the gem
                                from the GitHub Package Registry.
  -h, --help                    Displays this help screen.
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        elif [[ $1 = "-g" || $1 = "--gemdir" ]]; then
            gemdir=${2// }

            if [[ "$gemdir" = "--"* ]]; then
                gemdir=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-v" || $1 = "--version" ]]; then
            version=${2// }

            if [[ "$version" = "--"* ]]; then
                version=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-t" || $1 = "--token" ]]; then
            token=${2// }

            if [[ "$token" = "--"* ]]; then
                token=""
                shift 1
            else
                shift 2
            fi
        elif [[ $1 = "-w" || $1 = "--workdir" ]]; then
            workdir=${2// }

            if [[ "$workdir" = "--"* ]]; then
                workdir=""
                shift 1
            else
                shift 2
            fi
        else
            break
        fi
    done

    if [[ -z "$workdir" ]]; then
        echo "Missing required argument: --workdir <workdir>."
        echo "$help_message"
        return 1
    fi

    if [[ (-z "$gemdir" && -z "$token") || (-n "$gemdir" && -n "$token") ]]; then
        echo "Missing or invalid required arguments: --gemdir <gem-path> or --token <token>."
        echo "Either [--gemdir] or [--token] needs to be provided, but not both."
        echo "$help_message"
        return 1
    fi

    if [[ (-n "$version" && -z "$token") || (-z "$version" && -n "$token") ]]; then
        echo "Missing or invalid required arguments: --version <gem-path> and --token <token>."
        echo "When either argument is present, both must be."
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

test_gem() {
    cd "$workdir"

    gem install bundler

    if [[ -n "$token" ]]; then
        # A non-empty $token means we should install the Gem from GPR
        repository="https://rubygems.pkg.github.com/swedbankpay"
        bundle config "$repository" "SwedbankPay:$token"
        printf "source '%s' do\n\tgem 'kramdown-plantuml', '%s'\nend" "$repository" "$version" >> Gemfile
    else
        echo "gem 'kramdown-plantuml', path: '$gemdir'" >> Gemfile
    fi

    if [[ $verbose ]]; then
        cat Gemfile
    fi

    bundle install
    bundle exec jekyll build

    file="$workdir/_site/index.html"

    file_contains "$file" "class=\"plantuml\""
    file_contains "$file" "<svg"
    file_contains "$file" "<ellipse"
    file_contains "$file" "<polygon"
    file_contains "$file" "<path"
}

file_contains() {
    file=$1
    contents=$2

    if [[ -z "$file" ]]; then
        echo "file_contains missing required argument <file>."
        return 1
    fi

    if [[ -z "$contents" ]]; then
        echo "file_contains missing required argument <contents>."
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "file_contains <file> not found: '$file'."
        return 1
    fi

    if grep --quiet --fixed-strings "$contents" "$file"; then
        echo "Success! '$contents' found in '$file'."
    else
        echo "Failed! '$contents' not found in '$file'."

        if [[ $verbose ]]; then
            cat "$file"
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
