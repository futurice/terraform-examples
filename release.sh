#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # dir of this script

set -e # exit on error

echo -n "Checking dependencies... "
deps="git curl node"
if [ "$(echo $deps | tr ' ' '\n' | wc -l)" != "$(command -v $deps | wc -l)" ]; then
  echo -e "ERROR\n\nRequired commands not available: $deps"
  exit 1
fi
echo OK

echo -n "Checking for clean working copy... "
git diff-index HEAD
echo OK

echo -n "Parsing git remote... "
github_raw="$(git config --get remote.origin.url | sed 's/.*://' | sed 's/\..*//')" # e.g. "git@github.com:user/project.git" => "user/project"
github_user="$(echo "$github_raw" | cut -d / -f 1)"
github_project="$(echo "$github_raw" | cut -d / -f 2)"
if [[ ! "$github_user" =~ ^[[:alnum:]-]+$ ]]; then
  echo -e "ERROR\n\nCan't seem to determine GitHub user name reliably: \"$github_user\""
  exit 1
fi
if [[ ! "$github_project" =~ ^[[:alnum:]-]+$ ]]; then
  echo -e "ERROR\n\nCan't seem to determine GitHub project name reliably: \"$github_project\""
  exit 1
fi
echo OK

echo -n "Verifying GitHub API access... "
github_test="$(curl -s -n -o /dev/null -w "%{http_code}" https://api.github.com/user)"
if [ "$github_test" != "200" ]; then
  echo -e "ERROR\n\nPlease ensure that:"
  echo "* You've set up a Personal access token for the GitHub API (https://github.com/settings/tokens/new)"
  echo "* The resulting token is listed in your ~/.netrc file (under \"machine api.github.com\" and \"machine uploads.github.com\")"
  exit 1
fi
echo OK

echo -n "Fetching previous tags from GitHub... "
git fetch --tags --quiet
tag_prev="$(git tag | tail -n 1)" # figure out the latest tag
echo OK

echo
echo "Previous release was: $tag_prev"
echo -n "This release will be: "
read tag_next
echo

echo -n "Tagging new release... "
git tag "$tag_next"
echo OK

echo -n "Pushing release to GitHub... "
git push --quiet origin master
git push --quiet origin "$tag_next"
echo OK

echo -n "Creating release on GitHub... " # https://developer.github.com/v3/repos/releases/
curl -o curl-out -s -n -X POST "https://api.github.com/repos/$github_user/$github_project/releases" --data "{\"tag_name\":\"$tag_next\"}"
release_html_url="$(cat curl-out | node -p 'JSON.parse(fs.readFileSync(0)).html_url')"
if [[ ! "$release_html_url" =~ ^https:// ]]; then
  echo ERROR
  cat curl-out
  exit 1
fi
echo OK

echo -n "Updating example code with new release... "
find "$DIR"/* -name README.md | xargs sed -i '.sed-bak' -E "s/\?ref=v[0-9.]+\"/?ref=$tag_next\"/g" # update all "source" links in examples
find "$DIR"/* -name README.md | xargs sed -i '.sed-bak' -E "s#/compare/v[0-9.]+...master#/compare/$tag_next...master#g" # update all "check for updates" links in examples
echo OK

echo -n "Updating Terraform module docs... "
for file in $(find $DIR/* -name README.md); do
  perl -i -p0e "s/terraform-docs:begin.*?terraform-docs:end/terraform-docs:begin -->\n$(terraform-docs markdown table $(dirname $file) | sed 's#/#\\/#g')\n<\!-- terraform-docs:end/s" "$file"
done
echo OK

echo -n "Creating commit from docs updates... "
git add */README.md
git commit --quiet --message "Update docs & examples for $tag_next."
echo OK

echo -n "Pushing updated docs to GitHub... "
git push --quiet origin
echo OK

echo -n "Cleaning up... "
rm -f curl-out # remove curl temp file
find . -name README.md.sed-bak | xargs rm -f # remove sed's backup files
echo OK

echo
echo "New release is: $release_html_url"
echo
