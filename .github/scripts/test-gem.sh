#!/usr/bin/env bash
set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --workdir <workdir> [--gem <gem-path>] | --token <token>] [--verbose]
  $me --help
Arguments:
  -w, --workdir <workdir>       The path to the working directory.
  -g, --gem <gem-path>          The path to the Gem file to test.
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
        elif [[ $1 = "-g" || $1 = "--gem" ]]; then
            gem_path=$(dirname "$2")
            shift 2
        elif [[ $1 = "-t" || $1 = "--token" ]]; then
            token=$2
            shift 2
        elif [[ $1 = "-w" || $1 = "--workdir" ]]; then
            workdir=$2
            shift 2
        else
            break
        fi
    done

    if [[ -z "$workdir" ]]; then
        echo "Missing required argument: --workdir <workdir>."
        echo "$help_message"
        return 1
    fi

    if [[ (-z "$gem_path" && -z "$token") || (-n "$gem_path" && -n "$token") ]]; then
        echo "Missing or invalid required arguments: --gem <gem-path> or --token <token>."
        echo "Either [--gem] or [--token] needs to be provided, but not both."
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
        repository="https://rubygems.pkg.github.com/SwedbankPay"
        bundle config "$repository" "SwedbankPay:$token"
        echo "source '$repository' { gem 'kramdown-plantuml' }" >> Gemfile
    else
        echo "gem 'kramdown-plantuml', path: '$gem_path'" >> Gemfile
    fi

    bundle install
    bundle exec jekyll build
    grep -Fxq 'class="plantuml"' _site/index.html
    grep -Fxq '<svg' _site/index.html
    grep -Fxq '<ellipse' _site/index.html
    grep -Fxq '<polygon' _site/index.html
    grep -Fxq '<path' _site/index.html
}

main() {
    parse_args "$@"
    enable_expanded_output
    test_gem
}

main "$@"
