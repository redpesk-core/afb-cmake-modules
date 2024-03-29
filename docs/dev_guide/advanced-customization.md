# Advanced Customization

Beyond the configurations described in the
[Configuring CMake Templates](configuring-cmake.html) section,
you can provide some advanced configurations.

This section describes how you can include additional CMake files
and custom template scripts.

## Including Additional CMake Files

You can include machine and system custom CMake files and
operating system custom CMake files.

### Machine and System Custom CMake Files

Advanced configuration is possible by automatically including
additional CMake files from specific locations.
Following are the locations from which you can add CMake
files.
Inclusions occur in the order shown here:

- `<project-root-path>/conf.d/app-templates/cmake/cmake.d` - normally located CMake project files
- `$HOME/.config/app-templates/cmake.d` - the home location
- `/etc/app-templates/cmake.d` - the system location

The CMake files you include must be named using either of the following conventions:

- `XX-common*.cmake`
- `XX-${PROJECT_NAME}*.cmake`

In both formats, `XX` are numbers and indicate the order in which the file
is included.
The `*` character represents the filename.

When naming the file, consider the projects in which the file needs to be
included.
If you want to include the file in all projects, use the keyword `common`.
If you want to include the file in a specific project, use the `${PROJECT_NAME}`
value.

For example, if you want a CMake file whose name is `my_custom_file`
included first and you want it included in all projects, name the file
`01-common-my_custom_file.cmake`.
If you want the same file included in a single project defined by the
`PROJECT_NAME` variable, and you want it included after all other files,
name the file `99-${PROJECT_NAME}-my_custom_file.cmake`.

When you include CMake files that use CMake variables, the values override
variables with the same name.
The exception to this rule is if you use a cached variable.
Following is an example:

```cmake
set(VARIABLE_NAME 'value string random' CACHE STRING 'docstring')
```

In this example, the `VARIABLE_NAME` variable is defined as a cached
variable by using the **CACHE** keyword.
Consequently, `VARIABLE_NAME` does not get overridden as a result of
including a CMake file that sets the same variable.

### Operating System Custom CMake Files

Including custom CMake files based on the operating system
lets you personalize a project depending on the operating system
you are using.

At the end of the `config.cmake` file `common.cmake` includes
CMake files to customize your project build depending on your platform.
The operating system is detected by using `/etc/os-release`,
which is the default method used in almost all Linux distributions.
Consequently, you can use the value of field **ID_LIKE** to
add a CMake file for that distribution.
The file comes from your `conf.d/cmake/` directory or relatively
from your `app-templates` submodule path `app-templates/../cmake/`.

**NOTE:** If the **ID_LIKE** field does not exist, you can use the
**ID** field.

Files that you add must be named according to the following file naming
convention:

- `XX-${OSRELEASE}*.cmake`

In the naming convention, `XX` represents numbers and is the order in which
you want a file included.
The ${OSRELEASE} value is taken from either the **ID_LIKE** or **ID** field
of the `/etc/os-release` file.

You can also configure a CMake file to be included in cases where no
specific operating system can be found.
To do so, name your CMake file as follows:

- `XX-default*.cmake`

A good use case example for these two naming conventions is when you have
a several Linux distributions and all but one can use the same module.
For that case, name one CMake file using the `${OSRELEASE}` value and
name the CMake file to be used with the other distributions using
the `XX-default*.cmake` method.

## Including Custom Template Scripts

You can include your own custom template scripts that are passed to the
CMake command `configure_file`.

Just create your own script and place it in either of the following directories:

- `$HOME/.config/app-templates/scripts` - the home location
- `/etc/app-templates/scripts` - the system location

Scripts only need to use the extension `.in` to be parsed and configured by
CMake.
