# Configuring CMake Templates

Configuration consists of editing the `config.cmake` file for your
specific project.

## Creating Your `config.cmake` File

First, you need to create the directory `conf.d/cmake` in your main project
directory.

```bash
mkdir -p conf.d/cmake
```

Next, use one the following command to copy the file `cmake.config.sample`
as the `config.cmake` file of your project.

```bash
TEMPL=/usr/share/doc/CMakeAfbTemplates
cp ${TEMPL}/samples.d/config.cmake.sample conf.d/cmake/config.cmake
```

Once you have created your `config.cmake` file, you need to make the changes
specific to your project.

If the directory `/usr/share/doc/CMakeAfbTemplates` does not exist,
try the locations below:

- `/usr/local/share/doc/CMakeAfbTemplates`
- `/opt/AGL/share/doc/CMakeAfbTemplates`

## Creating Your `CMakeLists.txt` File

To create this file, use the example template in the **cmake module**.
Use one of the following command to create your file.

```bash
cp ${TEMPL}/samples.d/CMakeLists.txt.sample CMakeLists.txt
```

## Creating Your CMake Targets

Creating a CMake target is the result of editing your `CMakeLists.txt` file.

For each target that is part of your project, you need to use the
***PROJECT_TARGET_ADD*** statement.
Using this statement includes the target in your project.

Using the ***PROJECT_TARGET_ADD*** statement makes the CMake ***TARGET_NAME***
variable available until the next ***PROJECT_TARGET_ADD*** statement is
encountered that uses a new target name.

Following is typical use within the `CMakeLists.txt` file to create a target:

```cmake
PROJECT_TARGET_ADD(target_name) --> Adds *target_name* to the project.
*target_name* is a sub-folder in the CMake project.

add_executable/add_library(${TARGET_NAME}.... --> Defines the target sources.

SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES.... --> Configures the target properties
so they can be used by macros.

INSTALL(TARGETS ${TARGET_NAME}....
```

## Target Properties

Target properties are used to determine the nature of the
target and where the target is stored within the package being built.

Use the **LABELS** property to specify the target type that you want
included in the widget package.
You can choose the following target types:

Choose between:

- **BINDING**: A shared library loaded by the Application Framework.
- **BINDINGV2**: A shared library loaded by the Application Framework.
  This library must be accompanied by a JSON file named similar to the
  *${OUTPUT_NAME}-apidef* of the target, which describes the API with OpenAPI
  syntax (e.g: *mybinding-apidef*).
  Alternatively, you can choose the name without the extension using the
  **set_openapi_filename** macro.
  If you use C++, you must set **PROJECT_LANGUAGES** through *CXX*.
- **BINDINGV3**: A shared library loaded by the Application Framework.
  This library must be accompanied by a JSON file named similar to the
  *${OUTPUT_NAME}-apidef* of the target, which describes the API with OpenAPI
  syntax (e.g: *mybinding-apidef*).
  Alternatively, you can choose the name without the extension using the
  **set_openapi_filename** macro.
  If you use C++, you must set **PROJECT_LANGUAGES** through *CXX*.
- **PLUGIN**: A shared library meant to be used as a binding plugin, which
  would load the library as a plugin consequently extending its
  functionalities.
  You should name the binding using a special extension that you choose
  with `SUFFIX cmake target property`.
  If you do not use the special extension, it defaults to **.ctlso**.
- **HTDOCS**: The root directory of a web application.
  This target has to build its directory and puts its files in the
  **${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}**.
- **DATA**: Resources used by your application.
  This target has to build its directory and puts its files in the
  **${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}**.
- **EXECUTABLE**: The entry point of your application executed by the
  Application Framework.
- **LIBRARY**: An external third-party library bundled with the binding.
  The library is bundled in this manner because the platform does not
  provide bundling.
- **BINDING-CONFIG**: Any files used as configuration by your binding.

**TIP:** you should use the prefix _afb-_ (**Application Framework Binding**)
with your *BINDING* targets.

Following is an example that uses the **BINDINGV3** property:

```cmake
SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
	PREFIX "afb-"
	LABELS "BINDINGV3"
	OUTPUT_NAME "file_output_name")
```

**CAUTION**: You do not need to specify an **INSTALL** command for these
targets.
Installation is performed by the template.
Targets are installed in the **${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}**
directory.
