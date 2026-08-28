#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
set -Eeuo pipefail

package_file=${1:?usage: check-package.sh PACKAGE_FILE}
expected_sha256=746962d80115e3b9b0b2fbe44673b4e3acef5f06f7914baf235a5a652e8be09c

[[ $(dpkg-deb -f "$package_file" Package) == sof-topology-yogabook ]]
[[ $(dpkg-deb -f "$package_file" Version) == 1.0.0 ]]
[[ $(dpkg-deb -f "$package_file" Architecture) == all ]]

temporary_root=${TMPDIR:-/tmp}
extract_directory=$(mktemp -d "$temporary_root/sof-topology-yogabook-check.XXXXXX")
cleanup() {
	rm -rf -- "$extract_directory"
}
trap cleanup EXIT

dpkg-deb --extract "$package_file" "$extract_directory"
installed_file=$extract_directory/usr/lib/firmware/intel/sof-tplg/sof-cht-rt5677.tplg
[[ -f $installed_file ]]
[[ $(sha256sum "$installed_file" | awk '{print $1}') == "$expected_sha256" ]]

echo "Yoga Book SOF topology package: PASS ($package_file)"
