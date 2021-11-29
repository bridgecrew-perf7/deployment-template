#!/bin/bash

public_dir_name=deployments

echo "Creating public hosting folder: ${public_dir_name}"
mkdir -p $public_dir_name

# Creating subfolders with branch name and copying all files.
create_subfolders() {
  branch=$1

  echo "Creating folder: ${branch}";

  git checkout $branch
  mkdir -p $public_dir_name/$branch

  find . -maxdepth 1 \
    ! -name . \
    ! -name .git \
    ! -name $public_dir_name \
    -exec cp -r -t $public_dir_name/$branch {} +
}

# Generating HTML list item
create_li_tag() {
  branch=$1

  echo "<li>
    <a href=\"/${branch}\">${branch}</a>
  </li>"
}

html_li_tags=""
while read -r remote_branch; do
  echo "Branch: ${remote_branch}";
  branch=$(echo "${remote_branch}" | cut -d'/' -f3)

  create_subfolders $branch
  html_li_tags+=$(create_li_tag $branch)
done < <(git branch -a | grep 'remotes')

git checkout main

HTML_LI_TAGS=$html_li_tags envsubst < .deployment.template.html >> $public_dir_name/index.html
