# Autobuild script

The Applications based on AGL framework should have a full packaging solution,
independently of yocto workflow.

Unfortunately the build part of the Applications is only in documentation or in
yocto recipes.

The Applications build with AGL framework must be automated without any yocto
recipes.

A script named **autobuild** is used to control applications build operations.
The bbclass aglwgt.bbclass will call the **autobuild** script for all operations
and is located at the top level of the application repository.

This script could be written in one of the following languages:

* Makefile
* Bash
* Python

The script will be executed directly after a chmod() on it (this implies that the caller should make the script executable before calling it: caller could be aglwgt.bbclass, a jenkins job, a 'real' developer ...)
An appropriate shebang is required to make the script callable directly:

* '#!/usr/bin/make -f' for Makefile format,
* '#!/usr/bin/bash' for Bash
* etc.

The calling convention is close to the one from make, in particular to pass arguments through env variables. This is also easy for bash, as a simple eval on arguments will set environment variables correctly.
The generic call has the following format:

```bash
autobuild/agl/autobuild <command> [ARG1="value1" [ARG2="value2" ... ]]
```

autobuild can be invoked from any directory and all relative paths are
considered to be relative to the location of autobuild.

For makefile scripts, this is the usual behaviour.

For bash scripts, running a 'cd $(dirname $0)' at the beginning is mandatory.

At build time, the following calls must be made in the following order:

```bash
autobuild/agl/autobuild configure CONFIGURE_ARGS="..."
```

initializes the build environment (ex: if app uses cmake, the 'configure''
step will run cmake)

```bash
autobuild/agl/autobuild build BUILD_ARGS="...."
```

builds the application (compile, link binaries, assembles javascript etc.)

```bash
autobuild/agl/autobuild package PACKAGE_ARGS="..." DEST=<path for resulting wgt
file(s)>
```

creates the widget package(s) in the specified destination path prepared by the
caller

```bash
autobuild/agl/autobuild package-test PACKAGE_ARGS="..." DEST=<path for resulting wgt
file(s)>
```

creates the test widget package(s) in the specified destination path prepared by the
caller

```bash
autobuild/agl/autobuild clean CLEAN_ARGS="..."
```

clean the built files (removes the result of autobuild build)

```bash
autobuild/agl/autobuild distclean DISTCLEAN_ARGS="..."
```

clean everything (removes the result of autobuild build + autobuild configure)

## Generation

To be integrated in the Yocto build workflow you have to generate `autobuild`
scripts using _autobuild_ target.

To generate those scripts proceeds:

```bash
mkdir -p build
cd build
cmake .. && make autobuild
```

You should see _autobuild/agl/autobuild_ file now.

## Available targets

Here are the available targets available from _autobuild_ scripts:

- **clean** : clean build directory from object file and targets results.
- **distclean** : delete build directory
- **configure** : generate project Makefile from CMakeLists.txt files.
- **build** : compile all project targets.
- **package** : build and output a wgt package.
- **package-test** : build and output the test wgt as well as the normal wgt
 package.
- **install** : install the project in your filesystem

You can specify variables that modify the behavior of compilation using
the following variables:

- **CLEAN_ARGS** : Variable used at **clean** time.
- **DISTCLEAN_ARGS** : Variable used at **distclean** time.
- **CONFIGURE_ARGS** : Variable used at **configure** time.
- **BUILD_ARGS** : Variable used at **build** time.
- **DEST** : Directory where to output ***wgt*** file (default at build root
 directory).

Variable as to be in CMake format. (ie: BUILD_ARGS="-DC_FLAGS='-g -O2'")

Usage example:

```bash
./autobuild/wgt/autobuild package DEST=/tmp
```
