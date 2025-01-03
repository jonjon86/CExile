#include <stdbool.h>
#include <assert.h>

#define PRIMARY_STACK_SIZE 16
#define OBJECT_COUNT 101 //100+target
#define SPRITE_COUNT 125


typedef struct ZeroPage {
    // Implementation of 6502 zero page, and functions where more appropriate
    bool whistle1_played;
    bool whistle2_played;
    bool object_being_fired;
    unsigned char autofire_timeout;
    unsigned char loop_counter;
    unsigned char red_mushroom_daze;
    unsigned char blue_mushroom_daze;
    unsigned char explosion_timer;
} ZeroPage;

ZeroPage zp; // essentially the zero page data of the 6502 version; may be better to split elsewhere as for water

bool loop_counter_XX(unsigned char x) {
    // true every n'th loop : equiv to 6502 loop_counter_XX
    return zp.loop_counter % x == 0;
};

typedef struct ObjectDefinitions {
    unsigned char sprite_idx[OBJECT_COUNT];
    unsigned char palette_idx[OBJECT_COUNT];
    bool can_pick_up[OBJECT_COUNT];
    unsigned char gravity_flags[OBJECT_COUNT];  // extracted into below
    unsigned char weight[OBJECT_COUNT];         // 1-6 weight; 7=static
    bool can_collide[OBJECT_COUNT];
    bool is_static[OBJECT_COUNT];               // weight=7
} ObjectDefinitions;

ObjectDefinitions obj_defs = {
    .sprite_idx = {  0x04, 0x14, 0x04, 0x75, 0x1e, 0x1b, 0x10, 0x10, 0x10, 0x1c, 0x1c, 0x20, 0x70, 0x70, 0x61, 0x52,
                     0x72, 0x4f, 0x21, 0x08, 0x08, 0x21, 0x21, 0x08, 0x08, 0x21, 0x78, 0x78, 0x13, 0x13, 0x13, 0x5e,
                     0x5e, 0x15, 0x16, 0x16, 0x16, 0x16, 0x04, 0x52, 0x45, 0x64, 0x64, 0x64, 0x64, 0x64, 0x59, 0x59,
                     0x59, 0x59, 0x6d, 0x63, 0x63, 0x0b, 0x0f, 0x17, 0x14, 0x17, 0x39, 0x17, 0x4a, 0x4b, 0x3c, 0x41,
                     0x1a, 0x71, 0x2e, 0x5d, 0x17, 0x20, 0x56, 0x57, 0x47, 0x22, 0x60, 0x7b, 0x76, 0x76, 0x58, 0x58,
                     0x21, 0x4d, 0x4d, 0x4d, 0x4d, 0x20, 0x4d, 0x4d, 0x22, 0x6b, 0x6c, 0x6c, 0x79, 0x6c, 0x04, 0x7a,
                     0x63, 0x7c, 0x7c, 0x79, 0x77},
    // & &80 = can be picked up
    // & &7f = palette
    .palette_idx = { 0x3e, 0x1b, 0x2e, 0xf2, 0x32, 0x32, 0x53, 0x05, 0x0f, 0x14, 0x29, 0xbc, 0x65, 0x65, 0xf7, 0x97,
                    0xd3, 0xc7, 0xef, 0x7e, 0x5f, 0x3c, 0x5a, 0x11, 0x2d, 0x34, 0xe1, 0x80, 0x55, 0x1b, 0x4c, 0x59,
                    0x23, 0x72, 0x2e, 0x7b, 0x77, 0x33, 0x39, 0x8b, 0x44, 0x51, 0x0d, 0x46, 0x2b, 0x53, 0x35, 0x3c,
                    0x02, 0x01, 0x70, 0x9c, 0xcf, 0x00, 0x14, 0x10, 0x4b, 0x10, 0x0c, 0x34, 0x6b, 0x6b, 0x42, 0x42,
                    0x31, 0x6f, 0x15, 0x2e, 0x12, 0xcb, 0x33, 0xb1, 0x62, 0x00, 0xdb, 0x9f, 0x8f, 0xcf, 0xe5, 0x8e,
                    0xef, 0xab, 0xad, 0x95, 0x9c, 0x91, 0x92, 0xa6, 0x91, 0xb1, 0x8e, 0xe0, 0xa2, 0xb5, 0xb3, 0xe3,
                    0xd5, 0xe3, 0xd7, 0xf0, 0xf1},

    // & &80 = doesn't collide with other objects
    // & &07 = weight; 01 = light, 06 = heavy, 07 = static
    .gravity_flags = {    0x03, 0x23, 0x23, 0x22, 0x77, 0x77, 0x26, 0x6d, 0x6e, 0xf7, 0x6e, 0x25, 0xf7, 0xf7, 0x25, 0x69,
                        0x6b, 0x68, 0x04, 0x63, 0x66, 0x66, 0x65, 0x66, 0x62, 0x64, 0x69, 0x69, 0x24, 0x25, 0x26, 0x77,
                        0x77, 0x23, 0x05, 0x05, 0x05, 0x05, 0x04, 0x68, 0x77, 0x6a, 0x6c, 0x6b, 0x6b, 0x6c, 0x6c, 0x6c,
                        0x6d, 0x6d, 0xe5, 0x61, 0x61, 0xe4, 0xe5, 0xe8, 0x24, 0xec, 0x26, 0xd7, 0x57, 0x57, 0x57, 0x57,
                        0xd6, 0xd7, 0x57, 0x25, 0x82, 0x26, 0x25, 0x24, 0x77, 0x74, 0x24, 0x02, 0x22, 0x24, 0x22, 0x22,
                        0x24, 0x23, 0x23, 0x23, 0x23, 0x25, 0x23, 0x23, 0x02, 0x26, 0x23, 0x23, 0x23, 0x23, 0x26, 0x25,
                        0x22, 0x22, 0x22, 0x25, 0xe7}
};

typedef struct SpriteDefinitions {
    unsigned char width[SPRITE_COUNT];
    unsigned char height[SPRITE_COUNT];
    unsigned char offset_a[SPRITE_COUNT];
    unsigned char offset_b[SPRITE_COUNT];
} SpriteDefinitions;

SpriteDefinitions sprite_defs = {
    .width = {  0xc0, 0xa0, 0x50, 0x90, 0x40, 0x50, 0x60, 0x40, 0x21, 0x20, 0x20, 0x21, 0x11, 0x11, 0x50, 0x30,
                0x60, 0x51, 0x50, 0x50, 0x80, 0x50, 0x50, 0xb0, 0xb0, 0x80, 0x80, 0x50, 0x90, 0x70, 0x50, 0x30,
                0x40, 0x20, 0x10, 0xf1, 0xf1, 0x71, 0x30, 0xf0, 0xf0, 0xf0, 0xf0, 0xf1, 0xf0, 0x30, 0x60, 0x30,
                0x30, 0xf0, 0xf0, 0xf1, 0xf0, 0xf0, 0xf0, 0xf0, 0xf1, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0,
                0xf0, 0x30, 0x60, 0xf0, 0xf0, 0x70, 0x00, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x31, 0x41, 0xf0, 0x20,
                0x40, 0x20, 0x50, 0x50, 0x30, 0x70, 0xc0, 0x40, 0x40, 0x20, 0x60, 0x60, 0x40, 0xf0, 0x70, 0x20,
                0x70, 0x90, 0xc0, 0x30, 0x40, 0x50, 0x60, 0x40, 0x40, 0x30, 0xf0, 0x20, 0x30, 0x31, 0x70, 0xb1,
                0xf0, 0x70, 0x51, 0x41, 0x50, 0x51, 0x30, 0x80, 0x30, 0x30, 0x50, 0x50, 0x40},

    .height = { 0x40, 0x80, 0x98, 0x91, 0xa8, 0xa0, 0xa0, 0xa0, 0x09, 0x08, 0x10, 0x19, 0x19, 0x18, 0x58, 0x18,
                0x60, 0x78, 0x81, 0x98, 0x78, 0x70, 0x98, 0x90, 0x28, 0x48, 0x78, 0x69, 0x20, 0x28, 0x38, 0x48,
                0x38, 0x20, 0x08, 0xf8, 0xf8, 0x68, 0xf9, 0xf9, 0xb9, 0x79, 0x39, 0xf8, 0x78, 0x38, 0x38, 0x38,
                0xf8, 0x38, 0x78, 0xf8, 0xf8, 0x78, 0xf8, 0x78, 0xf8, 0xf8, 0xc9, 0x78, 0x38, 0xf8, 0x89, 0x09,
                0x49, 0xf8, 0xf8, 0xf9, 0xf9, 0x68, 0x00, 0xf8, 0x78, 0x38, 0x39, 0xf9, 0xf9, 0x28, 0x48, 0x18,
                0x11, 0x19, 0x20, 0x29, 0x41, 0xf8, 0x70, 0x30, 0x20, 0x20, 0x19, 0x18, 0x28, 0x60, 0x48, 0x80,
                0x58, 0x58, 0x39, 0x19, 0x68, 0x68, 0x68, 0x58, 0x68, 0x58, 0x38, 0x38, 0x28, 0x48, 0x48, 0x48,
                0x48, 0x08, 0x30, 0x20, 0x28, 0x39, 0x70, 0x38, 0x30, 0x20, 0x20, 0x20, 0x20},

    .offset_a = {0x36, 0x44, 0xc5, 0x04, 0x66, 0x06, 0x91, 0x41, 0x60, 0x43, 0xd0, 0xd4, 0xe4, 0xe4, 0xa4, 0x03,
                0x97, 0x63, 0x03, 0x05, 0x77, 0x97, 0x65, 0x06, 0x06, 0x06, 0x06, 0xe6, 0xc6, 0xd6, 0xe6, 0xf6,
                0x37, 0xd6, 0x65, 0x02, 0x03, 0x12, 0xc2, 0x03, 0x03, 0x03, 0x03, 0x02, 0x02, 0x04, 0x96, 0xc4,
                0x04, 0x04, 0x43, 0x43, 0x00, 0x00, 0x05, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x05, 0x05, 0x05,
                0x05, 0x00, 0xc0, 0x00, 0x00, 0x44, 0xc0, 0x03, 0x03, 0x03, 0x07, 0x07, 0x53, 0x17, 0x02, 0xd4,
                0x80, 0xd4, 0x07, 0xf6, 0xc6, 0x87, 0x04, 0x84, 0x47, 0x67, 0xc6, 0xc6, 0x96, 0x02, 0x44, 0xd4,
                0xc3, 0x67, 0x36, 0x86, 0x01, 0x51, 0x31, 0xb1, 0xb1, 0xc4, 0x02, 0x67, 0x47, 0x15, 0x55, 0x35,
                0x05, 0x00, 0x16, 0x37, 0xe6, 0x76, 0x04, 0xb6, 0xc4, 0x47, 0x84, 0xb6, 0xa4},

    .offset_b = {0x42, 0x02, 0xe9, 0x81, 0x98, 0x98, 0xe0, 0xe0, 0x7a, 0x00, 0x72, 0xe1, 0x5a, 0x3a, 0x81, 0x00,
                0xe1, 0x0a, 0x02, 0xe9, 0x60, 0x68, 0xe9, 0x00, 0x00, 0x49, 0x49, 0x50, 0x68, 0x68, 0x58, 0x50,
                0xd0, 0xd9, 0xa0, 0x00, 0x28, 0x01, 0x01, 0x09, 0x49, 0x89, 0xc9, 0x01, 0x81, 0x41, 0x81, 0x41,
                0x80, 0x41, 0x80, 0x20, 0x00, 0x00, 0x00, 0x00, 0x89, 0x80, 0x80, 0x80, 0x31, 0x80, 0x09, 0x89,
                0x49, 0x80, 0x80, 0x71, 0x01, 0xd0, 0x00, 0x80, 0x01, 0x41, 0x4a, 0x89, 0xa8, 0xe9, 0xf9, 0xc0,
                0x72, 0xc0, 0x00, 0x20, 0x00, 0xe0, 0x00, 0x18, 0x11, 0xe1, 0xc0, 0xc8, 0x51, 0xb1, 0x78, 0x00,
                0x2a, 0x00, 0x02, 0x02, 0x00, 0x00, 0x70, 0x00, 0x60, 0xe0, 0x4a, 0x0a, 0xb1, 0x99, 0x99, 0x99,
                0x99, 0x72, 0xc9, 0x61, 0x59, 0xc1, 0xd0, 0x11, 0x88, 0x89, 0x90, 0xe8, 0x90}
};

//separate the flags from the data so we have a clean view to use later
void init_object_definitions(void) {
    for (int i = 0; i < OBJECT_COUNT; ++i) {
        obj_defs.can_pick_up[i] = obj_defs.palette_idx[i] & 0x80;
        obj_defs.palette_idx[i] = obj_defs.palette_idx[i] - obj_defs.palette_idx[i] & 0x80;

        obj_defs.can_collide[i] = obj_defs.gravity_flags[i] & 0x80;
        obj_defs.weight[i] = obj_defs.gravity_flags[i] & 0x07;
        obj_defs.is_static[i] = obj_defs.weight == 0x07;
    }
}

// Primary stack (active objects)
// slot 17 is target, and 18 is waterfall; can we remove these elsewhere?
// Combined x/y high & low into single 16-bit value
typedef struct PrimaryStack {
    unsigned char object_stack_type[PRIMARY_STACK_SIZE];
    unsigned char object_stack_sprite[PRIMARY_STACK_SIZE];
    unsigned short object_stack_x[PRIMARY_STACK_SIZE];
    unsigned short object_stack_y[PRIMARY_STACK_SIZE];
    // object_stack_flags
    // 80 set = horizontal invert (facing left)
    // 40 set = vertical invert (upside down)
    // 20 set = remove from display
    // 10 set = teleporting
    // 08 set = damaged
    // 02 set = collision detected
    // 01 set at load positon?
    unsigned char object_stack_flags[PRIMARY_STACK_SIZE];

    // object_stack_palette:
    // 10 set = damaged
    unsigned char object_stack_palette[PRIMARY_STACK_SIZE];
    unsigned char object_stack_vel_x[PRIMARY_STACK_SIZE];
    unsigned char object_stack_vel_y[PRIMARY_STACK_SIZE];
    unsigned char object_stack_target[PRIMARY_STACK_SIZE];
    unsigned char object_stack_tx[PRIMARY_STACK_SIZE];
    unsigned char object_stack_energy[PRIMARY_STACK_SIZE];
    unsigned char object_stack_ty[PRIMARY_STACK_SIZE];
    unsigned char object_stack_supporting[PRIMARY_STACK_SIZE];
    unsigned char object_stack_timer[PRIMARY_STACK_SIZE];
    unsigned char object_stack_data_pointer[PRIMARY_STACK_SIZE];
    unsigned char object_stack_extra[PRIMARY_STACK_SIZE];
} PrimaryStack;

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

enum obj_types {
    obj_player,
    obj_active_chatter,
    obj_pericles_crew_member,
    obj_fluffy,
    obj_small_nest,
    obj_big_nest,
    obj_red_frogman,
    obj_green_frogman,
    obj_cyan_frogman,
    obj_red_slime,
    obj_green_slime,
    obj_yellow_ball,
    obj_sucker,
    obj_deadly_sucker,
    obj_big_fish,
    obj_worm,
    obj_pirahna,
    obj_wasp,
    obj_active_grenade,
    obj_icer_bullet,
    obj_tracer_bullet,
    obj_ball,
    obj_blue_death_ball,
    obj_red_bullet,
    obj_pistol_bullet,
    obj_plasma_ball,
    obj_hover_ball,
    obj_invisible_hover_ball,
    obj_magenta_robot,
    obj_red_robot,
    obj_blue_robot,
    obj_green_white_turret,
    obj_cyan_red_turret,
    obj_hovering_robot,
    obj_magenta_clawed_robot,
    obj_cyan_clawed_robot,
    obj_green_clawed_robot,
    obj_red_clawed_robot,
    obj_triax,
    obj_maggot,
    obj_gargoyle,
    obj_red_magenta_imp,
    obj_red_yellow_imp,
    obj_blue_cyan_imp,
    obj_cyan_yellow_imp,
    obj_red_cyan_imp,
    obj_green_yellow_bird,
    obj_white_yellow_bird,
    obj_red_magenta_bird,
    obj_invisible_bird,
    obj_lightning,
    obj_red_mushroom_ball,
    obj_blue_mushroom_ball,
    obj_engine_fire,
    obj_red_drop,
    obj_fireball,
    obj_inactive_chatter,
    obj_moving_fireball,
    obj_giant_wall,
    obj_engine_thruster,
    obj_horizontal_door,
    obj_vertical_door,
    obj_horizontal_stone_door,
    obj_vertical_stone_door,
    obj_bush,
    obj_teleport_beam,
    obj_switch,
    obj_chest_,
    obj_explosion,
    obj_rock_,
    obj_cannon,
    obj_mysterious_weapon,
    obj_maggot_machine,
    obj_placeholder,
    obj_destinator,
    obj_energy_capsule,
    obj_empty_flask,
    obj_full_flask,
    obj_remote_control_device,
    obj_cannon_control_device,
    obj_inactive_grenade,
    obj_cyan_yellow_green_key,
    obj_red_yellow_green_key,
    obj_green_yellow_red_key,
    obj_yellow_white_red_key,
    obj_coronium_boulder,
    obj_red_magenta_red_key,
    obj_blue_cyan_green_key,
    obj_coronium_crystal,
    obj_jetpack_booster,
    obj_pistol,
    obj_icer,
    obj_discharge_device,
    obj_plasma_gun,
    obj_protection_suit,
    obj_fire_immunity_device,
    obj_mushroom_immunity_pull,
    obj_whistle_1,
    obj_whistle_2,
    obj_radiation_immunity_pull,
    obj_undefined
};

#define X_RANGES 4
#define WATER_ENDGAME_POS 1
typedef struct Water {
    unsigned short x_ranges[X_RANGES];
    unsigned short water_level_by_x_range[X_RANGES];
    unsigned short desired_water_level_by_x_range[X_RANGES];
    unsigned short water_level;             //& water_level_low : might belong in zp as dynamic
    unsigned short water_level_on_screen;   //might belong in zp as dynamic
    unsigned short water_level_end_game;
} Water;

Water water = {
    .x_ranges = {0x0000, 0x5400, 0x7400, 0xa000},
    .water_level_by_x_range = {0xce00, 0xdf00, 0xc100, 0xc100},
    .desired_water_level_by_x_range = {0xce00, 0xdf00, 0xc100, 0xc100}
};

unsigned short get_water_level_for_x(unsigned short x) {
    unsigned short level;
    for (unsigned char i = X_RANGES - 1; i > 0; --i) {
        if (x > water.x_ranges[i]) {
            level = water.water_level_by_x_range[i];
            break;
        }
    };
    //if (water.water_level_by_x_range[WATER_ENDGAME_POS] > level) {
    //    level = water.water_level_by_x_range[WATER_ENDGAME_POS];
    if (water.water_level_end_game > level)
        level = water.water_level_end_game;

    return level;
}

void init() {
    init_object_definitions();
}

bool running = true;

void process_screen_background_flash() {
    // not clear why we need to do this yet
}

typedef struct Sprite {
    unsigned char index;
    unsigned char height;
    unsigned char width;
    unsigned char offset_a;
    unsigned char offset_b;
    //do we need these?
    bool flipped_vertical;
    bool flipped_horizontal;
    unsigned char palette;
} Sprite;

typedef struct PrimaryStackObject {
    // stack values (can be stored back)
    unsigned char type;
    bool is_player;
    unsigned short y;
    unsigned short x;
    unsigned char flags;
    unsigned char angle;
    unsigned char vel_x;
    unsigned char vel_y;
    unsigned char sprite_idx;
    unsigned char palette;
    unsigned char data_pointer;
    unsigned char target;
    unsigned char energy;
    unsigned char tx;
    unsigned char ty;
    unsigned char supporting;
    unsigned char extra;
    unsigned char timer;

    // object definition copies
    Sprite sprite;
    unsigned char weight;
    bool can_collide;
    bool can_pick_up;
    bool is_static;
} PrimaryStackObject;

//Load the various properties for a primary stack object by index
PrimaryStackObject get_object_from_stack(int i) {
    assert(i < PRIMARY_STACK_SIZE);

    PrimaryStackObject obj;

    obj.type = ps.object_stack_type[i];
    obj.is_player = obj.type = (unsigned char)obj_player;

    obj.y = ps.object_stack_y[i];
    obj.x = ps.object_stack_x[i];
    obj.flags = ps.object_stack_flags[i];
    obj.angle = obj.flags; // not sure why this is a copy
    // flags lefted (ASL); probably want to split flags out into their meaning, though probably different per object
    obj.vel_x = ps.object_stack_vel_x[i];
    obj.vel_y = ps.object_stack_vel_y[i];
    obj.sprite_idx = ps.object_stack_sprite[i];
    obj.palette = ps.object_stack_palette[i];
    obj.data_pointer = ps.object_stack_data_pointer[i];
    obj.target = ps.object_stack_target[i];
    obj.energy = ps.object_stack_energy[i];
    obj.tx = ps.object_stack_tx[i];
    obj.ty = ps.object_stack_ty[i];
    obj.supporting = ps.object_stack_supporting[i];
    obj.extra = ps.object_stack_extra[i];
    obj.timer = ps.object_stack_timer[i];

    // add object definition values
    assert(obj.type < OBJECT_COUNT);

    // sprite data
    unsigned char idx = obj.sprite_idx;
    obj.sprite.index = idx;
    obj.sprite.width = sprite_defs.width[idx];
    obj.sprite.height = sprite_defs.height[idx];
    obj.sprite.offset_a = sprite_defs.offset_a[idx];
    obj.sprite.offset_b = sprite_defs.offset_b[idx];

    // other object values
    obj.weight = obj_defs.weight[obj.type];
    obj.can_collide = obj_defs.can_collide[obj.type];
    obj.can_pick_up = obj_defs.can_pick_up[obj.type];

    return obj;
}

void zero_velocities(PrimaryStackObject* obj) {
    obj->vel_x = 0;
    obj->vel_y = 0;
}

void move_object(PrimaryStackObject* obj) {
    obj->x = obj->x + obj->vel_x;
    obj->y = obj->y + obj->vel_y;
}

void process_object(int i) {
    // Process specified object in the primary stack
    assert(i <= PRIMARY_STACK_SIZE);

    // pull object values from stack
    PrimaryStackObject obj = get_object_from_stack(i);

    // keep a copy of the old values
    PrimaryStackObject obj_old = obj;

    // process the object
    unsigned char current_rotator = i * 17 + zp.loop_counter;   // pseudo random number 00-ff
    unsigned char current_rotator_low = current_rotator & 0x0f; // pseudo random number 00-0f

    //TODO: reset whistle 2 ??

    // if static set velocities to zero
    if (obj.is_static) {
        zero_velocities(&obj);
    }

    unsigned char acc_x = 0;
    unsigned char acc_y = 0;
    unsigned char gun_aim_acc = 0;
    unsigned char collision_with_other_object_top_bottom = 0;
    unsigned char collision_with_other_object_sides = 0;
    unsigned char wall_collision_frict_y_vel = 0;
    unsigned char something_about_player_angle = 0xff; //I think??
    unsigned char is_invisible = 0;

    move_obj(&obj);

    if (obj.is_player) {
        //&1aea
    }



    //CONTINUE HERE

}

void process_objects() {
    // Process all objects in the primary stack
    for (int i = 0; i < 16; i++) {
        if (ps.object_stack_y == 0x00)
            continue;
        process_object(i);
    }
}



void process_events() {

}

void main_loop() {
    while (running) {
        zp.whistle1_played = false; // reset the whistle
        zp.loop_counter++;         // increment counter

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


int main(int argc, char* argv[]) {
    init();
    main_loop();
}
