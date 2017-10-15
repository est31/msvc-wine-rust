#!/bin/bash

set -e

wine_exec=${WINE_EXEC:=wine}

cd "$( dirname "${BASH_SOURCE[0]}" )"

function dl_url() {
	wget -P dl -nc $1
}

function dl() {
	dl_url https://download.visualstudio.microsoft.com/download/pr/$1
}

function download() {
	mkdir -p dl

	# Obtain lessmsi

	dl_url https://github.com/activescott/lessmsi/releases/download/v1.6.1/lessmsi-v1.6.1.zip

	# Obtain the tools

	dl 11436965/d360453cfd1f34b6164afe24d1edc4b2/microsoft.visualcpp.tools.hostx86.targetx64.vsix
	dl 11436915/aff3326c9d694e3f92617dcb3827e9f7/microsoft.visualcpp.tools.hostx86.targetx86.vsix
	dl 11437778/36f212a9738f5888c73f46e0d25c1db7/microsoft.visualcpp.tools.hostx64.targetx64.vsix
	dl 11437792/ade27216a21adb0795b71f57d979f758/microsoft.visualcpp.tools.hostx64.targetx86.vsix

	# Obtain the SDK Desktop libs

	dl 100107594/d176ecb4240a304d1a2af2391e8965d4/Windows%20SDK%20Desktop%20Libs%20x64-x86_en-us.msi
	dl 100107594/d176ecb4240a304d1a2af2391e8965d4/58314d0646d7e1a25e97c902166c3155.cab

	dl 100107594/d176ecb4240a304d1a2af2391e8965d4/Windows%20SDK%20Desktop%20Libs%20x86-x86_en-us.msi
	dl 100107594/d176ecb4240a304d1a2af2391e8965d4/53174a8154da07099db041b9caffeaee.cab

	# Obtain the SDK store app libs

	dl 100120735/59fd0bbd7af55837187bbf971d485bec/Windows%20SDK%20for%20Windows%20Store%20Apps%20Libs-x86_en-us.msi
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/05047a45609f311645eebcac2739fc4c.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/0b2a4987421d95d0cb37640889aa9e9b.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/13d68b8a7b6678a368e2d13ff4027521.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/463ad1b0783ebda908fd6c16a4abfe93.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/5a22e5cde814b041749fb271547f4dd5.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/ba60f891debd633ae9c26e1372703e3c.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/e10768bb6e9d0ea730280336b697da66.cab
	dl 100120735/59fd0bbd7af55837187bbf971d485bec/f9b24c8280986c0683fbceca5326d806.cab

	# Obtain the CRT libs

	dl 10933200/2185d21eb8245d7c79a5e74ade047c1a/microsoft.visualcpp.crt.x64.store.vsix
	dl 10933295/e2c969895aaa4974d7d5819e9ee4cdc4/microsoft.visualcpp.crt.x86.store.vsix

	# Obtain the UCRT libs

	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/Universal%20CRT%20Headers%20Libraries%20and%20Sources-x86_en-us.msi
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/16ab2ea2187acffa6435e334796c8c89.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/2868a02217691d527e42fe0520627bfa.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/6ee7bbee8435130a869cf971694fd9e2.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/78fa3c824c2c48bd4a49ab5969adaaf7.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/7afc7b670accd8e3cc94cfffd516f5cb.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/80dcdb79b8a5960a384abe5a217a7e3a.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/96076045170fe5db6d5dcf14b6f6688e.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/a1e2a83aa8a71c48c742eeaff6e71928.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/b2f03f34ff83ec013b9e45c7cd8e8a73.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/beb5360d2daaa3167dea7ad16c28f996.cab
	dl 100110573/1a91d4d5ac358c110e7c874fd8c07239/f9ff50431335056fb4fbac05b8268204.cab
}

# Extracts the given .vsix files
function extract_vsix() {
	mkdir -p $1
	for f in ${@:2}; do
		unzip $f 'Contents/*' -d $1
	done
	cp -Ra $1/Contents/. $1
	rm -rf $1/Contents
}

# Extracts a given msi file
function extract_msi() {
	mkdir -p $1
	$wine_exec extracted/lessmsi/lessmsi.exe x "$2" "$1\\"
	cp -RT $1/SourceDir/* $1
	rm -rf $1/SourceDir
}

function extract() {
	mkdir -p extracted

	# Extract lessmsi
	mkdir -p extracted/lessmsi
	unzip dl/lessmsi-v1.6.1.zip -d extracted/lessmsi

	# Extract the tools
	extract_vsix extracted/tools dl/microsoft.visualcpp.tools.*.vsix

	# Extract the SDK
	mkdir -p extracted/sdk
	extract_vsix extracted/sdk dl/microsoft.visualcpp.crt.*.vsix
	extract_msi extracted/sdk "dl/Windows SDK Desktop Libs x64-x86_en-us.msi"
	extract_msi extracted/sdk "dl/Windows SDK Desktop Libs x86-x86_en-us.msi"
	extract_msi extracted/sdk "dl/Windows SDK for Windows Store Apps Libs-x86_en-us.msi"
	extract_msi extracted/sdk "dl/Universal CRT Headers Libraries and Sources-x86_en-us.msi"
}

case "$1" in
"download")
	# Download the build tools and the SDK libs
	download

	# Verify the downloaded files
	sha256sum --quiet --check dl.sha256 || exit 2

	# NOTE: Create the file using:
	# sha256sum dl/* > dl.sha256
	;;
"extract")
	# Extract everything
	mkdir -p extracted
	extract
	;;
*)
	# Extract, then download:
	download
	sha256sum --quiet --check dl.sha256 || exit 2
	extract
	;;
esac






echo "Downloaded and extracted successfully"
