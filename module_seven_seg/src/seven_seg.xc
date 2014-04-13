//---------------------------------------------------------
// Serial 7 segment display driver
// by teachop
//

#include <xs1.h>
#include <stdint.h>
#include "seven_seg.h"


// ---------------------------------------------------------
// seven_seg_task - Serial 7 segment display driver
//
[[combinable]]
void seven_seg_task(port txd, interface seven_seg_if server display) {
    const uint32_t bit_rate = (100*1000*1000)/9600;
    uint8_t latest_ascii[4] = {0,0,0,0};
    uint8_t latest_dp = 0;
    uint32_t display_updated = 0;
    uint32_t tx_count = 0;
    uint8_t buffer[8];
    buffer[0] = 'w'; // 4 == 1 decimal place
    buffer[1] = 4;
    buffer[2] = 'y'; // 0 == goto left-most digit
    for( uint32_t loop=3; loop<sizeof(buffer); ++loop ) {
        buffer[loop] = 0;
    }

    uint32_t display_rate = 25*1000*100;
    timer tick;
    uint32_t next_tick;
    tick :> next_tick;

    while( 1 ) {
        select {
        case display.setValue(uint32_t value, uint8_t dplaces, uint8_t lead_0s):
            value = (9999<value)? 9999 : value;
            dplaces = (3<dplaces)? 3 : dplaces;
            latest_dp = dplaces? 1<<(3-dplaces) : 0;
            for ( uint32_t loop=0; loop<4; ++loop ) {
                uint8_t digit = (lead_0s || (dplaces>=loop) || value)? '0' + value%10 : ' ';
                latest_ascii[sizeof(latest_ascii)-1-loop] = digit;
                value /= 10;
            }
            display_updated = 1;
            break;
        case display.setClock(uint8_t hours, uint8_t minutes, uint8_t flags):
            hours = (23<hours)? 23 : hours;
            minutes = (59<minutes)? 59 : minutes;
            latest_dp = (SSEG_COLON&flags)? 0x10 : 0;
            uint8_t am_pm = SSEG_AM_PM & flags;
            if ( am_pm ) {
                if ( 12 <= hours ) {
                    latest_dp |= 0x08;
                    if ( 12 != hours ) {
                        hours -= 12;
                    }
                }
                if ( !hours ) {
                    hours = 12;
                }
            }
            latest_ascii[0] = (9<hours)? '0'+hours/10 : (am_pm?' ':'0');
            latest_ascii[1] = '0' + hours%10;
            latest_ascii[2] = '0' + minutes/10;
            latest_ascii[3] = '0' + minutes%10;
            display_updated = 1;
            break;
        case display.setText(uint8_t (&text)[4]):
            latest_dp = 0;
            for ( uint32_t loop=0; loop<4; ++loop ) {
                latest_ascii[loop] = text[loop];
            }
            display_updated = 1;
            break;
        case display.blank(void):
            latest_dp = 0;
            for ( uint32_t loop=0; loop<4; ++loop ) {
                latest_ascii[loop] = ' ';
            }
            display_updated = 1;
            break;
        case tick when timerafter(next_tick) :> void:
            if ( !tx_count && display_updated ) {
                // build data string for display
                buffer[1] = latest_dp;
                for ( uint32_t loop = 0; loop<4; ++loop ) {
                    buffer[sizeof(buffer)-4+loop] = latest_ascii[loop];
                }
                tx_count = sizeof(buffer);
                display_updated = 0;
            }
            if ( tx_count ) {
                uint16_t delay_count;
                // sync counter then start bit low
                txd <: 1 @ delay_count;
                delay_count += bit_rate;
                txd @ delay_count <: 0;
                uint8_t shifter = buffer[sizeof(buffer)-tx_count];
                for ( uint32_t bit=0; bit<8; ++bit ) {
                    // data bits
                    delay_count += bit_rate;
                    txd @ delay_count <: shifter;
                    shifter >>= 1;
                }
                // stop bit high
                delay_count += bit_rate;
                txd @ delay_count <: 1;
                tx_count--;
            } else {
                // pause
                display.written();
                next_tick += display_rate;
            }
            break;
        }
    }

}
