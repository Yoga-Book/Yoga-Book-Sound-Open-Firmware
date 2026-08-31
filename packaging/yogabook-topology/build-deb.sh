#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -Eeuo pipefail

topology_file=${1:?usage: build-deb.sh TOPOLOGY_FILE OUTPUT_DIRECTORY}
output_directory=${2:?usage: build-deb.sh TOPOLOGY_FILE OUTPUT_DIRECTORY}
expected_sha256=746962d80115e3b9b0b2fbe44673b4e3acef5f06f7914baf235a5a652e8be09c
package_epoch=${SOURCE_DATE_EPOCH:-1787682896}

[[ $package_epoch =~ ^[0-9]+$ ]] || {
	echo "ERROR: SOURCE_DATE_EPOCH must be a non-negative integer" >&2
	exit 1
}

[[ -f $topology_file ]] || {
	echo "ERROR: topology not found: $topology_file" >&2
	exit 1
}

actual_sha256=$(sha256sum "$topology_file" | awk '{print $1}')
[[ $actual_sha256 == "$expected_sha256" ]] || {
	echo "ERROR: topology checksum mismatch: $actual_sha256" >&2
	exit 1
}

temporary_root=${TMPDIR:-/tmp}
build_directory=$(mktemp -d "$temporary_root/sof-topology-yogabook.XXXXXX")
cleanup() {
	rm -rf -- "$build_directory"
}
trap cleanup EXIT

package_root=$build_directory/root
script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
install -D -m 0644 "$topology_file" \
	"$package_root/usr/lib/firmware/intel/sof-tplg/sof-cht-rt5677.tplg"
install -D -m 0644 "$script_directory/copyright" \
	"$package_root/usr/share/doc/sof-topology-yogabook/copyright"
install -d -m 0755 "$package_root/usr/share/doc/sof-topology-yogabook"
gzip -n -9 -c "$script_directory/changelog" > \
	"$package_root/usr/share/doc/sof-topology-yogabook/changelog.gz"
chmod 0644 "$package_root/usr/share/doc/sof-topology-yogabook/changelog.gz"
install -D -m 0644 "$script_directory/control" "$package_root/DEBIAN/control"
(cd "$package_root" && find usr -type f -print0 | sort -z | xargs -0 md5sum) \
	>"$package_root/DEBIAN/md5sums"
find "$package_root" -exec touch --date="@$package_epoch" {} +
mkdir -p "$output_directory"
SOURCE_DATE_EPOCH=$package_epoch dpkg-deb --root-owner-group --build "$package_root" \
	"$output_directory/sof-topology-yogabook_1.0.1_all.deb"
