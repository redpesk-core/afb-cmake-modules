# Installing CMake Templates

You can install CMake templates on your native Linux system.

In order to use the templates, you need to install them as
a CMake module.
On your native Linux system, use your distribution's package manager.
See the
"[Prerequisites](../host-configuration/docs/2-download-packages.html)"
section for how to install packages using your distribution's package
manager.
Be sure to use the following with you install the packages:

```bash
export DISTRO="xUbuntu_16.10"
export REVISION=Master
```

**NOTE:** In order to use the CMake templates, you must be using the
AGL Guppy release.
You cannot use prior releases.

## Installing on Debian or Ubuntu

Use the following command to install AGL's CMake Application Module
on a native Debian or Ubuntu system:

```bash
sudo apt-get install agl-cmake-apps-module-bin
```

## Installing on OpenSUSE

Use the following command to install AGL's CMake Application Module
on a native OpenSUSE system:

```bash
sudo zypper install agl-cmake-apps-module
```

## Installing on Fedora

Use the following command to install AGL's CMake Application Module
on a native Fedora system:

```bash
sudo dnf install agl-cmake-apps-module
```

# Using CMake Templates in a Cross-Compilation Environment

Beginning with the `Grumpy Guppy`, version 7, the CMakeAfbTemplates CMake module
is installed by default in the SDKs supplied by AGL.
Consequently, you do not need to take steps to install the modules.

Following are links to the latest SDKs on the AGL master branch:

* [dra7xx-evm](https://download.automotivelinux.org/AGL/snapshots/master/latest/dra7xx-evm/deploy/sdk/)
* [dragonboard-410c](https://download.automotivelinux.org/AGL/snapshots/master/latest/dragonboard-410c/deploy/sdk/)
* [intel-corei7-64](https://download.automotivelinux.org/AGL/snapshots/master/latest/intel-corei7-64/deploy/sdk/)
* [m3ulcb-nogfx](https://download.automotivelinux.org/AGL/snapshots/master/latest/m3ulcb-nogfx/deploy/sdk/)
* [qemux86-64](https://download.automotivelinux.org/AGL/snapshots/master/latest/qemux86-64/deploy/sdk/)
* [raspberrypi3](https://download.automotivelinux.org/AGL/snapshots/master/latest/raspberrypi3/deploy/sdk/)

# Using CMake Templates from BitBake Recipes

If you have developed an application and you want to include it in an AGL image,
you must add a BitBake recipe in one of the following layers:

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

Once you have the recipe in place, edit it to include the following
line to cause the `aglwgt` class to be inherited:

```bb
inherit aglwgt
```

Following is an example that uses the HVAC application recipe (i.e. `hvac.bb`), which
builds the HVAC application:

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

# Additional Examples

The following links provide further examples of recipes that use the
CMake templates:

* [helloworld-service](https://github.com/iotbzh/helloworld-service)
* [agl-service-audio-4a](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-audio-4a)
* [agl-service-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-unicens)
* [4a-hal-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/4a-hal-unicens)
