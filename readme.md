# cesium-buildtools

A collection of scripts to automate building the [Cesium](https://cesiumlang.org) compiler from source.

Currently, this is only written for Windows, but eventually it will also support other platforms.

The scripts in this repo address<!-- cloning the [Cesium source repo](https://github.com/cesiumlang/cesium.git) (as a submodule),  -->
downloading portable versions of CMake, Ninja, and LLVM as necessary.
<!-- and then checks out a known good commit of Cesium to do the build.   -->
It also locally sets `$PATH` to a minimal set of values due to issues with other libraries installed on the machine polluting the build.

## Usage

1. Install the [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/).
2. Run `get-buildtools`, which will set up the build environment.

## Background

These scripts are initially developed to simply codify the steps to get a build environment, ensure repeatability, and, perhaps, easing future CI builds or other automation.

I intentionally do not set `@echo off` for the Windows scripts because all of this is still very much in development, and it is a useful debugging tool to see exactly what commands go with what terminal outputs or see what variable expansions and substitutions are happening.

Tar commands have the additional `-mS` flags added.  This is because I tried to compile on exFAT flash storage, which doesn't fully support POSIX-like file attributes.  The `-m` prevents trying to update the last modified time, while `-S` allows it to handle sparse files more efficiently (which seems to be important due to how the devkit tar file is constructed I suppose; this may not actually be necessary, but did seem to help performance)
