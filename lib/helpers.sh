#!/usr/bin/env bash
set -eu
[ "${BASH_VERSINFO[0]}" -ge 3 ] && set -o pipefail

get_platform() {
	local silent=${1:-}
	local platform=""
	platform="$(uname | tr '[:upper:]' '[:lower:]')"
	local platform_check=${ASDF_STRIPE_OVERWRITE_PLATFORM:-"$platform"}

	case "$platform_check" in
		linux | darwin)
			[ -z "$silent" ] && msg "Platform '${platform_check}' supported!"
			;;
		*)
			fail "Platform '${platform_check}' not supported!"
			;;
	esac

	echo -n "$platform_check"
}

get_platform_for_download() {
	local platform=""
	platform=$(get_platform silently)

	case "$platform" in
		darwin) echo -n "mac-os" ;;
		*) echo -n "$platform" ;;
	esac
}

get_arch() {
	local arch=""
	local arch_check=${ASDF_STRIPE_OVERWRITE_ARCH:-"$(uname -m)"}
	local platform
	platform=$(get_platform silently)
	local platform_arch="${arch_check}:${platform}"
	case "${platform_arch}" in
		x86_64:darwin)
			arch="x86_64"
			;;
		aarch64:darwin)
			arch="arm64"
			;;
		x86_64:* | amd64:*)
			arch="x86_64"
			;;
		armv7l:*)
			arch="armv7l"
			;;
		aarch64:* | arm64:*)
			arch="aarch64"
			;;
		*)
			fail "Arch '${arch_check}' not supported!"
			;;
	esac

	echo -n $arch
}

get_extension() {
	echo -n "tar.gz"
}

get_filename() {
	echo -n "stripe_${ASDF_INSTALL_VERSION}_$(get_platform_for_download)_$(get_arch).$(get_extension)"
}

msg() {
	echo -e "\033[32m$1\033[39m" >&2
}

err() {
	echo -e "\033[31m$1\033[39m" >&2
}

fail() {
	err "$1"
	exit 1
}
