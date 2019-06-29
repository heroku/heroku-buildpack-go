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
jf="${cwd}/files.json"

td="${cwd}/file-cache"
mkdir -p "${td}"
cd "${td}"

echo "Getting bucket credentials"

export AWS_ACCESS_KEY_ID="$(lpass show --sync=now --notes 9022891142845286058 | jq -r '.AccessKey | .AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(lpass show --sync=now --notes 9022891142845286058 | jq -r '.AccessKey | .SecretAccessKey')"

echo "Syncing contents of ${BUCKET} to $(pwd)."
aws s3 sync ${BUCKET} .

t=$(mktemp -d)
pipe=${t}/comms
trap "rm -f ${pipe}; pkill -P $$" EXIT
trap "" SIGWINCH

if [[ ! -p ${pipe} ]]; then
  mkfifo ${pipe}
fi

ensureFile() {
  local f="${1}"
  local u=""

  if [ ! -e "${f}" ]; then
    u="$(< "${jf}" jq -r '."'${f}'".URL')"
    curl -s -J -o "${f}" -L --retry 15 --retry-delay 2 $u 2>&1
  fi

  local sk="$(< "${jf}" jq -r '."'${f}'".SHA' 2>&1)"
  local sf=""
  if [ ${#sk} -eq 40 ]; then
    sf="$(shasum "${f}" 2>&1 | cut -d \  -f 1)"
  else
    sf="$(shasum -a 256 "${f}" 2>&1 | cut -d \  -f 1)"
  fi

  echo "${f} ${sk} ${sf}"
}

FILES=($(ls))
echo "Ensuring the correct versions of all files specified in files.json"

# TODO: do it in batches to avoid an hitting ulimit process max
for f in $(< "${jf}" jq -r 'keys[]'); do
  ensureFile ${f} >>${pipe} &
done

bad=0
while read -r f sk sf; do
  FILES=(${FILES#${f}})

  if [[ ${IGNORE[(ie)$f]} -le ${#IGNORE} ]]; then
    echo "Ignored file: ${f}"
    continue
  fi

  if [[ "${sf}" != "${sk}" ]]; then
    echo
    echo "SHA of file '${f}' differs from known SHA"
    echo "know SHA: ${sk}"
    echo "file SHA: ${sf}"
    let bad+=1
  fi

done<${pipe}

if [[ ${bad} -gt 0 ]]; then
  echo
  echo "Please erase these file(s) and run again"
  echo "If this persists, please validate the known SHA(s)"
fi

for f in ${FILES[@]}; do
  if [[ ${IGNORE[(ie)$f]} -le ${#IGNORE} ]]; then
    echo "Ignored file: ${f}"
    FILES=(${FILES#${f}})
  fi
done

if [[ ${#FILES[@]} -gt 0 ]]; then
  echo
  echo "EXTRA FILES IN ${td}."
  echo "Please delete these files or add them to files.json, then run again"
  echo "NOTE: You can ignore them by passing their names to this script"
  for f in ${FILES[@]}; do
    echo -e "\t${td}/$f"
  done
fi

if [ ${bad} -gt 0 -o ${#FILES[@]} -gt 0 ]; then
  exit 1
fi

echo "All files verified, syncing to s3"
echo
aws s3 sync --delete . ${BUCKET}
