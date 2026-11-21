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

Start VS Code from a shell that has the environment: `code .` in the workspace, from a Git Bash with the hook above. The editor, its terminals and its extensions then have what the `.envrc` files give.

The [direnv extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) (`mkhl.direnv`) is not recommended on Windows (emanspeaks, 2026-11-21). Tried with version 0.17.0 and direnv 2.37.1, it needs three settings before it starts at all, and then asks to allow the `.envrc` again and again:

- **Settings:** `direnv.path.executable` must name a direnv whose name ends in `.exe`; and `direnv.extraEnv` must give `HOME` (Windows sets none, and direnv stops with "couldn't find a configuration directory") and `DIRENV_BASH` (the first `bash` on a Windows `PATH` is the WSL launcher in `System32`).
- **The loop:** VS Code names the folder with a lowercase drive letter (`c:\...`), and the extension runs direnv there. direnv looks an `.envrc` up among the approved ones by its path as it is written, so it looks for `c:\...\.envrc`; the extension's "Allow" records `C:\...\.envrc`. The approval is never found. `direnv allow`, run in a process whose working directory is written with the lowercase letter, records the one that is looked for, and has to be run again after every change to an `.envrc`.

The `.envrc` files here use only what bash has built in, so they load whatever `PATH` direnv is started with: a bash started by the extension has no `dirname`, `sort` or `tail`.

## Notes

The `tar` commands use `-mS`. `-m` does not restore modification times, which fail on exFAT storage. `-S` handles sparse files efficiently.

Only Windows is covered.
