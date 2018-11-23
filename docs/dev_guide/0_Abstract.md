# Abstract

This CMake module is used to build an application or a binding project for the
AGL Application Framework. It allows to easily build a widget and its related
test widget for running on top the application framework.

## Installation for a native environment

To build your AGL project using the templates, you have to install them as
a CMake module. The easy way is to install using your distro package manager
following [this guide](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/1_Prerequisites.html).

To install it, depending on your distro:

* **Debian/Ubuntu**

```bash
sudo apt-get install agl-cmake-apps-module-bin
```

* **openSUSE**

```bash
sudo zypper install agl-cmake-apps-module
```

* **Fedora**

```bash
sudo dnf install agl-cmake-apps-module
```

## Installing in a cross compilation environment

### Using AGL SDK

Beginning with the `Grumpy Guppy`, version 7, the CMakeAfbTemplates CMake module
is installed by default in the SDKs. So, you don't need anything to use it.

Here are some links to the latest SDKs on the master branch:

* [dra7xx-evm](https://download.automotivelinux.org/AGL/snapshots/master/latest/dra7xx-evm/deploy/sdk/)
* [dragonboard-410c](https://download.automotivelinux.org/AGL/snapshots/master/latest/dragonboard-410c/deploy/sdk/)
* [intel-corei7-64](https://download.automotivelinux.org/AGL/snapshots/master/latest/intel-corei7-64/deploy/sdk/)
* [m3ulcb-nogfx](https://download.automotivelinux.org/AGL/snapshots/master/latest/m3ulcb-nogfx/deploy/sdk/)
* [qemux86-64](https://download.automotivelinux.org/AGL/snapshots/master/latest/qemux86-64/deploy/sdk/)
* [raspberrypi3](https://download.automotivelinux.org/AGL/snapshots/master/latest/raspberrypi3/deploy/sdk/)

### Using bitbake recipes

If you have developed an application and you want to include it in the AGL image,
you have to add a `bitbake` recipe in one of the **AGL Yocto layer**:

* [meta-agl](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/AGL/meta-agl):
 meta-agl layer (core AGL)
* [meta-agl-cluster-demo](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/AGL/meta-agl-cluster-demo):
 cluster demo specific recipes and configuration
* [meta-agl-demo](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/AGL/meta-agl-demo):
 meta-agl-demo layer (demo/staging/"one-shot")
* [meta-agl-devel](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/AGL/meta-agl-devel):
 meta-agl-devel (Development and Community BSPs)
* [meta-agl-extra](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/AGL/meta-agl-extra):
 meta-agl-extra (additional/optional components for AGL)

Then in your recipe, you simply have to add the class `aglwgt` to the *inherit*
line:

```bb
inherit aglwgt
```

i.e with the **HVAC** app recipe:

```bb
SUMMARY     = "HVAC Service Binding"
DESCRIPTION = "AGL HVAC Service Binding"
HOMEPAGE    = "https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-hvac"
SECTION     = "apps"

LICENSE     = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ae6497158920d9524cf208c09cc4c984"

SRC_URI = "gitsm://gerrit.automotivelinux.org/gerrit/apps/agl-service-hvac;protocol=https;branch=${AGL_BRANCH}"
SRCREV  = "${AGL_APP_REVISION}"

PV = "1.0+git${SRCPV}"
S  = "${WORKDIR}/git"

DEPENDS = "json-c"
RDEPENDS_${PN} += "agl-service-identity-agent"

inherit cmake aglwgt pkgconfig
```

----

You'll find usage samples here:

* [helloworld-service](https://github.com/iotbzh/helloworld-service)
* [agl-service-can-low-level](https://gerrit.automotivelinux.org/gerrit/apps/agl-service-can-low-level)
* [agl-service-audio-4a](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-audio-4a)
* [agl-service-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-unicens)
* [4a-hal-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/4a-hal-unicens)
