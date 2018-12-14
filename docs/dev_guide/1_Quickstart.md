# Quickstart

## Initialization

To use these templates files on your project just install the reference files
using **cmake module** then use `config.cmake` file to configure your project specificities :

```bash
mkdir -p conf.d/cmake
# From the SDK sysroot >= 6.99.2 b992
cp ${OECORE_NATIVE_SYSROOT}/usr/share/doc/CMakeAfbTemplates/samples.d/config.cmake.sample conf.d/cmake/config.cmake
# From the SDK sysroot < 6.99.2 b992
cp ${OECORE_NATIVE_SYSROOT}/usr/share/cmake-3.8/Modules/CMakeAfbTemplates/samples.d/config.cmake.sample conf.d/cmake/config.cmake
# From a native installation
cp /usr/share/doc/CMakeAfbTemplates/samples.d/config.cmake.sample conf.d/cmake/config.cmake
```

Edit the copied config.cmake file to fit your needs.

Now, create your top CMakeLists.txt file which include `config.cmake` file.

An example is available in the **cmake module** that you can copy and use:

```bash
# From the SDK sysroot >= 6.99.2 b992
cp ${OECORE_NATIVE_SYSROOT}/usr/share/doc/CMakeAfbTemplates/samples.d/CMakeLists.txt.sample CMakeLists.txt
# From the SDK sysroot < 6.99.2 b992
cp ${OECORE_NATIVE_SYSROOT}/usr/share/cmake-3.8/Modules/CMakeAfbTemplates/samples.d/CMakeLists.txt.sample CMakeLists.txt
# From a native installation
cp /usr/share/doc/CMakeAfbTemplates/samples.d/CMakeLists.txt.sample CMakeLists.txt
```

## Auto-detection of CMakeLists.txt and *.cmake files

The directories matching the pattern ***PROJECT_SRC_DIR_PATTERN*** (defaults to "*")
will be automatically scanned.

When a files ***CMakeLists.txt*** is found, its directory is automatically added to
the cmake project.

Similarily, when a file named with the extension ***.cmake*** is found, it is automatically
added to the cmake project.

## Create your CMake targets

For each target that is part of your project, you need to use
***PROJECT_TARGET_ADD*** to include this target to your project.

> **NOTE**: Using it, make available the cmake variable ***TARGET_NAME*** until
> the next ***PROJECT_TARGET_ADD*** is invoked with a new target name.

So, typical usage defining a target is:

```cmake
PROJECT_TARGET_ADD(SuperExampleName) --> Adding target to your project

add_executable/add_library(${TARGET_NAME}.... --> defining your target sources

SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES.... --> fit target properties
for macros usage

INSTALL(TARGETS ${TARGET_NAME}....
```

## Targets PROPERTIES

Targets properties is used to determine nature of targets and where they will be
stored in the package that will be build.

Specify what is the type of your targets that you want to be included in the
widget package with the property **LABELS**:

Choose between:

- **BINDING**: Shared library that be loaded by the AGL Application Framework
- **BINDINGV2**: Shared library that be loaded by the AGL Application Framework
 This has to be accompagnied with a JSON file named like the
 *${OUTPUT_NAME}-apidef* of the target that describe the API with OpenAPI
 syntax (e.g: *mybinding-apidef*).
 Or Alternatively, you can choose the name, without the extension, using macro
 **set_openapi_filename**. If you use C++, you have to set **PROJECT_LANGUAGES**
 with *CXX*.
- **BINDINGV3**: Shared library that be loaded by the AGL Application Framework
 This has to be accompagnied with a JSON file named like the
 *${OUTPUT_NAME}-apidef* of the target that describe the API with OpenAPI
 syntax (e.g: *mybinding-apidef*).
 Or Alternatively, you can choose the name, without the extension, using macro
 **set_openapi_filename**. If you use C++, you have to set **PROJECT_LANGUAGES**
 with *CXX*.
- **PLUGIN**: Shared library meant to be used as a binding plugin. Binding
 would load it as a plugin to extend its functionnalities. It should be named
 with a special extension that you choose with SUFFIX cmake target property or
 it'd be **.ctlso** by default.
- **HTDOCS**: Root directory of a web app. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **DATA**: Resources used by your application. This target has to build its
 directory and puts its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **EXECUTABLE**: Entry point of your application executed by the AGL
 Application Framework
- **LIBRARY**: An external 3rd party library bundled with the binding for its
 own purpose because platform doesn't provide it.
- **BINDING-CONFIG**: Any files used as configuration by your binding.

> **TIP** you should use the prefix _afb-_ with your **BINDING* targets which
> stand for **Application Framework Binding**.

```cmake
SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
	PREFIX "afb-"
	LABELS "BINDINGV3"
	OUTPUT_NAME "file_output_name")
```

> **CAUTION**: You doesn't need to specify an **INSTALL** command for these
> targets. This is already handle by template and will be installed in the
> following path : **${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}**
