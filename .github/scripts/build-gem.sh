#!/usr/bin/env bash
set -o errexit # Abort if any command fails

gem_build_name=$(gem build kramdown-plantuml.gemspec | awk '/File/ {print $2}')
echo "Gem filename: '${gem_build_name}'"
echo "::set-output name=name::${gem_build_name}"
