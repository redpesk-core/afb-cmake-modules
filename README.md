AGL CMake template
==================

Files used to build an application, or binding, project with the
AGL Application Framework.

To build your AGL project using these templates, you have to install
them within your project and adjust compilation option in `config.cmake`.
For technical reasons, you also have to specify **cmake** target in
sub CMakeLists.txt installed. Make a globbing search to find source files
isn't recommended now to handle project build especially in a multiuser
project because CMake will not be aware of new or removed source files.

You'll find simple usage example for different kind of target under the `examples` folder.
More advanced usage can be saw with the [low-level-can-service](https://gerrit.automotivelinux.org/gerrit/apps/low-level-can-service)
which mix external libraries, binding.

Typical project architecture
---------------------------------

A typical project architecture would be :

```tree
<project-root-path>
│
├── conf.d/
│   ├── app-templates/
│   │   ├── cmake/
│   │   │   ├── config.cmake.sample
│   │   │   ├── export.map
│   │   │   └── macros.cmake
│   │   ├── deb/
│   │   │   └── config.deb.in
│   │   ├── rpm/
│   │   │   └── config.spec.in
│   │   └── wgt/
│   │       ├── config.xml.in
│   │       ├── config.xml.in.sample
│   │       ├── icon-default.png
│   │       ├── icon-html5.png
│   │       ├── icon-native.png
│   │       ├── icon-qml.png
│   │       └── icon-service.png
│   ├── packaging/
│   │   ├── config.xml
│   │   ├── config.spec
│   │   └── config.deb
│   ├── autobuild/
│   │   ├── agl
│   │   │   └── autobuild.sh
│   │   ├── linux
│   │   │   └── autobuild.sh
│   │   └── windows
│   │       └── autobuild.bat
│   ├── README.md
│   └── config.cmake
├── <libs>
├── <target>
├── <target>
└── <target>
```

| # | Parent | Description |
| - | -------| ----------- |
| \<root-path\> | - | Path to your project. Hold master CMakeLists.txt and general files of your projects. |
| conf.d | \<root-path\> | Git submodule to app-templates AGL repository which provides CMake helpers macros library, and build scripts. config.cmake is a copy of config.cmake.sample configured for the projects. |
| app-templates | conf.d | Holds examples files and cmake macros used to build packages |
| packaging | conf.d | Contains output files used to build packages. |
| autobuild | conf.d | Scripts used to build packages the same way for differents platforms. |
| \<libs\> | \<root-path\> | External dependencies libraries. This isn't to be used to include header file but build and link statically specifics libraries. | Library sources files. Can be a decompressed library archive file or project fork. |
| \<target\> | \<root-path\> | A target to build, typically library, executable, etc. |

Usage
------

To use these templates files on your project just install the reference files using **git submodule** then use `config.cmake` file to configure your project specificities :

```bash
git submodule add https://gerrit.automotivelinux.org/gerrit/apps/app-templates conf.d/app-templates
```

Specify manually your targets, you should look at samples provided in this
repository to make yours. Then when you are ready to build, using `autobuild`
that will wrap CMake build command:

```bash
./conf.d/app-templates/autobuild/agl/autobuild.mk package
```

Or with the classic way :

```bash
mkdir -p build
cd build
cmake .. && make
```

### Create a CMake target

For each target part of your project, you need to use ***PROJECT_TARGET_ADD***
to include this target to your project, using it make available the cmake
variable ***TARGET_NAME*** until the next ***PROJECT_TARGET_ADD*** is invoked
with a new target name. Be aware that ***populate_widget*** macro will also use
***PROJECT_TARGET_ADD*** so ***TARGET_NAME*** will change after using
***populate_widget*** macro.

So, typical usage defining a target is:

```cmake
PROJECT_TARGET_ADD(SuperExampleName) --> Adding target to your project

add_executable/add_library(${TARGET_NAME}.... --> defining your target sources

SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES.... --> fit target properties for macros usage

INSTALL(TARGETS ${TARGET_NAME}....

populate_widget() --> add target to widget tree depending upon target properties
```

### Build a widget

#### config.xml.in file

To build a widget you need to configure file _config.xml_. This repo
provide a simple default file _config.xml.in_ that will be configured using the
variable set in _config.cmake_  file.

> ***CAUTION*** : The default file is only meant to be use for a
> simple widget app, more complicated ones which needed to export
> their api, or ship several app in one widget need to use the provided
> _config.xml.in.sample_ which had all new Application Framework
> features explained and examples.

#### Using cmake template macros

To leverage all macros features, you have to specify ***properties*** on your
targets. Some macros will not works without specifying which is the target type.

As the type is not always specified for some custom targets, like an ***HTML5***
application, macros make the difference using ***LABELS*** property.

Example:

```cmake
SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
		LABELS "HTDOCS"
		OUTPUT_NAME dist.prod
	)
```

If your target output is not named as the ***TARGET_NAME***, you need to specify
***OUTPUT_NAME*** property that will be used by the ***populate_widget*** macro.

Use the ***populate_widget*** macro as latest statement of your target
definition. Then at the end of your project definition you should use the macro
***build_widget*** that make an archive from the populated widget tree using the
`wgtpkg-pack` Application Framework tools.

Macro reference
--------------------

### PROJECT_TARGET_ADD

Typical usage would be to add the target to your project using macro
`PROJECT_TARGET_ADD` with the name of your target as parameter.

Example:

```cmake
PROJECT_TARGET_ADD(low-can-demo)
```

> ***NOTE***: This will make available the variable `${TARGET_NAME}`
> set with the specificied name. This variable will change at the next call
> to this macros.

### project_subdirs_add

This macro will search in all subfolder any `CMakeLists.txt` file. If found then
it will be added to your project. This could be use in an hybrid application by
example where the binding lay in a sub directory.

Usage :

```cmake
project_subdirs_add()
```

You also can specify a globbing pattern as argument to filter which folders will be looked for.

To filter all directories that begin with a number followed by a dash the anything:

```cmake
project_subdirs_add("[0-9]-*")
```

### project_targets_populate

Macro use to populate widget tree. To make this works you have to specify some properties to your target :

* LABELS : specify *BINDING*, *HTDOCS*, *EXECUTABLE*, *DATA*
* PREFIX : must be empty **""** when target is a *BINDING* else default prefix *lib* will be applied
* OUTPUT_NAME : Name of the output file generated, useful when generated file name is different from `${TARGET_NAME}`

Always specify  `populate_widget()` macro as the last statement, especially if
you use ${TARGET_NAME} variable. Else variable will be set at wrong value with
the **populate_** target name.

Usage :

```cmake
project_targets_populate()
```

### project_package_build

Use at project level, to gather all populated targets in the widget tree plus
widget specifics files into a **WGT** archive. Generated under your `build`
directory :

Usage :

```cmake
project_package_build()
```

### project_closing_message

Will display the closing message configured in `config.cmake` file. Put it at the end of your project CMake file.
