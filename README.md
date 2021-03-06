##XCore Driver for 4 Digit 7 Segment Display
This repository provides an xCore driver module for a SparkFun [Serial 7 Segment Display](https://github.com/sparkfun/Serial7SegmentDisplay/wiki/Serial-7-Segment-Display-Datasheet).  An example app is included that uses an [XMOS xCore startKIT](http://www.xmos.com/startkit) with this display to count button events.

###Introduction
The SparkFun display unit offers several serial interface choices includng I2C, SPI and UART. For this driver UART was selected as it requires only one pin and is easy to level shift.  **Note** The display uses an ATmega328P internal oscillator for timing.  By default this may not be calibrated well enough to guarantee UART communication (based on actual experience).  If this is the case, the baud parameter must be adjusted as compensation (or the oscillator calibrated).

The driver is formatted as an XMOS XCore module, and written as a task function.  Applications use the driver via an inter-task communication interface.  Interfaces are a feature of the XC language.  This technique implements a message passing API between application and driver tasks allowing use of the display.

###Starting the Driver Task
- **seven_seg_task(txd_pin, baud_rate, display)**  When starting the task (inside a par() statement) the TXD output pin is specified.  The parameter **display** is the interface.  A baud rate parameter is provide to allow adjustment of the default 9600 rate (see **Note** above).

###Driver API
- **setValue(value, dplaces, lead_0s)**  Display **value** which ranges from 0 to 9999 with **dplaces** decimal places (0 to 3).  If **lead_0s" is true, unused digits to the left of the number will be '0' instead of spaces.
- **setText(text)**  Display four characters as ASCII which is rather limited on seven segments.
- **setClock(hours, minutes, am_pm)**  Display a digital clock face.  If **am_pm** is false, a 24 hour format will be used.  When in 12 hour mode, the right-most decimal point is used as the PM indicator.  For example, if **hours**=13, **minutes**=45, in 12 hour mode " 1:45." will display.
- **blank()**  Display all segments off.
- **written()**  Provides support for [notification](https://www.xmos.com/published/how-use-notifications-over-interfaces?secure=1).  Notification will be sent from the driver whenever a **setValue/setText/setClock/blank** display update completes.  The notification is cleared whenever any of the same interface functions are called.  Use of the notification feature is completely optional.
