#!/bin/bash
set -e

BUCKET="s3://heroku-golang-prod/"

if [ -z "$ACCESS_KEY" -o -z "$SECRET_KEY" ]; then
  echo "ACCESS_KEY and SECRET_KEY must be set"
  exit 1
fi

S3CMD="s3cmd --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY}"

tools=(jq curl shasum s3cmd)
for tool in ${tools[@]}; do
  if ! which -s ${tool}; then
    continue
  fi
  tools=( "${tools[@]/${tool}}" )
done

if [ ${#tools} -ne 0 ]; then
  echo "The following tools are missing from \$PATH and are required to run this script"
  echo -e "\t${tools[@]}"
  echo
  exit 1
fi

# assumes we are in bin, find the directory above that
cwd="$(cd $(dirname $0); cd ..; pwd)"
jf="${cwd}/files.json"

td="${cwd}/file-cache"
mkdir -p "${td}"
cd "${td}"

echo "Syncing contents of ${BUCKET} to $(pwd)."
${S3CMD} sync --check-md5 ${BUCKET} ./

FILES=($(ls))

echo "Ensuring that we have the right versions of all files specified in files.json"
for f in $(< "${jf}" jq -r 'keys[]'); do
  if [ ! -e "${f}" ]; then
    u="$(< "${jf}" jq -r '."'${f}'".URL')"
    echo "Downloading: ${u}"
    curl -J -o "${f}" -L --retry 15 --retry-delay 2 $u
  fi

  s="$(< "${jf}" jq -r '."'${f}'".SHA')"
  if [ ${#s} -eq 40 ]; then
    sf="$(shasum "${f}" | cut -d \  -f 1)"
  else
    sf="$(shasum -a 256 "${f}" | cut -d \  -f 1)"
  fi
  if [ "${sf}" != "${s}" ]; then
    echo "SHA of file '${f}' differs from known SHA"
    echo "know SHA: ${s}"
    echo "file SHA: ${sf}"
    echo
    echo "Please erase the file and run again"
    echo "If this persists, please validate the known SHA"
    exit 1
  fi

  echo "VALID: ${f} SHA ${s}"
  echo

  FILES=(${FILES[@]/${f}})
done

if [ ${#FILES[@]} -gt 0 ]; then
  echo "EXTRA FILES IN ${td}."
  echo "Please delete these files and then run again"
  for f in ${FILES[@]}; do
    echo -e "\t${cwd}/$f"
  done
  exit 1
fi

echo "All files verified, syncing to s3"
echo
${S3CMD} sync -P --no-guess-mime-type --check-md5 --delete-removed --preserve --delete-after ./ ${BUCKET}