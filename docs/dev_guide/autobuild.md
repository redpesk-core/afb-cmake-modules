﻿# Autobuild

Applications based on the redpesk framework should have a
full build and packaging solution that is independent of the
[Yocto Project](https://www.yoctoproject.org) workflow.

You can create a script named **autobuild** to control applications
build operations.

You can write the **autobuild** script using any of the following languages:

* Makefile
* Bash
* Python

The script executes directly after applying a `chmod()` command.
The caller, which can be a Jenkins job, or an actual person,
must make the **autobuild** executable before calling it.
To facilitate direct execution, you need to start the script with a
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) sequence:

* '#!/usr/bin/make -f' for Makefile format
* '#!/usr/bin/bash' for Bash format

The calling convention is similar to the convention used in `make`.
To pass arguments, use environment variables.

**NOTE:** For Bash, an evaluation of the arguments
sets the environment variables correctly.

The following format shows the generic call:

```bash
autobuild/redpesk/autobuild <command> [ARG1="value1" [ARG2="value2" ... ]]
```

The **autobuild** script can be invoked from any directory
with all paths considered to be relative to the
script's location.
For makefile scripts, this is the usual behavior.
For Bash scripts, a `cd $(dirname $0)` command must be run at
the beginning of the script.

At build time, the following calls must be made in the following order:

1. Initialize the build environment (e.g if the application uses
   `cmake` the configure step runs CMake).

   ```bash
   autobuild/redpesk/autobuild configure CONFIGURE_ARGS="..."
   ```

2. Build the application (i.e. compile, link binaries, assembles javascript,
   and so forth).

   ```bash
   autobuild/redpesk/autobuild build BUILD_ARGS="...."
   ```

3. Create the widget package(s) in the specified destination path
   prepared by the caller.

   ```bash
   autobuild/redpesk/autobuild package PACKAGE_ARGS="..." DEST=<path-for-resulting-wgt-files>
   ```

4. Create the test widget package(s) in the specified destination path
   prepared by the caller.

   ```bash
   autobuild/redpesk/autobuild package-test PACKAGE_ARGS="..." DEST=<path-for-resulting-wgt-files>
   ```

5. Clean the built files by removing the result of the **autobuild** build.

   ```bash
   autobuild/redpesk/autobuild clean CLEAN_ARGS="..."
   ```

6. Clean everything by removing the result of the **autobuild** build
   and the **autobuild** configure.

   ```bash
   autobuild/redpesk/autobuild distclean DISTCLEAN_ARGS="..."
   ```

## Integrating **autobuild** into the Yocto Project Workflow

If you want to integrate the **autobuild** script into the Yocto Project
workflow, you need to generate the script.
To generate the script, use the `autobuild` target.

The following commands create the **autobuild** script in the
`autobuild/redpesk` directory:

```bash
mkdir -p build
cd build
cmake .. && make autobuild
```

## Available Targets

Following are the targets available from the **autobuild** script:

- **clean**: Removes all the object files and target results generated by Makefile.
- **clean-{release,debug,coverage,test}**: Removes all the object files and target results generated by Makefile for the specified build type.
- **clean-all**: Deletes the build directories for all build types.
- **distclean**: Deletes the build directories for all build types.
- **configure**: Generates the project Makefile from the `CMakeLists.txt` files for the release build type.
- **configure-{release,debug,coverage,test}**: Generates the project Makefile from the `CMakeLists.txt` files for the specified build type.
- **build**: Compiles all project targets for the release build type.
- **build-{release,debug,coverage,test}**: Compiles all project targets for the specified build type.
- **build-all**: Compiles all project targets for all specified build types.
- **package**: Builds the widget (**wgt**) package for the release build type.
- **package-{release,debug,coverage}**: Builds the widget (**wgt**) package for the specified build type.
- **package-test**: Builds the test **wgt** package.
- **package-all**: Builds the widget (**wgt**) packages for all build types.
- **install**: Installs the project into your filesystem.

Specifying the following variables lets you modify compilation behavior:

- **CLEAN_ARGS**: Variable used at **clean** time.
- **CONFIGURE_ARGS**: Variable used at **configure** time.
- **BUILD_ARGS**: Variable used at **build** time.
- **BUILD_DIR**: Build directory for release type build.
  The default value is a "build" directory in the root of the project.
- **BUILD_DIR_DEBUG**: Build directory for debug type build.
  The default value is a "build-debug" directory in the root of the project.
- **BUILD_DIR_TEST**: Build directory for test type build.
  The default value is a "build-test" directory in the root of the project.
- **BUILD_DIR_COVERAGE**: Build directory for coverage type build.
  The default value is a "build-coverage" directory in the root of the project.
- **DEST**: Directory in which to place the created ***wgt*** file(s).
  The default directory is the build root directory.

Note that the values of **BUILD_DIR_{DEBUG,TEST,COVERAGE}** are defined based on the value of **BUILD_DIR**, so this needs to be kept in mind if over-riding it and building those other widget types.

When you provide a variable, use the CMake format (i.e.
BUILD_ARGS="-DC_FLAGS='-g -O2'").
Following is an example:

```bash
./autobuild/redpesk/autobuild package DEST=/tmp
```
