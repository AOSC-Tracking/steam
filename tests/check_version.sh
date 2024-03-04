#!/bin/bash

set -eu -o pipefail

# Output in TAP format on fd 3, which is our original stdout.
# Direct commands' stdout to our original stderr.
exec 3>&1
exec >&2
echo "1..1" >&3

function detect_scriptversion()
{
	SCRIPT_VERSION=$(grep -F "$2=" "$1")
	if [[ "$SCRIPT_VERSION" ]]; then
		expr "$SCRIPT_VERSION" : ".*=\(.*\)"
	else
		echo "0"
	fi
}

function detect_changelogversion()
{
	local version epoch client rest

	epoch=
	client=

	version="$(dpkg-parsechangelog | sed -ne 's/^Version:[ 	]*//p')"
	rest="$version"

	case "$rest" in
		(*:*)
			epoch="${rest%%:*}:"
			rest="${rest#*:}"
			;;
	esac
	client="$rest"

	echo "Complete version number from debian/changelog: $version" >&2
	echo "Epoch: $epoch" >&2
	echo "Client version: $client" >&2

	if [ "x${version}" != "x${epoch}${client}" ]; then
		echo "Error: failed to reassemble version number" >&2
		exit 1
	fi

	echo "$client"
}

set -- "${1:-bin_steam.sh}" "${2:-debian/changelog}"

SCRIPT_VERSION="$(detect_scriptversion "$1" STEAMSCRIPT_VERSION)"
CHANGELOG_VERSION="$(detect_changelogversion "$2")"

if [ "$SCRIPT_VERSION" != "$CHANGELOG_VERSION" ]; then
	echo "not ok 1 - $1 is at version $SCRIPT_VERSION which doesn't match debian/changelog at $CHANGELOG_VERSION" >&3
	exit 1
fi

echo "ok 1" >&3
exit 0
