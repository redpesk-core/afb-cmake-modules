# Installing CMake Templates

You can install CMake templates on your native Linux system.

In order to use the templates, you need to install them as
a CMake module.
On your native Linux system, use your distribution's package manager.
See the
"[Prerequisites]({% chapter_link host-configuration-doc.setup-your-build-host %})"
section for how to install packages using your distribution's package
manager.

## Installing on Debian or Ubuntu

Use the following command to install CMake Application Module
on a native Debian or Ubuntu system:

```bash
sudo apt-get install afb-cmake-modules
```

## Installing on Fedora

Use the following command to install CMake Application Module
on a native Fedora system:

```bash
sudo dnf install afb-cmake-modules
```

## Installing on OpenSUSE

Use the following command to install CMake Application Module
on a native OpenSUSE system:

```bash
sudo zypper install afb-cmake-modules
```

## Troubleshooting

During your building, you may face this error : 

```bash
CMake Error at conf.d/cmake/config.cmake:189 (include):
  include could not find requested file:

    CMakeAfbTemplates
Call Stack (most recent call first):
  CMakeLists.txt:20 (include)
```
In the `config.cmake` file located in your application's `conf.d/cmake` directory, add the following line at the end of the file before including CMakeAfbTemplates :

```bash
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} /usr/share/cmake-3.16/Modules)
```

