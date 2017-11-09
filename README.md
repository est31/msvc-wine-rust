## Download MSVC build tools and the Windows SDK for Rust development on GNU/Linux

This script downloads and extracts the needed components of the Visual Studio 2017 build tools and the Windows SDK,
so that Rust toolchains can target the platform.

Note that these are the very latest build tools and the latest SDK. If you are okay with the older 2015 build tools,
you should download the [enterprise WDK](https://developer.microsoft.com/en-us/windows/hardware/license-terms-enterprise-wdk-1703) instead,
it contains all the needed files.

Requirements:

* 7z executable
* GNU/Linux with GNU Bash installed. May also work on Mac or other BSD's, but I haven't tried.
* Bleeding edge Wine from git that supports _memicmp_l. Wine 2.21 (not released yet at the moment of writing this) should have support. Compilation is explained below.
* 32 bit Wine with .Net installed -- can be a completely separate, second, Wine installation/toolchain

The bleeding edge Wine is required to run the linker, while the .Net requirement is because of [lessmsi](http://lessmsi.activescott.com/).

Once [there is support by msitools](https://bugzilla.gnome.org/show_bug.cgi?id=789020) for the msi files involved,
the requirement on the second toolchain will be replaced by a requirement on [msitools](https://wiki.gnome.org/msitools).

Compilation of any C/C++ dependencies is not supported.

## Compiling Wine with _memicmp_l support

Wine 2.20 doesn't support memicmp_l, but a patch with support has is available
on the git master branch. It will most likely be included in the 2.21 release.
So if you have 2.21 or later you can safely skip this compilation step!

First, obtain the dev-dependencies of wine (assuming Ubuntu here, but other Debian like distros may work as well).

```bash
sudo apt build-dep wine64-development
```

Then, obtain the wine source code:

```bash
git clone git://source.winehq.org/git/wine.git
cd wine
git checkout d045a5ea29aada4182689cd80f4b57a694322b42 -b memicmp_l
```

Now create a build directory, and execute the build:

```bash
mkdir /path/to/wine-memicmp-l-build
cd /path/to/wine-memicmp-l-build
/path/to/wine/source/configure --prefix=/path/to/wine-memicmp-l-build --enable-win64
make -j 8
```

Now, if things went well, you should have a binary `wine` inside that build directory. That's the executable you need to point the `WINE_EXEC` environment variable at when running the linker.

## Setup

First, execute `get.sh`, and accept the licensing terms.
If you have accepted, `get.sh` will download files to the `dl/` folder and extract them into the `extracted/` folder.

Then put the following into your `~/.cargo/config`:

```toml
[target.x86_64-pc-windows-msvc]
linker = "/path/to/msvc-wine-rust/linker-scripts/linkx64.sh"

[target.i686-pc-windows-msvc]
linker = "/path/to/msvc-wine-rust/linker-scripts/linkx32.sh"
```

Then go to your favourite Rust project and compile it e.g. with:

```
cargo build --release --target x86_64-pc-windows-msvc
```

As the wine executable might not be in your `$PATH`, you can also override it manually:

```
WINE_EXEC=/path/to/wine cargo build --release --target x86_64-pc-windows-msvc
```

Same applies for `get.sh` as well -- if the Wine installation with 32 bit and .Net support is not in your `$PATH`,
you can invoke `WINE_EXEC=/path/to/wine/with/dotnet ./get.sh`.

## License

Licensed under Apache 2 or MIT (at your option). For details, see the [LICENSE](LICENSE) file.

### License of your contributions

Unless you explicitly state otherwise, any contribution intentionally submitted for
inclusion in the work by you, as defined in the Apache-2.0 license,
shall be dual licensed as above, without any additional terms or conditions.
