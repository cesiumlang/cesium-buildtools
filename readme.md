# cesium-buildtools

Windows scripts that install the tools and libraries for working on [Cesium](https://cesiumlang.org) that the [Cesium devkit](https://github.com/cesiumlang/devkits) does not contain.

The devkit holds the pinned Zig (the C compiler and build system), the LLVM and LLD libraries, and QBE. The Cesium compiler is built with those alone; see the [cesium](https://github.com/cesiumlang/cesium) repository. These scripts cover the rest of a Windows setup.

If your machine already has these tools, you do not need this repository.

## What it installs

| Tool | Default | Option | Where |
| --- | --- | --- | --- |
| Qt 6.8.0 (`msvc2022_64`) | on | `--qt`, `--no-qt` | `opt/qt-6.8.0` |
| Vulkan SDK 1.4.321.1 | on | `--vulkan`, `--no-vulkan` | `opt/vulkansdk-1.4.321.1` |
| Git for Windows (latest) | on | `--git`, `--no-git`, `--force-git` | system-wide |
| Node.js 22.23.1 | on | `--node`, `--no-node` | `opt/node-22.23.1` |
| Miniforge (latest) | off | `--miniforge`, `--no-miniforge`, `--force-miniforge` | `opt/miniforge3` |
| CMake 4.1.1 | off | `--cmake`, `--no-cmake` | `opt/cmake-4.1.1` |
| Clang and LLVM 21.1.0 | off | `--llvm`, `--no-llvm` | `opt/llvm-21.1.0` |
| Ninja 1.13.1 | off | `--ninja`, `--no-ninja` | `bin` |
| Zig 0.17.1 | off | `--zig`, `--no-zig` | `opt/zig-0.17.1` |

The last four are off because the devkit provides the Zig and LLVM that Cesium is built with, and nothing in the Cesium build uses CMake or Ninja. The LLVM here is the upstream release with Clang, not the devkit's LLVM.

Git is installed system-wide, or updated if it is already installed. Everything else stays inside this directory.

## Usage

Run `buildtools.bat` from a Command Prompt in this directory.

| Option | Effect |
| --- | --- |
| `--export-path` | Leave the `PATH` the script built in the calling shell. |
| `--echo-path` | Print that `PATH` at the end. |

The script sets `PATH` to a minimal list before it installs anything, so that libraries installed elsewhere on the machine do not affect the tools it sets up.

### Qt account

The Qt installer needs a Qt account.

1. If you do not have one, [create a Qt account](https://login.qt.io/register).
2. If you have installed Qt with this account on this computer before, Qt has saved your credentials, and no login is needed.
3. Otherwise, either let the script ask for your email and password, or put the email on the first line of a file `.qtemail` and the password on the first line of a file `.qtpassword`, both in this directory. Git ignores both files. Delete them after the script succeeds: Qt stores the credentials encrypted from then on.

## Notes

The `tar` commands use `-mS`. `-m` does not restore modification times, which fail on exFAT storage. `-S` handles sparse files efficiently.

Only Windows is covered.
