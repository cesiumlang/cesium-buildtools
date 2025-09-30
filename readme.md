# cesium-buildtools

A collection of scripts to automate building the [Cesium](https://cesiumlang.org) compiler from source.

Currently, this is only written for Windows, but eventually it will also support other platforms.

The scripts in this repo address<!-- cloning the [Cesium source repo](https://github.com/cesiumlang/cesium.git) (as a submodule),  -->
downloading portable versions of CMake, Ninja, LLVM, etc., as necessary.
<!-- and then checks out a known good commit of Cesium to do the build.   -->
It also locally sets `$PATH` to a minimal set of values due to issues with other libraries installed on the machine polluting the build.

## Usage

<!-- 1. Install the [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/). -->
1. If you do not already have one, [create a Qt account](https://login.qt.io/register)
2. If you have successfully installed Qt with this account before on this computer, you do not need to do the login steps since your credentials are saved by Qt after your first successful login.
3. If you have not logged into Qt from an installer before, create a file in the root of this repo called `.qtemail` and put your Qt account email on the first line.  Also create a file in the root of this repo called `.qtpassword` and put your Qt account password on the first line in plaintext.  Note that these files are optional, and the absence of either one will prompt you for the missing information interactively.  After the script completes successfully, you may delete these files since the credentials will be stored by Qt encrypted.
4. Run `get-buildtools`, which will set up the build environment.

## Background

These scripts are initially developed to simply codify the steps to get a build environment, ensure repeatability, and, perhaps, easing future CI builds or other automation.

I intentionally do not set `@echo off` for the Windows scripts because all of this is still very much in development, and it is a useful debugging tool to see exactly what commands go with what terminal outputs or see what variable expansions and substitutions are happening.

Tar commands have the additional `-mS` flags added.  This is because I tried to compile on exFAT flash storage, which doesn't fully support POSIX-like file attributes.  The `-m` prevents trying to update the last modified time, while `-S` allows it to handle sparse files more efficiently (which seems to be important due to how the devkit tar file is constructed I suppose; this may not actually be necessary, but did seem to help performance)
