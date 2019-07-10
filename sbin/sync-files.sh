#!/usr/bin/env zsh
set -e

IGNORE=($*)

BUCKET="s3://heroku-golang-prod/"

tools=(jq curl shasum aws lpass)
for tool in ${tools[@]}; do
  if ! which -s ${tool} >>&/dev/null; then
    continue
  fi
  tools=(${tools#${tool}})
done

if [ ${#tools} -ne 0 ]; then
  echo "The following tools are missing from \$PATH and are required to run this script"
  echo -e "\t${tools[@]}"
  echo
  exit 1
fi

# assumes we are in bin, find the directory above that
cwd="$(cd $(dirname $0); cd ..; pwd)"
filesJSON="${cwd}/files.json"

cache="${cwd}/file-cache"
mkdir -p "${cache}"
cd "${cache}"

echo "Getting bucket credentials"
source "${cwd}/sbin/aws.sh"

echo "Syncing contents of ${BUCKET} to $(pwd)."
args=()
if [[ ${#IGNORE} -gt 0 ]]; then
  for file in ${IGNORE[@]}; do
    args+=(--exclude ${file})
  done
fi
aws s3 sync ${args} ${BUCKET} .

pipe=$(mktemp -d)/comms
trap "rm -f ${pipe}; pkill -P $$" EXIT
trap "" SIGWINCH

if [[ ! -p ${pipe} ]]; then
  mkfifo ${pipe}
fi

ensureFile() {
  local file="${1}"
  local url=""

  if [ ! -e "${file}" ]; then
    url="$(< "${filesJSON}" jq -r '."'${file}'".URL')"
    curl -s -J -o "${file}" -L --retry 15 --retry-delay 2 ${url} 2>&1
  fi

  local knownSHA="$(< "${filesJSON}" jq -r '."'${file}'".SHA' 2>&1)"
  local fileSHA=""
  if [ ${#knownSHA} -eq 40 ]; then
    fileSHA="$(shasum "${file}" 2>&1 | cut -d \  -f 1)"
  else
    fileSHA="$(shasum -a 256 "${file}" 2>&1 | cut -d \  -f 1)"
  fi

  echo "${file} ${knownSHA} ${fileSHA}"
}

FILES=($(ls))
echo "Ensuring the correct versions of all files specified in files.json"

# TODO: do it in batches to avoid an hitting ulimit process max
for file in $(< "${filesJSON}" jq -r 'keys[]'); do
  ensureFile ${file} >>${pipe} &
done

bad=0
while read -r file knownSHA fileSHA; do
  FILES=(${FILES#${file}})

  if [[ ${IGNORE[(ie)$file]} -le ${#IGNORE} ]]; then
    echo "Ignored file: ${file}"
    continue
  fi

  if [[ "${fileSHA}" != "${knownSHA}" ]]; then
    echo
    echo "SHA of file '${file}' differs from known SHA"
    if [[ -z "${fileSHA}" ]]; then
      echo "known SHA: "  # knownSHA was actually empty making what was read "$file $fileSHA"
      echo "file SHA: ${knownSHA}"
    else
      echo "known SHA: ${knownSHA}"
      echo "file SHA: ${fileSHA}"
    fi
    let bad+=1
  fi

done<${pipe}

if [[ ${bad} -gt 0 ]]; then
  echo
  echo "Please erase these file(s) and run again"
  echo "If this persists, please validate the known SHA(s)"
fi

for file in ${FILES[@]}; do
  if [[ ${IGNORE[(ie)$file]} -le ${#IGNORE} ]]; then
    echo "Ignored file: ${file}"
    FILES=(${FILES#${file}})
  fi
done

if [[ ${#FILES[@]} -gt 0 ]]; then
  echo
  echo "EXTRA FILES IN ${cache}."
  echo "Please delete these files or add them to files.json, then run again"
  echo "NOTE: You can ignore them by passing their names to this script"
  for f in ${FILES[@]}; do
    echo -e "\t${cache}/$f"
  done
fi

if [ ${bad} -gt 0 -o ${#FILES[@]} -gt 0 ]; then
  exit 1
fi

echo "All files verified, syncing to s3"
echo
args=(--delete)
args+=(--acl public-read)
if [[ ${#IGNORE} -gt 0 ]]; then
  for file in ${IGNORE[@]}; do
    args+=(--exclude ${file})
  done
fi
aws s3 sync ${args} . ${BUCKET}
