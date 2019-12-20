Gravitate

A game similar to TileFall or the SameGame.

It was created simply to learn Nim and for fun.

Copyright © 2019-20 Mark Summerfield. All Rights Reserved.

Gravitate is free open source software licensed under the GPLv3 (GPLv3.txt).

For precompiled packages visit: http://www.qtrac.eu/gravitate.html

Windows (64-bit):
- unzip gravitate-VERSION.zip anywhere convenient
- double-click gravitate.exe in Windows Explorer or run it from a console

Linux (64-bit):
- tar xvfz gravitate-VERSION.tar.gz anywhere convenient
- double-click gravitate in a file manager or in an xterm, run
    chmod +x gravitate
    ./gravitate

The complete source is included in the src/ folder in the *.nim files.

To build the game:
- install the nim programming language from https://nim-lang.org
- in a console, install the GUI library by running:
    nimble install nigui
- in a console cd to the gravitate src/ folder and run
  on Windows:
    build.bat
  on Linux:
    bash build.sh
	
