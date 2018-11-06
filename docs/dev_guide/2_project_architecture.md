# Project architecture

A typical project architecture would be :

```tree
<project-root-path>
│
├── autobuild/
│   ├── agl
│   │   └── autobuild
│   ├── linux
│   │   └── autobuild
│   └── windows
│       └── autobuild
├── conf.d/
│   ├── packaging/
│   │   ├── rpm
│   │   │   └── package.spec
│   │   └── deb
│   │       ├── package.dsc
│   │       ├── debian.package.install
│   │       ├── debian.changelog
│   │       ├── debian.compat
│   │       ├── debian.control
│   │       └── debian.rules
│   ├── cmake
│   │   ├── 00-debian-osconfig.cmake
│   │   ├── 00-suse-osconfig.cmake
│   │   ├── 01-default-osconfig.cmake
│   │   └── config.cmake
│   └── wgt
│       ├── icon.png
│       └── config.xml.in
├── <target>
│   └── <files>
├── <target>
│   └── <file>
└── <target>
    └── <files>
```

| # | Parent | Description |
| - | -------| ----------- |
| \<root-path\> | - | Path to your project. Hold master CMakeLists.txt and general files of your projects. |
| autobuild | \<root-path\> | Scripts generated from app-templates to build packages the same way for differents platforms.|
| conf.d | \<root-path\> | Holds needed files to build, install, debug, package an AGL app project |
| cmake | conf.d | Contains at least config.cmake file modified from the sample provided in app-templates submodule. |
| packaging | conf.d | Contains output files used to build packages. |
| wgt | conf.d | Contains config.xml.in, and optionnaly test-config.xml.in template files modified from the sample provided in cmake module for the needs of project (See config.xml.in.sample and test-config.xml.in.sample file for more details). |
| \<target\> | \<root-path\> | A target to build, typically library, executable, etc. |
