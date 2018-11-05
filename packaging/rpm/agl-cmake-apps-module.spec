#
# spec file for package cmake-apps-module
#

%define __cmake cmake

%if 0%{?fedora_version}
%global debug_package %{nil}
%endif

Name:           agl-cmake-apps-module
# WARNING {name} is not used for tar file name in source nor for setup
#         Check hard coded values required to match git directory naming
BuildArchitectures: noarch
Version:        6.90
Release:        0
License:        Apache-2.0
Summary:        AGL cmake-apps-module
Group:          Development/Libraries/C and C++
Url:            https://gerrit.automotivelinux.org/gerrit/#/admin/projects/src/cmake-apps-module
Source:         cmake-apps-module-%{version}.tar.gz
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This is a CMake module made to ease development of binding and application
framework binder apps.

%prep
%setup -q -n cmake-apps-module-%{version}

%build
[ ! -d build ] && mkdir build
cd build
cmake ..

%install
[ -d build ] && cd build
%make_install

%files
%defattr(-,root,root)
%dir %{_datadir}/cmake/Modules/
%{_datadir}/cmake/Modules/*

%changelog
* Thu Nov 5 2018 Romain
- initial creation
