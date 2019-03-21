# Terraform Utils

This repository contains reusable [Terraform](https://www.terraform.io/) utility modules, which are liberally licensed, and can be shared between projects.

## Resources

In addition to the modules here, there's a lot of useful ones in the wild. For example:

- https://github.com/cloudposse - look for repos starting with `terraform-` for lots of good building blocks

## Release

```bash
git push origin master # make sure all changes are pushed
# Go to https://github.com/futurice/terraform-utils/releases and make a new one
git fetch # pull the tag created by the release
TAG="$(git tag | tail -n 1)" # figure out the latest tag
find . -name README.md | grep -v \\.terraform | xargs sed -i '.sed-bak' -E "s/\?ref=v[0-9.]+\"/?ref=$TAG\"/g" # update all "source" links in examples
find . -name README.md.sed-bak | xargs rm # remove sed's backup files
git add --patch
git commit -m "Update module versions in examples."
git push
```

## License

MIT
