===========================
uCore Toplevel Build System
===========================

:Author: Junjie Mao <eternal.n08@gmail.com>

.. contents::

This is a toplevel build system for uCore which now consists of bootloader, kernel, file system, user space libraries and applications.

Why Bothering
=============

Since uCore is already able to bootstrap itself from source, why bothering create all this stuff?

Because we have added several user space components to the system and will add more in the future. The kernel lives quite well when alone. But it is still a pain to cope with components such as bionic libc, uclibc and go.

One way to organize the source code is putting all of them in a single git repository (like ucore-x64-smp_). This method is good at maintaining 'cooperative changes' which involves multiple components to enable a feature or fix a bug. But when we want to include more and more components, it is no longer practical (though feasible) to mix up all history in one repository. It gets slower to check repository status, more complicated to read history of a single component. Worst of all, the mothod brings much trouble to bisecting as there are more commits to check and more code to compile. In short, it won't scale.

Another way is putting every component in a standalone repository (like current version of ucore_, bionic-libc_ and uclibc_ ). Now the commit histories are clean. But how can I build a component (which resides in one repository) and put it into another (usually the kernel) component's build system to create a complete image? The current solution is to assume that those repositories are put in a pre-defined manner. This leads to a complicated list of instructions to set up a local, working copy of the system.

This system adopts git submodule mechanism to keep each component living in its own repository and simplify build process. This repository itself is also a suitable place for maintaining build and test scripts that manages everything from kernel to applications.

Getting Started
===============

First of all, clone this repository by::

    ~$ git clone --recursive https://github.com/eternalNight/ucore.git ucore

This will clone this repository and all components managed as submodules.

To build and run a working kernel (for i386 as an example)::

    ~$ cd ucore
    ucore$ source scripts/envsetup.sh
    ucore$ board i386
    ucore$ make all
    ucore$ make run

The second line imports a script that setting up some functions for architecture and component management (board is one of them) along with some auto-completion rules. The third line selects the architecture on which uCore will run on. The fourth line makes everything specified (only the kernel is included by default). The last line invokes the proper emulator and starts the kernel. That's all.

envsetup.sh
-----------

The script *envsetup.sh* must always be imported and architecture must be specified at least once using *board* before you can use the build system in a new terminal. If this is not done, *make* will report an error saying::

    Makefile:2: *** ARCH is not set. Use 'board' to set it after 'source scripts/envsetup.sh'.  Stop.

board
-----

The command (or function actually) *board* is one of the management tools provided by the system. The usage of the command is listed as follows.

board
  Print the current architecture and board settings.

board <boardname>
  Set architecture and board settings. All components will then be built for the architecture you specified if they are able to. For a complete list of supported board names, press *tab* key after you typed *board* (i.e. consulting auto-completion).

Advanced Usage
==============

Building and Installing Components
----------------------------------

The build system provides another command *component* for managing components. Its usage is listed as follows.

component
  List the status of all components (whether they will be built and installed or not).

component <component-name>
  Print the status of the given component. For a complete list of possible components, press *tab* after typing *component* (auto-completion again).

component <component-name> [y|n]
  Set if the component referred to by <component-name> should be built and installed (y) or not (n).

The component settings are saved per architecture. You do not need to set them again when you open a new terminal.

Examples
--------

To build uCore for ARM with bionic libc test cases included, use the following commands (assume all components are excluded right now)::

    ucore$ source scripts/envsetup.sh
    ucore$ board arm
    ucore$ component lib/bionic-libc y
    ucore$ make all
    ucore$ make run

You can now see the test cases for bionic libc under *disk0:/bionic-test/*.

.. _ucore-x64-smp: https://code.google.com/p/ucore-x64-smp/
.. _ucore: https://github.com/chyyuu/ucore_plus.git
.. _bionic-libc: https://github.com/chyyuu/ucore_lib_bioniclibc
.. _uclibc: https://github.com/chyyuu/ucore_lib_uclibc.git
