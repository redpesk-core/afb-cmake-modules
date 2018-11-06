# Abstract

Files used to build an application, or a binding project with the AGL
Application Framework.

To build your AGL project using these templates, you have to installed them as
a CMake module. The easy way is to install using your distro package manager
following [this guide](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/1_Prerequisites.html).

Then install it, depending of your distro:

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

----

You'll find usage samples here:

- [helloworld-service](https://github.com/iotbzh/helloworld-service)
- [agl-service-can-low-level](https://gerrit.automotivelinux.org/gerrit/apps/agl-service-can-low-level)
- [agl-service-audio-4a](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-audio-4a)
- [agl-service-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/agl-service-unicens)
- [4a-hal-unicens](https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/4a-hal-unicens)
