#!/bin/sh

# A posix install example

set -eou pipefail

SNYK_BUILD="linux"

SNYK_LATEST=$(curl -s -L "https://static.snyk.io/cli/latest/version")

SNYK_PATH="${PWD}/snyk"

curl -O -s -L "https://static.snyk.io/cli/v${SNYK_LATEST}/snyk-${SNYK_BUILD}"
curl -O -s -L "https://static.snyk.io/cli/v${SNYK_LATEST}/snyk-${SNYK_BUILD}.sha256"

if sha256sum -c "snyk-${SNYK_BUILD}.sha256"; then
  echo "Snyk binary checksum passed, updating"
  mv "snyk-${SNYK_BUILD}" "${SNYK_PATH}"
  chmod +x "${SNYK_PATH}"
  SNYK_VERSION=$("${SNYK_PATH}" --version | cut -d' ' -f1)
  rm "snyk-${SNYK_BUILD}.sha256"
else
  echo "Snyk Binary Checksum Failed!"
  exit 1
fi


if [ "${SNYK_VERSION}" = "${SNYK_LATEST}" ]; then
    echo "Snyk installed at ${SNYK_PATH} with latest version: ${SNYK_VERSION}"
else
    echo "Snyk didn't install properly"
    exit 1
fi

echo "::set-output name=snyk_path::${SNYK_PATH}"