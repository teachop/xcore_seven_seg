##Serial Display Example Application Counter
The example program counts on the display whenever button inputs are activated.  On reset, the program will write "PUSH" on the display.  Pressing buttons will cause the text to be replaced by a counter.  The counter can be incremented / decremented with buttons.

###Required Modules
For an xCore xC application, the required modules are listed in the Makefile:
- USED_MODULES = module_seven_seg

###Wiring
The SparkFun display unit offers several serial interface choices includng I2C, SPI and UART.  For the driver UART was used, and thus only the one **RX** signal needs connected (in addition to the display power).  My breadboard used the LSB of a 4 bit XCore port, the other 3 bits of 4C being unused.  A 1 bit port would normally be selected for such a use.  The buttons are wired to a 4 bit port 4E for input, and the pull-down resistors enabled.  This means the buttons need to pull up to 3.3V when pressed.  The example uses 4 buttons.
- **J7.5**  Transmit serial data (wire to display **RX** input).
- **J7.24** UP button.
- **J7.22** DOWN button.
- **J7.16** UP-by-100 button.
- **J7.18** DOWN-by-100 button.

Note that using a wide port for the transmit data means the capability of shifting in the port output statement could not be used in the driver.
