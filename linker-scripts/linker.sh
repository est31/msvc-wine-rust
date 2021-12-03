#!/usr/bin/env bash

extracted_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../extracted && pwd )"

# Legal values for host/target are: x64, x86
host=x64
target=${TARGET_ARCH:=x64}

wine_exec=${WINE_EXEC:=wine}

tools_version=14.11.25503
sdk_version=10.0.16299.0

link_exec=$extracted_dir/tools/VC/Tools/MSVC/$tools_version/bin/Host$host/$target/link.exe

sdk_libs=$extracted_dir/sdk/10/Lib/$sdk_version/um/$target/
ucrt_libs=$extracted_dir/sdk/10/Lib/$sdk_version/ucrt/$target/
crt_libs=$extracted_dir/sdk/VC/Tools/MSVC/$tools_version/lib/$target/

echo "Running the linker wrapper."

function make_wine_path() {
	v=`realpath "$1"`
	$wine_exec winepath -w "$v"
}

export LIB="`make_wine_path \"$sdk_libs\"`;`make_wine_path \"$ucrt_libs\"`;`make_wine_path \"$crt_libs\"`"

echo $LIB

#args="/VERBOSE"
args=""
for v in $@; do
	num_of_slash=`tr -dc '/' <<< "$v" | wc -c`
	num_of_colon=`tr -dc ':' <<< "$v" | wc -c`
	if [ "$num_of_slash" -gt "1" ] && [ "$num_of_colon" -eq "0" ]; then
		v=`$wine_exec winepath -w $v`
	fi
	args="$args $v"
done

$wine_exec $link_exec $args
