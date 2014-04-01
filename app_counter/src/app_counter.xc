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
#define BUTTON_UP       (0x02)
#define BUTTON_DOWN     (0x01)
#define BUTTON_BIG_UP   (0x04)
#define BUTTON_BIG_DOWN (0x08)


// ---------------------------------------------------------
// counter_task - count on sparkfun 4 digit 7-segment display
//
void counter_task(in port buttons, interface seven_seg_if client display) {
    uint32_t counter = 0;
    const uint8_t places = 1;
    uint32_t pins = 0;
    uint32_t hold_off = 0;
    const uint32_t tick_rate = 2*1000*100;
    timer tick;
    uint32_t next_tick;
    tick :> next_tick;
    
    //display.setValue(counter,places,0);
    //display.setClock(12,59,1);
    uint8_t message[4] = {'p','U','S','H'};
    display.setText(message);

    while (1) {
        select {
        case tick when timerafter(next_tick) :> void:
            // 2 millisecond timer tick
            next_tick += tick_rate;
            uint32_t new_pins;
            buttons :> new_pins;
            hold_off = (!new_pins && (40<hold_off))? 40 : hold_off;
            if ( hold_off ) {
                hold_off--;
            } else {
                uint32_t counter_was = counter;
                switch ( new_pins ) {
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
                }
                if ( counter != counter_was ) {
                    display.setValue( counter, places, 0 );
                    hold_off = pins? 75 : 350;
                }
            }
            pins = new_pins;
            break;
        }
    }
}


// ---------------------------------------------------------
// main - xCore ping sensor test
//
in port button_pins = XS1_PORT_4E; // j7.22, 24, 16, 18
port txd_pin = XS1_PORT_4C; // j7.5 [6, 7, 8]

int main() {
    interface seven_seg_if display;

    set_port_pull_down(button_pins);

    par {
        counter_task(button_pins, display);
        seven_seg_task(txd_pin, display);
    }

    return 0;
}

