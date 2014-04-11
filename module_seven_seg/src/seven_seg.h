//---------------------------------------------------------
// Serial 7 segment display driver header
// by teachop
//

#ifndef __SEVEN_SEG_H__
#define __SEVEN_SEG_H__

// setClock flags
#define SSEG_AM_PM 0x01 // enable 12 hour clock mode
#define SSEG_COLON 0x02 // enable colon in clock display

// driver interface
interface seven_seg_if {

    // the display was written
    [[notification]] slave void written(void);

    // text to display (limited function on 7 segment)
    [[clears_notification]] void setText(uint8_t (&text)[4]);

    // blank the display
    [[clears_notification]] void blank(void);

    // show value with optional decimal places, optional leading zeros
    [[clears_notification]] void setValue(uint32_t value, uint8_t dplaces, uint8_t lead_0s);

    // show clock display with optional format flags: bit0=am_pm, bit1=colon
    [[clears_notification]] void setClock(uint8_t hours, uint8_t minutes, uint8_t flags);
};

[[combinable]]
void seven_seg_task(port txd, interface seven_seg_if server dvr);


#endif //__SEVEN_SEG_H__
