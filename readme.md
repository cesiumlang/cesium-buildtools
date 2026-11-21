# Cesium Build Tools

Windows scripts that install the tools and libraries for working on [Cesium](https://cesiumlang.org) that the [Cesium devkit](https://github.com/cesiumlang/devkits) does not contain.

The devkit holds the pinned Zig (the C compiler and build system), the LLVM and LLD libraries, and QBE. The Cesium compiler is built with those alone; see the [cesium](https://github.com/cesiumlang/cesium) repository. These scripts cover the rest of a Windows setup.

If your machine already has these tools, you do not need this repository.

## What it installs

| Tool | Default | Option | Where |
| --- | --- | --- | --- |
| Vulkan SDK 1.4.363.1 | on | `--vulkan`, `--no-vulkan` | `opt/vulkansdk-1.4.363.1` |
| Git for Windows (latest) | on | `--git`, `--no-git`, `--force-git` | system-wide |
| Node.js 24.22.3 | on | `--node`, `--no-node` | `opt/node-24.22.3` |
| tree-sitter CLI 0.27.2 | on | `--tree-sitter`, `--no-tree-sitter` | `opt/tree-sitter-0.27.2` |
| direnv 2.38.2 | on | `--direnv`, `--no-direnv` | `opt/direnv-2.38.2` |
| Qt 6.8.0 (`msvc2022_64`) | off | `--qt`, `--no-qt` | `opt/qt-6.8.0` |
| Miniforge (latest) | off | `--miniforge`, `--no-miniforge`, `--force-miniforge` | `opt/miniforge3` |
| CMake 4.1.1 | off | `--cmake`, `--no-cmake` | `opt/cmake-4.1.1` |
| Clang and LLVM 21.1.0 | off | `--llvm`, `--no-llvm` | `opt/llvm-21.1.0` |
| Ninja 1.13.1 | off | `--ninja`, `--no-ninja` | `bin` |
| Zig 0.17.1 | off | `--zig`, `--no-zig` | `opt/zig-0.17.1` |

Qt is off because nothing in Cesium uses it yet (which build to install is open in [#6](https://github.com/cesiumlang/cesium-buildtools/issues/6)). The last four are off because the devkit provides the Zig and LLVM that Cesium is built with, and nothing in the Cesium build uses CMake or Ninja. The LLVM here is the upstream release with Clang, not the devkit's LLVM.

Git is installed system-wide, or updated if it is already installed. Everything else stays inside this directory.

The Vulkan SDK is installed copy-only (`copy_only=1`): it sets no system `VULKAN_SDK`, `PATH` or registry entries, so an SDK installed system-wide (`C:\VulkanSDK`) is left alone, whichever is newer. `VULKAN_SDK` is set to the copy here for the script's session only. Cesium's code is to use this copy.

## Usage

Run `buildtools.bat` from a Command Prompt in this directory.

| Option | Effect |
| --- | --- |
| `--export-path` | Leave the `PATH` the script built, and `VULKAN_SDK`, in the calling shell. |
| `--echo-path` | Print that `PATH` at the end. |

The script sets `PATH` to a minimal list before it installs anything, so that libraries installed elsewhere on the machine do not affect the tools it sets up.

### Qt account

The Qt installer needs a Qt account.

1. If you do not have one, [create a Qt account](https://login.qt.io/register).
2. If you have installed Qt with this account on this computer before, Qt has saved your credentials, and no login is needed.
3. Otherwise, either let the script ask for your email and password, or put the email on the first line of a file `.qtemail` and the password on the first line of a file `.qtpassword`, both in this directory. Git ignores both files. Delete them after the script succeeds: Qt stores the credentials encrypted from then on.

## The environment: direnv and `.envrc`

The `.envrc` here puts the newest version of each tool installed in `opt/` on `PATH`: the Vulkan SDK (and `VULKAN_SDK` set to it), the tree-sitter CLI, Node.js and direnv itself. Tools that are not installed are left out. The `.envrc` of [cesium](https://github.com/cesiumlang/cesium) sources this one, so the Cesium repositories get these tools from here.

The [direnv](https://direnv.net) program loads `.envrc` files. `buildtools.bat` installs it; the download is checked against the sha256 that GitHub lists for the release asset, as direnv publishes no checksum file. Approve each `.envrc` once with `direnv allow` in its directory, and again after it changes.

### Git Bash

Add this line to `~/.bashrc`, with the path of this directory:

```sh
source /c/cesium/workspace/cesium-src/buildtools/direnv-hook.sh
```

`direnv-hook.sh` is direnv's own hook (`eval "$(direnv hook bash)"`) with two changes: it finds the direnv in `opt/` when none is on `PATH`, and it turns `PATH` back into Git Bash's form, as direnv for Windows writes it in Windows form, which Git Bash cannot use. It does nothing when no direnv is installed.

### VS Code

The [direnv extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) (`mkhl.direnv`) loads the `.envrc` of the workspace into the editor, its terminals and its extensions. It needs two things that a VS Code started from the Start menu does not have:

- **Finding direnv:** start VS Code from Git Bash with the hook above (`code .` in the workspace), so that direnv is on `PATH`, or set `direnv.path.executable` in the user settings to the `direnv.exe` in `opt/`.
- **Finding Git Bash:** direnv runs `.envrc` files with the first `bash` on `PATH`, which outside Git Bash is the WSL launcher in `System32`. Started from Git Bash, VS Code has Git's `bash` first; otherwise set `DIRENV_BASH` to `C:\Program Files\Git\usr\bin\bash.exe`, or put `bash_path = "C:/Program Files/Git/usr/bin/bash.exe"` in direnv's `direnv.toml`.

## Notes

The `tar` commands use `-mS`. `-m` does not restore modification times, which fail on exFAT storage. `-S` handles sparse files efficiently.

Only Windows is covered.
