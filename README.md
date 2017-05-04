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
More advanced usage can be saw with the [CAN_signaling binding](https://github.com/iotbzh/CAN_signaling)
which mix external libraries, binding, and html5 hybrid demo application.

Typical project architecture
-----------------------------

A typical project architecture would be :

* \<root-path\>/
* \<root-path\>/<libs>
* \<root-path\>/packaging
* \<root-path\>/packaging/wgt
* \<root-path\>/packaging/wgt/etc
* \<root-path\>/\<target\>/

| # | Parent | Description | Files |
| - | -------| ----------- | ----- |
| \<root-path\> | - | Path to your project | Hold master CMakeLists.txt and general files of your projects. |
| \<libs\> | \<root-path\> | External dependencies libraries. This isn't to be used to include header file but build and link statically specifics libraries. | Library sources files. Can be a decompressed library archive file or project fork. |
| \<target\> | \<root-path\> | A sub component between: tool, binding, html5, html5-hybrid type. | ----- |
| packaging | \<root-path\> | Contains folder by package type (rpms, deb, wgt...) | Directory for each packaging type. |
| wgt | packaging | Files used to build project widget that can be installed on an AGL target. | config.xml.in, icon.png.in files. |
| etc | wgt | Configuration files for your project. This will be installed in the application root directory under etc/ folder once installed by Application Framework. | specific project configuration files |

Usage
------

Once installed, use them by customize depending on your project with file
`\<root-path\>/etc/config.cmake`.

Specify manually your targets, you should look at samples provided in this
repository to make yours. Then when you are ready to build, using `AGLbuild`
that will wrap CMake build command:

```bash
`./AGLBuild` package
```

Or with the classic way :

```bash
mkdir -p build && cd build
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

### Build a widget using provided macros

To leverage all macros features, you have to specify ***properties*** on your
targets. Some macros will not works without specifying which is the target type.
As the type is not always specified for some custom target, like an ***HTML5***
application, macros make the difference using ***LABELS*** property.

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
----------------

### PROJECT_TARGET_ADD

Typical usage would be to add the target to your project using macro
`PROJECT_TARGET_ADD` with the name of your target as parameter. Example:

```cmake
PROJECT_TARGET_ADD(low-can-demo)
```

This will make available the variable `${TARGET_NAME}` set with the specificied
name.

### search_targets

This macro will search in all subfolder any `CMakeLists.txt` file. If found then
it will be added to your project. This could be use in an hybrid application by
example where the binding lay in a sub directory.

Usage :

```cmake
search_targets()
```

### populate_widget

Macro use to populate widget tree. To make this works you have to specify some properties to your target :

- LABELS : specify *BINDING*, *HTDOCS*, *EXECUTABLE*, *DATA*
- PREFIX : must be empty **""** when target is a *BINDING* else default prefix *lib* will be applied
- OUTPUT_NAME : Name of the output file generated, useful when generated file name is different from `${TARGET_NAME}`

Always specify  `populate_widget()` macro as the last statement, especially if
you use ${TARGET_NAME} variable. Else variable will be set at wrong value with
the **populate_** target name.

Usage :

```cmake
populate_widget()
```

### build_widget

Use at project level, to gather all populated targets in the widget tree plus
widget specifics files into a **WGT** archive. Generated under your `build`
directory :

Usage :

```cmake
build_widget()
```
