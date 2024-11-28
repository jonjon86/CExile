#include <stdbool.h>

struct ZeroPage {
    // Implementation of 6502 zero page, and functions where more appropriate
    bool whistle1_played;
    unsigned char loop_counter;
    unsigned char mushroom_daze;

    bool loop_counter(unsigned_char x) {
        // true every n'th loop
        return loop_counter % x = 0;
    }
}

void main_loop() {
    ZeroPage zp;

    process_screen_background_flash();
    process_objects();
    process_events();

    if zp.
}

void process_screen_background_flash() {

}

void process_objects() {

}

void process_events() {

}