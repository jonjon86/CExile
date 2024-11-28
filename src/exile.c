#include <stdbool.h>

int main(int argc, char *argv[]) {
    init();
    main_loop();
}

typedef struct ZeroPage {
    // Implementation of 6502 zero page, and functions where more appropriate
    bool whistle1_played;
    unsigned char loop_counter;
    unsigned char red_mushroom_daze;
    unsigned char blue_mushroom_daze;
    unsigned char explosion_timer;
} ZeroPage;

bool is_nth_loop(unsigned char x) {
    // true every n'th loop : equiv to 6502 loop_counter_XX
    return zp.loop_counter % x == 0;
};

// Primary stack (active objects)
// slot 17 is target, and 18 is waterfall; can we remove these elsewhere?
// Combined x/y high & low into single 16-bit value
typedef struct PrimaryStack {
    unsigned char object_stack_type[16];
    unsigned char object_stack_sprite[16];
    unsigned short object_stack_x[18];
    unsigned short object_stack_y[16];
    // object_stack_flags
    // 80 set = horizontal invert (facing left)
    // 40 set = vertical invert (upside down)
    // 20 set = remove from display
    // 10 set = teleporting
    // 08 set = damaged
    // 02 set = collision detected
    // 01 set at load positon?
    unsigned char object_stack_flags[16];

    // object_stack_palette:
    // 10 set = damaged
    unsigned char object_stack_palette[16];
    unsigned char object_stack_vel_x[16];
    unsigned char object_stack_vel_y[16];
    unsigned char object_stack_target[16];
    unsigned char object_stack_tx[16];
    unsigned char object_stack_energy[16];
    unsigned char object_stack_ty[16];
    unsigned char object_stack_supporting[16];
    unsigned char object_stack_timer[16];
    unsigned char object_stack_data_pointer[16];
    unsigned char object_stack_extra[16];
} PrimaryStack;

ZeroPage zp;
PrimaryStack ps = {
    .object_stack_type = {0x00, 0x26, 0xd7, 0x57, 0x57, 0x57, 0x57, 0xd6, 0xd7, 0x57, 0x25, 0x82, 0x26, 0x25, 0x47, 0x77},
    .object_stack_sprite = {0x04, 0x04, 0x02, 0x22, 0x24, 0x22, 0x22, 0x24, 0x23, 0x23, 0x23, 0x23, 0x25, 0x23, 0x23, 0x02},
    .object_stack_x = {0x9bc0, 0x9964, 0x0023, 0x0023, 0x0023, 0x0026, 0x0025, 0x0022, 0x0022, 0x0022, 0x0025, 0x00e7, 0x00d7, 0x00c8, 0x00a4, 0x007d},
    .object_stack_y = {0x3b20, 0x3b20, 0x0094, 0x0048, 0x005c, 0x005a, 0x00ae, 0x000f, 0x004b, 0x006e, 0x00d2, 0x0046, 0x00ef, 0x0006, 0x0006, 0x00dc},
    //.object_stack_x_low = {0xc0, 0x64, 0x23, 0x23, 0x23, 0x26, 0x25, 0x22, 0x22, 0x22, 0x25, 0xe7, 0xd7, 0xc8, 0xa4, 0x7d},
    //.object_stack_x = {0x9b, 0x99, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbc, 0x65},
    //.object_stack_y_low = {0x20, 0x20, 0x94, 0x48, 0x5c, 0x5a, 0xae, 0x0f, 0x4b, 0x6e, 0xd2, 0x46, 0xef, 0x06, 0x06, 0xdc, 0xa4},
    //.object_stack_y = {0x3b, 0x3b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    .object_stack_flags = {0x81, 0x11, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01},
    .object_stack_palette = {0x7e, 0x39, 0xa6, 0x0b, 0x81, 0xfa, 0x68, 0x68, 0x68, 0x68, 0x8e, 0x6b, 0x82, 0x92, 0x81, 0x92},
    .object_stack_vel_x = {0x00, 0x00, 0x84, 0x49, 0x59, 0x45, 0x8c, 0x93, 0x36, 0x36, 0x3d, 0x6d, 0x6d, 0x6d, 0x6d, 0xaf},
    .object_stack_vel_y = {0x00, 0x10, 0xa7, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x92, 0x20},
    .object_stack_target = {0xb0, 0x00, 0xf0, 0xf0, 0xb1, 0xb1, 0xb1, 0xb1, 0xb0, 0xb0, 0x31, 0x90, 0x31, 0x30, 0x31, 0x20},
    .object_stack_tx = {0x02, 0x99, 0x02, 0x0b, 0x0a, 0x88, 0x84, 0xcd, 0xcd, 0x86, 0x86, 0x86, 0x09, 0x04, 0x04, 0x09},
    .object_stack_energy = {0xff, 0xc8, 0x83, 0xd1, 0x91, 0xc4, 0xc8, 0xc7, 0xc5, 0xc5, 0xc5, 0xc6, 0x8c, 0x45, 0x45, 0x50},
    .object_stack_ty = {0x50, 0x3b, 0x50, 0x50, 0x49, 0x4a, 0x4a, 0x4a, 0x4a, 0x08, 0x90, 0xc3, 0x86, 0x86, 0x86, 0x86},
    .object_stack_supporting = {0x86, 0x88, 0x88, 0x88, 0x88, 0x02, 0x08, 0x08, 0xc9, 0xc9, 0x0c, 0x0a, 0x0d, 0x05, 0x0d, 0xce},
    .object_stack_timer = {0xce, 0x0e, 0xce, 0x0d, 0x0f, 0xcb, 0x05, 0x11, 0x05, 0x02, 0x43, 0x03, 0x0d, 0x05, 0x85, 0x05},
    .object_stack_data_pointer = {0x00, 0x05, 0x05, 0xc3, 0x0d, 0x0d, 0x0d, 0x0d, 0x03, 0x0d, 0x0d, 0x03, 0x0d, 0x0d, 0x0d, 0x0d},
    .object_stack_extra = {0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x05, 0xc6, 0xce, 0xc6, 0xc6, 0xc6, 0xbb, 0xc6, 0x18}
};
bool running = true;

void init() {
    //do nothing for now
}

void main_loop() {
    while(running) {
        zp.whistle1_played = false; // reset the whistle
        zp.loop_counter ++;         // increment counter

        process_screen_background_flash();
        process_objects();
        process_events();

        // Reduce mushroom dazes
        if (zp.red_mushroom_daze > 0) {
            --zp.red_mushroom_daze;
        }
        if (zp.blue_mushroom_daze > 0) {
            --zp.blue_mushroom_daze;
        }

        // Increase explosion timer if non-zero
        if (zp.explosion_timer > 0) {
            ++zp.explosion_timer;
        }
    }
}

void process_screen_background_flash() {
    // not clear why we need to do this yet
}

void process_objects() {
    // Process all objects in the primary stack
    for (int i; i < 16; i++) {
        if (ps.object_stack_y == 0x00)
            continue;
        process_object(i);
    }
}

typedef struct Object {
    unsigned char type;
    unsigned short y;
    unsigned short x;
    unsigned char flags;
    unsigned char angle;
    unsigned char vel_x;
    unsigned char vel_y;
    unsigned char sprite;
    unsigned char palette;
    unsigned char data_pointer;
    unsigned char target;
    unsigned char tx;
    unsigned char ty;
    unsigned char supporting;
    unsigned char extra;
    unsigned char timer;
} Object;

void process_object(int i) {
    // Process specified object in the primary stack

    // pull object values from stack
    Object obj;
    obj.type = ps.object_stack_type[i];
    obj.y = ps.object_stack_y[i];
    obj.x = ps.object_stack_x[i];
    obj.flags = ps.object_stack_flags[i];
    obj.angle = flags;
    // flags lefted (ASL)
    obj.vel_x = ps.object_stack_vel_x;
    obj.vel_y = ps.object_stack_vel_y;
    obj.sprite = ps.object_stack_sprite;
    obj.palette = ps.object_stack_palette;
    obj.data_pointer = ps.object_stack_data_pointer;
    obj.target = ps.object_stack_target;
    obj.tx = ps.object_stack_tx;
    obj.ty = ps.object_stack_ty;
    obj.supporting = ps.object_stack_supporting;
    obj.extra = ps.object_stack_extra;
    obj.timer = ps.object_stack_timer;

    // keep a copy of the old values
    Object obj_old;
    obj_old = obj;

    // process the object
    


}

void process_events() {

}