AGL CMake template
================

Files used to build an application, or binding, project with the
AGL Application Framework.

To build your AGL project using these templates, you have to install
them within your project and adjust compilation option in `config.cmake`.
For technical reasons, you also have to specify **cmake** target in
sub CMakeLists.txt installed. Make a globbing search to find source files
isn't recommended now to handle project build especially in a multiuser 
project because CMake will not be aware of new or removed source files.

You'll find simple usage example for different kind of target under the `examples` folder.
More advanced usage can be saw with the [CAN_signaling binding](https://github.com/iotbzh/CAN_signaling) which mix external libraries,
binding, and html5 hybrid demo application.

Typical project architecture
----------------------------------

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

Installation
--------------

Use the `install.sh` script to help you install templates to your project. Here is the help for it :

```bash
$ ./install.sh -h
The general script's help msg
Usage: ./install.sh [-b|--binding-path <arg>] [-ha|--html5-app-path <arg>] [-d|--(no-)debug] [-h|--help] <root-path>
	<root-path>: Project root path
	-d,--debug,--no-debug: Optional debug flag. (off by default)
	-h,--help: Prints help
```

Usage
--------

Once installed, use them by customize depending on your project with file
`\<root-path\>/etc/config.cmake`. 

Specify manually your targets, you should look at samples provided in this repository to make yours.
Then when you are ready to build, using 'AGLBuild' that will wrap CMake build command:
./AGLBuild package

Or with the classic way : 
mkdir -p build && cd build
cmake .. && make

Macro reference
--------------------

### PROJECT_TARGET_ADD

Typical usage would be to add the target to your project using macro `PROJECT_TARGET_ADD` with the name of your target as parameter. Example:

```cmake
PROJECT_TARGET_ADD(low-can-demo)
```

This will make available the variable `${TARGET_NAME}` set with the specificied name.

### search_targets

This macro will search in all subfolder any `CMakeLists.txt` file. If found then it will be added to your project. This could be use in an hybrid application by example where the binding lay in a sub directory. 

Usage : 

```cmake
search_targets()
```

### populate_widget

Macro use to populate widget tree. To make this works you have to specify some propertiers to your target :

- LABELS : specify *BINDING*, *HTDOCS*, *EXECUTABLE*, *DATA*
- PREFIX : must be empty **""** when target is a *BINDING* else default prefix *lib* will be applied
- OUTPUT_NAME : Name of the output file generated, useful when generated file name is different from `${TARGET_NAME}`

Always specify  `populate_widget()` macro as the last statement, especially if you use ${TARGET_NAME} variable. Else variable will be set at wrong value with the **populate_** target name.

Usage :

```cmake
populate_widget()
```

### build_widget

Use at project level, to gather all populated targets in the widget tree plus widget specifics files into a **WGT** archive. Generated under your `build` directory :

Usage :

```cmake
build_widget()
````
