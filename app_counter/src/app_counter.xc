//-----------------------------------------------------------
// XCore Seven Segment Serial Display Test Application
// by teachop
//
// Count up and down to demonstrate driver interface.
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include "seven_seg.h"

// one at a time...
#define BUTTON_DOWN     (0x01)
#define BUTTON_UP       (0x02)
#define BUTTON_BIG_UP   (0x04)
#define BUTTON_BIG_DOWN (0x08)


// ---------------------------------------------------------
// counter_task - count on sparkfun 4 digit 7-segment display
//
void counter_task(in port buttons, interface seven_seg_if client display) {
    uint32_t counter = 0;
    uint32_t counter_update = 0;
    uint32_t none_on = 1;
    uint32_t hold_off = 0;
    const uint32_t tick_rate = 2*1000*100;
    timer tick;
    uint32_t next_tick;
    tick :> next_tick;
    
    display.setText("pUSH");

    while (1) {
        select {
        case display.written():
            counter_update = 0;
            break;
        case tick when timerafter(next_tick) :> void:
            // 2 millisecond timer tick
            next_tick += tick_rate;
            uint32_t pressed;
            buttons :> pressed;
            hold_off = (!pressed && (30<hold_off))? 30 : (hold_off? hold_off-1 : 0);
            if ( !hold_off && !counter_update) {
                counter_update = 1;
                switch ( pressed ) {
                case BUTTON_UP:
                    counter = (9999>counter)? counter+1 : 9999;
                    break;
                case BUTTON_DOWN:
                    counter = (0<counter)? counter-1 : 0;
                    break;
                case BUTTON_BIG_UP:
                    counter = (9900>counter)? counter+100 : 9999;
                    break;
                case BUTTON_BIG_DOWN:
                    counter = (99<counter)? counter-100 : 0;
                    break;
                default:
                    counter_update = 0;
                    pressed = 0;
                    break;
                }
                if ( counter_update ) {
                    display.setValue( counter, 1, 0 );
                    hold_off = none_on? 300 : 75;
                    none_on = 0;
                }
            }
            none_on = none_on || !pressed;
            break;
        }
    }
}


// ---------------------------------------------------------
// main - xCore ping sensor test
//
in port button_pins = XS1_PORT_4E; // j7.22, 24, 16, 18
port txd_pin = XS1_PORT_4C; // j7.5 [6, 7, 8]
out port drive_pins = XS1_PORT_4D; // j7.9, 13, 12, 14

int main() {
    interface seven_seg_if display;

    set_port_pull_down(button_pins);
    drive_pins <: 0x0f; // light up the keypad for button inputs

    par {
        counter_task(button_pins, display);
        seven_seg_task(txd_pin, 9600, display);
    }

    return 0;
}

