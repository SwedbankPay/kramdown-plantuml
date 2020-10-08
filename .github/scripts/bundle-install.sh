#!/usr/bin/env bash
set -o errexit # Abort if any command fails

gem install bundler
bundle config path vendor/bundle
bundle install --jobs 4 --retry 3
