# bitcoin-msvc
Projects and procedures to build Bitcoin Core with MS Visual Studio

1.0 - 7/2/15 - initial release for Bitcoin Core 0.10.2 with Visual Studio 2013  
1.1 - 11/6/15 - support for Bitcoin Core 0.11.1 with Visual Studio 2013 (includes OpenSSL 1.0.2d)
1.2 - 11/7/15 - support miniupnpc-1.9.20151026 (fixes buffer overrun vulnerability)
1.3 - 3/5/16 - support for Bitcoin Classic 0.11.2 with Visual Studio 2013

Current Versions
Bitcoin
- bitcoin	bitcoinclassic-0.11.2.cl1
External
- berkeleydb	db_4.8.30.NC
- boost	boost_1.56.0
- miniupnpc	miniupnpc_1.9 (2015.1026)
- openssl	openssl_1.0.2d
- protobuf	protobuf-2.6.1
- qrencode	qrencode-3.4.4
- qt	qt-everywhere-opensource-src-5.4.2
- zlib	zlib_1.2.8

There are three parts to this readme.  The first part is a rant.  Please feel free to skip :)  The second part is a cookbook for building Bitcoin Core with Microsoft Visual Studio.  This Git repository includes the project files you'll need to do this.  The third part talks about initializing the blockchain.


rant
====================

In which an intrepid engineer sets out to build Bitcoin Core from scratch, encounters a minefield of issues, emerges victorious after a long series of battles, and celebrates by writing about his experience.

So, there are a million development environments lying around, different languages, platforms, and various tools for creating software.  But there is one which is kind of the default, Microsoft Visual Studio for C++.  (The second would be Apple XCode for Objective C, and if there were a third, it would be IBM Eclipse for Java...)

When Satoshi Nakamoto developed the first Bitcoin client (now called Bitcoin Core), back in 2008, he used Microsoft Visual Studio for C++ (MSVC).  It was the logical choice.  Subsequently this code has been ported to Linux (of course), and Mac OS, and a variety of other platforms (even iPhone and Android), but naturally Microsoft Visual Studio remains the baseline.  

Wait, BZZZZZT!  Actually that's not true.  MSVC is no longer even supported as a development environment!  Way back in 2013 Bitcoin Core was ported away from MSVC to the "MinGW toolchain"*.  And now woa betide you should you desire to build Bitcoin Core with MSVC.  You are not only on your own, but you are facing a whole series of hurdles.

	* MinGW is a perfectly fine toolchain, and is beloved by Open Source advocates who don't want anything to do with Micro$oft.  I have no problem with MinGW, but I have a big problem with dropping support for MSVC.  For every MinGW developer there are 10,000 using MSVC.

To give you a flavor of the problems, Bitcoin core might be written in C++, but it now takes a lot more than C++ to build it.  In addition to MinGW for C++ one needs Perl, Python, and Ruby compilers (specific versions please, to ensure compatibiity), as well as a lot of big ancillary libraries.

Even figuring out what external stuff is required is not easy; for the record, we need:

- **Berkeley DB**, an open source SQL database
- **Boost**, a huge library of C++ utility classes
- **libQREncode**, an open source library for creating and parsing QR codes
- **MinUPnPC**, an open source implementation of the PnP protocol for opening ports on routers
- **OpenSSL**, a large open source library for implementation of SSL encryption for communications
- **Protocol Buffers**, an open source Google-developed parse/format library for text-based data structures
- **zlib**, an open source library implementing LZW compression
- and last but most definitely not least, **Qt**, an open source Nokia-owned framework for building graphical user interfaces

Yeah, whew.

Each of these has its own source code stored somewhere on the Internet, each has its own configuration, building, and configuration scripts, and each has its own pattern for how source, object, libraries, and executables should be arranged.  Let's not talk about compiler options, static vs dynamic linking, debug vs release builds, etc.  And let's not *even* talk about 32-bit vs 64-bit.  Well okay we will talk about all of these things.

**BerkeleyDB** is fortunately a simple case.  The source code is available here*: http://download.oracle.com/berkeley-db, and includes template MSVC project files.  Of course, the templates are for VS2008, so some adjustment is required to VS2013.

	* Specific instructions for downloading and installation are in the cookbook below

**libQRencode**, **MinUPnPC**, **Protocol Buffers** (aka protobuf), and **zlib** are each also simple, we get the source from here: http://fukuchi.org/works/qrencode, here: http://miniupnp.free.fr/files/download.php, here: https://github.com/google/protobuf/releases/download, and here: https://github.com/madler/zlib.git, and we make up MSVC projects to build them.  After a bit of futzing, poof, they build.  At least they are vanilla C++!

Nowhere does it tell you that you need these things, where to get them, or how to build them.  Some assembly required.  Onward...

**Boost** is ... huge.  Seriously huge.  You get it here: https://github.com/boostorg/boost.git; it comprises over 40,000 files and requires about 1.5GB on disk, before any compiling or linking.  Fortunately most of Boost is implemented solely in class headers, which means the functionality is compiled right into your code.  No libraries, no building, no linking.  That's pretty nice.  But you will have noticed that I said "most", not "all", and as it turns out there are pieces of Boost which do require compiling and linking into libraries, and some of those pieces are used by Bitcoin Core.  So yeah, we have to make an MSVC project to do this, and no, it wasn't that easy.  I kind of punted and made a MSVC project which ran a PowerShell script that came with Boost to do most of the making.  The biggest challenge was that Boost was designed to be built for 32-bit or 64-bit, but not both on the same machine.  So some assembly was required.  Onward.

Okay, what can we say about **OpenSSL**?  It is the absolute standard and of course it makes sense to use it, but somehow the maintainers have turned it into much more than a simple library.  Although it is written in C++ and compiles and links into static libraries, the build process requires Perl *and* Python.  So you get the source here: https://github.com/openssl/openssl.git, Perl here: http://www.perl.org, and Python here: http://www.python.org.  I cannot imagine the sequence of events which led to this, well actually, I can, and I am thinking dirty thoughts about the maintainers who allowed such impurity to pollute their pond.  Making matters worse, OpenSLL is under active development, so you have to plan on downloading the latest all the time, and rerunning the whole Rube Goldberg build process.  As with Boost I made a MSVC project which runs a PowerShell script that comes with OpenSSL.  After serious futzing it works, but it feels quite brittle.  Not totally happy with this, but IIWII.

Now allow me to make a brief digression to talk about **Bitcoin Core** itself.  Oh yeah, that thing we were building :)  Bitcoin Core consists of four executables:

- **bitcoind** - the Bitcoin daemon, which implements the "full node" functionality
- **bitcoin-cli** - a command line interface which uses RPC to communicate with bitcoind for a wide variety of utility functions
- **bitcoin-tx** - a command line interface which uses RPC to communicate with bitcoind for sending transactions and other wallet-based functions
- **bitcoin-qt** - a graphical interface which combines all of the functionality of bitcoind, bitcoin-cli, and bitcoin-tx

So basically you can run **bitcoind** as a daemon/service, and talk to it with **bitcoin-cli** and **bitcoin-tx**, or you can run **bitcoin-qt**, and have all the functionality of a "full node" including a simple wallet, all in one graphic program.  The four executables together comprise "Bitcoin Core".

Back to building.  So having successfully fetched/built/compiled/linked/installed **BerkeleyDB**, **Boost**, **libQREncode**, **MinUPnPC**, **protobuf**, **OpenSSL**, and **zlib**, we can now make **bitcoind**, **bitcoin-cli**, and **bitcoin-tx**.  This is a relatively simple* matter of taking MSVC project templates available online (here: https://github.com/ENikS/bitcoin-dev-msvc and here: https://github.com/fsb4000/bitcoin.git), fixing them so they work, updating them, and running them.  After sufficient time has elapsed, woo hoo we have a working Bitcoin Code "full node".  That was pretty exciting...

	* by "relatively simple" I mean, relative to creating MSVC projects for Boost and OpenSSL, not relative to something easy like nuclear rocket engines.

Now onward, to creating **bitcoin-qt**.  How hard could it be?

The rationale behind the **Qt** framework is pretty defensible.  Back in the day it was created to enable sophisticated fully-functional graphical user interfaces to be created in C++ programs, deployable across a wide variety of platforms, with "native" look and feel on each one.  Given that, it is easy to see why Satoshi chose it to build Bitcoin Core.  But unfortunately Qt has grown beyond its initial target into a giant unwieldy framework, with its own configuration and installation processes, its own makefile, and its own language and interface preprocessors.  All of which requires Perl, Python, *and* Ruby to install.  Yeah.  I cannot imagine that anyone would use it for anything new, it is just too hard to figure out*.  Not to mention it comprises 150,000 files and 3.5GB, I kid you not.

	* Digression: virtually all of the functionality of bitcoin-qt could be duplicated by running bitcoind and communicating to it via RPC with a simple GUI program written in C#, VB, or even and especially a web interface.  That seems like an opportunity ... :)

Having downloaded Qt from here: http://download.qt.io/official\_releases/qt, and having configured and installed it (many, many times, each time with slightly different parameters), whew, it worked.  Where by "worked" I mean, I was able to build and link together a working bitcoin-qt.  To give you a feel for the type of arcana involved, under Windows you have to choose how wchar_t is defined; is it a native type or a macro.  Naturally the default for OpenSLL conflicted with the default for Qt, and naturally this caused strange linker errors.  Another example: the Bitcoin Core modules which interface to Qt have to have numerous preprocessor symbols defined to guide the Qt macros, and they are not well documented and in some cases conflict.  You have to tell Qt that yes, you have SSL, and yes, you are using OpenSSL, and yes, you have static linking, and yes, you have a Windows plugin available for it and no, the plugin is not a plugin, because it is statically linked. As you go through this process, you have to make a bunch of decisions, like do you want to use ANGLE or OpenGL?  (Who knows, but the right answer was the non-default choice, OpenGL.)  And so on.  At one point I had a completely functional bitcoin-qt (yay!) but it required Qt DLLs to run (boo!), and that was of course ... bogus.

Another great thing* is that with Qt, there's some preprocessing involved with their proprietary compiler and interface builder.  All those commands are undocumented, which makes doing anything with them ... challenging.  So I took the entire chunk of Qt preprocessor stuff and stuck it in a PowerShell .bat file which has to be run stand-alone before building Bitcoin Core.  It's ugly but it works.  I have no doubt that new versions of Bitcoin Core will have changes to these commands, so it represents a maintenance crummy-ness, but for now IIWII.

	* by "great thing" I meant face-plant-worthy non-greatness.  Whoever invented this ... anyway.

After all that, I finally built a stand-alone **bitcoin-qt.exe** which runs and works.  Yay.  Hero emerges victorious.

But of course, that was a *32-bit* stand-alone bitcoin-qt.exe.  Ha...  Into 64-bit land we go.  

So all of the libraries except Boost and Qt were pretty easy to compile for 64-bit. (Boost and Qt of course being the biggest and most complicated ... Miraculously, OpenSLL "just worked" for 64-bit compiling, yay.)  Boost was a relatively simple* matter of changing the PowerShell script to put 32-bit and 64-bit libraries into separate directories.  Since most of Boost is simply headers, this actually only affected a teeny part of the library as a whole, and worked.  Onward.

	* see "relative to nuclear rocket engine" comment above

Qt is not 64-bit aware (we've had 64-bit processors for 20 years now!).  Anyway my first effort was simply to configure, build, and install the entire thing from scratch as 64-bit, using the MSVC 64-bit compiler.  That *almost* worked.  There are a few compiler switches which had to be tuned, and then it actually did work.  And I actually did have a 64-bit Qt.  However I no longer had a 32-bit Qt anymore.  So I ended up installing Qt twice, and configuring, building, and installing it twice, once for 32-bit and once for 64-bit.  Since it is so small and simple and doesn't take very long to install, this was easy.  Actually I'm kidding, it is huge and complicated and takes hours to install, so this was not easy, but it was done.  

And lo and behold we can now build 32-bit and 64-bit versions of **bitcoin-qt**.  Yay.  Hero emerges more victorious.

In case it is of use to a future would-be developer, here is the sequence of steps to recreate my path (I've omitted all the false starts, cul de sacs, and tears):


cookbook
====================

Okay, let's start with the desired directory layout.  Let's assume there's a place you want to put everything called `<path>`.  You will end up with the following:

	<path>						- base directory
	<path>\bitcoin\bitcoin.sln			- MSVC solution for building Bitcoin Core (in this repo)
	<path>\bitcoin\bitcoin			- * bitcoin source code (as downloaded from its repo)
	<path>\bitcoin\*.vcxproj			- MSVC projects for building Bitcoin Core (in this repo)
	<path>\bitcoin\_int\<project>\...		- intermediate files
	<path>\bitcoin\bin\<platform>\<config>	- bitcoin output files (executables)
	<path>\bitcoin\lib\<platform>\<config>	- bitcoin libraries
	<path>\external					- external libraries
	<path>\external\bitcoinExternal.sln	- MSVC solution for building external libraries (in this repo)
	<path>\external\<library>			- * library source (for each external library, from its repo)
	<path>\external\<library>.vcxproj	- MSVC projects for external libraries (in this repo)
	<path>\external\_int\<project>			- intermediate files
	<path>\external\bin\<platform>\<config>	- external library executables (utilities)
	<path>\external\lib\<platform>\<config>	- external library static libraries

	* = as will be noted below, most likely links to version-dependent directory with source

This directory structure is important, because there are a lot of relative paths in the MSVC projects.

If you've cloned this repo you will have the start of the directory structure, and the MSVC solution and project files.  Now it's time to get all the source code from everywhere.

### getting the source ###

Clone the Bitcoin Core repo https://github.com/bitcoin/bitcoin.git to:
	`<path>\bitcoin`
	You might want to name it per its current version, and create a link from "bitcoin" to the current version.  That's what I did.  For example, if the current version is 0.11.1, you could name the directory `bitcoin-0.11.1` and then `>mklink /j bitcoin bitcoin-0.11.1`

Download the Berkeley DB source http://download.oracle.com/berkeley-db and unzip it to:
	`<path>\external\berkeleydb`
	You might want to name it for it's version and create a link, e.g. unzip to `db-4.8.30.NC`, then >`mklink /j berkeleydb db-4.8.30.NC`  (Note that db-4.8.30.NC is NOT the current version, but it is the version recommended for use with Bitcoin Core...)

Clone the Boost repo https://github.com/boostorg/boost.git to:
	`<path>\external\boost`
	You might name it `boost_1.56.0` and then `>mklink /j boost boost_1.56.0`

Clone protobuf repo https://github.com/google/protobuf/releases/download to:
	`<path>\external\protobuf`
	You might name it `protobuf-2.6.1` and then `>mklink /j protobuf protobuf-2.6.1`

	Here's a special little thing you have to do ... Copy `<path>\external\protobuf\config.h.in` to `config.h`, then modify as follows for Visual Studio (headers etc):
		#define HAVE_MEMORY_H 1
		#define HAVE_STDINT_H 1
		#define HAVE_STDLIB_H 1
		#define HAVE_STRDUP 1
		#define HAVE_STRINGS_H 1
		#define HAVE_STRING_H 1
		#define HAVE_SYS_STAT_H 1
		#define HAVE_SYS_TYPES_H 1
		#define MAJOR_VERSION 3
		#define MICRO_VERSION 4
		#define MINOR_VERSION 4
		#define PACKAGE "libqrencode"
		#define VERSION "3.4.4"
		#define inline _inline

Download the libQREncode source http://fukuchi.org/works/qrencode and unzip to:
	`<path>\external\qrencode`
	Maybe name it `qrencode-3.4.4` and `>mklink /j qrencode qrencode-3.4.4`

Download the MiniUPnPc source http://miniupnp.free.fr/files/download.php to:
	`<path>\external\miniupnp`
	Maybe name it `miniupnpc-1.9.20151026` and `>mklink /j miniupnpc miniupnpc-1.9.20151026`

	Here's a special little thing you have to do ... Create `<path>/external/miniupnpc/miniupnpcstrings.h`, with this content:

		/* $Id: miniupnpcstrings.h.in,v 1.6 2014/11/04 22:31:55 nanard Exp $ */
		/* Project: miniupnp
		 * http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
		 * Author: Thomas Bernard
		 * Copyright (c) 2005-2014 Thomas Bernard
		 * This software is subjects to the conditions detailed
		 * in the LICENCE file provided within this distribution */
		#ifndef MINIUPNPCSTRINGS_H_INCLUDED
		#define MINIUPNPCSTRINGS_H_INCLUDED
		
		#define OS_STRING "MSWindows/6.1.7601"
		#define MINIUPNPC_VERSION_STRING "1.9"

		#if 0
		/* according to "UPnP Device Architecture 1.0" */
		#define UPNP_VERSION_STRING "UPnP/1.0"
		#else
		/* according to "UPnP Device Architecture 1.1" */
		#define UPNP_VERSION_STRING "UPnP/1.1"
		#endif
			
		#endif

Clone OpenSSL repo https://github.com/openssl/openssl.git to:
	`<path>\external\openssl`
	Maybe name it `openssl-1.0.2d` and `>mklink /j openssl openssl-1.0.2d`

Clone zlib repo https://github.com/madler/zlib.git to:
	`<path>\external\zlib`
	Maybe name it `zlib_1.2.8` and `>mklink /j zlib zlib_1.2.8`

	* The idea behind naming the library directories by their versions is that later you can get a later version, switch the link, rebuild, and poof you're done.  You can do this for new versions of bitcoin itself, too.

Yay, you have all the source code!  No actually you don't, we haven't retrieved Qt yet.  That comes later.  And we also need a couple of tools for OpenSLL:

If you don't already have Perl, visit http://www.perl.org to download and install Active State Perl.  It can go anywhere but the default is `c:\perl64` for the x64 version.  It will update your PATH to include this directory.  NB I used v5.20.2.2001 for x64.

If you don't already have Python, visit http://www.python.org to download and install it.  It can go anywhere but the default is `c:\python27` for v2.7.  It will update your PATH to include this directory.  NB I used v2.7.10 for x64.

### for 0.11.1: some assembly required ###

For Bitcoin Core 0.11.1, there are a few of tweaks required to the source code in order to get the C++ to compile.  

* Create an empty file named <path>/bitcoin/src/leveldb/include/unistd.h  
this file is never present for Windows, but some of the source expects it

* Modify the system header \Program Files (x86)\Microsoft Visual Studio 14.0\VC\include\crtdefs.h  
right below where size_t is defined, add this  
`typedef __int64 ssize_t;`  
this type is never present for Windows, but some of the source expects it

* Modify <path>\bitcoin\src\chainparams.cpp  
in three places, remove the `(Checkpoints::CCheckpointData)` casts  
they are not needed and while they appear correct, they cause compile errors (!)

### building daemon and command line tools ###

Okay!  Let's build all the external libraries.  Launch VS 2013, open the `<path>\external\bitcoinExternal.sln` solution, and build all of the external libraries.  Each one has a separate project in this solution.  You can build them each for two platforms, win32 and x64, and two configurations, Debug and Release.  If all went well, this will all work.  The diciest parts are the shell scripts for Boost and OpenSLL.  Good luck!


Yay, we're making progress.  Now let's make Bitcoin Core.

From within VS 2013, load the `<path>\bitcoin\bitcoin.sln` solution.  This has a number of projects, including four for each of the executables.  At this point go ahead and build **bitcoin-cli**, **bitcoind**, and **bitcoin-tx**.  As with the external libraries you can build each one for each of the two platforms and configurations.  Hold off on **bitcoin-qt** for now.  This should work, and you now have a working version of **bitcoind**, and you can talk to it with **bitcoin-cli** and **bitcoin-tx**.  Yay.  

It's possible this is all you wanted, because you want to run a "full node" on a server; if so, you'd done!  Congratulations and take the rest of this readme off.  However if you want the Bitcoin Core GUI, then ... here we go.

### getting and installing Qt for GUI ###

Download the Qt source http://download.qt.io/official_releases/qt and unzip it to:
	`<path>\external\qt`
	As above, name it `qt-opensource-5.4.2` and `>mklink /j qt qt-opensource-5.4.2`

(This takes a long time, it is a huge library...)

	Edit `<path>\external\qt\qtbase\mkspecs\win32-msvc2013\qmake.conf`, as follows:
		/MD change to /MT
		/MDd change to /MTd
		
	Within `<path>\external\qt\qtbase\include`, make a link to OpenSLL:
		>mklink /j openssl <path>\external\openssl\include\opensll
 
Okay, now launch a Visual Studio 2013 x64 shell.  This can be done from the Visual Studio Tools folder in the start menu.  Now:

	cd <path>\external\qt
	configure -prefix %CD%\qtbase -static -developer-build -opensource -openssl -opengl desktop -nomake tests -nomake examples -platform win32-msvc2013
	nmake module-qtbase module-qttools
	(this takes a looong time ...)

Congratulations, you've made 64-bit Qt.  After make completes...

	Create <path>\external\qt\x64, with lib and plugin subdirectories
	Move all LIB etc from ...\qt\qtbase\lib to ...\qt\win32\lib
	Move everything from ...\qt\qtbase\plugins to ...\qt\win32\plugins

Now, if you also want to make 32-bit Qt, you can do so, by doing the following...

	Delete *.obj from ...\qt\qtbase
	Search makefile* in ...\qt\qtbase and delete recently generated.  You can tell from the timestamps which are the output from the build and which are part of the source.

Launch a Visual Studio 2013 x86 shell.  Again, from the Visual Studio Tools folder.  Then:

	cd <path>\external\qt
	configure -prefix %CD%\qtbase -static -developer-build -opensource -openssl -opengl desktop -nomake tests -nomake examples -platform win32-msvc2013
	nmake module-qtbase module-qttools
	(this takes another looong time ...)

Congratulations, you've made 32-bit Qt.  After make completes...

	Create <path>\bitcoin\external\qt\win32, with lib and plugin subdirectories
	Move all LIB etc from ...\qt\qtbase\lib to ...\qt\win32\lib
	Move everything from ...\qt\qtbase\plugins to ...\qt\win32\plugins

### building GUI ###

Whew.  Now we're finally ready to make **bitcoin-qt**.  To start we have to preprocess a bunch of Qt source and interface definitions.  This has been packaged as a BAT file which ships in this repo alongside the project files.  The script runs Qt tools lcreate (language translator), moc (meta-object compiler), and rcc (resource compiler, as well as a tool called protoc which is built as part of Google's Protocol Buffers.  Open a Visual Studio 2013 x86 shell, and:

	cd <path>\bitcoin
	bitcoin-qt.bat
	(this creates C++ source and headers into the <path>\bitcoin\build directory)

Normally you would only do this once.  If you *change* anything in the user interface - by editing the Qt forms, etc - then you should rerun this batch file before rebuilding.  In principle this batch file could be a prebuild step in the Visual Studio project, but it seemed easier to break it out.

Now launch VS 2013 again, and open the `<path>\bitcoin\bitcoin.sln solution`.  And then ... try building it!  You should be able to build it for both platforms and both configurations.

Note that the output executables can be found in `<path>\bitcoin\bin`


blockchain
====================

Now that you have a working Bitcoin Core, you will be confronted with the problem of initializing your blockchain.  Every "full node" has to have a copy of the entire blockchain, and there are only two ways to get it; you can simply run the node for a while to request all the blocks from peers in the network, or you can initialize it from a known good copy*.  

	* If you initialize it from a bad copy, it won't compromise you; the network will figure out you have a corrupt copy and ignore you.  Depending on the nature of the corruption, it might even be something your node can fix.  It could take a long time, however.

When Bitcoin Core 0.10 was released one of the cool new features was the ability to use multiple peers to initialize the blockchain concurrently, supposedly making initializing your copy of the blockchain with a torrent or something like unnecessary.  Don't believe it.  In mid-2015 it takes about three days to download the entire blockchain, and your node will be CPU-bound the whole time.  Meanwhile it only takes a few hours to download the 40GB or so which comprises the blockchain.  So if you can simply copy in the blockchain, that will be great.

On Windows, Bitcoin Core stores all its data in `c:\users\<user>\appdata\roaming\bitcoin`.  In this directory you will find two subdirectories which contain the blockchain, named **blocks** and **chainstate**.  I suggest you poke around and see if you can find a torrent or FTP these from somewhere.  I've done it multiple times and it works great, no muss no fuss.  Of course the copied in version won't be quite current, but as soon as you start running your node it will sync with the network and bring the copy up to date.


/.
=====================

I hope you found this useful.  If you have questions or comments please email ole.eichhorn@gmail.com
- Ole Eichhorn