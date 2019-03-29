#!/bin/bash

for file in $(find ./* -name README.md); do
  perl -i -p0e "s/terraform-docs:begin.*?terraform-docs:end/terraform-docs:begin -->\n$(terraform-docs markdown table $(dirname $file) | sed 's#/#\\/#g')\n<\!-- terraform-docs:end/s" "$file"
done
