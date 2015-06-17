dash1090
========

A dashboard for displaying information about an ADS-B collector site on a local display.

Dependencies
------------

dash1090 is written in lua and developed on the Raspberry Pi with an [Adafruit 2.2 inch PiTFT][1] . It relies on [TekUI][2] to provide the user interface directly onto the framebuffer without the need to run X. For details on installing TekUI on the Raspberry Pi and displaying on the PiTFT, please see the [section](Using TekUI on the Raspberry Pi and Linux Framebuffer) below. To control the backlight, it uses the [rpi-gpio][3] package


Installation
------------

Operation
---------

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

Additionally, to use a display other than the HDMI output, you will have to modify the file src/display_rawfb/display_rfb_linux.c so that

    mod->rfb_fbhnd = open("/dev/fb0", O_RDWR);
  
reads

    mod->rfb_fbhnd = open("/dev/fb1", O_RDWR);
  
See the TekUI documentation if you want to do anything more complicated.

[1]: https://learn.adafruit.com/adafruit-2-2-pitft-hat-320-240-primary-display-for-raspberry-pi/overview
[2]: http://tekui.neoscientists.org/download.html
[3]: https://github.com/Tieske/rpi-gpio
