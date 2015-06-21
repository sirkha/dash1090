dash1090
========

A dashboard for displaying information about an ADS-B collector site on a local
display.

Dependencies
------------

dash1090 is written in lua and developed on the Raspberry Pi with an
[Adafruit 2.2 inch PiTFT][1].

It relies on 
* [TekUI][2] to provide the user interface directly onto the framebuffer
    without the need to run X. For details on installing TekUI on the Raspberry
    Pi and displaying on the PiTFT, please seethe [section](Using TekUI on the
    Raspberry Pi and Linux Framebuffer) below.
* To control the backlight and receive input, it uses the [rpi-gpio][3]
    package.
* To monitor data, [luasocket][4] is used.
* A [dump1090][5] variant serving SBS data on port 30003.
 
If installed, dash1090 can be used to control the [flightradar24 feeder service][6] and [flight aware feeder service][7].


Installation
------------
Installation is optional. If the dependencies are installed, the program may be run by executing bin/dash1090.lua.
If desired, install dash1090 by running the install.lua script as root.

    sudo install.lua
    
This will install the main program in /usr/bin, a SysV init script in /etc/init.d/ and the required lua files in
your lua directory.

Operation
---------
dash1090 can be run 

* from the downloaded directory (bin/dash1090)
* from its installed location (dash1090)
* using the init script (/etc/init.d/dash1090 start)

Usage:

     dash1090 [-d DRIVER] [-S WxH] [-f FEEDER [FEEDER OPTIONS] [-f FEEDER ...] ]
     dash1090 --list-feeders
     dash1090 -f FEEDER -h
     
  Argument        |    | Description
  :---------------|:--:|:-------------------------------------------------
  --help          | -h | print help and exit
  --display       | -d | Specify the display driver *TODO*
  --size          | -S | window size in pixels formatted as WxH
  --theme         | -T | specify the tekUI theme
  --feeder        | -f | name of the feeder followed by feeder options
  --list-feeders  | -F | list the available feeders and their descriptions
    

Programming Overview for Developers
-----------------------------------
bin/dash1090.lua executes the main elements of the program. It forks feeder processes that send messages
back to the UI and controllers for display and input.

Using TekUI on the Raspberry Pi and Linux Framebuffer
-----------------------------------------------------
To install TekUI on the Raspberry Pi (raspbian) open the file config in the top directory, change

    PREFIX ?= /usr/local

to

    PREFIX ?= /usr

To use *only* the Linux framebuffer, change

    DISPLAY_DRIVER ?= x11
  
to

    DISPLAY_DRIVER ?= rawfb

Additionally, to use a display other than the HDMI output, you will have to modify the file 
src/display_rawfb/display_rfb_linux.c so that

    mod->rfb_fbhnd = open("/dev/fb0", O_RDWR);
  
reads

    mod->rfb_fbhnd = open("/dev/fb1", O_RDWR);
  
See the TekUI documentation if you want to do anything more complicated.

[1]: https://learn.adafruit.com/adafruit-2-2-pitft-hat-320-240-primary-display-for-raspberry-pi/overview
[2]: http://tekui.neoscientists.org/download.html
[3]: https://github.com/Tieske/rpi-gpio
[4]: http://w3.impa.br/~diego/software/luasocket/
[5]: https://github.com/antirez/dump1090
[6]: http://www.flightradar24.com/software/
[7]: http://flightaware.com/adsb/piaware/install
