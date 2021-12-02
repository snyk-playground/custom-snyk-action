#!/bin/bash
set -e

# This script takes two positional arguments. The first is the version of Snyk to install.
# This can be a standard version (ie. v1.390.0) or it can be latest, in which case the
# latest released version will be used.
#
# The second argument is the platform, in the format used by the `runner.os` context variable
# in GitHub Actions. Note that this script does not currently support Windows based environments.
#
# As an example, the following would install the latest version of Snyk for GitHub Actions for
# a Linux runner:
#
#     ./snyk-setup.sh latest Linux
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 2 ] || die "Setup Snyk requires two argument, $# provided"

echo "Installing the $1 version of Snyk on $2"

if [ "$1" == "latest" ]; then
    SNYK_VERSION=$(curl -s -L"https://static.snyk.io/cli/latest/version")
else
    SNYK_VERSION="${1}"
fi

# strips version down to A.B.C
SNYK_VERSION="${SNYK_VERSION##*v}"
SNYK_VERSION="${SNYK_VERSION%\"*}"

case "$2" in
    Linux)
        PLATFORM=linux
        SHA_COMMAND="sha256sum"
        ;;
    Windows)
        die "Windows runner not currently supported"
        ;;
    macOS)
        PLATFORM=macos
        SHA_COMMAND="shasum"
        ;;
    *)
        die "Invalid running specified: $2"
esac

curl -O -L "https://static.snyk.io/cli/v${SNYK_VERSION}/snyk-${PLATFORM}"
curl -O -L "https://static.snyk.io/cli/v${SNYK_VERSION}/snyk-${PLATFORM}.sha256"

if "${SHA_COMMAND}" -c snyk-${PLATFORM}.sha256; then
    echo "snyk-${PLATFORM} binary checksum passed, Installed"
    chmod +x snyk-${PLATFORM}
    sudo mv snyk-${PLATFORM} /usr/local/bin
else
    echo "Snyk binary failed to install"
    exit 1
fi


{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION=\"setup \(${2}\)\"
    echo eval /usr/local/bin/snyk-${PLATFORM} \$@
} > snyk

chmod +x snyk
sudo mv snyk /usr/local/bin

