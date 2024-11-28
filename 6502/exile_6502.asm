Exile disassembly
=================
Published by Superior Software in 1988, Exile is widely regarded as the most
technically advanced game released for the BBC Micro. Featuring an enormous
procedurally generated landscape, a complete physics engine and a host of game
elements to interact with, it remains unsurpassed in pushing the capabilities
of the system to their limits.

The following disassembly was created by a process of reverse engineering a
binary image, without access to any source code. Consequently, although it is
reasonably complete, there are areas in which the original intentions of the
authors have been impossible to discern thanks to the heavy optimisation of
their code. Nevertheless, it should provide an indication of the complexity
present in this game, as well as many of the programming tricks used to
squeeze it all into a mere 16k of memory.

The author of this disassembly imposes no additional copyright restrictions
beyond those already present on the game itself. It is provided for educational
purposes only, and it is hoped that the original authors will accept it in the
good faith it was intended - as a tribute to their skills.

Technical notes
===============
This disassembly analyses the standard version of Exile, without sideways RAM.
Almost every byte of memory is used, including pretty much all of zero page.
There is extensive use of self-modifying code throughout, which has been
heavily optimised. The carry flag is often used in association with shift
operations to process boolean variables. The BIT operation is often used for
efficient branching as well as providing multiple entry points to functions.

Areas of particular interest:

&0d4d - &10cf : sprite plotting routines
All the sprites used in the game are generated from a 128x128 four colour
bitmap (stored at &53ec). The sprite plotting routines allow an arbitrary
portion of this bitmap to be translated into a choice of colour schemes and
flipped horizontally and vertically. The sixteen colours provided by the system
are split into two groups of eight - one for the background, one for objects.

&1715 - &19a6 : landscape generation routines
Procedural generation is used to create a 256x256 square landscape, overlaid
with a small amount of mapped data (stored at &4fec) for areas associated with
the start and end game.

&0860 - &0985 : primary object stack
&0af2 - &0b72 : secondary object stack
&05ef - &07ec : tertiary object stack (part one)
&0986 - &0af1 : tertiary object stack (part two)
&1a0b - &1e18 : physics engine
Objects are stored in one of three stacks. The primary object stack contains
up to sixteen objects that are onscreen, which are processed by the physics
engine. The secondary object stack provides an additional thirty two slots for
storing partial information about permanent objects dropped offscreen. However,
the majority of the objects in the game are transient. Those that are fixed to,
or emerge from, a particular location are stored in the tertiary object stack,
which keeps track of their status.

For example, a nest of birds is stored in the tertiary stack. When the player
moves near to it, a bird may emerge, creating an object on the primary stack,
and the nest is marked as having one fewer bird. Should the player teleport
away, the bird is now offscreen, removed from the primary stack and the nest
is marked as having one more bird. A bullet, on the other hand, would simply
disappear from the primary stack, whereas a dropped remote control device
would be stored on the secondary stack.

&028a - &04a5 : object tables
There are precisely one hundred distinct types of object (&64), each of which
has an associated sprite, palette and function to handle its behaviour. Object
&49 is a placeholder which turns into another object based on its data value.

&12a6 - &1398 : interrupt routine
&11f6 - &1243 : function table
A custom interrupt routine handles sound and keyboard events. Each keypress
has a function associated with it, which the routine calls by pushing its
details to the stack.

Angles are stored such that &100 = 360 degrees, starting from straight right at
&00 and increasing clockwise. &40 = down, &80 = left, &c0 = up.

Game-play notes
===============
Invisible objects become visible under the influence of red mushroom daze.

Windy caverns cease to be so once underwater.

Imps can be fed according to their species (see &316b) to yield energy
capsules, a strange weapon that fires plasma balls or active grenades.

Each creature has a minimum energy which must be overcome in order to destroy
it. Clawed robots therefore cannot be destroyed simply by firing at them
repeatedly with an icer - a more explosive means of destruction must be found.

Interesting Pokes
=================
&0806 - &0818 = &ff
acquire all keys and equipment

&0822 = &04
see teleport positions left behind by developers

&0823 = x, &0859 = y
set first teleport position

&0848 - &084c = object type
fill pockets with objects of desired type

&0854 - &0859 = energy
set weapon energy levels

&1c4a = y
remove surface wind below y (default = &4f)

&24aa = &60
player is never damaged

&2c2b - &2c2c = &ea
scroll around landscape without moving player

&2cdc = object type
fire objects of desired type when jetpack is selected

&25de = &80
set water level to rise above maggot machine, triggering earthquake

&34c6 - &34c7 = &ea
pocket all objects, regardless of size

Disassembly
===========
; $.ExileB
; FF1200 FF7200 006080
;
; Addresses used in zero-page:
;     &00 square_is_mapped_data
;     &01 intro_one
;     &02 intro_two
;     &03 intro_three
;     &04 npc_speed
;     &05 something_about_player_angle
;     &06 current_object_rotator
;     &07 current_object_rotator_low
;     &08 square_sprite
;     &09 square_orientation
;     &0a held_object_x_low
;     &0b held_object_x
;     &0c held_object_y_low
;     &0d held_object_y
;     &0e this_object_target_object
;     &0f f3_xy
;     &10 f2_xy
;     &11 this_object_extra
;     &12 this_object_timer
;     &13 this_object_timer_old
;     &14 this_object_tx
;     &15 this_object_energy
;     &16 this_object_ty
;     &17 object_onscreen
;     &18 wall_collision_bottom_minus_top
;     &19 any_collision_top_bottom
;     &1a wall_collision_top_minus_bottom
;     &1b wall_collision_top_or_bottom
;     &1c wall_collision_angle
;     &1d wall_collision_frict_y_vel
;     &1e wall_collision_post_angle
;     &1f underwater
;     &20 this_object_water_level
;     &21 npc_fed
;     &22 npc_type
;     &23 used_in_sound
;     &24 object_static
;     &25 bells_to_sound
;     &26 copy_of_stack_pointer
;     &27 whistle1_played
;     &28 sucking_damage
;     &29 sucking_angle_modifier
;     &2a screen_background_flash_counter
;     &2b object_is_invisible
;     &2c object_affected_by_gravity
;     &2d background_processing_flag
;     &2e objects_to_reserve
;     &2f objects_two_reserve
;     &30 child_created
;     &31 player_crawling
;     &32 gun_aim_value
;     &33 gun_aim_velocity
;     &34 firing_angle
;     &35 sucking_distance
;     &36 player_bullet
;     &37 this_object_angle
;     &38 this_object_weight
;     &39 this_object_flags_lefted
;     &3a this_object_width
;     &3b this_object_supporting
;     &3c this_object_height
;     &3d this_object_data_pointer
;     &3e this_object_target
;     &3f this_object_target_old
;     &40 acceleration_x
;     &41 this_object_type
;     &42 acceleration_y
;     &43 this_object_vel_x
;     &44 this_object_vel_x_old
;     &45 this_object_vel_y
;     &46 this_object_vel_y_old
;     &47 this_object_x_max_low
;     &48 this_object_x_max
;     &49 this_object_y_max_low
;     &4a this_object_y_max
;     &4b this_sprite_width
;     &4c this_sprite_width_old
;     &4d this_sprite_height
;     &4e this_sprite_height_old
;     &4f this_object_x_low
;     &50 this_object_x_low_old
;     &51 this_object_y_low
;     &52 this_object_y_low_old
;     &53 this_object_x
;     &54 this_object_x_old
;     &55 this_object_y
;     &56 this_object_y_old
;     &57 this_object_screen_x_low
;     &58 this_object_screen_x_low_old
;     &59 this_object_screen_y_low
;     &5a this_object_screen_y_low_old
;     &5b this_object_screen_x
;     &5c this_object_screen_x_old
;     &5d this_object_screen_y
;     &5e this_object_screen_y_old
;     &5f this_sprite_a
;     &60 this_sprite_a_old
;     &61 this_sprite_b
;     &62 this_sprite_b_old
;     &63 this_sprite_flipping_flags
;     &64 this_sprite_flipping_flags_old
;     &65 this_sprite_partflip
;     &66 this_sprite_vertflip_old
;     &67 something_plot_var
;     &68 some_other_plot_var
;     &69 bytes_per_line_in_sprite
;     &6a copy_of_stack_pointer_6a
;     &6b bytes_per_line_on_screen
;     &6c lines_in_sprite
;     &6d (unused)
;     &6e skip_sprite_calculation_flags
;     &6f this_object_flags
;     &70 this_object_flags_old
;     &71 this_object_flipping_flags
;     &72 this_object_flipping_flags_old
;     &73 this_object_palette
;     &74 this_object_palette_old
;     &75 this_object_sprite
;     &76 this_object_sprite_old
;     &77 wall_collision_count_left
;     &78 wall_collision_count_top
;     &79 wall_collision_count_right
;     &7a wall_collision_count_bottom
;     &7b support_delta_x_low
;     &7c support_delta_x wall_y_start_lookup_pointer
;     &7d support_delta_y_low wall_y_start_lookup_pointer_h_4
;     &7e support_delta_y wall_y_start_base
;     &7f support_overlap_x_low wall_sprite
;     &80 support_overlap_x wall_y_start_lookup_pointer_4
;     &81 support_overlap_y_low wall_y_start_lookup_pointer_h_4
;     &82 support_overlap_y wall_y_start_base_4
;     &83 distance wall_sprite_4
;     &84 this_object_y_low_bumped some_kind_of_velocity_copy distance_left
;     &85 this_object_y_max_low_bumped
;     &86 (unused)
;     &87 this_object_x_centre_low particle_x_low
;     &88 stack_object_x_centre_low
;     &89 this_object_y_centre_low particle_y_low
;     &8a stack_object_y_centre_low
;     &8b this_object_x_centre particle_x 
;     &8c stack_object_x_centre
;     &8d this_object_y_centre particle_y
;     &8e stack_object_y_centre
;     &8f screen_address
;     &90 other_object_weight support_weight_delta
;     &91 pixel_x_low
;     &92 pixel_x
;     &93 pixel_y_low screen_address_two
;     &94 pixel_y screen_address_two_h
;     &95 square_x
;     &96 (unused)
;     &97 square_y
;     &98 temp_a supporting_object_xy
;     &99 velocity_signs pixel_colour
;     &9a (various)
;     &9b (various)
;     &9c (various)
;     &9d (various)
;     &9e (various)
;     &9f number_particles this_object_gravity_flags
;     &a0 (various)
;     &a1 find_carry
;     &a2 (various)
;     &a3 (various)
;     &a4 map_address
;     &a5 map_address_high
;     &a6 (unused)
;     &a7 (unused)
;     &a8 (unused)
;     &a9 (unused)
;     &aa current_object
;     &ab other_object_minus_10 this_object_width_divided_32
;     &ac key_number
;     &ad (unused)
;     &ae plotter_x
;     &af strip_length
;     &b0 screen_offset
;     &b1 screen_offset_h
;     &b2 screen_start_square_x_low_copy
;     &b3 some_screen_address_offset
;     &b4 velocity_x
;     &b5 angle
;     &b6 velocity_y
;     &b7 some_kind_of_velocity
;     &b8 delta_magnitude
;     &b9 something_player_collision_value
;     &ba player_immobility_daze
;     &bb player_nothrust_daze
;     &bc this_object_data
;     &bd new_object_data_pointer
;     &be new_object_type_pointer
;     &bf this_object_offscreen
;     &c0 loop_counter
;     &c1 loop_counter_every_40
;     &c2 loop_counter_every_20
;     &c3 loop_counter_every_10
;     &c4 loop_counter_every_08
;     &c5 loop_counter_every_04
;     &c6 loop_counter_every_02
;     &c7 screen_start_square_x_low
;     &c8 screen_start_square_x
;     &c9 screen_start_square_y_low
;     &ca screen_start_square_y
;     &cb scroll_square_x_velocity_low
;     &cc scroll_square_x_velocity_high
;     &cd scroll_square_y_velocity_low
;     &ce scroll_square_y_velocity_high
;     &cf scroll_x_direction
;     &d0 (unused)
;     &d1 scroll_y_direction
;     &d2 something_x_acc
;     &d3 gun_aim_acceleration
;     &d4 something_y_acc
;     &d5 (unused)
;     &d6 (unused)
;     &d7 (unused)
;     &d8 (unused)
;     &d9 timer_1
;     &da timer_2
;     &db timer_3
;     &dc timer_4
;     &dd object_held
;     &de player_angle
;     &df player_facing

; wall_base_y_lookup
#0100: 00 00 00 00 00 00 00 00
#0108: 00 08 10 18 20 28 30 38
#0110: 00 10 20 30 40 50 60 70
#0118: 08 28 48 68 88 a8 c8 e8
#0120: ff ff 00 00 00 00 00 00
#0128: 60 98 b8 d0 e0 f0 ff ff
#0130: 00 00 08 18 28 40 60 98
#0138: 00 00 ff ff ff ff ff ff
#0140: 38 30 28 20 18 10 08 00
#0148: 70 60 50 40 30 20 10 00
#0150: e8 c8 a8 88 68 48 28 08
#0158: 00 00 00 00 00 00 ff ff
#0160: ff ff f0 e0 d0 b8 98 60
#0168: 98 60 40 28 18 08 00 00
#0170: ff ff ff ff ff ff 00 00
#0178: 40 40 00 00 00 00 00 00
#0180: 00 00 00 00 00 00 40 40
#0188: 00 00 ff ff ff ff 00 00
#0190: 40 40 00 00 00 00 40 40
#0198: 80 68 48 10 00 00 00 00
#01a0: 00 00 00 00 10 48 68 80

; process_keys
&01a8: a2 26            LDX #&26
&01aa: 86 ac            STX &ac ; key_number
&01ac: a6 ac            LDX &ac ; key_number
&01ae: bd 6b 12         LDA &126b,X ; keys_pressed
&01b1: 10 0f            BPL &01c2 ; not_pressed
&01b3: c9 c0            CMP #&c0
&01b5: bd 1d 12         LDA &121d,X ; function_table_h
&01b8: 6a               ROR
&01b9: 10 04            BPL &01bf
&01bb: b0 05            BCS &01c2 ; not_pressed
&01bd: 29 7f            AND #&7f
&01bf: 20 ca 01         JSR &01ca ; call_function
; not_pressed
&01c2: c6 ac            DEC &ac ; key_number
&01c4: 10 e6            BPL &01ac
&01c6: ee f5 11         INC &11f5 ; keys_processed
&01c9: 60               RTS
; call_function
&01ca: 48               PHA
&01cb: bd f6 11         LDA &11f6,X ; function_table
&01ce: 48               PHA
&01cf: 60               RTS

; intro2
&01d0: 58               CLI 
&01d1: a9 60            LDA #&60	                                        # wipe &6000 - &8000 (screen memory)
&01d3: 85 90            STA &90; screen_address_h
&01d5: a9 00            LDA #&00
&01d7: 85 8f            STA &8f; screen_address
&01d9: a8               TAY
&01da: 91 8f            STA (&8f),Y; screen_address
&01dc: c8               INY
&01dd: d0 fb            BNE &01da
&01df: e6 90            INC &90; screen_address_h
&01e1: 10 f7            BPL &01da
&01e3: a9 01            LDA #&01
&01e5: a2 40            LDX #&40
&01e7: 8d 00 fe         STA &fe00 	                                        # write to video controller (register number)
&01ea: 8e 01 fe         STX &fe01 	                                        # write to video controller (register value)
&01ed: 4c b6 19         JMP &19b6 ; main_loop

; &01ff and descending is the 6502 stack
#01f0: aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa

#0200: aa aa aa aa
#0204: a6 12 ; IRQ1V - Main interrupt vector

; tables used in particle generation
;
; &0206 = particle_life_randomness_table
; &0207 = particle_life_table
; &0208 = particle_velocity_randomness_table
; &0209 = particle_velocity_table
; &020a = particle_colour_table
; &020b = particle_colour_randomness_table
; &020c = particle_flags_table
;         &80 = set angle based on velocity or acceleration
;         &40 = set angle based on velocity
;         &20 = use object x/y
; &020d = particle_x_randomness_table
; &020e = particle_y_randomness_table
; &020f = particle_x_velocity_randomness_table
; &0210 = particle_y_velocity_randomness_table
;       6  7  8  9  a  b  c  d  e  f  0
;       life   vel   col  f  x  y xv yv
;       r     r        r     r  r  r  r
#0206: 0f 1e 0f 0a 91 02 a0 1f 1f 03 03 ; + &00 # plasma ball
#0211: 0f 03 0f 18 86 01 ed 00 00 03 03 ; + &0b # jetpack thrust
#021c: ff 00 00 00 91 46 2a 00 00 2f 2f ; + &16 # explosion 
#0227: 07 05 07 0a 81 02 20 7f 3f 00 00 ; + &21 # fireball
#0232: 07 02 0f 03 82 01 2a 00 00 03 03 ; + &2c # icer
#023d: 0f 14 0f 1e 81 42 00 00 00 0f 03 ; + &37 # engine thruster
#0248: 03 10 01 3f a8 07 2d 00 00 00 01 ; + &42 # gun aim
#0253: 1c 08 00 00 88 47 00 ff ff 00 00 ; + &4d # stars / mushroom ball
#025e: 0f 14 07 0a 97 41 22 00 00 03 03 ; + &58 # flask
#0269: 07 0a 03 06 97 41 01 00 00 0f 03 ; + &63 # water splashes
#0274: 07 0a 0f 28 97 41 00 ff ff 03 03 ; + &6e # wind
#027f: 00 00 00 00 00 00 00 00 4c df 14 ; + &79 # (unused)

###############################################################################
#
#   Object handlers
#   ===============
#   background objects:
#   no   l   h    addr  name                                    object created          80 40 20 10
#   &00  &d7 &20  3ef2 handle_background_invisible_switch                               -  -  +  -
#   &01  &c8 &b0  3ee3 handle_background_teleport_beam     	teleport beam           +  -  +  +
#   &02  &a4 &91  3fbf handle_background_object_from_data	(use object_data & &7f) +  -  -  +
#   &03  &7d &f0  3e98 handle_background_door			door                    +  +  +  +
#   &04  &7a &f0  3e95 handle_background_stone_door		stone door              +  +  +  +
#   &05  &9c &b1  3fb7 handle_background_object_from_type	(use object_type)       +  -  +  +
#   &06  &9c &b1  3fb7 handle_background_object_from_type	(use object_type)       +  -  +  +
#   &07  &9c &b1  3fb7 handle_background_object_from_type	(use object_type)       +  -  +  +
#   &08  &b2 &b1  3fcd handle_background_switch       		switch                  +  -  +  +
#   &09  &00 &b0  3e1b handle_background_object_emerging	(use object_type)       +  -  +  +
#   &0a  &00 &b0  3e1b handle_background_object_emerging	(use object_type)       +  -  +  +
#   &0b  &26 &31  3f41 handle_background_object_fixed_wind                              -  -  +  +
#   &0c  &6f &90  3e8a handle_background_engine_thruster 	engine thruster         +  -  -  +
#   &0d  &88 &31  3fa3 handle_background_object_water                                   -  -  +  +
#   &0e  &fd &30  3f18 handle_background_object_random_wind                             -  -  +  +
#   &0f  &b7 &31  3fd2 handle_background_mushrooms		mushroom ball           -  -  +  +
#   &10  &7b &02  4096 handle_explosion_type_00
#   &11  &a3 &02  40be handle_explosion_type_40
#   &12  &a0 &02  40bb handle_explosion_type_80
#   &13  &aa &02  40c5 handle_explosion_type_c0
#
#   stack objects:
# r no   l   h    addr  name			      object
# 0:&00  &f6 &0b  &4a11 handle_player_object          player
#   &01  &bc &0a  &48d7 handle_chatter_active         active chatter
#   &02  &d5 &88  &46f0 handle_crew_member            pericles crew member
#   &03  &6d &84  &4288 handle_fluffy                 fluffy
# 1:&04  &94 &cd  &4baf handle_nest                   small nest
#   &05  &94 &cd  &4baf handle_nest                   big nest
# 2:&06  &48 &86  &4463 handle_frogman_red            red frogman
#   &07  &5c &86  &4477 handle_frogman_green          green frogman
#   &08  &5a &86  &4475 handle_frogman_cyan           cyan frogman
#   &09  &ae &09  &47c9 handle_red_slime              red slime
#   &0a  &0f &04  &422a handle_green_slime            green slime
#   &0b  &4b &04  &4266 handle_yellow_ball            yellow ball
#   &0c  &6e &09  &4789 handle_sucker                 sucker
#   &0d  &d2 &0f  &4ded handle_sucker_deadly          deadly sucker
#   &0e  &46 &89  &4761 handle_big_fish               big fish
# 3:&0f  &ef &83  &420a handle_worm                   worm
#   &10  &06 &d1  &4f21 handle_nest_dweller           pirahna
#   &11  &06 &91  &4f21 handle_nest_dweller           wasp
# 4:&12  &dc &c4  &42f7 handle_grenade_active         active grenade
#   &13  &a4 &c8  &46bf handle_icer_bullet            icer bullet
#   &14  &f9 &c7  &4614 handle_tracer_bullet          tracer bullet
#   &15  &0b &c5  &4326 handle_cannonball	      cannonball
#   &16  &17 &c5  &4332 handle_death_ball_blue        blue death ball
#   &17  &2f &c5  &434a handle_red_bullet             red bullet
#   &18  &00 &c6  &441b handle_pistol_bullet          pistol bullet
#   &19  &6d &8c  &4a88 handle_plasma_ball            plasma ball
#   &1a  &cc &45  &43e7 handle_hover_ball             hover ball
#   &1b  &d0 &45  &43eb handle_hover_ball_invisible   invisible hover ball
# 5:&1c  &c3 &50  &4ede handle_robot                  magenta robot
#   &1d  &c3 &50  &4ede handle_robot                  red robot
#   &1e  &c7 &50  &4ee2 handle_robot_blue             blue robot
#   &1f  &bd &50  &4ed8 handle_turret                 green/white turret
#   &20  &bd &50  &4ed8 handle_turret                 cyan/red turret
#   &21  &e9 &49  &4804 handle_hovering_robot         hovering robot
# 6:&22  &04 &4a  &481f handle_clawed_robot           magenta clawed robot
#   &23  &04 &4a  &481f handle_clawed_robot           cyan clawed robot
#   &24  &04 &4a  &481f handle_clawed_robot           green clawed robot
#   &25  &04 &4a  &481f handle_clawed_robot           red clawed robot
#   &26  &e9 &08  &4704 handle_triax                  triax
#   &27  &37 &90  &4e52 handle_maggot                 maggot
#   &28  &55 &c3  &4170 handle_gargoyle               gargoyle
#   &29  &d4 &86  &44ef handle_imp                    red/magenta imp
#   &2a  &d4 &86  &44ef handle_imp                    red/yellow imp
#   &2b  &d4 &86  &44ef handle_imp                    blue/cyan imp
#   &2c  &d4 &86  &44ef handle_imp                    cyan/yellow imp
#   &2d  &d4 &86  &44ef handle_imp                    red/cyan imp
#   &2e  &16 &88  &4631 handle_bird                   green/yellow bird
#   &2f  &16 &88  &4631 handle_bird                   white/yellow bird
#   &30  &06 &88  &4621 handle_bird_red               red/magenta bird
#   &31  &10 &88  &462b handle_bird_invisible         invisible bird
# 7:&32  &e6 &02  &4000 handle_lightning              lightning
#   &33  &7d &08  &4698 handle_mushroom_ball          red mushroom ball
#   &34  &7d &08  &4698 handle_mushroom_ball          blue mushroom ball
#   &35  &76 &09  &4791 handle_engine_fire            engine fire
#   &36  &7e &c9  &4799 handle_red_drop               red drop
#   &37  &bb &0c  &4ad6 handle_fireball               fireball
# 8:&38  &a6 &0a  &48c1 handle_chatter_inactive       inactive chatter
#   &39  &0b &0d  &4b26 handle_moving_fireball        moving fireball
#   &3a  &81 &05  &439c handle_giant_wall             giant wall
#   &3b  &fa &0d  &4c15 handle_engine_thruster        engine thruster
#   &3c  &68 &ce  &4c83 handle_door                   horizontal door
#   &3d  &68 &ce  &4c83 handle_door                   vertical door
#   &3e  &68 &ce  &4c83 handle_door                   horizontal stone door
#   &3f  &68 &ce  &4c83 handle_door                   vertical stone door
#   &40  &8e &0d  &4ba9 handle_bush                   bush
#   &41  &6b &0f  &4d86 handle_teleport_beam          teleport beam
#   &42  &82 &cb  &499d handle_switch                 switch
#   &43  &92 &05  &43ad (null function)               chest 
#   &44  &81 &11  &4f9c handle_explosion              explosion
#   &45  &92 &05  &43ad (null function)               rock 
#   &46  &d3 &02  &40ee handle_cannon                 cannon
#   &47  &fb &43  &4216 handle_mysterious_weapon      mysterious weapon
#   &48  &84 &03  &419f handle_maggot_machine         maggot machine
#   &49  &49 &0d  &4b64 handle_placeholder            placeholder
# 9:&4a  &59 &05  &4374 handle_destinator             destinator
#   &4b  &45 &85  &4360 handle_energy_capsule         energy capsule
#   &4c  &8c &05  &43a7 handle_flask                  empty flask
#   &4d  &93 &05  &43ae handle_flask_full             full flask
#   &4e  &36 &05  &4351 handle_remote_control         remote control device
#   &4f  &36 &05  &4351 handle_remote_control         cannon control device
#   &50  &3d &c3  &4158 handle_grenade_inactive       inactive grenade
#   &51  &6d &0d  &4b88 handle_collectable            cyan/yellow/green key
#   &52  &6d &0d  &4b88 handle_collectable            red/yellow/green key
#   &53  &6d &0d  &4b88 handle_collectable            green/yellow/red key
#   &54  &6d &0d  &4b88 handle_collectable            yellow/white/red key
#   &55  &af &03  &41ca handle_coronium_boulder       coronium boulder
#   &56  &6d &0d  &4b88 handle_collectable            red/magenta/red key
#   &57  &6d &0d  &4b88 handle_collectable            blue/cyan/green key
#   &58  &a7 &03  &41c2 handle_coronium_crystal       coronium crystal
#   &59  &6d &0d  &4b88 handle_collectable            jetpack booster
#   &5a  &6d &0d  &4b88 handle_collectable            pistol
#   &5b  &6d &0d  &4b88 handle_collectable            icer
#   &5c  &6d &0d  &4b88 handle_collectable            discharge device
#   &5d  &6d &0d  &4b88 handle_collectable            plasma gun
#   &5e  &6d &0d  &4b88 handle_collectable            protection suit
#   &5f  &6d &0d  &4b88 handle_collectable            fire immunity device
#   &60  &6d &0d  &4b88 handle_collectable            mushroom immunity pull
#   &61  &6d &0d  &4b88 handle_collectable            whistle 1
#   &62  &6d &0d  &4b88 handle_collectable            whistle 2
#   &63  &6d &0d  &4b88 handle_collectable            radiation immunity pull
#   &64  &92 &05  &43ad (null function)               ?
#
###############################################################################

; object_sprite_lookup
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#028a: 04 14 04 75 1e 1b 10 10 10 1c 1c 20 70 70 61 52 ; 00
#029a: 72 4f 21 08 08 21 21 08 08 21 78 78 13 13 13 5e ; 10
#02aa: 5e 15 16 16 16 16 04 52 45 64 64 64 64 64 59 59 ; 20
#02ba: 59 59 6d 63 63 0b 0f 17 14 17 39 17 4a 4b 3c 41 ; 30
#02ca: 1a 71 2e 5d 17 20 56 57 47 22 60 7b 76 76 58 58 ; 40
#02da: 21 4d 4d 4d 4d 20 4d 4d 22 6b 6c 6c 79 6c 04 7a ; 50
#02ea: 63 7c 7c 79 77                                  ; 60

;object_palette_lookup
# & &80 = can be picked up
# & &7f = palette
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#02ef: 3e 1b 2e f2 32 32 53 05 0f 14 29 bc 65 65 f7 97 ; 00
#02ff: d3 c7 ef 7e 5f 3c 5a 11 2d 34 e1 80 55 1b 4c 59 ; 10
#030f: 23 72 2e 7b 77 33 39 8b 44 51 0d 46 2b 53 35 3c ; 20
#031f: 02 01 70 9c cf 00 14 10 4b 10 0c 34 6b 6b 42 42 ; 30
#032f: 31 6f 15 2e 12 cb 33 b1 62 00 db 9f 8f cf e5 8e ; 40
#033f: ef ab ad 95 9c 91 92 a6 91 b1 8e e0 a2 b5 b3 e3 ; 50
#034f: d5 e3 d7 f0 f1                                  ; 60

; object_gravity_flags
# & &80 = doesn't collide with other objects
# & &07 = weight; 01 = light, 06 = heavy, 07 = static
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#0354: 03 23 23 22 77 77 26 6d 6e f7 6e 25 f7 f7 25 69 ; 00
#0364: 6b 68 04 63 66 66 65 66 62 64 69 69 24 25 26 77 ; 10
#0374: 77 23 05 05 05 05 04 68 77 6a 6c 6b 6b 6c 6c 6c ; 20
#0384: 6d 6d e5 61 61 e4 e5 e8 24 ec 26 d7 57 57 57 57 ; 30
#0394: d6 d7 57 25 82 26 25 24 77 74 24 02 22 24 22 22 ; 40
#03a4: 24 23 23 23 23 25 23 23 02 26 23 23 23 23 26 25 ; 50
#03b4: 22 22 22 25 e7                                  ; 60

; object_handler_table
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f  0  1  2  3
#03b9: d7 c8 a4 7d 7a 9c 9c 9c b2 00 00 26 6f 88 fd b7 7b a3 a0 aa ; for background objects / explosions
#03cd: f6 bc d5 6d 94 94 48 5c 5a ae 0f 4b 6e d2 46 ef ; 00
#03dd: 06 06 dc a4 f9 0b 17 2f 00 6d cc d0 c3 c3 c7 bd ; 10
#03ed: bd e9 04 04 04 04 e9 37 55 d4 d4 d4 d4 d4 16 16 ; 20
#03fd: 06 10 e6 7d 7d 76 7e bb a6 0b 81 fa 68 68 68 68 ; 30
#040d: 8e 6b 82 92 81 92 d3 fb 84 49 59 45 8c 93 36 36 ; 40
#041d: 3d 6d 6d 6d 6d af 6d 6d a7 6d 6d 6d 6d 6d 6d 6d ; 50
#042d: 6d 6d 6d 6d 92                                  ; 60

; object_handler_table_h
# & &c0 = how the object explodes
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f  0  1  2  3
#0432: 20 b0 91 f0 f0 b1 b1 b1 b1 b0 b0 31 90 31 30 31 02 02 02 02 ; for background objects / explosions
#0446: 0b 0a 88 84 cd cd 86 86 86 09 04 04 09 0f 89 83 ; 00
#0456: d1 91 c4 c8 c7 c5 c5 c5 c6 8c 45 45 50 50 50 50 ; 10
#0466: 50 49 4a 4a 4a 4a 08 90 c3 86 86 86 86 86 88 88 ; 20
#0476: 88 88 02 08 08 09 c9 0c 0a 0d 05 0d ce ce ce ce ; 30
#0486: 0d 0f cb 05 11 05 02 43 03 0d 05 85 05 05 05 05 ; 40
#0496: c3 0d 0d 0d 0d 03 0d 0d 03 0d 0d 0d 0d 0d 0d 0d ; 50
#04a6: 0d 0d 0d 0d 05                                  ; 60


###############################################################################
#
#   Background sprites
#   ==================
#   
#   00 = bottom left, unflipped
#   40 = top left, vertical flip
#   80 = bottom right, horizontal flip
#   c0 = top right, vertical & horizontal flip
#   
#   00 = bush
#   01 = stone \ wall, filled in bottom left
#   02 = turret, top, facing left
#   03 = door, horizontal, top
#   04 = brick wall, solid
#   05 = brick wall, 3/4 full, \, filled in bottom left
#   06 = brick wall, \, starting top left, ending middle right
#   07 = stone wall, bottom edging
#   08 = nothing ?
#   09 = sucker, bottom
#   0a = big pipe entrance, bottom
#   0b = wind
#   0c = engine exhaust, \ filled in bottom left
#   0d = water
#   0e = mushrooms, bottom right corner
#   0f = mushrooms, bottom
#   10 = green stone wall, bottom edging
#   11 = green leaf, bottom left corner
#   12 = brick wall, solid
#   13 = brick wall, \, starting top middle, ending middle right, 3/4 full
#   14 = spaceship pipework
#   15 = thin spaceship wall, left side
#   16 = thick spaceship wall, bottom edge
#   17 = thin spacewship wall, bottom edge
#   18 = flag? left side
#   19 = nothing ?
#   1a = half a bush, bottom left corner
#   1b = bush, bottom left corner
#   1c = spaceship tiny corner piece, bottom left
#   1d = spaceship 3/4 corner piece, bottom left
#   1e = brick wall, solid
#   1f = brick wall, bottom half
#   20 = horizontal brick door
#   21 = pillar, left edge
#   22 = green leaf, bottom left corner
#   23 = brick \ wall, filled in bottom left
#   24 = brick wall, \, starting top left, ending middle right
#   25 = brick wall, \, starting middle left, ending bottom right
#   26 = spaceship wall, \, starting top left, ending half top right
#   27 = spaceship wall, \, starting half top left, ending middle right
#   28 = spaceship wall, \, starting middle left, ending half bottom right
#   29 = spaceship wall, \, starting half bottom left, ending bottom left
#   2a = brick wall, \, very steep down
#   2b = couple of pixels of stone edging strip, bottom
#   2c = stone edge, bottom
#   2d = stone wall, solid
#   2e = stone \ wall, filled in bottom left
#   2f = stone \ wall, starting top left, ending middle right
#   30 = stone \ wall, starting middle left, ending bottom right
#   31 = stone - wall, filled bottom
#   32 = spaceship corner with pipes, filled
#   33 = pipe, bottom
#   34 = pipe, bottom left corner
#   35 = pipe, left
#   36 = spaceship - wall, filled bottom
#   37 = spaceship corner with pipes, filled
#   38 = spaceship pipes, half, filled bottom
#   39 = vertical brick door
#   3a = gargoyle, bottom left
#   3b = brick wall, 3/4 filled bottom 
#   3c = big pipe entrance, bottom
#   3d = spaceship support
#   3e = computer console, bottom left
#   3f = hydraulic leg
#
###############################################################################

; background_sprite_lookup 
; & &7f = sprite
; & &80 = vertically flipped
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#04ab: c6 ce c6 c6 c6 bb c6 18 2d 70 6a c6 23 39 c6 62
#04bb: c0 8e 39 44 47 26 48 49 df c6 99 9a 25 2b 39 3b
#04cb: 3c 55 8e 43 34 35 27 28 29 2a 42 bf 40 3d 38 36
#04db: 37 3e 33 31 2f 30 2c 24 32 41 45 3a 6a 23 60 cc

; background_y_offset_lookup
#04eb: 00 00 00 00 00 00 00 d0 c5 b0 c7 00 06 00 00 c0
#04fb: b0 a0 07 08 00 04 80 c0 70 00 b0 80 99 08 00 80
#050b: c0 00 a0 03 02 82 01 41 81 c1 04 f0 b0 00 03 02
#051b: 82 70 06 c0 c5 04 80 06 80 04 99 30 c7 06 a9 00

; background_palette_lookup
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#052b: 80 02 91 91 91 00 91 a8 dc b8 8c 80 c9 4a 80 06
#053b: 88 05 04 00 02 02 02 02 02 91 03 03 02 02 00 00
#054b: 00 bc b1 00 00 00 01 01 01 01 00 04 04 04 04 04
#055b: 04 04 02 01 01 01 02 02 02 00 00 00 82 02 64 ee

; background_wall_y_start_base_lookup
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#056b: 0f 3a 0f 0f 0f 77 0f f0 b0 f0 c0 0f 00 f0 0f f0
#057b: 0f 0f 00 06 0f 00 77 b3 0f 0f 0f 0f 90 06 0f 77
#058b: b3 f0 0f 10 07 70 0b 37 73 b0 00 0f b3 0f 10 07
#059b: 70 77 00 b3 b0 00 77 00 77 00 90 2c c0 00 90 0f

; background_wall_y_start_lookup
# Add &100 to get address in wall_base_y_lookup
;      -- -V H- HV
#05ab: 00 00 00 00
#05af: 08 40 40 08
#05b3: 10 48 48 10
#05b7: 18 50 50 18
#05bb: 38 20 70 58
#05bf: 38 78 70 80
#05c3: 30 60 68 28
#05c7: 88 90 88 90
#05cb: a0 50 98 18
#05cf: 18 98 50 a0

; background_objects_range_minus_one
#05d3: 00
; background_objects_range 
#05d4: 19 39 57 7a 9e bc d8 f6 fe
; background_objects_data_offset
#05dd: 01 fe fb fa f8 f5 f5 f3 f3
; background_objects_type_offset
#05e6: 00 f5 e9 de ce be b1 a1 98

; background_objects_x_lookup
#05ef: ff ff b0 ec 77 64 9a af da c6 36 9f 2e a9 9c 83
#05ff: 88 5f 57 bf 9d 4d 45 81 b3 3f cb 40 4c ca 2f a7
#060f: 56 34 e3 3b e4 80 e0 64 37 47 9f 9c aa 9b 9a 5e
#061f: c7 8a 60 9d a2 b2 98 a9 db 28 29 3c 98 63 cb 61
#062f: a3 ce e9 80 2e 4f 79 87 b6 97 2d d6 5c a0 74 6a
#063f: a1 9f 89 85 6b ae 65 e2 ed 80 cd a8 2b ab 9d 62
#064f: e5 70 ec 83 c1 c6 67 eb 2d 98 aa cc a5 9e a2 d7
#065f: e6 e7 94 7c e3 45 9b 9f c2 71 67 4f cf d2 e2 7a
#066f: 62 da 76 b2 66 d7 83 84 80 87 9b 50 ae 64 a3 63
#067f: b8 7f 82 e0 9c 61 9d 29 46 9f 9a 74 75 77 b2 e4
#068f: 62 63 82 61 d4 d3 77 2e 64 86 a5 a0 d1 b4 7f a3
#069f: 9f 99 80 67 da 89 95 8b ab c4 9d aa bb 47 8a a7
#06af: 61 9e 2e d6 7e da aa ab 45 67 d4 29 b8 6b 69 9d
#06bf: 94 63 b4 a1 9f a0 57 e1 7f a6 b4 53 61 d4 82 e3
#06cf: 75 c3 84 9e c6 64 a2 28 29 9d 83 a8 80 aa d5 a0
#06df: 9f d6 62 69 2c a5 b8 b9 d9 59 79 39 48 e8 03

; background_objects_handler_lookup
#06ee: 89 89 89 89 89 8a 46 c6 06 06 46 05 05 00 c3 04
#06fe: 83 84 84 83 88 48 02 02 42 02 7b 22 1e 06 06 c6
#070e: 06 46 46 85 85 87 89 89 c7 0a 8c 03 84 83 43 84
#071e: 84 02 01 41 01 01 2e 1e 3b 46 46 06 c6 06 06 06
#072e: 46 06 09 c9 89 ca 8a 8a 0a 4a 8a 04 44 41 01 c8
#073e: 48 cc 82 02 02 02 1e 89 09 0a 4a ca 4a 86 46 46
#074e: 46 86 45 47 00 00 00 00 84 c3 44 43 43 43 44 84
#075e: 44 04 01 08 08 02 02 82 1e 2d 46 46 45 46 c6 89
#076e: c9 49 89 ca ca 8a 8a 8a 0a 00 00 c4 43 04 43 84
#077e: 44 04 44 84 41 01 01 01 c8 42 82 3b 11 3b 89 c9
#078e: ca 8a c6 06 c6 c6 06 06 85 47 4a ca 8a 00 00 44
#079e: 43 c3 44 44 04 41 c8 88 c8 c8 02 8c 49 89 0a 0a
#07ae: 8a c6 06 06 47 87 cc 41 01 08 08 08 08 c4 84 43
#07be: 43 84 04 83 82 82 0d 0d 46 06 06 06 06 45 45 45
#07ce: 06 07 89 09 8a 4a 4a ca ca 4a 00 00 00 48 08 82
#07de: 82 82 02 c4 c4 0b 0b 0b d1 91 d1 d1 91 91 0d

; background_strip_cache_orientation
#07ed: 2e 2e 2e 2e 2e 2e 2e 2e 2e
; background_strip_cache_sprite
#07f6: 2e 2e 2e 2e 2e 2e 2e 2e 2e

#07f8 is where the game state data starts copying from
#07f8 - 07fe : copy of &d9 - &df when saving position

; game_time
#07ff: 00 00 00 00
; player_deaths
#0803: 00 00 00

; keys_collected
#0806: 00 ; cyan/yellow/green key
#0807: 00 ; red/yellow/green key
#0808: 00 ; green/yellow/red key
#0809: 00 ; yellow/white/red key
#080a: 00 ; (unused)
#080b: 00 ; red/magenta/red key
#080c: 00 ; blue/cyan/green key
#080d: 00 ; (unused)
#080e: 00 ; booster_collected
#080f: 00 ; pistol
#0810: 00 ; icer
#0811: 00 ; discharge device
#0812: 00 ; plasma gun
#0813: 00 ; protection_suit_collected
#0814: 00 ; fire_immunity_collected
#0815: 00 ; mushroom_pill_collected
#0816: 00 ; whistle1_collected
#0817: 00 ; whistle2_collected
#0818: 00 ; radiation_pill_collected

#0819: 00 ; door_timer
#081a: 00 ; red_mushroom_daze
#081b: 00 ; blue_mushroom_daze
#081c: 00 ; chatter_energy_level
#081d: 00 ; explosion_timer
#081e: 00 ; endgame_value
#081f: 00 ; earthquake_triggered

#0820: ff ; (unused)

#0821: 00 ; teleport_last
#0822: 00 ; teleports_used
#0823: 32 8e d2 63 ; teleports_x
#0827: 99 ; teleport_fallback_x
#0828: 98 c0 c0 c7 ; teleports_y
#082c: 3c ; teleport_fallback_y
#082d: 00 ; timers_and_eor

#082e: 00 00 00 00 ; water_level_low_by_x_range
#0832: ce df c1 c1 ; water_level_by_x_range
#0836: ce df c1 c1 ; desired_water_level_by_x_range

#083a: 04 0a 01 01 0a ; imp_gift_counts

#083f: 80 80 80 80 ; clawed_robot_availability
#0843: 00 00 00 00 ; clawed_robot_energy_when_last_used

#0847: 00 ; pockets_used
#0848: 50 50 50 50 50 ; contents of pockets
#084d: 00 current_weapon
;       0  1  2  3  4  5 jetpack, pistol, icer, discharge, plasma, suit
#084e: 00 00 00 00 00 00 weapon_energy
#0854: 30 10 10 01 08 10 weapon_energy_h
#085a: 01 06 10 ff 32 00 energy_per_shot

###############################################################################
#
#   Object Stack (primary)
#   ======================
#   (&9b, &3b) &00 player
#   (&99, &3b) &26 triax
#   fourteen empty slots
#
###############################################################################

#0860: 00 26 d7 57 57 57 57 d6 d7 57 25 82 26 25 47 77 ; object_stack_type

#0870: 04 04 02 22 24 22 22 24 23 23 23 23 25 23 23 02 ; object_stack_sprite

#0880: c0 64 23 23 23 26 25 22 22 22 25 e7 d7 c8 a4 7d ; object_stack_x_low
#0890: 7a ; seventeenth slot = target

#0891: 9b 99 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ; object_stack_x
#08a1: bc 65 ; eighteenth slot = waterfall (&65, &dc), for sound

#08a3: 20 20 94 48 5c 5a ae 0f 4b 6e d2 46 ef 06 06 dc ; object_stack_y_low
#08b3: a4

#08b4: 3b 3b 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ; object_stack_y
#08c4: 04 dc

; object_stack_flags
; 80 set = horizontal invert (facing left)
; 40 set = vertical invert (upside down)
; 20 set = remove from display
; 10 set = teleporting
; 08 set = damaged
; 02 set = collision detected
; 01 set at load positon?
#08c6: 81 11 01 01 01 01 01 01 01 01 01 01 01 01 01 01 ; object_stack_flags

; object_stack_palette:
; 10 set = damaged
#08d6: 7e 39 a6 0b 81 fa 68 68 68 68 8e 6b 82 92 81 92 ; object_stack_palette

#08e6: 00 00 84 49 59 45 8c 93 36 36 3d 6d 6d 6d 6d af ; object_stack_vel_x

#08f6: 00 10 a7 6d 6d 6d 6d 6d 6d 6d 6d 6d 6d 6d 92 20 ; object_stack_vel_y

#0906: b0 00 f0 f0 b1 b1 b1 b1 b0 b0 31 90 31 30 31 20 ; object_stack_target

#0916: 02 99 02 0b 0a 88 84 cd cd 86 86 86 09 04 04 09 ; object_stack_tx

#0926: ff c8 83 d1 91 c4 c8 c7 c5 c5 c5 c6 8c 45 45 50 ; object_stack_energy

#0936: 50 3b 50 50 49 4a 4a 4a 4a 08 90 c3 86 86 86 86 ; object_stack_ty

#0946: 86 88 88 88 88 02 08 08 c9 c9 0c 0a 0d 05 0d ce ; object_stack_supporting

#0956: ce 0e ce 0d 0f cb 05 11 05 02 43 03 0d 05 85 05 ; object_stack_timer

#0966: 00 05 05 c3 0d 0d 0d 0d 03 0d 0d 03 0d 0d 0d 0d ; object_stack_data_pointer

#0976: 0d 0d 0d 0d 0d 0d 0d 05 c6 ce c6 c6 c6 bb c6 18 ; object_stack_extra

###############################################################################
#
#   Background objects
#   ==================
#   no    x            handler      data         type            x, y    handler: object
# 0:&00 : &05ef = &ff  &06ee = &89  &0987 = &7c  &0a72 = &0f  (&ff, &??) &09: worm (x 31) (unused?)
#   &01 : &05f0 = &ff  &06ef = &89  &0988 = &60  &0a73 = &27  (&ff, &??) &09: maggot (x 24) (unused?)
#   &02 : &05f1 = &b0  &06f0 = &89  &0989 = &04  &0a74 = &2e  (&b0, &4e) &09: green/yellow bird
#   &03 : &05f2 = &ec  &06f1 = &89  &098a = &88  &0a75 = &07  (&ec, &c0) &09: green frogman (x 2)
#   &04 : &05f3 = &77  &06f2 = &89  &098b = &88  &0a76 = &2f  (&77, &54) &09: white/yellow bird (x 2)
#   &05 : &05f4 = &64  &06f3 = &8a  &098c = &a0  &0a77 = &2d  (&64, &94) &0a: red/cyan imp (x 8)
#   &06 : &05f5 = &9a  &06f4 = &46  &098d = &a6  &0a78 = &1f  (&9a, &80) &06: green/white turret
#   &07 : &05f6 = &af  &06f5 = &c6  &098e = &ae  &0a79 = &1f  (&af, &61) &06: green/white turret
#   &08 : &05f7 = &da  &06f6 = &06  &098f = &83  &0a7a = &0d  (&da, &80) &06: deadly sucker
#   &09 : &05f8 = &c6  &06f7 = &06  &0990 = &86  &0a7b = &0d  (&c6, &c0) &06: deadly sucker
#   &0a : &05f9 = &36  &06f8 = &46  &0991 = &82  &0a7c = &0d  (&36, &8c) &06: deadly sucker
#   &0b : &05fa = &9f  &06f9 = &05  &0992 = &80  &0a7d = &0c  (&9f, &c0) &05: sucker
#   &0c : &05fb = &2e  &06fa = &05  &0993 = &80  &0a7e = &60  (&2e, &94) &05: mushroom immunity pull
#   &0d : &05fc = &a9  &06fb = &00  &0994 = &ad  &0a7f = &2c  (&a9, &9c) &00: invisible switch
#   &0e : &05fd = &9c  &06fc = &c3  &0995 = &81  &0a80 = &00  (&9c, &3c) &03: door
#   &0f : &05fe = &83  &06fd = &04  &0996 = &f7  &0a81 = &0d  (&83, &77) &04: stone door
#   &10 : &05ff = &88  &06fe = &83  &0997 = &a1  &0a82 = &0d  (&88, &72) &03: door
#   &11 : &0600 = &5f  &06ff = &84  &0998 = &f1  &0a83 = &1f  (&5f, &c0) &04: stone door
#   &12 : &0601 = &57  &0700 = &84  &0999 = &f7  &0a84 = &0d  (&57, &94) &04: stone door
#   &13 : &0602 = &bf  &0701 = &83  &099a = &81  &0a85 = &5c  (&bf, &80) &03: door
#   &14 : &0603 = &9d  &0702 = &88  &099b = &8a  &0a86 = &0d  (&9d, &3b) &08: switch
#   &15 : &0604 = &4d  &0703 = &48  &099c = &ac  &0a87 = &20  (&4d, &80) &08: switch
#   &16 : &0605 = &45  &0704 = &02  &099d = &d2  &0a88 = &05  (&45, &4e) &02: red/yellow/green key
#   &17 : &0606 = &81  &0705 = &02  &099e = &df  &0a89 = &04  (&81, &75) &02: fire immunity device
#   &18 : &0607 = &b3  &0706 = &42  &099f = &d4  &0a8a = &06  (&b3, &80) &02: yellow/white/red key
# 1:&19 : &0608 = &3f  &0707 = &02  &099d = &d2  &0a7d = &0c  (&3f, &??) &02: red/yellow/green key (unused)
#   &1a : &0609 = &cb  &0708 = &7b  &099e = &df  &0a7e = &60  (&cb, &??) &3b: brick wall, 3/4 filled bottom (unused)
#   &1b : &060a = &40  &0709 = &22  &099f = &d4  &0a7f = &2c  (&40, &??) &22: leaf (unused)
#   &1c : &060b = &4c  &070a = &1e  &09a0 = &a3  &0a80 = &00  (&4c, &??) &1e: brick wall
#   &1d : &060c = &ca  &070b = &06  &09a1 = &84  &0a81 = &0d  (&ca, &58) &06: deadly sucker
#   &1e : &060d = &2f  &070c = &06  &09a2 = &85  &0a82 = &0d  (&2f, &94) &06: deadly sucker
#   &1f : &060e = &a7  &070d = &c6  &09a3 = &ae  &0a83 = &1f  (&a7, &80) &06: green/white turret
#   &20 : &060f = &56  &070e = &06  &09a4 = &80  &0a84 = &0d  (&56, &94) &06: deadly sucker
#   &21 : &0610 = &34  &070f = &46  &09a5 = &80  &0a85 = &5c  (&34, &8c) &06: discharge device
#   &22 : &0611 = &e3  &0710 = &46  &09a6 = &88  &0a86 = &0d  (&e3, &98) &06: deadly sucker
#   &23 : &0612 = &3b  &0711 = &85  &09a7 = &ac  &0a87 = &20  (&3b, &c0) &05: cyan/red turret
#   &24 : &0613 = &e4  &0712 = &85  &09a8 = &c4  &0a88 = &05  (&e4, &80) &05: big nest
#   &25 : &0614 = &80  &0713 = &87  &09a9 = &c0  &0a89 = &04  (&80, &c5) &07: small nest
#   &26 : &0615 = &e0  &0714 = &89  &09aa = &04  &0a8a = &06  (&e0, &98) &09: red frogman
#   &27 : &0616 = &64  &0715 = &89  &09ab = &a8  &0a8b = &31  (&64, &80) &09: invisible bird (x 10)
#   &28 : &0617 = &37  &0716 = &c7  &09ac = &c4  &0a8c = &05  (&37, &8c) &07: big nest
#   &29 : &0618 = &47  &0717 = &0a  &09ad = &bc  &0a8d = &2a  (&47, &c0) &0a: red/yellow imp (x 15)
#   &2a : &0619 = &9f  &0718 = &8c  &09ae = &fd  &0a8e = &09  (&9f, &3a) &0c: engine thruster
#   &2b : &061a = &9c  &0719 = &03  &09af = &81  &0a8f = &0d  (&9c, &3d) &03: door
#   &2c : &061b = &aa  &071a = &84  &09b0 = &c1  &0a90 = &0d  (&aa, &98) &04: stone door
#   &2d : &061c = &9b  &071b = &83  &09b1 = &d1  &0a91 = &1f  (&9b, &80) &03: door
#   &2e : &061d = &9a  &071c = &43  &09b2 = &91  &0a92 = &20  (&9a, &5c) &03: door
#   &2f : &061e = &5e  &071d = &84  &09b3 = &f1  &0a93 = &55  (&5e, &c0) &04: stone door
#   &30 : &061f = &c7  &071e = &84  &09b4 = &f1  &0a94 = &55  (&c7, &c0) &04: stone door
#   &31 : &0620 = &8a  &071f = &02  &09b5 = &da  &0a95 = &0d  (&8a, &71) &02: pistol
#   &32 : &0621 = &60  &0720 = &01  &09b6 = &f7  &0a96 = &63  (&60, &98) &01: teleport beam
#   &33 : &0622 = &9d  &0721 = &41  &09b7 = &f3  &0a97 = &0f  (&9d, &49) &01: teleport beam
#   &34 : &0623 = &a2  &0722 = &01  &09b8 = &d8  &0a98 = &2e  (&a2, &58) &01: teleport beam
#   &35 : &0624 = &b2  &0723 = &01  &09b9 = &88  &0a99 = &0a  (&b2, &80) &01: teleport beam
#   &36 : &0625 = &98  &0724 = &2e  &09ba = &80  &0a9a = &1b  (&98, &80) &2e: stone wall \
#   &37 : &0626 = &a9  &0725 = &1e  &09bb = &83  &0a9b = &37  (&a9, &80) &1e: brick wall
#   &38 : &0627 = &db  &0726 = &3b  &09bc = &83  &0a9c = &29  (&db, &80) &3b: brick wall, top quarter empty
# 2:&39 : &0628 = &28  &0727 = &46  &09ba = &80  &0a8e = &09  (&28, &98) &06: red slime
#   &3a : &0629 = &29  &0728 = &46  &09bb = &83  &0a8f = &0d  (&29, &98) &06: deadly sucker
#   &3b : &062a = &3c  &0729 = &06  &09bc = &83  &0a90 = &0d  (&3c, &80) &06: deadly sucker
#   &3c : &062b = &98  &072a = &c6  &09bd = &b0  &0a91 = &1f  (&98, &4e) &06: green/white turret
#   &3d : &062c = &63  &072b = &06  &09be = &aa  &0a92 = &20  (&63, &c0) &06: cyan/red turret
#   &3e : &062d = &cb  &072c = &06  &09bf = &80  &0a93 = &55  (&cb, &dc) &06: coronium boulder
#   &3f : &062e = &61  &072d = &06  &09c0 = &80  &0a94 = &55  (&61, &c6) &06: coronium boulder
#   &40 : &062f = &a3  &072e = &46  &09c1 = &87  &0a95 = &0d  (&a3, &c0) &06: deadly sucker
#   &41 : &0630 = &ce  &072f = &06  &09c2 = &80  &0a96 = &63  (&ce, &d8) &06: radiation immunity pull
#   &42 : &0631 = &e9  &0730 = &09  &09c3 = &30  &0a97 = &0f  (&e9, &98) &09: worm (x 12)
#   &43 : &0632 = &80  &0731 = &c9  &09c4 = &08  &0a98 = &2e  (&80, &88) &09: green/yellow bird (x 2)
#   &44 : &0633 = &2e  &0732 = &89  &09c5 = &10  &0a99 = &0a  (&2e, &98) &09: green slime (x 4)
#   &45 : &0634 = &4f  &0733 = &ca  &09c6 = &7c  &0a9a = &1b  (&4f, &80) &0a: invisible hover ball (x 31)
#   &46 : &0635 = &79  &0734 = &8a  &09c7 = &04  &0a9b = &37  (&79, &76) &0a: fireball
#   &47 : &0636 = &87  &0735 = &8a  &09c8 = &10  &0a9c = &29  (&87, &bf) &0a: red/magenta imp (x 4)
#   &48 : &0637 = &b6  &0736 = &0a  &09c9 = &a8  &0a9d = &1a  (&b6, &80) &0a: hover ball (x 10)
#   &49 : &0638 = &97  &0737 = &4a  &09ca = &90  &0a9e = &1a  (&97, &5c) &0a: hover ball (x 4)
#   &4a : &0639 = &2d  &0738 = &8a  &09cb = &04  &0a9f = &37  (&2d, &c7) &0a: fireball
#   &4b : &063a = &d6  &0739 = &04  &09cc = &c1  &0aa0 = &37  (&d6, &72) &04: stone door
#   &4c : &063b = &5c  &073a = &44  &09cd = &f1  &0aa1 = &0a  (&5c, &b8) &04: stone door
#   &4d : &063c = &a0  &073b = &41  &09ce = &e1  &0aa2 = &37  (&a0, &63) &01: teleport beam
#   &4e : &063d = &74  &073c = &01  &09cf = &95  &0aa3 = &4b  (&74, &54) &01: teleport beam
#   &4f : &063e = &6a  &073d = &c8  &09d0 = &bc  &0aa4 = &4b  (&6a, &de) &08: switch
#   &50 : &063f = &a1  &073e = &48  &09d1 = &b4  &0aa5 = &2d  (&a1, &58) &08: switch
#   &51 : &0640 = &9f  &073f = &cc  &09d2 = &fd  &0aa6 = &1f  (&9f, &3b) &0c: engine thruster
#   &52 : &0641 = &89  &0740 = &82  &09d3 = &a1  &0aa7 = &20  (&89, &72) &02: hovering robot
#   &53 : &0642 = &85  &0741 = &02  &09d4 = &d6  &0aa8 = &0d  (&85, &bf) &02: red/magenta/red key
#   &54 : &0643 = &6b  &0742 = &02  &09d5 = &dd  &0aa9 = &0d  (&6b, &88) &02: plasma gun
#   &55 : &0644 = &ae  &0743 = &02  &09d6 = &e2  &0aaa = &28  (&ae, &98) &02: whistle 2
#   &56 : &0645 = &65  &0744 = &1e  &09d7 = &04  &0aab = &55  (&65, &b4) &1e: brick wall
# 3:&57 : &0646 = &e2  &0745 = &89  &09d7 = &04  &0aa0 = &37  (&e2, &c0) &09: fireball
#   &58 : &0647 = &ed  &0746 = &09  &09d8 = &0c  &0aa1 = &0a  (&ed, &bc) &09: green slime (x 3)
#   &59 : &0648 = &80  &0747 = &0a  &09d9 = &04  &0aa2 = &37  (&80, &54) &0a: fireball
#   &5a : &0649 = &cd  &0748 = &4a  &09da = &20  &0aa3 = &4b  (&cd, &7c) &0a: energy capsule (x 8)
#   &5b : &064a = &a8  &0749 = &ca  &09db = &21  &0aa4 = &4b  (&a8, &68) &0a: energy capsule (x 8)
#   &5c : &064b = &2b  &074a = &4a  &09dc = &a0  &0aa5 = &2d  (&2b, &80) &0a: red/cyan imp (x 8)
#   &5d : &064c = &ab  &074b = &86  &09dd = &b0  &0aa6 = &1f  (&ab, &80) &06: green/white turret
#   &5e : &064d = &9d  &074c = &46  &09de = &ac  &0aa7 = &20  (&9d, &6f) &06: cyan/red turret
#   &5f : &064e = &62  &074d = &46  &09df = &83  &0aa8 = &0d  (&62, &c0) &06: deadly sucker
#   &60 : &064f = &e5  &074e = &46  &09e0 = &81  &0aa9 = &0d  (&e5, &bc) &06: deadly sucker
#   &61 : &0650 = &70  &074f = &86  &09e1 = &84  &0aaa = &28  (&70, &88) &06: gargoyle
#   &62 : &0651 = &ec  &0750 = &45  &09e2 = &80  &0aab = &55  (&ec, &bc) &05: coronium boulder
#   &63 : &0652 = &83  &0751 = &47  &09e3 = &c4  &0aac = &05  (&83, &5c) &07: big nest
#   &64 : &0653 = &c1  &0752 = &00  &09e4 = &85  &0aad = &80  (&c1, &7c) &00: invisible switch
#   &65 : &0654 = &c6  &0753 = &00  &09e5 = &95  &0aae = &00  (&c6, &7c) &00: invisible switch
#   &66 : &0655 = &67  &0754 = &00  &09e6 = &a3  &0aaf = &80  (&67, &da) &00: invisible switch
#   &67 : &0656 = &eb  &0755 = &00  &09e7 = &b5  &0ab0 = &80  (&eb, &bc) &00: invisible switch
#   &68 : &0657 = &2d  &0756 = &84  &09e8 = &f1  &0ab1 = &20  (&2d, &94) &04: stone door
#   &69 : &0658 = &98  &0757 = &c3  &09e9 = &ad  &0ab2 = &28  (&98, &54) &03: door
#   &6a : &0659 = &aa  &0758 = &44  &09ea = &c1  &0ab3 = &0d  (&aa, &9c) &04: stone door
#   &6b : &065a = &cc  &0759 = &43  &09eb = &81  &0ab4 = &0d  (&cc, &7c) &03: door
#   &6c : &065b = &a5  &075a = &43  &09ec = &89  &0ab5 = &28  (&a5, &80) &03: door
#   &6d : &065c = &9e  &075b = &43  &09ed = &a0  &0ab6 = &27  (&9e, &6b) &03: door
#   &6e : &065d = &a2  &075c = &44  &09ee = &c1  &0ab7 = &31  (&a2, &c0) &04: stone door
#   &6f : &065e = &d7  &075d = &84  &09ef = &f1  &0ab8 = &0e  (&d7, &c0) &04: stone door
#   &70 : &065f = &e6  &075e = &44  &09f0 = &f1  &0ab9 = &08  (&e6, &bc) &04: stone door
#   &71 : &0660 = &e7  &075f = &04  &09f1 = &c1  &0aba = &11  (&e7, &bc) &04: stone door
#   &72 : &0661 = &94  &0760 = &01  &09f2 = &8c  &0abb = &39  (&94, &5c) &01: teleport beam
#   &73 : &0662 = &7c  &0761 = &08  &09f3 = &a4  &0abc = &37  (&7c, &c0) &08: switch
#   &74 : &0663 = &e3  &0762 = &08  &09f4 = &e4  &0abd = &37  (&e3, &9c) &08: switch
#   &75 : &0664 = &45  &0763 = &02  &09f5 = &d7  &0abe = &37  (&45, &c0) &02: blue/cyan/green key
#   &76 : &0665 = &9b  &0764 = &02  &09f6 = &9d  &0abf = &2a  (&9b, &66) &02: red robot
#   &77 : &0666 = &9f  &0765 = &82  &09f7 = &e1  &0ac0 = &80  (&9f, &73) &02: whistle 1
#   &78 : &0667 = &c2  &0766 = &1e  &09f8 = &a6  &0ac1 = &4a  (&c2, &7c) &1e: brick wall
#   &79 : &0668 = &71  &0767 = &2d  &09f9 = &81  &0ac2 = &10  (&71, &88) &2d: stone wall
# 4:&7a : &0669 = &67  &0768 = &46  &09f8 = &a6  &0ab1 = &20  (&67, &c8) &06: cyan/red turret
#   &7b : &066a = &4f  &0769 = &46  &09f9 = &81  &0ab2 = &28  (&4f, &b8) &06: gargoyle
#   &7c : &066b = &cf  &076a = &45  &09fa = &85  &0ab3 = &0d  (&cf, &b8) &05: deadly sucker
#   &7d : &066c = &d2  &076b = &46  &09fb = &83  &0ab4 = &0d  (&d2, &9d) &06: deadly sucker
#   &7e : &066d = &e2  &076c = &c6  &09fc = &83  &0ab5 = &28  (&e2, &b8) &06: gargoyle
#   &7f : &066e = &7a  &076d = &89  &09fd = &d0  &0ab6 = &27  (&7a, &94) &09: maggot (x 20)
#   &80 : &066f = &62  &076e = &c9  &09fe = &a8  &0ab7 = &31  (&62, &72) &09: invisible bird (x 10)
#   &81 : &0670 = &da  &076f = &49  &09ff = &04  &0ab8 = &0e  (&da, &d8) &09: big fish
#   &82 : &0671 = &76  &0770 = &89  &0a00 = &04  &0ab9 = &08  (&76, &94) &09: cyan frogman
#   &83 : &0672 = &b2  &0771 = &ca  &0a01 = &d0  &0aba = &11  (&b2, &8d) &0a: wasp (x 20)
#   &84 : &0673 = &66  &0772 = &ca  &0a02 = &88  &0abb = &39  (&66, &66) &0a: moving fireball (x 2)
#   &85 : &0674 = &d7  &0773 = &8a  &0a03 = &04  &0abc = &37  (&d7, &6e) &0a: fireball
#   &86 : &0675 = &83  &0774 = &8a  &0a04 = &04  &0abd = &37  (&83, &78) &0a: fireball
#   &87 : &0676 = &84  &0775 = &8a  &0a05 = &04  &0abe = &37  (&84, &6c) &0a: fireball
#   &88 : &0677 = &80  &0776 = &0a  &0a06 = &08  &0abf = &2a  (&80, &75) &0a: red/yellow imp (x 2)
#   &89 : &0678 = &87  &0777 = &00  &0a07 = &bd  &0ac0 = &80  (&87, &77) &00: invisible switch
#   &8a : &0679 = &9b  &0778 = &00  &0a08 = &8a  &0ac1 = &4a  (&9b, &3b) &00: invisible switch
#   &8b : &067a = &50  &0779 = &c4  &0a09 = &f1  &0ac2 = &10  (&50, &60) &04: stone door
#   &8c : &067b = &ae  &077a = &43  &0a0a = &d1  &0ac3 = &2f  (&ae, &62) &03: door
#   &8d : &067c = &64  &077b = &04  &0a0b = &f1  &0ac4 = &30  (&64, &c8) &04: stone door
#   &8e : &067d = &a3  &077c = &43  &0a0c = &b1  &0ac5 = &30  (&a3, &69) &03: door
#   &8f : &067e = &63  &077d = &84  &0a0d = &f1  &0ac6 = &09  (&63, &cc) &04: stone door
#   &90 : &067f = &b8  &077e = &44  &0a0e = &c1  &0ac7 = &0d  (&b8, &c5) &04: stone door
#   &91 : &0680 = &7f  &077f = &04  &0a0f = &c1  &0ac8 = &09  (&7f, &94) &04: stone door
#   &92 : &0681 = &82  &0780 = &44  &0a10 = &c1  &0ac9 = &09  (&82, &c3) &04: stone door
#   &93 : &0682 = &e0  &0781 = &84  &0a11 = &c1  &0aca = &4f  (&e0, &b8) &04: stone door
#   &94 : &0683 = &9c  &0782 = &41  &0a12 = &e2  &0acb = &24  (&9c, &66) &01: teleport beam
#   &95 : &0684 = &61  &0783 = &01  &0a13 = &e4  &0acc = &4a  (&61, &d9) &01: teleport beam
#   &96 : &0685 = &9d  &0784 = &01  &0a14 = &dc  &0acd = &04  (&9d, &58) &01: teleport beam
#   &97 : &0686 = &29  &0785 = &01  &0a15 = &a0  &0ace = &1a  (&29, &c6) &01: teleport beam
#   &98 : &0687 = &46  &0786 = &c8  &0a16 = &c2  &0acf = &39  (&46, &56) &08: switch
#   &99 : &0688 = &9f  &0787 = &42  &0a17 = &cb  &0ad0 = &10  (&9f, &6b) &02: energy capsule
#   &9a : &0689 = &9a  &0788 = &82  &0a18 = &b8  &0ad1 = &00  (&9a, &66) &02: inactive chatter
#   &9b : &068a = &74  &0789 = &3b  &0a19 = &a8  &0ad2 = &4c  (&74, &94) &3b: brick wall, top quarter empty
#   &9c : &068b = &75  &078a = &11  &0a1a = &10  &0ad3 = &0a  (&75, &94) &11: leaf
#   &9d : &068c = &77  &078b = &3b  &0a1b = &98  &0ad4 = &2f  (&77, &94) &3b: brick wall, top quarter empty
# 5:&9e : &068d = &b2  &078c = &89  &0a19 = &a8  &0ac2 = &10  (&b2, &c2) &09: pirahna (x 10)
#   &9f : &068e = &e4  &078d = &c9  &0a1a = &10  &0ac3 = &2f  (&e4, &b4) &09: white/yellow bird (x 4)
#   &a0 : &068f = &62  &078e = &ca  &0a1b = &98  &0ac4 = &30  (&62, &a2) &0a: red/magenta bird (x 6)
#   &a1 : &0690 = &63  &078f = &8a  &0a1c = &a0  &0ac5 = &30  (&63, &b5) &0a: red/magenta bird (x 8)
#   &a2 : &0691 = &82  &0790 = &c6  &0a1d = &80  &0ac6 = &09  (&82, &bf) &06: red slime
#   &a3 : &0692 = &61  &0791 = &06  &0a1e = &83  &0ac7 = &0d  (&61, &c7) &06: deadly sucker
#   &a4 : &0693 = &d4  &0792 = &c6  &0a1f = &80  &0ac8 = &09  (&d4, &bf) &06: red slime
#   &a5 : &0694 = &d3  &0793 = &c6  &0a20 = &80  &0ac9 = &09  (&d3, &be) &06: red slime
#   &a6 : &0695 = &77  &0794 = &06  &0a21 = &80  &0aca = &4f  (&77, &aa) &06: cannon control device
#   &a7 : &0696 = &2e  &0795 = &06  &0a22 = &80  &0acb = &24  (&2e, &d6) &06: green clawed robot
#   &a8 : &0697 = &64  &0796 = &85  &0a23 = &00  &0acc = &4a  (&64, &d6) &05: destinator
#   &a9 : &0698 = &86  &0797 = &47  &0a24 = &c4  &0acd = &04  (&86, &56) &07: small nest
#   &aa : &0699 = &a5  &0798 = &4a  &0a25 = &40  &0ace = &1a  (&a5, &e7) &0a: hover ball (x 16)
#   &ab : &069a = &a0  &0799 = &ca  &0a26 = &84  &0acf = &39  (&a0, &bf) &0a: moving fireball
#   &ac : &069b = &d1  &079a = &8a  &0a27 = &28  &0ad0 = &10  (&d1, &d3) &0a: pirahna (x 10)
#   &ad : &069c = &b4  &079b = &00  &0a28 = &75  &0ad1 = &00  (&b4, &c2) &00: invisible switch
#   &ae : &069d = &7f  &079c = &00  &0a29 = &bc  &0ad2 = &4c  (&7f, &77) &00: invisible switch
#   &af : &069e = &a3  &079d = &44  &0a2a = &f1  &0ad3 = &0a  (&a3, &63) &04: stone door
#   &b0 : &069f = &9f  &079e = &43  &0a2b = &d1  &0ad4 = &2f  (&9f, &71) &03: door
#   &b1 : &06a0 = &99  &079f = &c3  &0a2c = &a9  &0ad5 = &29  (&99, &4c) &03: door
#   &b2 : &06a1 = &80  &07a0 = &44  &0a2d = &f1  &0ad6 = &2c  (&80, &77) &04: stone door
#   &b3 : &06a2 = &67  &07a1 = &44  &0a2e = &c0  &0ad7 = &37  (&67, &ce) &04: stone door
#   &b4 : &06a3 = &da  &07a2 = &04  &0a2f = &c1  &0ad8 = &20  (&da, &6d) &04: stone door
#   &b5 : &06a4 = &89  &07a3 = &41  &0a30 = &8f  &0ad9 = &3a  (&89, &71) &01: teleport beam
#   &b6 : &06a5 = &95  &07a4 = &c8  &0a31 = &94  &0ada = &0d  (&95, &5d) &08: switch
#   &b7 : &06a6 = &8b  &07a5 = &88  &0a32 = &c2  &0adb = &05  (&8b, &71) &08: switch
#   &b8 : &06a7 = &ab  &07a6 = &c8  &0a33 = &ca  &0adc = &05  (&ab, &6b) &08: switch
#   &b9 : &06a8 = &c4  &07a7 = &c8  &0a34 = &fa  &0add = &0d  (&c4, &c4) &08: switch
#   &ba : &06a9 = &9d  &07a8 = &02  &0a35 = &9c  &0ade = &20  (&9d, &5d) &02: magenta robot
#   &bb : &06aa = &aa  &07a9 = &8c  &0a36 = &fe  &0adf = &0d  (&aa, &61) &0c: engine thruster
# 6:&bc : &06ab = &bb  &07aa = &49  &0a37 = &10  &0ad3 = &0a  (&bb, &c3) &09: green slime (x 4)
#   &bd : &06ac = &47  &07ab = &89  &0a38 = &14  &0ad4 = &2f  (&47, &59) &09: white/yellow bird (x 5)
#   &be : &06ad = &8a  &07ac = &0a  &0a39 = &90  &0ad5 = &29  (&8a, &78) &0a: red/magenta imp (x 4)
#   &bf : &06ae = &a7  &07ad = &0a  &0a3a = &98  &0ad6 = &2c  (&a7, &9a) &0a: cyan/yellow imp (x 6)
#   &c0 : &06af = &61  &07ae = &8a  &0a3b = &04  &0ad7 = &37  (&61, &d7) &0a: fireball
#   &c1 : &06b0 = &9e  &07af = &c6  &0a3c = &a4  &0ad8 = &20  (&9e, &51) &06: cyan/red turret
#   &c2 : &06b1 = &2e  &07b0 = &06  &0a3d = &80  &0ad9 = &3a  (&2e, &c8) &06: giant wall
#   &c3 : &06b2 = &d6  &07b1 = &06  &0a3e = &83  &0ada = &0d  (&d6, &a1) &06: deadly sucker
#   &c4 : &06b3 = &7e  &07b2 = &47  &0a3f = &c6  &0adb = &05  (&7e, &76) &07: big nest
#   &c5 : &06b4 = &da  &07b3 = &87  &0a40 = &c4  &0adc = &05  (&da, &6e) &07: big nest
#   &c6 : &06b5 = &aa  &07b4 = &cc  &0a41 = &fe  &0add = &0d  (&aa, &62) &0c: engine thruster
#   &c7 : &06b6 = &ab  &07b5 = &41  &0a42 = &aa  &0ade = &20  (&ab, &69) &01: teleport beam
#   &c8 : &06b7 = &45  &07b6 = &01  &0a43 = &90  &0adf = &0d  (&45, &57) &01: teleport beam
#   &c9 : &06b8 = &67  &07b7 = &08  &0a44 = &ec  &0ae0 = &0d  (&67, &cb) &08: switch
#   &ca : &06b9 = &d4  &07b8 = &08  &0a45 = &dc  &0ae1 = &48  (&d4, &6f) &08: switch
#   &cb : &06ba = &29  &07b9 = &08  &0a46 = &9e  &0ae2 = &51  (&29, &c8) &08: switch
#   &cc : &06bb = &b8  &07ba = &08  &0a47 = &f4  &0ae3 = &0c  (&b8, &c3) &08: switch
#   &cd : &06bc = &6b  &07bb = &c4  &0a48 = &f7  &0ae4 = &55  (&6b, &e1) &04: stone door
#   &ce : &06bd = &69  &07bc = &84  &0a49 = &f1  &0ae5 = &22  (&69, &de) &04: stone door
#   &cf : &06be = &9d  &07bd = &43  &0a4a = &f1  &0ae6 = &04  (&9d, &56) &03: door
#   &d0 : &06bf = &94  &07be = &43  &0a4b = &81  &0ae7 = &2e  (&94, &5f) &03: door
#   &d1 : &06c0 = &63  &07bf = &84  &0a4c = &f1  &0ae8 = &2f  (&63, &ca) &04: stone door
#   &d2 : &06c1 = &b4  &07c0 = &04  &0a4d = &f1  &0ae9 = &2b  (&b4, &c3) &04: stone door
#   &d3 : &06c2 = &a1  &07c1 = &83  &0a4e = &b1  &0aea = &2a  (&a1, &6b) &03: door
#   &d4 : &06c3 = &9f  &07c2 = &82  &0a4f = &db  &0aeb = &21  (&9f, &57) &02: icer
#   &d5 : &06c4 = &a0  &07c3 = &82  &0a50 = &9e  &0aec = &02  (&a0, &6b) &02: blue robot
#   &d6 : &06c5 = &57  &07c4 = &0d  &0a51 = &84  &0aed = &02  (&57, &69) &0d: water
#   &d7 : &06c6 = &e1  &07c5 = &0d  &0a52 = &ac  &0aee = &1a  (&e1, &73) &0d: water
# 7:&d8 : &06c7 = &7f  &07c6 = &46  &0a51 = &84  &0add = &0d  (&7f, &c1) &06: deadly sucker
#   &d9 : &06c8 = &a6  &07c7 = &06  &0a52 = &ac  &0ade = &20  (&a6, &69) &06: cyan/red turret
#   &da : &06c9 = &b4  &07c8 = &06  &0a53 = &80  &0adf = &0d  (&b4, &c5) &06: deadly sucker
#   &db : &06ca = &53  &07c9 = &06  &0a54 = &80  &0ae0 = &0d  (&53, &95) &06: deadly sucker
#   &dc : &06cb = &61  &07ca = &06  &0a55 = &80  &0ae1 = &48  (&61, &d8) &06: maggot machine
#   &dd : &06cc = &d4  &07cb = &45  &0a56 = &80  &0ae2 = &51  (&d4, &73) &05: cyan/yellow/green key
#   &de : &06cd = &82  &07cc = &45  &0a57 = &80  &0ae3 = &0c  (&82, &c5) &05: sucker
#   &df : &06ce = &e3  &07cd = &45  &0a58 = &80  &0ae4 = &55  (&e3, &b5) &05: coronium boulder
#   &e0 : &06cf = &75  &07ce = &06  &0a59 = &80  &0ae5 = &22  (&75, &87) &06: magenta clawed robot
#   &e1 : &06d0 = &c3  &07cf = &07  &0a5a = &c0  &0ae6 = &04  (&c3, &c5) &07: small nest
#   &e2 : &06d1 = &84  &07d0 = &89  &0a5b = &04  &0ae7 = &2e  (&84, &69) &09: green/yellow bird
#   &e3 : &06d2 = &9e  &07d1 = &09  &0a5c = &08  &0ae8 = &2f  (&9e, &69) &09: white/yellow bird (x 2)
#   &e4 : &06d3 = &c6  &07d2 = &8a  &0a5d = &90  &0ae9 = &2b  (&c6, &be) &0a: blue/cyan imp (x 4)
#   &e5 : &06d4 = &64  &07d3 = &4a  &0a5e = &a2  &0aea = &2a  (&64, &c6) &0a: red/yellow imp (x 8)
#   &e6 : &06d5 = &a2  &07d4 = &4a  &0a5f = &04  &0aeb = &21  (&a2, &5b) &0a: hovering robot
#   &e7 : &06d6 = &28  &07d5 = &ca  &0a60 = &04  &0aec = &02  (&28, &d8) &0a: pericles crew member
#   &e8 : &06d7 = &29  &07d6 = &ca  &0a61 = &04  &0aed = &02  (&29, &d8) &0a: pericles crew member
#   &e9 : &06d8 = &9d  &07d7 = &4a  &0a62 = &20  &0aee = &1a  (&9d, &5b) &0a: hover ball (x 8)
#   &ea : &06d9 = &83  &07d8 = &00  &0a63 = &bc  &0aef = &80  (&83, &76) &00: invisible switch
#   &eb : &06da = &a8  &07d9 = &00  &0a64 = &53  &0af0 = &4b  (&a8, &69) &00: invisible switch
#   &ec : &06db = &80  &07da = &00  &0a65 = &9d  &0af1 = &80  (&80, &c2) &00: invisible switch
#   &ed : &06dc = &aa  &07db = &48  &0a66 = &84  &0af2 = &00  (&aa, &63) &08: switch
#   &ee : &06dd = &d5  &07dc = &08  &0a67 = &da  &0af3 = &00  (&d5, &73) &08: switch
#   &ef : &06de = &a0  &07dd = &82  &0a68 = &cb  &0af4 = &00  (&a0, &67) &02: energy capsule
#   &f0 : &06df = &9f  &07de = &82  &0a69 = &de  &0af5 = &00  (&9f, &51) &02: protection suit
#   &f1 : &06e0 = &d6  &07df = &82  &0a6a = &c5  &0af6 = &00  (&d6, &73) &02: rock 
#   &f2 : &06e1 = &62  &07e0 = &02  &0a6b = &a5  &0af7 = &00  (&62, &cc) &02: red clawed robot
#   &f3 : &06e2 = &69  &07e1 = &c4  &0a6c = &c1  &0af8 = &00  (&69, &d1) &04: stone door
#   &f4 : &06e3 = &2c  &07e2 = &c4  &0a6d = &f1  &0af9 = &00  (&2c, &d6) &04: stone door
#   &f5 : &06e4 = &a5  &07e3 = &0b  &0a6e = &70  &0afa = &00  (&a5, &64) &0b: downdraught
# 8:&f6 : &06e5 = &b8  &07e4 = &0b  &0a6f = &d0  &0af2 = &00  (&b8, &aa) &0b: updraught
#   &f7 : &06e6 = &b9  &07e5 = &0b  &0a70 = &80  &0af3 = &00  (&b9, &de) &0b: updraught
#   &f8 : &06e7 = &d9  &07e6 = &d1  &0a71 = &00  &0af4 = &00  (&d9, &57) &11: leaf
#   &f9 : &06e8 = &59  &07e7 = &91  &0a72 = &00  &0af5 = &00  (&59, &8c) &11: leaf
#   &fa : &06e9 = &79  &07e8 = &d1  &0a73 = &00  &0af6 = &00  (&79, &53) &11: leaf
#   &fb : &06ea = &39  &07e9 = &d1  &0a74 = &00  &0af7 = &00  (&39, &80) &11: leaf
#   &fc : &06eb = &48  &07ea = &91  &0a75 = &00  &0af8 = &00  (&48, &7d) &11: leaf
#   &fd : &06ec = &e8  &07eb = &91  &0a76 = &00  &0af9 = &00  (&e8, &80) &11: leaf
#
###############################################################################

; background_objects_data
; &80 set = not in current stack
#0986: 00 7c 60 04 88 88 a0 a6 ae 83 86 82 80 80 ad 81
#0996: f7 a1 f1 f7 81 8a ac d2 df d4 a3 84 85 ae 80 80
#09a6: 88 ac c4 c0 04 a8 c4 bc fd 81 c1 d1 91 f1 f1 da
#09b6: f7 f3 d8 88 80 83 83 b0 aa 80 80 87 80 30 08 10
#09c6: 7c 04 10 a8 90 04 c1 f1 e1 95 bc b4 fd a1 d6 dd
#09d6: e2 04 0c 04 20 21 a0 b0 ac 83 81 84 80 c4 85 95
#09e6: a3 b5 f1 ad c1 81 89 a0 c1 f1 f1 c1 8c a4 e4 d7
#09f6: 9d e1 a6 81 85 83 83 d0 a8 04 04 d0 88 04 04 04
#0a06: 08 bd 8a f1 d1 f1 b1 f1 c1 c1 c1 c1 e2 e4 dc a0
#0a16: c2 cb b8 a8 10 98 a0 80 83 80 80 80 80 00 c4 40
#0a26: 84 28 75 bc f1 d1 a9 f1 c0 c1 8f 94 c2 ca fa 9c
#0a36: fe 10 14 90 98 04 a4 80 83 c6 c4 fe aa 90 ec dc
#0a46: 9e f4 f7 f1 f1 81 f1 f1 b1 db 9e 84 ac 80 80 80
#0a56: 80 80 80 80 c0 04 08 90 a2 04 04 04 20 bc 53 9d
#0a66: 84 da cb de c5 a5 c1 f1 70 d0 80

; background_objects_type
#0a71: 00 0f 27 2e 07 2f 2d 1f 1f 0d 0d 0d 0c 60 2c 00
#0a81: 0d 0d 1f 0d 5c 0d 20 05 04 06 31 05 2a 09 0d 0d
#0a91: 1f 20 55 55 0d 63 0f 2e 0a 1b 37 29 1a 1a 37 37
#0aa1: 0a 37 4b 4b 2d 1f 20 0d 0d 28 55 05 80 00 80 80
#0ab1: 20 28 0d 0d 28 27 31 0e 08 11 39 37 37 37 2a 80
#0ac1: 4a 10 2f 30 30 09 0d 09 09 4f 24 4a 04 1a 39 10
#0ad1: 00 4c 0a 2f 29 2c 37 20 3a 0d 05 05 0d 20 0d 0d
#0ae1: 48 51 0c 55 22 04 2e 2f 2b 2a 21 02 02 1a 80 4b
#0af1: 80

###############################################################################
#
#   Secondary object stack
#   ======================
#   (&9b, &39) &64 mysterious object 64
#   (&a3, &5d) &43 chest
#   (&98, &4d) &50 grenade
#   (&98, &4d) &50 grenade
#   (&a4, &67) &59 jetpack booster
#   (&9f, &49) &50 grenade
#   (&a0, &49) &46 cannon
#   (&c0, &4e) &50 grenade
#   (&48, &56) &50 grenade
#   (&83, &78) &4e remote control device
#   (&c5, &60) &45 rock
#   (&87, &59) &53 green/yellow/red key
#   (&97, &5e) &1d red robot
#   (&e1, &61) &03 fluffy
#   (&84, &5b) &50 grenade
#   (&98, &80) &50 grenade
#   (&99, &3c) &4a destinator
#   (&e7, &80) &3a giant wall
#   (&7c, &77) &4c empty flask
#   (&00, &00) &00 (thirteen empty slots)
#
###############################################################################

; secondary_object_stack_x
#0af2: 9b a3 98 98 a4 9f a0 c0 48 83 c5 87 97 e1 84 98
#0b02: 99 e7 7c 00 00 00 00 00 00 00 00 00 00 00 00 00
; secondary_object_stack_y
#0b12: 39 5d 4d 4d 67 49 49 4e 56 78 60 59 5e 61 5b 80
#0b22: 3c 80 77 00 00 00 00 00 00 00 00 00 00 00 00 00
; secondary_object_stack_type
#0b32: 64 43 50 50 59 50 46 50 50 4e 45 53 1d 03 50 50
#0b42: 4a 3a 4c 00 00 00 00 00 00 00 00 00 00 00 00 00

#0b52: dc ; possible_checksum

; secondary_object_stack_energy_and_low
#0b53: f0 f3 71 79 fb 42 f5 47 f3 f2 f3 f2 f0 fb f2 40
#0b63: fb f0 f1 00 00 00 00 00 00 00 00 00 00 00 00 00

; variables used for secondary stack
#0b73: 00 ; secondary_stack_object_number
#0b74: 00 ; secondary_stack_random_1f
#0b75: 43 ; maybe_another_checksum
#0b76: 00 ; consider_secondary_stack_objects
#0b77: 00 ; secondary_stack_player_odometer

; used for redraw objects
#0b78: ff ; sprite_and

; palette_value_to_pixel_lookup
#0b79: ca c9 e3 e9 eb ce f8 e6 cc ee 30 de ef cb fb fe 

; plot_sprite_screen_location_offsets_low
#0b89: 00
#0b8a: ea
#0b8b: 00
#0b8c: ea

; plot_sprite_screen_location_offsets
#0b8d: 00
#0b8e: ea
#0b8f: 00
#0b90: ea

#0b91: ea ; screen_offset_x_low
#0b92: ea ; screen_offset_x_low_old
#0b93: ea ; screen_offset_y_low
#0b94: ea ; screen_offset_y_low_old

#0b95: ea ; screen_offset_x
#0b96: ea ; screen_offset_x_old
#0b97: ea ; screen_offset_y
#0b98: ea ; screen_offset_y_old

; plot_sprite_screen_address_offsets_low
#0b99: 00
#0b9a: ea
#0b9b: 00
#0b9c: ea

; plot_sprite_screen_address_offsets
#0b9d: 08
#0b9e: ea
#0b9f: 04
#0ba0: ea

; used_in_redraw_0ba1
#0ba1: f0
#0ba2: f0
#0ba3: f8
#0ba4: f8

; plot_sprite_when_to_flags_and
#0ba5: 05
#0ba6: 0a
#0ba7: 00
#0ba8: 00

; set_object_velocities
&0ba9: a5 43            LDA &43 ; this_object_vel_x
&0bab: 99 e6 08         STA &08e6,Y ; object_stack_vel_x
&0bae: a5 45            LDA &45 ; this_object_vel_y
&0bb0: 99 f6 08         STA &08f6,Y ; object_stack_vel_y
&0bb3: 60               RTS

; get_object_velocities
&0bb4: b9 e6 08         LDA &08e6,Y ; object_stack_vel_x
&0bb7: 85 43            STA &43 ; this_object_vel_x
&0bb9: b9 f6 08         LDA &08f6,Y ; object_stack_vel_y
&0bbc: 85 45            STA &45 ; this_object_vel_y
&0bbe: 60               RTS

; has_object_been_fired
&0bbf: a5 aa            LDA &aa ; current_object
&0bc1: cd d7 29         CMP &29d7 ; object_being_fired
&0bc4: 60               RTS

; has_object_been_hit_by_rcd_beam
&0bc5: a9 4e            LDA #&4e				                # &4e = remote control device
; has_object_been_hit_by_other
&0bc7: 38               SEC
&0bc8: ae d7 29         LDX &29d7 ; object_being_fired          
&0bcb: 30 1a            BMI &0be7			                        # if no control has been fired, leave with carry set
&0bcd: 5d 60 08         EOR &0860,X ; object_stack_type         
&0bd0: d0 15            BNE &0be7			                        # if not the control we care about, leave with carry set
&0bd2: a9 18            LDA #&18
&0bd4: 20 9c 35         JSR &359c ; is_object_close_enough                      # is the object close enough?
&0bd7: b0 0e            BCS &0be7                                               # if not, leave with carry set
&0bd9: 20 a0 22         JSR &22a0 ; get_angle_between_objects                   # get angle 
&0bdc: e5 34            SBC &34 ; firing_angle                                  # minus firing_angle
&0bde: e9 80            SBC #&80                                                # minus 180 degrees
&0be0: 20 56 32         JSR &3256 ; make_positive
&0be3: 65 83            ADC &83 ; distance
&0be5: c9 18            CMP #&18                                                # clear if object has been hit
&0be7: 60               RTS

; consider_objects_on_secondary_stack
# If the player has moved too far, or consider_secondary_stack_objects is set
# look at all the objects in the secondary stack, and push them into the
# primary stack if they're near the screen. Otherwise, look at one object per
# cycle and see if there's space for it on the primary stack - if so, push it.
&0be8: 2c 76 0b         BIT &0b76 ; consider_secondary_stack_objects
&0beb: 30 61            BMI &0c4e ; push_near_objects_from_secondary_to_primary_stack
&0bed: 20 b6 3b         JSR &3bb6 ; get_biggest_velocity                        # for the player
&0bf0: 4a               LSR
&0bf1: 4a               LSR
&0bf2: 6d 77 0b         ADC &0b77 ; secondary_stack_player_odometer             # keep track of how far the player has moved
&0bf5: 8d 77 0b         STA &0b77 ; secondary_stack_player_odometer
&0bf8: b0 54            BCS &0c4e ; push_near_objects_from_secondary_to_primary_stack
&0bfa: ce 73 0b         DEC &0b73 ; secondary_stack_object_number
&0bfd: 10 0d            BPL &0c0c
&0bff: 20 87 25         JSR &2587 ; increment_timers
&0c02: 29 1f            AND #&1f
&0c04: 8d 74 0b         STA &0b74 ; secondary_stack_random_1f
&0c07: a9 1f            LDA #&1f
&0c09: 8d 73 0b         STA &0b73 ; secondary_stack_object_number
&0c0c: ad 73 0b         LDA &0b73 ; secondary_stack_object_number
&0c0f: 4d 74 0b         EOR &0b74 ; secondary_stack_random_1f
&0c12: aa               TAX
&0c13: a0 04            LDY #&04						# only do this if there are four free slots
; move_secondary_object_into_primary_stack
&0c15: bd 12 0b         LDA &0b12,X ; secondary_object_stack_y			# look at random object on secondary stack
&0c18: f0 33            BEQ &0c4d						# does it exist? if not, leave
&0c1a: bd 32 0b         LDA &0b32,X ; secondary_object_stack_type		# get type
&0c1d: 20 62 1e         JSR &1e62 ; reserve_objects                             # find a slot to put it in, create object
&0c20: b0 2b            BCS &0c4d						# if no free slot, leave
&0c22: bd f2 0a         LDA &0af2,X ; secondary_object_stack_x
&0c25: 99 91 08         STA &0891,Y ; object_stack_x				# get x
&0c28: bd 12 0b         LDA &0b12,X ; secondary_object_stack_y
&0c2b: 99 b4 08         STA &08b4,Y ; object_stack_y				# get y
&0c2e: bd 53 0b         LDA &0b53,X ; secondary_object_stack_energy_and_low
&0c31: 48               PHA
&0c32: 09 0f            ORA #&0f
&0c34: 99 26 09         STA &0926,Y ; object_stack_energy			# get top four bits of energy + &f
&0c37: 68               PLA
&0c38: 0a               ASL
&0c39: 0a               ASL
&0c3a: 0a               ASL
&0c3b: 0a               ASL
&0c3c: 48               PHA
&0c3d: 29 c0            AND #&c0
&0c3f: 99 80 08         STA &0880,Y ; object_stack_x_low			# get top two bits of x_low
&0c42: 68               PLA
&0c43: 0a               ASL
&0c44: 0a               ASL
&0c45: 99 a3 08         STA &08a3,Y ; object_stack_y_low			# get top two bits of y_low
&0c48: a9 00            LDA #&00
&0c4a: 9d 12 0b         STA &0b12,X ; secondary_object_stack_y			# remove from secondary stack
&0c4d: 60               RTS
; push_near_objects_from_secondary_to_primary_stack
&0c4e: a2 1f            LDX #&1f                                                # start with last slot of secondary stack
&0c50: bd 12 0b         LDA &0b12,X ; secondary_object_stack_y
&0c53: 85 55            STA &55 ; this_object_y
&0c55: bd f2 0a         LDA &0af2,X ; secondary_object_stack_x
&0c58: 85 53            STA &53 ; this_object_x
&0c5a: a0 04            LDY #&04                                                # radius 4
&0c5c: 86 9e            STX &9e ; tmp_9e
&0c5e: 20 1d 11         JSR &111d ; is_object_offscreen
&0c61: a6 9e            LDX &9e ; tmp_9e
&0c63: b0 05            BCS &0c6a                                               
&0c65: a0 01            LDY #&01                                                # if this object is near the screen
&0c67: 20 15 0c         JSR &0c15 ; move_secondary_object_into_primary_stack    # push it into the primary stack
&0c6a: ca               DEX
&0c6b: 10 e3            BPL &0c50                                               # continue for the rest of the secondary stack
&0c6d: 60               RTS

; copy_object_onto_secondary_stack
&0c6e: a2 1f            LDX #&1f					        # 32 spaces on secondary stack
&0c70: bd 12 0b         LDA &0b12,X ; secondary_object_stack_y		        # find a free slot
&0c73: f0 06            BEQ &0c7b ; secondary_stack_free_slot_found
&0c75: ca               DEX
&0c76: 10 f8            BPL &0c70                                               # if no free slots are available
&0c78: 4c 92 1f         JMP &1f92 ; flash_screen_background                     # flash the background to warn the developer!
; secondary_stack_free_slot_found
&0c7b: a5 41            LDA &41 ; this_object_type
&0c7d: 9d 32 0b         STA &0b32,X ; secondary_object_stack_type	        # copy type
&0c80: a5 53            LDA &53 ; this_object_x
&0c82: 9d f2 0a         STA &0af2,X ; secondary_object_stack_x		        # copy x
&0c85: a5 55            LDA &55 ; this_object_y
&0c87: 9d 12 0b         STA &0b12,X ; secondary_object_stack_y		        # copy y
&0c8a: a5 4f            LDA &4f ; this_object_x_low
&0c8c: 0a               ASL
&0c8d: 2a               ROL
&0c8e: 2a               ROL
&0c8f: 29 03            AND #&03
&0c91: 85 9c            STA &9c						        # top two bits of x_low
&0c93: a5 51            LDA &51 ; this_object_y_low
&0c95: 0a               ASL
&0c96: 26 9c            ROL &9c
&0c98: 0a               ASL
&0c99: 26 9c            ROL &9c						        # top two bits of y_low
&0c9b: a5 15            LDA &15 ; this_object_energy
&0c9d: 29 f0            AND #&f0
&0c9f: 05 9c            ORA &9c						        # top four bits of energy
&0ca1: 9d 53 0b         STA &0b53,X ; secondary_object_stack_energy_and_low
&0ca4: 60               RTS

; plot_object
&0ca5: a9 3f            LDA #&3f                                                # objects are plotted and &3f
&0ca7: 8d 78 0b         STA &0b78 ; sprite_and
&0caa: 20 4d 0d         JSR &0d4d ; plot_sprite
&0cad: a6 aa            LDX &aa ; current_object
&0caf: 5e c6 08         LSR &08c6,X ; object_stack_flags
&0cb2: a5 6e            LDA &6e ; skip_sprite_calculation_flags 
&0cb4: 29 05            AND #&05
&0cb6: c9 01            CMP #&01
&0cb8: 3e c6 08         ROL &08c6,X ; object_stack_flags
&0cbb: a9 ff            LDA #&ff
&0cbd: 8d 78 0b         STA &0b78 ; sprite_and                                  # background is plotted and &ff
&0cc0: 60               RTS

; teleport_player
&0cc1: a4 dd            LDY &dd ; object_held		                        # are we holding something?
&0cc3: 10 2a            BPL &0cef			                        # if so leave - we can't teleport
&0cc5: ce 22 08         DEC &0822 ; teleports_used
&0cc8: 10 07            BPL &0cd1
&0cca: ee 22 08         INC &0822 ; teleports_used
&0ccd: a0 04            LDY #&04
&0ccf: d0 07            BNE &0cd8
&0cd1: ce 21 08         DEC &0821 ; teleport_last
&0cd4: 20 61 2c         JSR &2c61 ; fix_teleport_last
&0cd7: a8               TAY
&0cd8: b9 23 08         LDA &0823,Y ; teleports_x                               # get a position from the list of teleports
&0cdb: 85 14            STA &14 ; this_object_tx                                # set the player's teleport position to match
&0cdd: b9 28 08         LDA &0828,Y ; teleports_y
&0ce0: 85 16            STA &16 ; this_object_ty
&0ce2: 20 0d 44         JSR &440d ; play_teleport_noise
&0ce5: a5 6f            LDA &6f ; this_object_flags
&0ce7: 09 10            ORA #&10			                        # mark the player as teleporting
&0ce9: 85 6f            STA &6f ; this_object_flags
&0ceb: a9 20            LDA #&20
&0ced: 85 12            STA &12 ; this_object_timer                             # start the teleport timer
&0cef: 60               RTS

; mark_stack_object_as_teleporting
&0cf0: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&0cf3: 09 10            ORA #&10                                                # mark as teleporting
&0cf5: 99 c6 08         STA &08c6,Y ; object_stack_flags
&0cf8: a9 20            LDA #&20
&0cfa: 99 56 09         STA &0956,Y ; object_stack_timer                        # start the teleport timer
&0cfd: 60               RTS

; plot_sprite_resize_if_teleporting
# If the object is teleporting, randomise its sprite accordingly
&0cfe: b5 6d            LDA &6d,X ; # X = 3, &70 this_object_flags_old; X = 2, &6f this_object_flags
&0d00: 29 10            AND #&10                                                # is the object teleporting?
&0d02: f0 46            BEQ &0d4a                                               # if not, skip to plot_sprite_continued
&0d04: 8a               TXA
&0d05: 29 01            AND #&01
&0d07: a8               TAY
&0d08: b9 12 00         LDA &0012,Y # Y = 1, &13 this_object_timer_old; Y = 0, &12 this_object_timer
&0d0b: e0 02            CPX #&02
&0d0d: b0 06            BCS &0d15
&0d0f: 85 9c            STA &9c
&0d11: 4a               LSR
&0d12: 4a               LSR
&0d13: 65 9c            ADC &9c                                                 # alter this_object_timer, not this_object_timer_old
&0d15: 29 07            AND #&07
&0d17: a8               TAY
&0d18: b5 4b            LDA &4b,X ; # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0d1a: 4a               LSR                                             
&0d1b: 88               DEY
&0d1c: 10 fc            BPL &0d1a
&0d1e: 2a               ROL
&0d1f: 85 9c            STA &9c
&0d21: b5 4b            LDA &4b,X ; # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0d23: 38               SEC
&0d24: e5 9c            SBC &9c
&0d26: 4a               LSR
&0d27: 3d a1 0b         AND &0ba1,X # X = 3, &0ba4 (&f8), X = 2 &0ba3 (&f8)
&0d2a: 48               PHA
&0d2b: 18               CLC                                                     # alter the sprite position and the height of the sprite based on the timer
&0d2c: 75 5f            ADC (&5f,X) # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0d2e: 69 00            ADC #&00
&0d30: 95 5f            STA &5f,X ; # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0d32: 68               PLA
&0d33: 75 4f            ADC (&4f,X) # X = 3, &52 this_object_y_low_old; X = 2, &51 this_object_y_low
&0d35: 95 4f            STA &4f,X ; # X = 3, &52 this_object_y_low_old; X = 2, &51 this_object_y_low
&0d37: 90 02            BCC &0d3b
&0d39: f6 53            INC &53,X ; # X = 3, &56 this_object_y_old; X = 2, &55 this_object_y
&0d3b: a5 9c            LDA &9c
&0d3d: 3d a1 0b         AND &0ba1,X # X = 3, &0ba4 (&f8), X = 2 &0ba3 (&f8)
&0d40: 95 4b            STA &4b,X ; # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0d42: ca               DEX
&0d43: ca               DEX
&0d44: 10 be            BPL &0d04                                               # now do it again for x direction
&0d46: e8               INX
&0d47: e8               INX
&0d48: e8               INX
&0d49: e8               INX
&0d4a: 4c 86 0d         JMP &0d86 ; plot_sprite_continued

; plot_sprite
&0d4d: a2 03            LDX #&03        # first X = 3, previous ; then X = 2, current
&0d4f: 06 6e            ASL &6e ; skip_sprite_calculation_flags
; plot_sprite_calculation_loop
# Calculate various variables for the sprite, both for its previous and current
# location. We determine the screen address at which to plot, and whether the
# sprite crosses the edge of the screen - if so, we alter its size accordingly.
&0d51: b0 78            BCS &0dcb ; plot_sprite_skip_calculations
&0d53: e0 02            CPX #&02
&0d55: 90 2f            BCC &0d86
&0d57: b4 73            LDY &73,X ; # X = 3, &76 this_object_sprite_old, X = 2, &75 this_object_sprite
&0d59: b9 89 5e         LDA &5e89,Y ; sprite_height_lookup
&0d5c: 4a               LSR
&0d5d: b9 0c 5e         LDA &5e0c,Y ; sprite_width_lookup
&0d60: 6a               ROR
&0d61: 29 80            AND #&80
&0d63: 6a               ROR
&0d64: 55 6f            EOR &6f,X ; # X = 3, &72 this_object_flipping_flags_old ; X = 2, &71, this_object_flipping_flags
&0d66: 95 61            STA &61,X ; # X = 3, &64 this_sprite_flipping_flags_old ; X = 2, &63 this_sprite_flipping_flags
&0d68: 0a               ASL
&0d69: 95 63            STA &63,X ; # X = 3, &66 this_sprite_vertflip_old ; X = 2, &65 this_sprite_partflip
&0d6b: b9 0c 5e         LDA &5e0c,Y ; sprite_width_lookup
&0d6e: 29 f0            AND #&f0
&0d70: 95 49            STA &49,X ; # X = 3, &4c this_sprite_width_old ; X = 2, &4b this_sprite_width
&0d72: b9 89 5e         LDA &5e89,Y ; sprite_height_lookup
&0d75: 29 f8            AND #&f8
&0d77: 95 4b            STA &4b,X ; # X = 3, &4e this_sprite_height_old ; X =2, &4d this_sprite_height
&0d79: b9 06 5f         LDA &5f06,Y ; sprite_offset_a_lookup
&0d7c: 95 5d            STA &5d,X ; # X = 3, &60 this_sprite_a_old; X = 2, &5f this_sprite_a
&0d7e: b9 83 5f         LDA &5f83,Y ; sprite_offset_b_lookup
&0d81: 95 5f            STA &5f,X ; # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0d83: 4c fe 0c         JMP &0cfe ; plot_sprite_resize_if_teleporting

; plot_sprite_continued
&0d86: b5 4f            LDA &4f,X ; # X = 3, &52 this_object_y_low_old; X = 2, &51 this_object_y_low
&0d88: 3d a1 0b         AND &0ba1,X # X = 3, &0ba4 (&f8), X = 2 &0ba3 (&f8)
&0d8b: 38               SEC
&0d8c: fd 91 0b         SBC &0b91,X # X = 3, &0b94 screen_offset_y_low_old, X = 2, &0b93 screen_offset_y_low
&0d8f: 95 57            STA &57,X # X = 3, &5a this_object_screen_y_low_old ; X = 2 &59 this_object_screen_y_low
&0d91: b5 53            LDA &53,X ; # X = 3, &56 this_object_y_old; X = 2, &55 this_object_y
&0d93: fd 95 0b         SBC &0b95,X # X = 3, &0b98 screen_offset_y_old; X = 2, &0b97 screen_offset_y
&0d96: 95 5b            STA &5b,X # X = 3, &5e this_object_screen_y_old ; X = 2, &5d this_object_screen_y
&0d98: b5 57            LDA &57,X # X = 3, &5a this_object_screen_y_low_old ; X = 2 &59 this_object_screen_y_low
&0d9a: 18               CLC
&0d9b: 75 4b            ADC (&4b,X) # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0d9d: 85 8f            STA &8f ; screen_address
&0d9f: b5 5b            LDA &5b,X # X = 3, &5e this_object_screen_y_old ; X = 2, &5d this_object_screen_y
&0da1: 69 00            ADC #&00
&0da3: 85 90            STA &90; screen_address_h
&0da5: 30 5f            BMI &0e06
&0da7: b0 47            BCS &0df0
&0da9: a5 8f            LDA &8f ; screen_address
&0dab: 38               SEC
&0dac: fd 99 0b         SBC &0b99,X ; plot_sprite_screen_address_offsets_low
&0daf: 85 8f            STA &8f ; screen_address
&0db1: a5 90            LDA &90; screen_address_h
&0db3: fd 9d 0b         SBC &0b9d,X ; plot_sprite_screen_address_offsets
&0db6: 85 90            STA &90; screen_address_h
&0db8: f0 19            BEQ &0dd3
&0dba: 10 0f            BPL &0dcb ; plot_sprite_skip_calculations
&0dbc: b5 57            LDA &57,X # X = 3, &5a this_object_screen_y_low_old ; X = 2 &59 this_object_screen_y_low
&0dbe: 18               CLC
&0dbf: 7d 89 0b         ADC &0b89,X  ; plot_sprite_screen_location_offsets_low
&0dc2: 95 57            STA &57,X # X = 3, &5a this_object_screen_y_low_old ; X = 2 &59 this_object_screen_y_low
&0dc4: b5 5b            LDA &5b,X # X = 3, &5e this_object_screen_y_old ; X = 2, &5d this_object_screen_y
&0dc6: 7d 8d 0b         ADC &0b8d,X ; plot_sprite_screen_location_offsets
&0dc9: 95 5b            STA &5b,X # X = 3, &5e this_object_screen_y_old ; X = 2, &5d this_object_screen_y
; plot_sprite_skip_calculations
&0dcb: 26 6e            ROL &6e ; skip_sprite_calculation_flags
&0dcd: ca               DEX                                                     # do it again for X =2
&0dce: 30 39            BMI &0e09 ; plot_sprite_after_calculations
&0dd0: 4c 51 0d         JMP &0d51 ; plot_sprite_calculation_loop
&0dd3: a5 8f            LDA &8f ; screen_address
&0dd5: f5 4b            SBC &4b,X # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0dd7: b0 f2            BCS &0dcb ; plot_sprite_skip_calculations
&0dd9: 5d a1 0b         EOR &0ba1,X # # X = 3, &0ba4 (&f8), X = 2 &0ba3 (&f8)
&0ddc: 95 4b            STA &4b,X # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height
&0dde: b5 63            LDA &63,X # X = 3, &66 this_sprite_vertflip_old ; X = 2, &65 this_sprite_partflip
&0de0: 10 da            BPL &0dbc
&0de2: a5 8f            LDA &8f ; screen_address
&0de4: 38               SEC
&0de5: fd a1 0b         SBC &0ba1,X # # X = 3, &0ba4 (&f8), X = 2 &0ba3 (&f8)
&0de8: 75 5f            ADC (&5f,X) # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0dea: 69 00            ADC #&00
&0dec: 95 5f            STA &5f,X ; # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0dee: 90 cc            BCC &0dbc
&0df0: a5 8f            LDA &8f ; screen_address
&0df2: 95 4b            STA &4b,X ; # X = 3, &4e this_sprite_height_old ; X = 2, &4d this_sprite_height 
&0df4: b5 63            LDA &63,X # X = 3, &66 this_sprite_vertflip_old ; X = 2, &65 this_sprite_partflip
&0df6: 30 08            BMI &0e00
&0df8: b5 5f            LDA &5f,X ; # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0dfa: f5 57            SBC &57,X # X = 3, &5a this_object_screen_y_low_old ; X = 2 &59 this_object_screen_y_low
&0dfc: 69 00            ADC #&00
&0dfe: 95 5f            STA &5f,X ; # X = 3, &62 this_sprite_b_old ; X = 2, &61 this_sprite_b
&0e00: a9 00            LDA #&00
&0e02: 95 5b            STA &5b,X # X = 3, &5e this_object_screen_y_old ; X = 2, &5d this_object_screen_y
&0e04: f0 b8            BEQ &0dbe
&0e06: 38               SEC
&0e07: b0 c2            BCS &0dcb ; plot_sprite_skip_calculations
; plot_sprite_after_calculations
&0e09: a5 6e            LDA &6e ; skip_sprite_calculation_flags
&0e0b: 29 0f            AND #&0f
&0e0d: f0 0b            BEQ &0e1a ; consider_whether_object_has_changed
&0e0f: 29 05            AND #&05
&0e11: f0 70            BEQ &0e83 ; object_needs_redrawing
&0e13: a5 6e            LDA &6e ; skip_sprite_calculation_flags
&0e15: 29 0a            AND #&0a
&0e17: f0 6a            BEQ &0e83 ; object_needs_redrawing
&0e19: 60               RTS
; consider_whether_object_has_changed				                # has anything changed about the object?
&0e1a: a5 51            LDA &51 ; this_object_y_low
&0e1c: 45 52            EOR &52 ; this_object_y_low_old		                # y_low ?
&0e1e: 29 f8            AND #&f8
&0e20: d0 61            BNE &0e83 ; object_needs_redrawing
&0e22: a5 4f            LDA &4f ; this_object_x_low
&0e24: 45 50            EOR &50 ; this_object_x_low_old		                # x_low ?
&0e26: 29 f0            AND #&f0
&0e28: d0 59            BNE &0e83 ; object_needs_redrawing
&0e2a: a5 55            LDA &55 ; this_object_y
&0e2c: 45 56            EOR &56 ; this_object_y_old		                # y ?
&0e2e: d0 53            BNE &0e83 ; object_needs_redrawing
&0e30: a5 53            LDA &53 ; this_object_x
&0e32: 45 54            EOR &54 ; this_object_x_old		                # x ?
&0e34: d0 4d            BNE &0e83 ; object_needs_redrawing
&0e36: a5 75            LDA &75 ; this_object_sprite
&0e38: 45 76            EOR &76 ; this_object_sprite_old	                # sprite ?
&0e3a: d0 47            BNE &0e83 ; object_needs_redrawing
&0e3c: a5 73            LDA &73 ; this_object_palette
&0e3e: 45 74            EOR &74 ; this_object_palette_old	                # palette ?	
&0e40: d0 41            BNE &0e83 ; object_needs_redrawing
&0e42: a5 71            LDA &71 ; this_object_flipping_flags
&0e44: 45 72            EOR &72 ; this_object_flipping_flags_old	        # flipping ?
&0e46: d0 3b            BNE &0e83 ; object_needs_redrawing
&0e48: a5 6f            LDA &6f ; this_object_flags
&0e4a: 05 70            ORA &70 ; this_object_flags_old	 	
&0e4c: 29 10            AND #&10
&0e4e: d0 33            BNE &0e83 ; object_needs_redrawing                      # if either is teleporting?
&0e50: a5 4c            LDA &4c ; this_sprite_width_old		                # sprite width?
&0e52: c5 4b            CMP &4b ; this_sprite_width
&0e54: b0 30            BCS &0e86 ; redraw_object_resized_sprite
&0e56: a5 63            LDA &63 ; this_sprite_b
&0e58: 45 cc            EOR &cc ; scroll_square_x_velocity_high
&0e5a: 30 0a            BMI &0e66
&0e5c: a5 5f            LDA &5f ; this_sprite_a
&0e5e: 65 4c            ADC &4c ; this_sprite_width_old
&0e60: 69 10            ADC #&10
&0e62: 69 00            ADC #&00
&0e64: 85 5f            STA &5f ; this_sprite_a
&0e66: a5 4b            LDA &4b ; this_sprite_width
&0e68: 38               SEC
&0e69: e5 4c            SBC &4c ; this_sprite_width_old
&0e6b: e9 10            SBC #&10
&0e6d: 85 4b            STA &4b ; this_sprite_width
&0e6f: a5 cc            LDA &cc ; scroll_square_x_velocity_high
&0e71: 30 43            BMI &0eb6
&0e73: a5 4c            LDA &4c ; this_sprite_width_old
&0e75: 18               CLC
&0e76: 69 10            ADC #&10
&0e78: 65 57            ADC &57 ; this_object_screen_x_low_old
&0e7a: 85 57            STA &57 ; this_object_screen_x_low_old
&0e7c: 90 38            BCC &0eb6
&0e7e: e6 5b            INC &5b ; this_object_screen_x_old
&0e80: 4c b6 0e         JMP &0eb6

; object_needs_redrawing
&0e83: 4c ba 0e         JMP &0eba ; object_needs_redrawing_in

; redraw_object_resized_sprite
&0e86: a5 4e            LDA &4e ; this_sprite_height_old		        # is the new sprite taller than the old one?
&0e88: c5 4d            CMP &4d ; this_sprite_height
&0e8a: b0 3f            BCS &0ecb					        # if so, leave
&0e8c: a5 65            LDA &65 ; this_sprite_vertflip_old
&0e8e: 45 ce            EOR &ce ; scroll_square_y_velocity_high
&0e90: 30 0a            BMI &0e9c
&0e92: a5 61            LDA &61 ; this_sprite_a
&0e94: 65 4e            ADC &4e ; this_sprite_height_old
&0e96: 69 08            ADC #&08
&0e98: 69 00            ADC #&00
&0e9a: 85 61            STA &61 ; this_sprite_a
&0e9c: a5 4d            LDA &4d ; this_sprite_height
&0e9e: 38               SEC
&0e9f: e5 4e            SBC &4e ; this_sprite_height_old
&0ea1: e9 08            SBC #&08
&0ea3: 85 4d            STA &4d ; this_sprite_height
&0ea5: a5 ce            LDA &ce ; scroll_square_y_velocity_high
&0ea7: 30 0d            BMI &0eb6
&0ea9: a5 4e            LDA &4e ; this_sprite_height_old
&0eab: 18               CLC
&0eac: 69 08            ADC #&08
&0eae: 65 59            ADC &59 ; this_object_screen_y_low
&0eb0: 85 59            STA &59 ; this_object_screen_y_low
&0eb2: 90 02            BCC &0eb6
&0eb4: e6 5d            INC &5d ; this_object_screen_y
&0eb6: a9 0a            LDA #&0a
&0eb8: 85 6e            STA &6e ; skip_sprite_calculation_flags
; object_needs_redrawing_in
&0eba: a9 02            LDA #&02
&0ebc: 85 ae            STA &ae ; plotter_x
&0ebe: a9 00            LDA #&00
&0ec0: 85 00            STA &00 ; square_is_mapped_data
&0ec2: 48               PHA
&0ec3: ba               TSX
&0ec4: 86 6a            STX &6a ; copy_of_stack_pointer_6a
; object_redrawing_loop
&0ec6: c6 ae            DEC &ae ; plotter_x
&0ec8: 10 02            BPL &0ecc ; do_the_plotting
&0eca: 68               PLA
&0ecb: 60               RTS

# Plot an object or the background
; do_the_plotting
&0ecc: a6 ae            LDX &ae ; plotter_x     # first X = 1, previous ; then X = 0, current
&0ece: a5 6e            LDA &6e ; skip_sprite_calculation_flags
&0ed0: 3d a5 0b         AND &0ba5,X ; plot_sprite_when_to_flags_and             # should we actually plot it?
&0ed3: d0 f1            BNE &0ec6 ; object_redrawing_loop                       # if not, continue
&0ed5: b5 5f            LDA &5f,X # X = 1, &60 this_sprite_a_old ; X = 0, &5f this_sprite_a
&0ed7: 0a               ASL
&0ed8: 69 00            ADC #&00
&0eda: 0a               ASL
&0edb: 69 00            ADC #&00
&0edd: 29 1f            AND #&1f
&0edf: 85 9c            STA &9c
# Use the palette value to set up registers &00 &01 &10 &11 &02 &20 &22
# with pixel values representing the four colours in the palette
&0ee1: b5 73            LDA &73,X # X = 1, &74 this_object_palette_old ; X = 0, &73 this_object_palette
&0ee3: 4a               LSR                                                     # use our palette
&0ee4: 4a               LSR
&0ee5: 4a               LSR
&0ee6: 4a               LSR
&0ee7: a8               TAY							# Y = palette / 16
&0ee8: b9 48 1e         LDA &1e48,Y ; pixel_table				
&0eeb: 29 55            AND #&55
&0eed: 85 11            STA &11							# to set up &11
&0eef: 0a               ASL
&0ef0: 85 22            STA &22							# and &22
&0ef2: b5 73            LDA &73,X # X = 1, &74 this_object_palette_old ; X = 0, &73 this_object_palette
&0ef4: 29 0f            AND #&0f						# Y = palette % 16
&0ef6: a8               TAY
&0ef7: b9 79 0b         LDA &0b79,Y ; palette_value_to_pixel_lookup
&0efa: 2d 78 0b         AND &0b78 ; sprite_and
&0efd: a8               TAY
&0efe: 29 55            AND #&55
&0f00: 85 01            STA &01							# and &01
&0f02: 0a               ASL
&0f03: 85 02            STA &02							# and &02
&0f05: 98               TYA
&0f06: 29 aa            AND #&aa
&0f08: 85 20            STA &20							# and &20
&0f0a: 4a               LSR
&0f0b: 85 10            STA &10							# and &10
&0f0d: b5 63            LDA &63,X # X = 1, &64 this_sprite_flipping_flags_old ; X = 0, &63 this_sprite_flipping_flags
&0f0f: 85 65            STA &65 ; plot_flipping_flags
&0f11: 4a               LSR
&0f12: 4a               LSR
&0f13: 4a               LSR
&0f14: 35 4b            AND (&4b,X) # X = 1, &4c this_sprite_width_old ; X = 0, &4b this_sprite_width
&0f16: 55 57            EOR &57,X # X = 1, &58 this_object_screen_x_low_old ; X = 0, &57 this_object_screen_x_low
&0f18: 55 5f            EOR &5f,X # X = 1, &60 this_sprite_a_old ; X = 0, &5f this_sprite_a
&0f1a: 29 10            AND #&10
&0f1c: f0 18            BEQ &0f36 ; dont_swap
&0f1e: a5 02            LDA &02							# swap &02 and &01
&0f20: a4 01            LDY &01
&0f22: 85 01            STA &01
&0f24: 84 02            STY &02
&0f26: a5 20            LDA &20							# swap &20 and &10
&0f28: a4 10            LDY &10
&0f2a: 85 10            STA &10
&0f2c: 84 20            STY &20
&0f2e: a5 22            LDA &22							# swap &22 and &11
&0f30: a4 11            LDY &11
&0f32: 85 11            STA &11
&0f34: 84 22            STY &22
; dont_swap
# Calculate the offset between rows in the sprite
&0f36: a9 20            LDA #&20			                        # offset between rows is &20
&0f38: a0 00            LDY #&00			                        # (regular vertical orientation)
&0f3a: 24 65            BIT &65 ; plot_flipping_flags
&0f3c: 70 03            BVS &0f41
&0f3e: a9 e0            LDA #&e0			                        # offset between rows is &ffe0
&0f40: 88               DEY				                        # (inverse vertical orientation)
&0f41: 8d 7d 10         STA &107d ; sprite_byte_offset_between_rows             # self modifying code
&0f44: 8c 85 10         STY &1085 ; sprite_byte_offset_between_rows_h           # self modifying code
# Calculate the sprite address
&0f47: b5 4d            LDA &4d,X # X = 1, &4e this_sprite_height_old ; X = 0, &4d this_sprite_height
&0f49: 50 02            BVC &0f4d
&0f4b: a9 00            LDA #&00
&0f4d: 18               CLC
&0f4e: 75 61            ADC (&61,X) # X = 1, &62 this_sprite_b_old ; X = 0, &61 this_sprite_b
&0f50: 69 00            ADC #&00
&0f52: 0a               ASL
&0f53: 69 00            ADC #&00
&0f55: 0a               ASL
&0f56: 69 00            ADC #&00
&0f58: 85 9d            STA &9d
&0f5a: 29 e0            AND #&e0
&0f5c: 05 9c            ORA &9c
&0f5e: 69 ec            ADC #&ec
&0f60: 8d 23 10         STA &1023 ; sprite_address                              # self modifying code
&0f63: a5 9d            LDA &9d
&0f65: 29 0f            AND #&0f
&0f67: 69 53            ADC #&53
&0f69: 8d 24 10         STA &1024 ; sprite_address_h                            # self modifying code
# Calculate the number of bytes in a line of the sprite
&0f6c: b5 57            LDA &57,X # X = 1, &58 this_object_screen_x_low_old ; X = 0, &57 this_object_screen_x_low
&0f6e: 29 10            AND #&10
&0f70: 75 4b            ADC (&4b,X) # X = 1, &4c this_sprite_width_old ; X = 0, &4b this_sprite_width
&0f72: 85 99            STA &99
&0f74: 6a               ROR
&0f75: 29 f0            AND #&f0
&0f77: 4a               LSR
&0f78: 85 a0            STA &a0
&0f7a: b5 5f            LDA &5f,X # X = 1, &60 this_sprite_a_old ; X = 0, &5f this_sprite_a
&0f7c: 29 30            AND #&30
&0f7e: 75 4b            ADC (&4b,X) # X = 1, &4c this_sprite_width_old ; X = 0, &4b this_sprite_width
&0f80: 6a               ROR
&0f81: 4a               LSR
&0f82: 4a               LSR
&0f83: 4a               LSR
&0f84: a8               TAY
&0f85: 4a               LSR
&0f86: 4a               LSR
&0f87: 85 69            STA &69 ; bytes_per_line_in_sprite
# Calculate the number of bytes in a line on the screen. The sprite data is
# unpacked into the stack - we also calculate where to put it.
&0f89: b5 4b            LDA &4b,X # X = 1, &4c this_sprite_width_old ; X = 0, &4b this_sprite_width
&0f8b: 4a               LSR
&0f8c: 4a               LSR
&0f8d: 4a               LSR
&0f8e: 4a               LSR
&0f8f: 85 9d            STA &9d
&0f91: 98               TYA
&0f92: 29 03            AND #&03
&0f94: 18               CLC
&0f95: 65 6a            ADC &6a ; copy_of_stack_pointer_6a
&0f97: e9 01            SBC #&01
&0f99: 8d 52 10         STA &1052                                               # self modifying code
&0f9c: aa               TAX
&0f9d: e8               INX
&0f9e: e5 9d            SBC &9d
&0fa0: e9 02            SBC #&02
&0fa2: 8d 55 10         STA &1055                                               # self modifying code
&0fa5: a0 ca            LDY #&ca		                                # &ca = DEX (right facing)
&0fa7: 24 65            BIT &65 ; plot_flipping_flags
&0fa9: 10 04            BPL &0faf
&0fab: aa               TAX
&0fac: ca               DEX
&0fad: a0 e8            LDY #&e8		                                # &e8 = INX (left facing)
&0faf: a5 99            LDA &99
&0fb1: 29 10            AND #&10
&0fb3: f0 04            BEQ &0fb9
&0fb5: 8c b8 0f         STY &0fb8                                               # self modifying code
&0fb8: e8               INX                                                     # either INX or DEX from &0fb5
&0fb9: 86 6b            STX &6b ; bytes_per_line_on_screen
&0fbb: 8c 5c 10         STY &105c		                                # self modifying code
&0fbe: 8c 60 10         STY &1060		                                # self modifying code
# Calculate the number of lines in the sprite
&0fc1: a6 ae            LDX &ae ; plotter_x
&0fc3: b5 4d            LDA &4d,X # X = 1, &4e this_sprite_height_old ; X = 0, &4d this_sprite_height
&0fc5: 4a               LSR
&0fc6: 4a               LSR
&0fc7: 4a               LSR
&0fc8: 85 6c            STA &6c ; lines_in_sprite
# Calculate the screen address of the sprite
&0fca: b5 59            LDA &59,X # X = 1, &5a this_object_screen_y_low_old ; X = 0, &59 this_object_screen_y_low
&0fcc: 18               CLC
&0fcd: 75 4d            ADC (&4d,X) # X = 1, &4e this_sprite_height_old ; X = 0, &4d this_sprite_height
&0fcf: 85 8f            STA &8f ; screen_address
&0fd1: b5 5d            LDA &5d,X # X = 1, &5e this_object_screen_y_old ; X = 0 &5d this_object_screen_y
&0fd3: 69 00            ADC #&00
&0fd5: 85 90            STA &90; screen_address_h
&0fd7: 20 58 1f         JSR &1f58 ; scroll_screen
&0fda: a5 8f            LDA &8f ; screen_address
&0fdc: 46 90            LSR &90; screen_address_h
&0fde: 6a               ROR
&0fdf: 46 90            LSR &90; screen_address_h
&0fe1: 6a               ROR
&0fe2: 46 90            LSR &90; screen_address_h
&0fe4: 6a               ROR
&0fe5: a8               TAY
&0fe6: 29 07            AND #&07
&0fe8: 05 a0            ORA &a0
&0fea: 85 a1            STA &a1
&0fec: 09 07            ORA #&07
&0fee: 85 a0            STA &a0
&0ff0: b5 57            LDA &57,X # X = 1, &58 this_object_screen_x_low_old ; X = 0, &57 this_object_screen_x_low
&0ff2: 29 e0            AND #&e0
&0ff4: 65 b2            ADC &b2 ; screen_start_square_x_low_copy
&0ff6: 85 8f            STA &8f ; screen_address
&0ff8: 98               TYA
&0ff9: 29 f8            AND #&f8
&0ffb: 55 5b            EOR &5b,X # X = 1, &5c this_object_screen_x_old ; X = 0, &5b this_object_screen_x
&0ffd: 65 b3            ADC &b3 ; some_screen_address_offset
&0fff: 6a               ROR
&1000: 66 8f            ROR &8f ; screen_address
&1002: 4a               LSR
&1003: 66 8f            ROR &8f ; screen_address
&1005: 09 60            ORA #&60
&1007: 85 90            STA &90; screen_address_h
; plot_lines_loop
&1009: c9 7f            CMP #&7f
&100b: d0 13            BNE &1020 ; plot_sprite_line
&100d: a5 8f            LDA &8f ; screen_address
&100f: 18               CLC
&1010: 65 a1            ADC &a1
&1012: 90 0c            BCC &1020 ; plot_sprite_line
&1014: 85 67            STA &67 ; something_plot_var
&1016: a9 50            LDA #&50		                                # set &1070 to BVC &109c
&1018: 8d 70 10         STA &1070		                                # self modifying code
&101b: a9 2a            LDA #&2a		
&101d: 8d 71 10         STA &1071		                                # self modifying code
; plot_sprite_line
&1020: a4 69            LDY &69 ; bytes_per_line_in_sprite
# For each byte in the sprite data, unpack it onto the stack.
; line_loop
&1022: b9 ff ff         LDA &ffff,Y                                             # actually LDA &sprite_address,Y from &0f60, &0f69
&1025: aa               TAX
&1026: 29 11            AND #&11
&1028: 8d 2c 10         STA &102c		                                # self modifying code - &102c = sprite_data & 0x11
&102b: a5 ff            LDA &ff			                                # actually LDA &(sprite_data & 0x11) from &1028
&102d: 48               PHA			                                # push on to stack
&102e: 8a               TXA
&102f: 29 22            AND #&22
&1031: 8d 35 10         STA &1035		                                # self modifying code - &1035 = sprite_data & 0x22
&1034: a5 ff            LDA &ff			                                # actually LDA &(sprite_data & 0x22) from &1031
&1036: 48               PHA			                                # push on to stack
&1037: 8a               TXA
&1038: 4a               LSR
&1039: 4a               LSR
&103a: aa               TAX
&103b: 29 11            AND #&11
&103d: 8d 41 10         STA &1041		                                # self modifying code - &1041 = sprite_data & 0x44 / 4
&1040: a5 ff            LDA &ff			                                # actually LDA &(sprite_data & 0x44 / 4) from &103d
&1042: 48               PHA			                                # push on to stack
&1043: 8a               TXA
&1044: 29 22            AND #&22
&1046: 8d 4a 10         STA &104a		                                # self modifying code - &104a = sprite_data & 0x88 / 4
&1049: a5 ff            LDA &ff			                                # actually LDA &(sprite_data & 0x88 / 4) from &1046
&104b: 48               PHA			                                # push on to stack
&104c: 88               DEY
&104d: 10 d3            BPL &1022 ; line_loop
&104f: 48               PHA
&1050: c8               INY
&1051: 8c ff 01         STY &01ff		                                # actually &01XX from &0f99
&1054: 8c ff 01         STY &01ff		                                # actually &01XX from &0fa2
&1057: 38               SEC
&1058: a4 a1            LDY &a1
&105a: a6 6b            LDX &6b ; bytes_per_line_on_screen
; plot_screen_loop
# Now take that data from the stack and plot it to the screen - if the
# plotting mode is set to overwrite, just plot it, otherwise consider
# what is there already - if it's background data (&80 is set), don't.
&105c: ca               DEX			                                # actually either DEX or INX from &0fbb
&105d: bd 00 01         LDA &0100,X		                                # read data from stack
&1060: ca               DEX			                                # actually either DEX or INX from &0fbe
&1061: 1d 00 01         ORA &0100,X
&1064: 51 8f            EOR (&8f),Y ; screen_address 	                        # read the current screen data
&1066: 30 02            BMI &106a		                                # actually either "EOR, BMI &106a" or "BMI &1068, EOR" from &10f0
&1068: 91 8f            STA (&8f),Y ; screen_address                            # plot the sprite to screen depending on plotting mode
&106a: 98               TYA
&106b: e9 08            SBC #&08
&106d: a8               TAY
&106e: b0 ec            BCS &105c ; plot_screen_loop
&1070: a6 6a            LDX &6a ; copy_of_stack_pointer_6a	                # actually either "LDX &6a" or "BVC &109c" from &10c5, &10c5 or &1016, &101b
     # 50 2a		BVC &109c
&1072: 9a               TXS			                                # reset stack pointer
&1073: c6 6c            DEC &6c ; lines_in_sprite
&1075: 30 58            BMI &10cf ; plotting_done                               # any more lines to do? if not, leave
&1077: c6 a1            DEC &a1
&1079: ad 23 10         LDA &1023 ; sprite_address
&107c: 69 20            ADC #&20		                                # actually ADC #sprite_byte_offset_between_rows from &0f41
&107e: 8d 23 10         STA &1023 ; sprite_address
&1081: ad 24 10         LDA &1024 ; sprite_address_h
&1084: 69 00            ADC #&00		                                # actually ADC #sprite_byte_offset_between_rows_h from &0f44
&1086: 8d 24 10         STA &1024 ; sprite_address_h
&1089: c0 f9            CPY #&f9
&108b: b0 93            BCS &1020 ; plot_sprite_line
&108d: a5 a0            LDA &a0
&108f: 85 a1            STA &a1
&1091: a5 90            LDA &90; screen_address_h
&1093: e9 01            SBC #&01
&1095: 09 60            ORA #&60
&1097: 85 90            STA &90; screen_address_h
&1099: 4c 09 10         JMP &1009 ; plot_lines_loop                             # do it all again for the next line
&109c: a5 90            LDA &90; screen_address_h
&109e: c9 7f            CMP #&7f
&10a0: 49 1f            EOR #&1f
&10a2: 85 90            STA &90; screen_address_h
&10a4: 90 0c            BCC &10b2
&10a6: a5 8f            LDA &8f ; screen_address
&10a8: 85 68            STA &68 ; some_other_plot_var
&10aa: a9 00            LDA #&00
&10ac: 85 8f            STA &8f ; screen_address
&10ae: a4 67            LDY &67 ; something_plot_var
&10b0: b0 a8            BCS &105a
&10b2: a5 68            LDA &68 ; some_other_plot_var
&10b4: 85 8f            STA &8f ; screen_address
&10b6: a6 6a            LDX &6a ; copy_of_stack_pointer_6a
&10b8: c0 f9            CPY #&f9
&10ba: 90 07            BCC &10c3
&10bc: c6 67            DEC &67 ; something_plot_var
&10be: 18               CLC
&10bf: a5 6c            LDA &6c ; lines_in_sprite
&10c1: d0 af            BNE &1072
&10c3: a9 a6            LDA #&a6                                                # set &1070 to LDX &6a
&10c5: 8d 70 10         STA &1070			                        # self modifying code
&10c8: a9 6a            LDA #&6a
&10ca: 8d 71 10         STA &1071                                               # self modifying code
&10cd: 90 a3            BCC &1072
; plotting_done
&10cf: 4c c6 0e         JMP &0ec6 ; object_redrawing_loop

; plot_background_strip_from_cache
&10d2: 20 f0 10         JSR &10f0 ; change_display_mode                         # set display mode to "overwrite"
&10d5: c6 af            DEC &af ; strip_length
&10d7: 30 17            BMI &10f0 ; change_display_mode                         # revert display mode to "if empty", and leave
&10d9: a6 af            LDX &af ; strip_length
&10db: bd ed 07         LDA &07ed,X ; background_strip_cache_orientation        # get the square data from the cache
&10de: 85 09            STA &09 ; square_orientation
&10e0: bd f6 07         LDA &07f6,X ; background_strip_cache_sprite
&10e3: 85 08            STA &08 ; square_sprite
&10e5: 20 9b 23         JSR &239b ; setup_background_sprite_values_from_08_09   # determine which sprite/palette to use
&10e8: 20 06 11         JSR &1106 ; plot_background_square                      # plot the squre
&10eb: e6 95            INC &95 ; square_x                                      # move to next square (modified from &375b)
&10ed: 4c d5 10         JMP &10d5

; change_display_mode
&10f0: a2 01            LDX #&01			                        # swap &1064-1065 and &1066-&1067
&10f2: bd 64 10         LDA &1064,X			                        # this changes the display mode between overwriting
&10f5: bc 66 10         LDY &1066,X			                        # regardless and overwriting only if empty
&10f8: 9d 66 10         STA &1066,X			
&10fb: 98               TYA				
&10fc: 9d 64 10         STA &1064,X			
&10ff: ca               DEX				
&1100: 10 f0            BPL &10f2			
&1102: 60               RTS

# unused code
&1103: 20 98 23         JSR &2398 ; setup_background_sprite_values

; plot_background_square
&1106: c0 19            CPY #&19                                                # is the square an empty space?
&1108: f0 f8            BEQ &1102                                               # if so, leave
&110a: a9 00            LDA #&00
&110c: 85 6e            STA &6e ; skip_sprite_calculation_flags
&110e: a9 00            LDA #&00
&1110: 85 6f            STA &6f ; this_object_flags
&1112: 85 70            STA &70 ; this_object_flags_old
&1114: 4c 4d 0d         JMP &0d4d ; plot_sprite                                 # this plots the background space

#1117: e0 ; screen_size_low_x
#1118: ea ; (unused)
#1119: c0 ; screen_size_low_y
#111a: 07 ; screen_size_x
#111b: ea ; (unused)
#111c: 03 ; screen_size_y

; is_object_offscreen
# Y = radius around screen to consider
# returns carry clear if onscreen, carry set if offscreen
&111d: 84 9b            STY &9b ; radius
&111f: e6 9b            INC &9b ; radius
&1121: e6 9b            INC &9b ; radius
&1123: a2 02            LDX #&02                                                # in y direction first (X = 2), then x direction (X = 0)
&1125: bd 95 0b         LDA &0b95,X     # X = 2, &0b97 screen_offset_y; X = 0, &0b95 ; screen_offset_x
&1128: 38               SEC
&1129: f5 53            SBC &53,X       # X = 2, &55 this_object_y; X = 0, &53 this_object_x
&112b: 85 9d            STA &9d ; tmp_9d                                        # screen_offset - object
&112d: 18               CLC
&112e: e5 9b            SBC &9b ; radius                                        # is (screen_offset - object - radius) > 0
&1130: 10 1b            BPL &114d ; object_is_offscreen                         # if so, object is offscreen
&1132: bd 17 11         LDA &1117,X     # X = 2, &1119 screen_size_low_y; X = 0, &1117 screen_size_low_x
&1135: 18               CLC
&1136: 7d 91 0b         ADC &0b91,X     # X = 2, &0b93 screen_offset_y_low; X = 0, &0b91 ; screen_offset_x_low
&1139: bd 1a 11         LDA &111a,X     # X = 2, &111c screen_size_y; X = 0, &111a screen_size_x
&113c: 65 9d            ADC &9d
&113e: 18               CLC
&113f: 65 9b            ADC &9b ; radius                                        # is (screen_size + screen_offset - object + radius) < 0
&1141: 30 0a            BMI &114d ; object_is_offscreen                         # if so, object is offscreen
&1143: c6 9b            DEC &9b ; radius
&1145: c6 9b            DEC &9b ; radius                                        # smaller radius in x direction
&1147: ca               DEX
&1148: ca               DEX
&1149: f0 da            BEQ &1125                                               # and do it again for x direction
&114b: 18               CLC                                                     # return carry clear if onscreen
&114c: 60               RTS
; object_is_offscreen
&114d: 38               SEC                                                     # return carry set if offscreen
&114e: 60               RTS

; various lookups for background
; background_lookup
#114f: 19 2d ed 6d ad 2d ed
#1156: 5e 9e 00 c0 80 40 
#115c: 2e 2e 2e 23
#1160: 06 04 06 04 07 05 05 06 19 2c 19 2b 00 01 02 03
#1170: 1a 21 09 9b 12 10 60 2b 0f 4f 04 0a

; lookup_for_unmatched_hash
#117c: 1b 5a 19 19 1e 13 24 2c 19

; lookup table for Y -> palette for background
#1185: 8d 82 8b 8f 84 89 8d 81 82 81 85 ; wall_palette_zero_lookup
#118c: ; wall_palette_four_lookup
#1190: b2 cd 90 95

#1194: 81

#1195: b1 97 fd f3 00 ; wall_palette_three_lookup

#119a: 03 ; sound_max_channels
#119b: 01 ; (unused)

#119c: 00 40 84 b6 ; sound_data_119c
#11a0: e0 10 4a 80 ; sound_data_11a0
#11a4: e0 c0 a0 80 f0 d0 b0 90 ; sound_data_11a4
#11ac: 00 00 00 00 00 00 00 00 ; sound_duration
#11b4: 33 22 11 00 33 22 11 00 ; sound_data_11b4
#11bc: 33 22 11 00 33 22 11 00 ; sound_data_11bc
#11c4: 33 22 11 00 33 22 11 00 ; sound_data_11c4
#11cc: 00 00 00 00 00 00 00 00 ; sound_duration_low
#11d4: 33 22 11 00 33 22 11 00 ; sound_data_11d4
#11dc: 00 00 00 00 00 00 00 00 ; sound_data_11dc

#11e4: 00 ; palette_register_updating
#11e5: 07 16 25 34 43 52 61 70 87 96 a5 b4 c3 d2 e1 f0 ; palette_register_data
#      0:black 1:red 2:green 3:yellow 4:blue 5:magenta 6:cyan 7:white
#      8:black 9:red a:green b:yellow c:blue d:magenta e:cyan f:white

#11f5: 00 ; keys_processed

; function_table
#11f6: 75 e1 e1 e1 e1 e1 e1 e1 e1 e1 e1 d5 f7 32 1f 1c 1c 1c 1c 28 25 80 79 18 98 ab c0 3b d8 c7 b5 b0 99 6c 69 72 92 6f 9b
; function_table_h
#121d: 6a 59 59 59 59 59 59 59 59 59 59 28 69 5b 62 59 59 59 59 62 62 58 58 3d 59 59 19 59 64 64 64 69 25 58 58 58 77 58 28
; keys_to_check
#1244: 69 20 71 72 73 14 74 75 16 76 77 77 53 62 25 19 79 39 29 46 36 47 01 60 44 35 23 33 67 65 66 51 63 10 21 37 37 56 00
; keys_pressed
#126b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#1281: ctrl_held_duration
#1291: shift_held_duration

###############################################################################
#
#   Function Table
#   ==============
#   offset sym  h  l        key     address function
#   00      69 6a 75        copy    &3576   pause               # mapped as END in mess
#   01      20 59 e1        f0      &2ce2   change_to_weapon
#   02      71 59 e1        f1      &2ce2   change_to_weapon
#   03      72 59 e1        f2      &2ce2   change_to_weapon
#   04      73 59 e1        f3      &2ce2   change_to_weapon
#   05      14 59 e1        f5      &2ce2   change_to_weapon
#   06      74 59 e1        f5      &2ce2   change_to_weapon
#   07      75 59 e1        f6      &2ce2   change_to_weapon
#   08      16 59 e1        f7      &2ce2   change_to_weapon
#   09      76 59 e1        f8      &2ce2   change_to_weapon
#   0a      77 59 e1        f9      &2ce2   change_to_weapon
#   0b      77 28 d5        f9      &14d6   f9_pressed
#   0c      53 69 f7        g       &34f8   retrieve_object
#   0d      62 5b 32        space   &2d33   fire_weapon
#   0e      25 62 1f        i       &3120   reset_gun_aim
#   0f      19 59 1c        left    &2c1d   scroll_viewpoint
#   10      79 59 1c        right   &2c1d   scroll_viewpoint
#   11      39 59 1c        up      &2c1d   scroll_viewpoint
#   12      29 59 1c        down    &2c1d   scroll_viewpoint
#   13      46 62 28        k       &3129   lower_gun_aim
#   14      36 62 25        o       &3126   raise_gun_aim
#   15      47 58 80        @       &2c81   use_booster         # mapped as \ in mess
#   16      01 58 79        ctrl    &2c80   (null)
#   17      60 3d 18        tab     &1e19   swap_direction
#   18      44 59 98        y       &2c99   play_whistle_1
#   19      35 59 ab        u       &2cac   play_whistle_2
#   1a      23 19 c0        t       &0cc1   teleport_player
#   1b      33 59 3b        r       &2c3c   store_teleport
#   1c      67 64 d8        .       &32d9   throw_object
#   1d      65 64 c7        m       &32c8   drop_object
#   1e      66 64 b5        ,       &32b6   pick_up_object
#   1f      51 69 b0        s       &34b1   store_object
#   20      63 25 99        v       &129a   volume_control
#   21      10 58 6c        q       &2c6d   move_left
#   22      21 58 69        w       &2c6a   move_right
#   23      37 58 72        p       &2c73   move_up
#   24      37 77 92        p       &3b93   p_pressed
#   25      56 58 6f        l       &2c70   move_down
#   26      00 28 9b        shift   &149c   (null)
#
###############################################################################

#1292: ff ; volume

; increment_game_time
&1293: e8               INX
; increment_game_time_X
&1294: fe ff 07         INC &07ff,X ; game_time
&1297: f0 fa            BEQ &1293
&1299: 60               RTS

; volume_control
&129a: ad 92 12         LDA &1292 ; volume
&129d: 49 ff            EOR #&ff
&129f: 8d 92 12         STA &1292 ; volume
&12a2: 60               RTS

&12a3: 4c 92 13         JMP &1392 ; leave_interrupt

; IRQ1V from interrupt &0204
&12a6: 98               TYA
&12a7: 48               PHA
&12a8: 8a               TXA
&12a9: 48               PHA
&12aa: 2c 4d fe         BIT &fe4d                                               # get system VIA interrupt flag register
&12ad: 10 f4            BPL &12a3	                                        # has the VIA caused an interrupt? if not, leave
&12af: a9 7f            LDA #&7f
&12b1: 8d 4d fe         STA &fe4d                                               # set system VIA interrupt flag register
&12b4: 50 12            BVC &12c8
&12b6: a9 01            LDA #&01                                                # colour 0 = cyan
&12b8: 8d 21 fe         STA &fe21                                               # video ULA palette register
&12bb: a0 18            LDY #&18
&12bd: 88               DEY
&12be: d0 fd            BNE &12bd
&12c0: a9 03            LDA #&03                                                # colour 0 = blue
&12c2: 8d 21 fe         STA &fe21                                               # video ULA palette register
&12c5: 4c 92 13         JMP &1392 ; leave_interrupt

&12c8: ad cf 14         LDA &14cf ; water_level_on_screen
&12cb: f0 09            BEQ &12d6
&12cd: ac ce 14         LDY &14ce ; water_level_interrupt
&12d0: 8c 44 fe         STY &fe44	                                        # interrupt to change colour for water
&12d3: 8d 45 fe         STA &fe45

&12d6: a9 07            LDA #&07                                                # colour 0 = black
&12d8: 8d 21 fe         STA &fe21                                               # video ULA palette register
&12db: ee e4 11         INC &11e4 ; palette_register_updating
&12de: ad be 14         LDA &14be ; palette_register_data_updated	        # has the palette register data changed?
&12e1: f0 06            BEQ &12e9 ; no_update_to_palette		
&12e3: 20 0f 3e         JSR &3e0f ; push_palette_register_data		        # if so, push it to the video chip
&12e6: 8c be 14         STY &14be ; palette_register_data_updated	        # and mark it as having been updated
; no_update_to_palette
&12e9: a9 7f            LDA #&7f                                                # set port A for input on bit 7 others outputs
&12eb: 8d 43 fe         STA &fe43
&12ee: a9 03            LDA #&03                                                # stop auto scan
&12f0: 8d 40 fe         STA &fe40
&12f3: ae f5 11         LDX &11f5 ; keys_processed	                        # have we processed the last lot of keys?
&12f6: f0 02            BEQ &12fa			                        # don't check again unless we have
&12f8: a2 26            LDX #&26
&12fa: bd 44 12         LDA &1244,X ; keys_to_check                             # has a key been pressed?
&12fd: 8d 4f fe         STA &fe4f                                               # store the key sym
&1300: ad 4f fe         LDA &fe4f	                                        # read the result
&1303: 2a               ROL
&1304: 7e 6b 12         ROR &126b,X ; keys_pressed                              # and store in keys_pressed
&1307: ca               DEX
&1308: 10 f0            BPL &12fa
&130a: a9 0b            LDA #&0b                                                # select auto scan of keyboard
&130c: 8d 40 fe         STA &fe40
&130f: e8               INX
&1310: 8e f5 11         STX &11f5 ; keys_processed
&1313: 2c bd 14         BIT &14bd ; game_paused                                 # is the game paused?
&1316: 10 7a            BPL &1392 ; leave_interrupt                             # if so, leave interrupt
&1318: 20 94 12         JSR &1294 ; increment_game_time_X
&131b: a9 ff            LDA #&ff
&131d: 8d 43 fe         STA &fe43
&1320: ae 9a 11         LDX &119a ; sound_max_channels                          # handle sounds
&1323: 20 99 13         JSR &1399 ; process_sound
&1326: b0 0a            BCS &1332
&1328: bd ac 11         LDA &11ac,X ; sound_duration
&132b: e9 01            SBC #&01
&132d: 90 47            BCC &1376 ; sound_run_out
&132f: 9d ac 11         STA &11ac,X ; sound_duration
&1332: e8               INX
&1333: e8               INX
&1334: e8               INX
&1335: e8               INX
&1336: 20 99 13         JSR &1399 ; process_sound
&1339: ca               DEX
&133a: ca               DEX
&133b: ca               DEX
&133c: ca               DEX
&133d: 90 37            BCC &1376 ; sound_run_out
&133f: d0 04            BNE &1345
&1341: c5 23            CMP &23 ; used_in_sound
&1343: f0 31            BEQ &1376 ; sound_run_out
&1345: 49 ff            EOR #&ff
&1347: a0 04            LDY #&04
&1349: 84 23            STY &23 ; used_in_sound
&134b: 88               DEY
&134c: d9 9c 11         CMP &119c,Y ; sound_data_119c
&134f: 90 fa            BCC &134b
&1351: f9 a0 11         SBC &11a0,Y ; sound_data_11a0
&1354: 88               DEY
&1355: 30 06            BMI &135d
&1357: 0a               ASL
&1358: 26 23            ROL &23 ; used_in_sound
&135a: 4c 54 13         JMP &1354
&135d: 48               PHA
&135e: 29 0f            AND #&0f
&1360: 1d a4 11         ORA &11a4,X ; sound_data_11a4
&1363: 20 e4 13         JSR &13e4 ; push_sound_to_chip
&1366: 68               PLA
&1367: e0 00            CPX #&00
&1369: f0 0b            BEQ &1376 ; sound_run_out
&136b: 46 23            LSR &23 ; used_in_sound
&136d: 6a               ROR
&136e: 46 23            LSR &23 ; used_in_sound
&1370: 6a               ROR
&1371: 4a               LSR
&1372: 4a               LSR
&1373: 20 e4 13         JSR &13e4 ; push_sound_to_chip
; sound_run_out
&1376: bd ac 11         LDA &11ac,X ; sound_duration
&1379: fd dc 11         SBC &11dc,X ; sound_data_11dc
&137c: b0 02            BCS &1380
&137e: a9 00            LDA #&00
&1380: 2d 92 12         AND &1292 ; volume
&1383: 49 ff            EOR #&ff
&1385: 4a               LSR
&1386: 4a               LSR
&1387: 4a               LSR
&1388: 4a               LSR
&1389: 1d a8 11         ORA &11a8,X
&138c: 20 e4 13         JSR &13e4 ; push_sound_to_chip
&138f: ca               DEX
&1390: 10 91            BPL &1323
; leave_interrupt
&1392: 68               PLA
&1393: aa               TAX
&1394: 68               PLA
&1395: a8               TAY
&1396: a5 fc            LDA &fc
&1398: 40               RTI

; X = channel
; process_sound
&1399: 18               CLC
&139a: bd cc 11         LDA &11cc,X ; sound_duration_low                        # is this channel playing?
&139d: f0 44            BEQ &13e3 ; process_sound_out                           # if not, leave
&139f: bc b4 11         LDY &11b4,X ; sound_data_11b4
&13a2: bd bc 11         LDA &11bc,X ; sound_data_11bc
&13a5: d0 2d            BNE &13d4
&13a7: bd c4 11         LDA &11c4,X ; sound_data_11c4
&13aa: d0 05            BNE &13b1
&13ac: de cc 11         DEC &11cc,X ; sound_duration_low
&13af: f0 32            BEQ &13e3 ; process_sound_out
&13b1: c8               INY
&13b2: b9 b9 2d         LDA &2db9,Y ; sound_data_big_lookup_table
&13b5: 10 15            BPL &13cc
&13b7: de c4 11         DEC &11c4,X ; sound_data_11c4
&13ba: 10 0a            BPL &13c6
&13bc: 29 7f            AND #&7f
&13be: 9d c4 11         STA &11c4,X ; sound_data_11c4
&13c1: c8               INY
&13c2: 98               TYA
&13c3: 9d d4 11         STA &11d4,X ; sound_data_11d4
&13c6: bc d4 11         LDY &11d4,X ; sound_data_11d4
&13c9: b9 b9 2d         LDA &2db9,Y ; sound_data_big_lookup_table
&13cc: 9d bc 11         STA &11bc,X ; sound_data_11bc
&13cf: c8               INY
&13d0: 98               TYA
&13d1: 9d b4 11         STA &11b4,X ; sound_data_11b4
&13d4: bd ac 11         LDA &11ac,X ; sound_duration
&13d7: 85 23            STA &23 ; used_in_sound
&13d9: 79 b9 2d         ADC &2db9,Y ; sound_data_big_lookup_table
&13dc: 9d ac 11         STA &11ac,X ; sound_duration
&13df: de bc 11         DEC &11bc,X ; sound_data_11bc
&13e2: 38               SEC
; process_sound_out
&13e3: 60               RTS

; push_sound_to_chip
&13e4: 8d 4f fe         STA &fe4f
&13e7: a9 00            LDA #&00
&13e9: 8d 40 fe         STA &fe40
&13ec: a9 22            LDA #&22
&13ee: 4a               LSR
&13ef: 90 fd            BCC &13ee
&13f1: 8d 40 fe         STA &fe40
&13f4: 4a               LSR
&13f5: 90 fd            BCC &13f4
&13f7: 60               RTS

; play_sound2
&13f8: 38               SEC
&13f9: 24 18            BIT &18 ; wall_collision_bottom_minus_top
; play_sound
&13fa: 18		CLC
&13fb: 85 98            STA &98 ; temp_a                # store registers
&13fd: 86 99            STX &99 ; temp_x
&13ff: 84 9a            STY &9a ; temp_y
&1401: 08               PHP                             # push processor status
&1402: 68               PLA                             # and pull it back again
&1403: aa               TAX                             # X is processor status
&1404: 68               PLA                             
&1405: 85 9b            STA &9b ; sound_data_l          # &9b is lsb of sound data
&1407: 18               CLC
&1408: 69 04            ADC #&04
&140a: a8               TAY                             # Y is lsb of new return address
&140b: 68               PLA
&140c: 85 9c            STA &9c ; sound_data_h          # &9c is msb of sound data
&140e: 69 00            ADC #&00
&1410: 48               PHA                             # push msb of new return address
&1411: 98               TYA
&1412: 48               PHA                             # push lsb of new return address
&1413: 8a               TXA
&1414: 48               PHA                             # push processor status
&1415: 20 59 35         JSR &3559 ; get_object_distance_from_screen_centre
&1418: c9 10            CMP #&10                        # is it too far away?
&141a: b0 78            BCS &1494 ; play_sound_out      # if so, it makes no noise
&141c: 0a               ASL
&141d: 0a               ASL
&141e: 0a               ASL
&141f: 0a               ASL
&1420: a8               TAY                             # Y = distance * 16
&1421: 28               PLP                             # pull processor status
&1422: 90 09            BCC &142d
&1424: a2 00            LDX #&00
&1426: ad cc 11         LDA &11cc ; sound_duration_low
&1429: f0 39            BEQ &1464 ; sound_slot_found
&142b: b0 22            BCS &144f
&142d: ae 9a 11         LDX &119a ; sound_max_channels
&1430: bd cc 11         LDA &11cc,X ; sound_duration_low
&1433: f0 2f            BEQ &1464 ; sound_slot_found
&1435: ca               DEX
&1436: d0 f8            BNE &1430
&1438: ad e1 11         LDA &11e1
&143b: 4d e2 11         EOR &11e2
&143e: 4d e3 11         EOR &11e3
&1441: ae 9a 11         LDX &119a ; sound_max_channels
&1444: dd e0 11         CMP &11e0,X
&1447: f0 15            BEQ &145e
&1449: ca               DEX
&144a: d0 f8            BNE &1444
&144c: ae 9a 11         LDX &119a ; sound_max_channels
; find_sound_slot_loop
&144f: 98               TYA                             # A = distance * 16
&1450: dd dd 11         CMP &11dd,X
&1453: f0 0f            BEQ &1464 ; sound_slot_found
&1455: 90 0d            BCC &1464 ; sound_slot_found
&1457: ca               DEX
&1458: f0 3b            BEQ &1495 ; play_sound_out2     # couldn't find a slot
&145a: 10 f3            BPL &144f ; find_sound_slot_loop
&145c: 30 37            BMI &1495 ; play_sound_out2     # couldn't find a slot
&145e: ca               DEX
&145f: d0 03            BNE &1464 ; sound_slot_found
&1461: ae 9a 11         LDX &119a ; sound_max_channels
; sound_slot_found                                      # X = 
&1464: 98               TYA                             # A = distance * 16
&1465: 9d dc 11         STA &11dc,X ; sound_data_11dc
&1468: a5 9b            LDA &9b ; sound_data_l
&146a: 9d e0 11         STA &11e0,X
&146d: a0 01            LDY #&01
&146f: 08               PHP
&1470: 78               SEI
&1471: b1 9b            LDA (&9b),Y ; sound_data        # pitch increase?
&1473: 9d b4 11         STA &11b4,X ; sound_data_11b4
&1476: c8               INY
&1477: b1 9b            LDA (&9b),Y ; sound_data
&1479: 29 f0            AND #&f0
&147b: 9d ac 11         STA &11ac,X ; sound_duration
&147e: 51 9b            EOR (&9b),Y ; sound_data
&1480: 9d cc 11         STA &11cc,X ; sound_duration_low
&1483: c8               INY
&1484: a9 00            LDA #&00
&1486: 9d bc 11         STA &11bc,X ; sound_data_11bc
&1489: 9d c4 11         STA &11c4,X ; sound_data_11c4
&148c: e8               INX
&148d: e8               INX
&148e: e8               INX
&148f: e8               INX
&1490: e0 08            CPX #&08
&1492: 90 dd            BCC &1471
; play_sound_out
&1494: 28               PLP                             # restore processor status
; play_sound_out2
&1495: a5 98            LDA &98 ; temp_a                # restore registers
&1497: a6 99            LDX &99 ; temp_x
&1499: a4 9a            LDY &9a ; temp_y
&149b: 38               SEC
&149c: 60               RTS

; play_middle_beep
&149d: 20 fa 13         JSR &13fa ; play_sound
#14a0: 17 e3 2f 72 ; sound data
&14a4: 60               RTS

; play_high_beep
&14a5: 20 fa 13         JSR &13fa ; play_sound
#14a8: 17 82 13 f2 ; sound data
&14ac: 60               RTS

; play_low_beep
&14ad: 20 fa 13         JSR &13fa ; play_sound
#14b0: 5d 04 ff 05 ; sound data
&14b2; 60               RTS

; play_squeal
&14b5: 20 fa 13         JSR &13fa ; play_sound
#14b8: 33 03 2d 84
&14bc: 60		RTS

#14bd: 92 ; game_paused
#14be: 01 ; palette_register_data_updated

#14bf: bf 80 c0 ff 40 7f 3f 00 ; angle_modification_table

#14c7: 04 ; something_scrolly_x
#14c8: 00 ; scroll_offset_x
#14c9: 02 ; something_scrolly_y
#14ca: 00 ; scroll_offset_y
#14cb: 00 ; player_object_number
#14cc: 00 ; always_zero
#14cd: 00 ; call_object_handlers_when_redrawing_screen
#14ce: 00 ; water_level_interrupt
#14cf: 00 ; water_level_on_screen
#14d0: 00 ; water_level_low
#14d1: 00 ; water_level

#14d2: 00 54 74 a0 ; x_ranges

; f9_pressed
&14d6: 2c 91 12		BIT &1291 ; shift_held_duration                         # if shift held?
&14d9: 10 4e            BPL &1529                                               # if not, leave
; save our position data somewhere more stable...
&14db: 20 4e 39         JSR &394e ; null_function
&14de: f8               SED
&14df: 78               SEI
&14e0: a5 da            LDA &da ; timer_2
&14e2: 45 dc            EOR &dc ; timer_4
&14e4: 29 7f            AND #&7f
&14e6: 49 65            EOR #&65
&14e8: 8d 2d 08         STA &082d ; timers_and_eor
&14eb: 38               SEC
&14ec: a0 07            LDY #&07
&14ee: b9 d8 00         LDA &00d8,Y			                        # copy &0d9 - 0df
&14f1: 99 f7 07         STA &07f7,Y			                        # to &07f8 - &07fe
&14f4: 88               DEY
&14f5: d0 f7            BNE &14ee
&14f7: a9 6e            LDA #&6e
&14f9: 85 9d            STA &9d
&14fb: a9 92            LDA #&92
&14fd: 65 9d            ADC &9d
&14ff: 69 15            ADC #&15
&1501: 85 9d            STA &9d
&1503: b9 f8 07         LDA &07f8,Y			                        # modified by &151e
&1506: 48               PHA
&1507: 4d 52 0b         EOR &0b52 ; possible_checksum
&150a: 8d 52 0b         STA &0b52 ; possible_checksum
&150d: 68               PLA
&150e: 45 9d            EOR &9d
&1510: 48               PHA
&1511: 4d 75 0b         EOR &0b75 ; maybe_another_checksum
&1514: 8d 75 0b         STA &0b75 ; maybe_another_checksum
&1517: 68               PLA
&1518: 99 00 2c         STA &2c00,Y			                        # modified by &1521
&151b: c8               INY
&151c: d0 df            BNE &14fd
&151e: ee 05 15         INC &1505			                        # copy &07f8 -
&1521: ee 1a 15         INC &151a			                        # to &2c00 - &7fff
&1524: 10 d7            BPL &14fd
&1526: 4c bb 28         JMP &28bb ; zero_memory_and_loop_endlessly

&1529: 60               RTS

; focus_on_player_maybe
&152a: 4e 76 0b         LSR &0b76 ; consider_secondary_stack_objects            # don't
&152d: 20 88 22         JSR &2288 ; get_object_centre                           # get centre of player
&1530: a2 00            LDX #&00                                                # first, x direction
&1532: 20 d2 15         JSR &15d2 ; do_someting_in_one_direction_scrolls
&1535: 85 a2            STA &a2
&1537: 20 54 32         JSR &3254 ; make_positive_cmp_0
&153a: 85 9d            STA &9d
&153c: c9 0c            CMP #&0c
&153e: b0 4e            BCS &158e
&1540: c9 02            CMP #&02
&1542: 90 14            BCC &1558
&1544: f0 08            BEQ &154e
&1546: a0 04            LDY #&04
&1548: a5 c7            LDA &c7 ; screen_start_square_x_low
&154a: 29 7f            AND #&7f
&154c: f0 09            BEQ &1557
&154e: a0 02            LDY #&02
&1550: a5 c7            LDA &c7 ; screen_start_square_x_low
&1552: 29 20            AND #&20
&1554: f0 01            BEQ &1557
&1556: 88               DEY
&1557: 98               TYA
&1558: 24 a2            BIT &a2
&155a: 20 56 32         JSR &3256 ; make_positive
&155d: 85 cf            STA &cf ; scroll_x_direction
&155f: a2 02            LDX #&02
&1561: 20 d2 15         JSR &15d2 ; do_someting_in_one_direction_scrolls        # then y direction
&1564: a8               TAY
&1565: 20 56 32         JSR &3256 ; make_positive
&1568: c5 9d            CMP &9d
&156a: 90 1d            BCC &1589
&156c: c9 0c            CMP #&0c
&156e: b0 1e            BCS &158e
&1570: c9 02            CMP #&02
&1572: 98               TYA
&1573: 90 0d            BCC &1582
&1575: a9 01            LDA #&01
&1577: 24 c9            BIT &c9 ; screen_start_square_y_low
&1579: 70 02            BVS &157d
&157b: a9 02            LDA #&02
&157d: c0 00            CPY #&00
&157f: 20 56 32         JSR &3256 ; make_positive
&1582: 85 d1            STA &d1 ; scroll_y_direction
&1584: a9 00            LDA #&00
&1586: 85 cf            STA &cf ; scroll_x_direction
&1588: 60               RTS
&1589: a9 00            LDA #&00
&158b: 85 d1            STA &d1 ; scroll_y_direction
&158d: 60               RTS
&158e: a9 80            LDA #&80
&1590: 85 c7            STA &c7 ; screen_start_square_x_low
&1592: 85 c9            STA &c9 ; screen_start_square_y_low
&1594: a5 8d            LDA &8d
&1596: 38               SEC
&1597: e9 01            SBC #&01
&1599: 85 ca            STA &ca ; screen_start_square_y
&159b: a5 8b            LDA &8b
&159d: e9 04            SBC #&04
&159f: 85 c8            STA &c8 ; screen_start_square_x
&15a1: a9 fe            LDA #&fe
&15a3: 85 d1            STA &d1 ; scroll_y_direction
&15a5: a9 00            LDA #&00
&15a7: 85 cf            STA &cf ; scroll_x_direction
&15a9: 20 1f 16         JSR &161f ; refocus_on_player
&15ac: 20 6c 1f         JSR &1f6c
&15af: a5 ca            LDA &ca ; screen_start_square_y
&15b1: 18               CLC
&15b2: 69 04            ADC #&04
&15b4: 85 ca            STA &ca ; screen_start_square_y
&15b6: a2 08            LDX #&08
&15b8: 86 ab            STX &ab
&15ba: 20 1f 16         JSR &161f ; refocus_on_player
&15bd: 20 84 36         JSR &3684 ; redraw_screen
&15c0: 20 d2 10         JSR &10d2 ; plot_background_strip_from_cache
&15c3: a6 ab            LDX &ab
&15c5: ca               DEX
&15c6: d0 f0            BNE &15b8
&15c8: 86 d1            STX &d1 ; scroll_y_direction
&15ca: a9 f0            LDA #&f0
&15cc: 85 6e            STA &6e ; skip_sprite_calculation_flags
&15ce: 8d 76 0b         STA &0b76 ; consider_secondary_stack_objects            # do
&15d1: 60               RTS

; do_someting_in_one_direction_scrolls
&15d2: 2c ab 19         BIT &19ab ; ship_moving                                 # is the ship moving?
&15d5: 10 09            BPL &15e0 ; ship_not_moving
&15d7: 8a               TXA
&15d8: 49 02            EOR #&02
&15da: d0 3f            BNE &161b               
&15dc: a9 3b            LDA #&3b
&15de: 85 8d            STA &8d ; this_object_y_centre
; ship_not_moving
&15e0: b5 87            LDA &87,X ; this_object_centre_x_low
&15e2: d5 c7            CMP &c7,X ; screen_start_square_x_low
&15e4: 08               PHP
&15e5: b5 43            LDA &43,X ; this_object_vel_x
&15e7: e0 00            CPX #&00
&15e9: f0 03            BEQ &15ee
&15eb: c9 80            CMP #&80
&15ed: 6a               ROR
&15ee: 20 75 32         JSR &3275 ; shift_right_three_while_keeping_sign
&15f1: dd 1c 16         CMP &161c,X
&15f4: f0 0b            BEQ &1601
&15f6: 10 06            BPL &15fe
&15f8: de 1c 16         DEC &161c,X
&15fb: de 1c 16         DEC &161c,X
&15fe: fe 1c 16         INC &161c,X
&1601: bd 1c 16         LDA &161c,X
&1604: 20 75 32         JSR &3275 ; shift_right_three_while_keeping_sign
&1607: 7d c8 14         ADC &14c8,X ; scroll_offset_x
&160a: 18               CLC
&160b: 75 8b            ADC (&8b,X) ; this_object_centre_x
&160d: 28               PLP
&160e: f5 c8            SBC &c8,X ; screen_start_square_x
&1610: 38               SEC
&1611: fd c7 14         SBC &14c7,X ; something_scrolly_x
&1614: d5 cf            CMP &cf,X ; scroll_x_direction
&1616: 10 03            BPL &161b
&1618: 18               CLC
&1619: 69 01            ADC #&01
&161b: 60               RTS

&161c: 00               BRK
&161d: 00               BRK
&161e: 00               BRK

; refocus_on_player
&161f: a0 00            LDY #&00
&1621: a2 02            LDX #&02                                                # first X = 2, y direction, then X = 0, x direction
&1623: b5 cf            LDA &cf,X ; scroll_x_direction
&1625: f0 05            BEQ &162c                                               # are we scrolling?
&1627: b5 c7            LDA &c7,X ; screen_start_square_x_low
&1629: d0 01            BNE &162c                                               # if so, is a new square exposed
&162b: 88               DEY                                                     # if so, we need to call object handlers
&162c: ca               DEX
&162d: ca               DEX
&162e: f0 f3            BEQ &1623                                               # repeat for the x direction
&1630: 8c cd 14         STY &14cd ; call_object_handlers_when_redrawing_screen  # note whether background object handlers are needed
&1633: a2 02            LDX #&02                                                # first X = 2, y direction, then X = 0, x direction
&1635: b5 cf            LDA &cf,X ; scroll_x_direction                          # use the scroll direction to:
&1637: 0a               ASL
&1638: a0 00            LDY #&00
&163a: 90 01            BCC &163d
&163c: 88               DEY
&163d: e0 02            CPX #&02
&163f: 90 01            BCC &1642
&1641: 0a               ASL
&1642: 0a               ASL
&1643: 0a               ASL
&1644: 0a               ASL
&1645: 0a               ASL
&1646: 95 cb            STA &cb,X ; scroll_square_x_velocity_low                # calculate scroll square velocities
&1648: 18               CLC
&1649: 75 c7            ADC (&c7,X) ; screen_start_square_x_low
&164b: 95 c7            STA &c7,X ; screen_start_square_x_low                   # and new screen start square positions
&164d: 98               TYA
&164e: 95 cc            STA &cc,X ; scroll_square_x_velocity_high
&1650: 75 c8            ADC (&c8,X) ; screen_start_square_x
&1652: 95 c8            STA &c8,X ; screen_start_square_x
&1654: ca               DEX
&1655: ca               DEX
&1656: 10 dd            BPL &1635                                               # repeat for the x direction
&1658: a5 c7            LDA &c7 ; screen_start_square_x_low
&165a: 85 b2            STA &b2 ; screen_start_square_x_low_copy
&165c: 85 b0            STA &b0 ; screen_offset
&165e: a5 ca            LDA &ca ; screen_start_square_y
&1660: 4a               LSR
&1661: 85 9b            STA &9b
&1663: a5 c9            LDA &c9 ; screen_start_square_y_low
&1665: 6a               ROR
&1666: 46 9b            LSR &9b
&1668: 6a               ROR
&1669: 46 9b            LSR &9b
&166b: 6a               ROR
&166c: 65 c8            ADC &c8 ; screen_start_square_x
&166e: 85 9c            STA &9c
&1670: a5 9b            LDA &9b
&1672: 69 00            ADC #&00
&1674: a0 08            LDY #&08
&1676: 06 9c            ASL &9c
&1678: 2a               ROL
&1679: b0 04            BCS &167f
&167b: c9 80            CMP #&80
&167d: 90 02            BCC &1681
&167f: e9 80            SBC #&80
&1681: 88               DEY
&1682: d0 f2            BNE &1676
&1684: 85 b3            STA &b3 ; some_screen_address_offset
&1686: 4a               LSR
&1687: 66 b0            ROR &b0 ; screen_offset
&1689: 4a               LSR
&168a: 66 b0            ROR &b0 ; screen_offset
&168c: 85 b1            STA &b1 ; screen_offset_h
&168e: a2 02            LDX #&02
&1690: a9 00            LDA #&00
&1692: 38               SEC
&1693: f5 cb            SBC &cb,X ; scroll_square_x_velocity_low
&1695: a8               TAY
&1696: a9 00            LDA #&00
&1698: f5 cc            SBC &cc,X ; scroll_square_x_velocity_high
&169a: 10 03            BPL &169f
&169c: a9 00            LDA #&00
&169e: a8               TAY
&169f: 9d 8e 0b         STA &0b8e,X
&16a2: 98               TYA
&16a3: 9d 8a 0b         STA &0b8a,X
&16a6: b5 cb            LDA &cb,X ; scroll_square_x_velocity_low
&16a8: b4 cc            LDY &cc,X ; scroll_square_x_velocity_high
&16aa: 18               CLC
&16ab: 30 04            BMI &16b1
&16ad: 49 ff            EOR #&ff
&16af: 38               SEC
&16b0: 88               DEY
&16b1: 7d 99 0b         ADC &0b99,X
&16b4: 9d 9a 0b         STA &0b9a,X
&16b7: 98               TYA
&16b8: 7d 9d 0b         ADC &0b9d,X ; plot_sprite_screen_address_offsets
&16bb: 9d 9e 0b         STA &0b9e,X
&16be: b5 c7            LDA &c7,X ; screen_start_square_x_low
&16c0: 9d 91 0b         STA &0b91,X ; screen_offset_x_low
&16c3: 18               CLC
&16c4: 7d 8a 0b         ADC &0b8a,X
&16c7: 9d 92 0b         STA &0b92,X
&16ca: b5 c8            LDA &c8,X
&16cc: 9d 95 0b         STA &0b95,X ; screen_offset_x
&16cf: 7d 8e 0b         ADC &0b8e,X
&16d2: 9d 96 0b         STA &0b96,X
&16d5: ca               DEX
&16d6: ca               DEX
&16d7: 10 b7            BPL &1690
&16d9: a5 c8            LDA &c8 ; screen_start_square_x
&16db: 20 bc 2c         JSR &2cbc ; get_water_level_for_x
&16de: a0 01            LDY #&01
&16e0: ad d0 14         LDA &14d0 ; water_level_low
&16e3: e5 c9            SBC &c9 ; screen_start_square_y_low
&16e5: 85 9c            STA &9c
&16e7: ad d1 14         LDA &14d1 ; water_level
&16ea: e5 ca            SBC &ca ; screen_start_square_y
&16ec: 90 23            BCC &1711
&16ee: c9 04            CMP #&04
&16f0: b0 1e            BCS &1710
&16f2: 85 9d            STA &9d
&16f4: a5 9c            LDA &9c
&16f6: 0a               ASL
&16f7: 26 9d            ROL &9d
&16f9: 0a               ASL
&16fa: 26 9d            ROL &9d
&16fc: 0a               ASL
&16fd: 26 9d            ROL &9d
&16ff: 29 c0            AND #&c0
&1701: 69 70            ADC #&70
&1703: 78               SEI
&1704: 8d ce 14         STA &14ce ; water_level_interrupt
&1707: a5 9d            LDA &9d
&1709: 69 17            ADC #&17
&170b: 8d cf 14         STA &14cf ; water_level_on_screen
&170e: 58               CLI
&170f: 60               RTS

&1710: 88               DEY
&1711: 8c cf 14         STY &14cf ; water_level_on_screen
&1714: 60               RTS

; determine_background
; returns A = background type for square
&1715: a2 00            LDX #&00
&1717: 86 bd            STX &bd ; new_object_data_pointer
&1719: 86 00            STX &00 ; square_is_mapped_data
&171b: 20 8d 17         JSR &178d ; calculate_background
&171e: 85 08            STA &08 ; square_sprite
&1720: 29 c0            AND #&c0
&1722: 85 09            STA &09 ; square_orientation
&1724: 45 08            EOR &08 # = calculate_background &3f
&1726: c9 09            CMP #&09
&1728: b0 48            BCS &1772 ; no_background_object                        # is there a hash table point in this square?
&172a: 85 9d            STA &9d ; background_object_number
&172c: a8               TAY		# a = 0 - 8
&172d: be d4 05         LDX &05d4,Y ; background_objects_range		        # use background_objects_range to determine where to look
&1730: bd ef 05         LDA &05ef,X ; background_objects_x_lookup		# in background_objects_x_lookup
&1733: 48               PHA						        # backup value of background_objects_x_lookup
&1734: a5 95            LDA &95 ; square_x
&1736: 9d ef 05         STA &05ef,X ; background_objects_x_lookup		# push square_x at the end of this range
&1739: be d3 05         LDX &05d3,Y ; background_objects_range_minus_one
&173c: ca               DEX
&173d: e8               INX
&173e: dd ef 05         CMP &05ef,X ; background_objects_x_lookup
&1741: d0 fa            BNE &173d					        # X contains entry in background_objects_x_lookup with square_x
&1743: 8a               TXA						
&1744: d9 d4 05         CMP &05d4,Y ; background_objects_range
&1747: b0 11            BCS &175a ; no_background_object_in_hash		# if we found it beyond the end of the range, there's no entry 
&1749: 79 dd 05         ADC &05dd,Y ; background_objects_data_offset		# data_pointer = X + background_objects_data_offset
&174c: 85 bd            STA &bd ; new_object_data_pointer
&174e: 18               CLC
&174f: 79 e6 05         ADC &05e6,Y ; background_objects_type_offset		# type_pointer = X + background_objects_data_offset + background_objects_type_offset
&1752: 85 be            STA &be ; new_object_type_pointer
&1754: bd ee 06         LDA &06ee,X ; background_objects_handler_lookup
&1757: 4c 61 17         JMP &1761 ; use_background_object_from_hash
; no_background_object_in_hash
&175a: a6 9d            LDX &9d ; background_object_number
&175c: bd 7c 11         LDA &117c,X ; lookup_for_unmatched_hash
&175f: 45 09            EOR &09 ; square_orientation
; use_background_object_from_hash                                               # A = handler_lookup if in hash, square_sprite if not
&1761: 85 08            STA &08 ; square_sprite
&1763: be d4 05         LDX &05d4,Y ; background_objects_range
&1766: 68               PLA
&1767: 9d ef 05         STA &05ef,X ; background_objects_x_lookup		# restore value of background_objects_x_hash
&176a: a5 08            LDA &08 ; square_sprite
&176c: 29 c0            AND #&c0
&176e: 85 09            STA &09 ; square_orientation
&1770: 45 08            EOR &08 ; square_sprite
; no_background_object
&1772: 85 08            STA &08 ; square_sprite
&1774: c9 10            CMP #&10
&1776: b0 14            BCS &178c ; no_objects_to_create                        # do we need to create a background object?
&1778: ba               TSX	
&1779: 86 26            STX &26 ; copy_of_stack_pointer                         # store the stack pointer
&177b: aa               TAX
&177c: bd 32 04         LDA &0432,X ; object_handler_table_h
&177f: 24 2d            BIT &2d ; background_processing_flag                    # does background_processing_flag match the background object?
&1781: f0 07            BEQ &178a                                               # if set, call background object handlers
&1783: 29 0f            AND #&0f
&1785: a4 bd            LDY &bd ; new_object_data_pointer
&1787: 20 ea 19         JSR &19ea ; handle_background_object
&178a: a5 08            LDA &08 ; square_sprite
; no_objects_to_create
&178c: 60               RTS

; calculate_background
# First, determine whether we should use mapped data or not
&178d: a5 97            LDA &97	; square_y
&178f: aa               TAX		
&1790: 4a               LSR
&1791: 45 95            EOR &95 ; square_x
&1793: 29 f8            AND #&f8
&1795: 4a               LSR
&1796: 65 95            ADC &95	; square_x
&1798: 4a               LSR
&1799: 65 97            ADC &97 ; square_y
&179b: 85 9d            STA &9d	; f_xy			                        # f_xy is a function of square_x and square_y
&179d: 8a               TXA				                        # A = square_y
&179e: c9 79            CMP #&79
&17a0: 90 06            BCC &17a8
&17a2: c9 bf            CMP #&bf 	# y >= &80
&17a4: 90 50            BCC &17f6
&17a6: e9 46            SBC #&46	# y >= &c0 ; y -= &46;
&17a8: c9 48            CMP #&48
&17aa: b0 06            BCS &17b2
&17ac: c9 3e            CMP #&3e
&17ae: b0 46            BCS &17f6
&17b0: 69 0a            ADC #&0a
&17b2: 85 10            STA &10 ; f2_xy                                         # at this point, a function of square_y
&17b4: 29 a8            AND #&a8
&17b6: 49 6f            EOR #&6f
&17b8: 4a               LSR
&17b9: 65 95            ADC &95 ; square_x
&17bb: 49 60            EOR #&60
&17bd: 69 28            ADC #&28
&17bf: 85 0f            STA &0f ; f3_xy                                         # f3_xy is another function of square_x and square_y
&17c1: 29 38            AND #&38
&17c3: 49 a4            EOR #&a4
&17c5: 65 10            ADC &10 ; f2_xy
&17c7: 85 10            STA &10 ; f2_xy                                         # f2_xy a function of square_x and square_y
&17c9: a8               TAY                                                     # A is f2_xy
&17ca: 49 2c            EOR #&2c
&17cc: 65 0f            ADC &0f ; f3_xy                                         # A is a function of f2_xy and f3_xy
&17ce: c0 20            CPY #&20
&17d0: b0 24            BCS &17f6 ; not_mapped2	                                # if Y >= &20, don't use mapped data
&17d2: c9 20            CMP #&20
&17d4: b0 1c            BCS &17f2 ; not_mapped                                  # if A >= &20, don't use mapped data
&17d6: c6 00            DEC &00 ; square_is_mapped_data
&17d8: a8               TAY			                                # Y = A = f(f2_xy,f3_xy)
&17d9: 0a               ASL           
&17da: 0a               ASL
&17db: 0a               ASL
&17dc: 45 10            EOR &10 ; f2_xy
&17de: 85 a4            STA &a4	; map_address	                                # &a4 = (A * 8) ^ &10;
&17e0: 98               TYA                                                     # A = Y = f(f2_xy,f3_xy)
&17e1: 29 03            AND #&03
&17e3: 69 4f            ADC #&4f		
&17e5: 85 a5            STA &a5	; map_address_high              		# a5 = (A & 3) + &4f;
&17e7: a0 ec            LDY #&ec		                                # &4fec - &53ec
&17e9: b1 a4            LDA (&a4),Y ; map_address	                        # use mapped data
&17eb: 60               RTS

&17ec: 4c 37 19         JMP &1937

; via_return_background_empty
&17ef: 4c d8 18         JMP &18d8 ; return_background_empty

; not_mapped
# If not mapped data, are we on or above the surface?
&17f2: c9 3d            CMP #&3d
&17f4: 90 f9            BCC &17ef ; via_return_background_empty
; not_mapped2
&17f6: e0 4e            CPX #&4e				                # if square_y < &4e, return empty space
&17f8: 90 f5            BCC &17ef ; via_return_background_empty
&17fa: f0 f0            BEQ &17ec				                # if square_y = &4e, return bushes
&17fc: e0 4f            CPX #&4f
&17fe: d0 0e            BNE &180e ; below_surface
&1800: a5 95            LDA &95 ; square_x			                # if square_y = &4f, do surface
&1802: c9 40            CMP #&40
&1804: f0 05            BEQ &180b ; return_background_grass_frond		# force (&40, &4f) to be a grass frond
&1806: a0 01            LDY #&01
&1808: 4c 27 19         JMP &1927 ; via_background_is_114f_lookup_with_y        # otherwise, return wall

; return_background_grass_frond
&180b: a9 62            LDA #&62				                # &62 = grass frond
&180d: 60               RTS

; below_surface
# Things get rather hairy below the surface...
&180e: a4 9d            LDY &9d	; f_xy
&1810: a9 00            LDA #&00
&1812: 85 9d            STA &9d
&1814: a5 95            LDA &95 ; square_x
&1816: 24 97            BIT &97 ; square_y
&1818: 30 07            BMI &1821
&181a: 69 1d            ADC #&1d
&181c: c9 5e            CMP #&5e
&181e: 4c 25 18         JMP &1825
&1821: 69 07            ADC #&07
&1823: c9 2b            CMP #&2b
&1825: 90 55            BCC &187c
&1827: 98               TYA
&1828: 29 e8            AND #&e8
&182a: c5 97            CMP &97 ; square_y
&182c: 90 4e            BCC &187c
&182e: 84 9d            STY &9d
&1830: 8a               TXA
&1831: 0a               ASL
&1832: 65 97            ADC &97 ; square_y
&1834: 4a               LSR
&1835: 65 97            ADC &97 ; square_y
&1837: 29 e0            AND #&e0
&1839: 65 95            ADC &95 ; square_x
&183b: 29 e8            AND #&e8
&183d: d0 13            BNE &1852 ; no_mushrooms
&183f: a5 97            LDA &97 ; square_y
&1841: 10 ac            BPL &17ef ; via_return_background_empty	                # no mushrooms if square_y < &80
&1843: a5 95            LDA &95 ; square_x
&1845: 4a               LSR
&1846: 4a               LSR
&1847: 4a               LSR
&1848: aa               TAX
; return_background_mushrooms
&1849: a9 0e            LDA #&0e				                # &0e = mushrooms (on floor)
&184b: e0 0a            CPX #&0a
&184d: d0 02            BNE &1851
&184f: a9 8e            LDA #&8e				                # &8e = mushrooms (on ceiling)
&1851: 60               RTS

; no_mushrooms
&1852: 98               TYA					                # Y = f_xy
&1853: 4a               LSR
&1854: 4a               LSR
&1855: 29 30            AND #&30
&1857: 4a               LSR
&1858: 65 95            ADC &95 ; square_x
&185a: 4a               LSR
&185b: 45 95            EOR &95 ; square_x
&185d: 4a               LSR
&185e: 45 95            EOR &95 ; square_x
&1860: 65 95            ADC &95 ; square_x
&1862: 29 fd            AND #&fd
&1864: 45 95            EOR &95 ; square_x
&1866: 29 07            AND #&07
&1868: d0 0e            BNE &1878
&186a: a5 95            LDA &95 ; square_x
&186c: 30 07            BMI &1875
&186e: 4a               LSR
&186f: 65 97            ADC &97 ; square_y
&1871: 29 30            AND #&30
&1873: f0 03            BEQ &1878
&1875: a9 08            LDA #&08		                                # return hash point 8
&1877: 60               RTS

&1878: e0 52            CPX #&52
&187a: b0 03            BCS &187f
&187c: 4c 1c 19         JMP &191c ; background_is_114f_lookup_with_top_of_9d

&187f: 98               TYA
&1880: 29 68            AND #&68
&1882: 65 97            ADC &97 ; square_y
&1884: 4a               LSR
&1885: 65 97            ADC &97 ; square_y
&1887: 4a               LSR
&1888: 65 97            ADC &97 ; square_y
&188a: 29 fc            AND #&fc
&188c: 45 97            EOR &97 ; square_y
&188e: 29 17            AND #&17
&1890: d0 4d            BNE &18df
&1892: 98               TYA
&1893: 65 95            ADC &95 ; square_x
&1895: 29 50            AND #&50
&1897: f0 3f            BEQ &18d8 ; return_background_empty
&1899: 25 95            AND &95 ; square_x
&189b: 4a               LSR
&189c: 4a               LSR
&189d: 65 97            ADC &97 ; square_y
&189f: 4a               LSR
&18a0: 4a               LSR
&18a1: 29 0f            AND #&0f
&18a3: c9 08            CMP #&08
&18a5: 90 08            BCC &18af
&18a7: 24 9d            BIT &9d
&18a9: 50 16            BVC &18c1
&18ab: 09 04            ORA #&04
&18ad: d0 12            BNE &18c1
&18af: 85 9c            STA &9c
&18b1: 49 05            EOR #&05
&18b3: c9 06            CMP #&06
&18b5: a5 9c            LDA &9c
&18b7: b0 08            BCS &18c1
&18b9: 98               TYA
&18ba: 4a               LSR
&18bb: 65 97            ADC &97 ; square_y
&18bd: 45 95            EOR &95 ; square_x
&18bf: 29 07            AND #&07
&18c1: 18               CLC
&18c2: 69 1d            ADC #&1d
&18c4: 48               PHA
&18c5: 20 46 19         JSR &1946 ; some_background_calc_thing
&18c8: 68               PLA
&18c9: 90 0d            BCC &18d8 ; return_background_empty
&18cb: a8               TAY
&18cc: b9 4f 11         LDA &114f,Y ; background_lookup
&18cf: a4 97            LDY &97 ; square_y
&18d1: c0 e0            CPY #&e0
&18d3: d0 02            BNE &18d7
&18d5: 49 40            EOR #&40
&18d7: 60               RTS

; return_background_empty
&18d8: a0 00            LDY #&00
; background_is_114f_lookup_with_y
&18da: 38               SEC
&18db: b9 4f 11         LDA &114f,Y ; background_lookup
&18de: 60               RTS

&18df: 20 46 19         JSR &1946 ; some_background_calc_thing
&18e2: b0 38            BCS &191c ; background_is_114f_lookup_with_top_of_9d
&18e4: c0 00            CPY #&00
&18e6: f0 f2            BEQ &18da ; background_is_114f_lookup_with_y	        # empty space
&18e8: a5 9d            LDA &9d
&18ea: 48               PHA
&18eb: 84 9c            STY &9c
&18ed: 2a               ROL
&18ee: 2a               ROL
&18ef: 2a               ROL
&18f0: 29 01            AND #&01
&18f2: 2a               ROL
&18f3: a8               TAY
&18f4: 68               PLA
&18f5: 65 95            ADC &95 ; square_x
&18f7: 2a               ROL
&18f8: 45 97            EOR &97 ; square_y
&18fa: 29 1a            AND #&1a
&18fc: d0 15            BNE &1913
&18fe: 98               TYA
&18ff: a4 9c            LDY &9c
&1901: 59 56 11         EOR &1156,Y
&1904: 29 7f            AND #&7f
&1906: c9 40            CMP #&40
&1908: 2a               ROL
&1909: 29 07            AND #&07
&190b: aa               TAX
&190c: bd 60 11         LDA &1160,X
&190f: 59 56 11         EOR &1156,Y
&1912: 60               RTS

&1913: b9 5c 11         LDA &115c,Y
&1916: a4 9c            LDY &9c
&1918: 59 56 11         EOR &1156,Y
&191b: 60               RTS

; background_is_114f_lookup_with_top_of_9d
&191c: a5 9d            LDA &9d
&191e: 4a               LSR
&191f: 4a               LSR
&1920: 4a               LSR
&1921: 29 0e            AND #&0e
&1923: 4a               LSR
&1924: 69 01            ADC #&01
&1926: a8               TAY
; via_background_is_114f_lookup_with_y
&1927: 4c da 18         JMP &18da ; background_is_114f_lookup_with_y

&192a: 65 95            ADC &95 ; square_x
&192c: 2a               ROL
&192d: 2a               ROL
&192e: 2a               ROL
&192f: 29 02            AND #&02
&1931: 69 19            ADC #&19
&1933: a8               TAY
&1934: 4c da 18         JMP &18da ; background_is_114f_lookup_with_y

&1937: a0 19            LDY #&19
&1939: a5 95            LDA &95 ; square_x
&193b: 4a               LSR
&193c: 65 95            ADC &95 ; square_x
&193e: 29 17            AND #&17
&1940: d0 e8            BNE &192a
&1942: 66 9d            ROR &9d
&1944: 6a               ROR
&1945: 60               RTS

; some_background_calc_thing
&1946: 8a               TXA
&1947: 4a               LSR
&1948: 45 97            EOR &97 ; square_y
&194a: 29 06            AND #&06
&194c: d0 23            BNE &1971
&194e: 98               TYA
&194f: a0 02            LDY #&02
&1951: 29 20            AND #&20
&1953: 0a               ASL
&1954: 0a               ASL
&1955: 49 e5            EOR #&e5
&1957: 8d 61 19         STA &1961                                               # self modifying code
&195a: 30 02            BMI &195e
&195c: a0 04            LDY #&04
&195e: 8a               TXA
&195f: 69 16            ADC #&16
&1961: 65 95            ADC &95 ; square_x
&1963: 29 5f            AND #&5f
&1965: aa               TAX
&1966: ca               DEX
&1967: e0 0c            CPX #&0c
&1969: 90 38            BCC &19a3
&196b: f0 38            BEQ &19a5
&196d: c8               INY
&196e: e8               INX
&196f: f0 34            BEQ &19a5
&1971: a5 95            LDA &95 ; square_x
&1973: 4a               LSR
&1974: 4a               LSR
&1975: 4a               LSR
&1976: 4a               LSR
&1977: b0 29            BCS &19a2
&1979: a9 01            LDA #&01
&197b: 65 95            ADC &95 ; square_x
&197d: 65 97            ADC &97 ; square_y
&197f: 29 8f            AND #&8f
&1981: c9 01            CMP #&01
&1983: f0 1e            BEQ &19a3
&1985: aa               TAX
&1986: 38               SEC
&1987: a5 97            LDA &97 ; square_y
&1989: e5 95            SBC &95 ; square_x
&198b: 29 2f            AND #&2f
&198d: c9 01            CMP #&01
&198f: f0 12            BEQ &19a3
&1991: a0 02            LDY #&02
&1993: c9 02            CMP #&02
&1995: f0 0e            BEQ &19a5
&1997: c8               INY
&1998: 90 0b            BCC &19a5
&199a: c8               INY
&199b: e0 02            CPX #&02
&199d: f0 06            BEQ &19a5
&199f: c8               INY
&19a0: 90 03            BCC &19a5
&19a2: 60               RTS

&19a3: a0 00            LDY #&00
&19a5: 18               CLC
&19a6: 60               RTS

#19a7: 01 0c 04 ; funny_table_19a7

#19aa: 00 ; player_east_of_76

#19ab: 00 ; ship_moving

#19ac: 02 02 03 04 04 05 06 ; weight_when_held 
#19b3: 00 ; can_player_support_held_object

#19b4: 00 ; collided_in_last_cycle

#19b5: 00 ; player_teleporting_flag

; main_loop 
&19b6: 46 27            LSR &27 ; whistle1_played                               # reset whistle1
&19b8: e6 c0            INC &c0 ; loop_counter                                  # increment loop counter
&19ba: a5 c0            LDA &c0 ; loop_counter
&19bc: a0 ff            LDY #&ff
&19be: a2 05            LDX #&05
; loop_counter_every_loop			                                # calculate loop_counter_every_* based on bits of loop_counter
&19c0: 4a               LSR
&19c1: 90 01            BCC &19c4
&19c3: c8               INY			                                # loop_counter_every_X is &ff every X counts
&19c4: 94 c1            STY &c1,X       
&19c6: ca               DEX
&19c7: 10 f7            BPL &19c0 ; loop_counter_every_loop
&19c9: 20 97 1f         JSR &1f97 ; process_screen_background_flash
&19cc: 20 0b 1a         JSR &1a0b ; process_objects
&19cf: 20 9a 25         JSR &259a ; process_events
&19d2: a2 02            LDX #&02
&19d4: bd 19 08         LDA &0819,X ; actually mushroom_daze		        # decrease mushroom_daze if not zero
&19d7: f0 03            BEQ &19dc
&19d9: de 19 08         DEC &0819,X ; actually mushroom_daze            
&19dc: ca               DEX                                                     # for both red and blue dazes
&19dd: 10 f5            BPL &19d4
&19df: ad 1d 08         LDA &081d ; explosion_timer			        # increase explosion_timer if not zero
&19e2: f0 03            BEQ &19e7
&19e4: ee 1d 08         INC &081d ; explosion_timer
&19e7: 4c b6 19         JMP &19b6 ; main_loop                                   # go round the loop again

; handle_background_object
&19ea: ba               TSX
&19eb: 86 26            STX &26 ; copy_of_stack_pointer
&19ed: a6 08            LDX &08 ; square_sprite
&19ef: 10 04            BPL &19f5	                                        # we've already got A and calculated h of our handler
; handle_current_object
&19f1: aa               TAX
&19f2: bd 32 04         LDA &0432,X ; object_handler_table_h		        # Calculate address of object handler
&19f5: 48               PHA
&19f6: bd b9 03         LDA &03b9,X ; object_handler_table		
&19f9: 18               CLC
&19fa: 69 1a            ADC #&1a
&19fc: aa               TAX
&19fd: 68               PLA
&19fe: 29 3f            AND #&3f
&1a00: 69 3e            ADC #&3e
&1a02: 48               PHA						        # high = ((&0432, type + &14)) & 3f) + &3e
&1a03: 8a               TXA
&1a04: 48               PHA						        # low = (&03b9, type + &14) + &1a
&1a05: a6 bc            LDX &bc ; this_object_data
&1a07: 8a               TXA
&1a08: c0 00            CPY #&00
&1a0a: 60               RTS						        # Call the object handler we've put on stack

; process_objects
&1a0b: a2 00            LDX #&00			                        # start with object 0
&1a0d: 86 aa            STX &aa ; current_object
&1a0f: bd b4 08         LDA &08b4,X ; object_stack_y	                        # is there an object here?
&1a12: d0 03            BNE &1a17 ; process_object			        # if so, process it
&1a14: 4c 10 1e         JMP &1e10 ; next_object
; process_object
&1a17: 85 55            STA &55 ; this_object_y				        # pull object's details from object stack into registers
&1a19: 85 56            STA &56 ; this_object_y_old			        # keeping a copy of them before they're changed
&1a1b: bd c6 08         LDA &08c6,X ; object_stack_flags
&1a1e: 85 6f            STA &6f ; this_object_flags
&1a20: 85 70            STA &70 ; this_object_flags_old
&1a22: 85 37            STA &37 ; this_object_angle
&1a24: 0a               ASL
&1a25: 85 39            STA &39 ; this_object_flags_lefted
&1a27: bd 91 08         LDA &0891,X ; object_stack_x
&1a2a: 85 53            STA &53 ; this_object_x
&1a2c: 85 54            STA &54 ; this_object_x_old
&1a2e: bd 80 08         LDA &0880,X ; object_stack_x_low
&1a31: 85 4f            STA &4f ; this_object_x_low
&1a33: 85 50            STA &50 ; this_object_x_low_old
&1a35: bd f6 08         LDA &08f6,X ; object_stack_vel_y
&1a38: 85 45            STA &45 ; this_object_vel_y
&1a3a: 85 46            STA &46 ; this_object_vel_y_old
&1a3c: bd e6 08         LDA &08e6,X ; object_stack_vel_x
&1a3f: 85 43            STA &43 ; this_object_vel_x
&1a41: 85 44            STA &44 ; this_object_vel_x_old
&1a43: bd a3 08         LDA &08a3,X ; object_stack_y_low
&1a46: 85 51            STA &51 ; this_object_y_low
&1a48: 85 52            STA &52 ; this_object_y_low_old
&1a4a: bd 70 08         LDA &0870,X ; object_stack_sprite
&1a4d: 85 75            STA &75 ; this_object_sprite
&1a4f: 85 76            STA &76 ; this_object_sprite_old
&1a51: bd d6 08         LDA &08d6,X ; object_stack_palette
&1a54: 85 73            STA &73 ; this_object_palette
&1a56: 85 74            STA &74 ; this_object_palette_old
&1a58: bd 60 08         LDA &0860,X ; object_stack_type
&1a5b: 85 41            STA &41 ; this_object_type
&1a5d: bd 66 09         LDA &0966,X ; object_stack_data_pointer
&1a60: 85 3d            STA &3d ; this_object_data_pointer
&1a62: bd 06 09         LDA &0906,X ; object_stack_target
&1a65: 85 3e            STA &3e ; this_object_target
&1a67: 85 3f            STA &3f ; this_object_target_old
&1a69: 29 1f            AND #&1f
&1a6b: 85 0e            STA &0e ; this_object_target_object
&1a6d: bd 16 09         LDA &0916,X ; object_stack_tx
&1a70: 85 14            STA &14 ; this_object_tx
&1a72: bd 26 09         LDA &0926,X ; object_stack_energy
&1a75: 85 15            STA &15 ; this_object_energy
&1a77: bd 36 09         LDA &0936,X ; object_stack_ty
&1a7a: 85 16            STA &16 ; this_object_ty
&1a7c: bd 46 09         LDA &0946,X ; object_stack_supporting
&1a7f: 85 3b            STA &3b ; this_object_supporting
&1a81: bd 76 09         LDA &0976,X ; object_stack_extra
&1a84: 85 11            STA &11 ; this_object_extra
&1a86: bd 56 09         LDA &0956,X ; object_stack_timer
&1a89: 85 12            STA &12 ; this_object_timer
&1a8b: 85 13            STA &13 ; this_object_timer_old

&1a8d: a5 aa            LDA &aa ; current_object			        # calculate current_object_rotator[_low]
&1a8f: 0a               ASL
&1a90: 0a               ASL
&1a91: 0a               ASL
&1a92: 0a               ASL
&1a93: 05 aa            ORA &aa ; current_object	
&1a95: 65 c0            ADC &c0 ; loop_counter				        # current_object * 17 + loop_counter, ie:
&1a97: 85 06            STA &06 ; current_object_rotator		        # random number from &00-&ff, unique for each object
&1a99: 29 0f            AND #&0f
&1a9b: 85 07            STA &07 ; current_object_rotator_low		        # random number from &00-&0f, unique for each object
&1a9d: a5 53            LDA &53 ; this_object_x
&1a9f: 20 bc 2c         JSR &2cbc ; get_water_level_for_x		        # calculate water_level
&1aa2: a4 aa            LDY &aa ; current_object
&1aa4: cc d8 29         CPY &29d8 ; whistle2_played
&1aa7: d0 03            BNE &1aac ; not_being_used
&1aa9: 6e d8 29         ROR &29d8 ; whistle2_played			        # reset whistle2_played
; not_being_used
&1aac: 20 20 1e         JSR &1e20 ; get_object_weight			        # calculate object weight
&1aaf: 85 38            STA &38 ; this_object_weight
&1ab1: c9 07            CMP #&07    					        # is the object affected by gravity?
&1ab3: 66 2c            ROR &2c ; object_affected_by_gravity 
&1ab5: 10 03            BPL &1aba ; no_anti_gravity
&1ab7: 20 a3 28         JSR &28a3 ; zero_velocities			        # if not, zero its y velocity
; no_anti_gravity
&1aba: a6 75            LDX &75 ; this_object_sprite
&1abc: bd 0c 5e         LDA &5e0c,X ; sprite_width_lookup
&1abf: 29 f0            AND #&f0
&1ac1: 85 3a            STA &3a ; this_object_width			        # calculate sprite sizes for object
&1ac3: bd 89 5e         LDA &5e89,X ; sprite_height_lookup
&1ac6: 29 f8            AND #&f8
&1ac8: 85 3c            STA &3c ; this_object_height
&1aca: a2 00            LDX #&00
&1acc: 86 40            STX &40 ; acceleration_x			        # reset object accelerations to 0
&1ace: 86 42            STX &42 ; acceleration_y
&1ad0: 86 d3            STX &d3	; gun_aim_acceleration			        # reset gun_aim_acceleration to 0
&1ad2: 8e e5 29         STX &29e5 ; object_collision_with_other_object_top_bottom
&1ad5: 8e e6 29         STX &29e6 ; object_collision_with_other_object_sides
&1ad8: 86 1d            STX &1d ; wall_collision_frict_y_vel
&1ada: 86 30            STX &30 ; child_created                                 # reset child_created to 0
&1adc: 86 1c            STX &1c ; wall_collision_angle
&1ade: ca               DEX
&1adf: 86 05            STX &05 ; something_about_player_angle
&1ae1: 86 2b            STX &2b ; object_is_invisible                           # objects are not invisible by default
&1ae3: 20 31 2a         JSR &2a31 ; move_object				        # move object using current velocities
&1ae6: a6 aa            LDX &aa ; current_object        
&1ae8: d0 0f            BNE &1af9 ; not_player 				        # is this the player?
&1aea: a4 dd            LDY &dd ; object_held				        # if so, are we holding something?
&1aec: 30 0b            BMI &1af9 ; not_player
&1aee: 20 20 1e         JSR &1e20 ; get_object_weight
&1af1: a8               TAY
&1af2: b9 ac 19         LDA &19ac,Y ; weight_when_held
&1af5: 85 38            STA &38 ; this_object_weight                            # increase our weight to match
&1af7: a6 aa            LDX &aa ; current_object
; not_player
&1af9: e4 dd            CPX &dd ; object_held
&1afb: d0 50            BNE &1b4d ; not_held_object                             # is this object being held? if so, put next to us
&1afd: ae 70 08         LDX &0870 ; object_stack_sprite                         # player sprite
&1b00: bd 89 5e         LDA &5e89,X ; sprite_height_lookup
&1b03: 38               SEC
&1b04: e5 3c            SBC &3c ; this_object_height			        # half player height minus object height
&1b06: 08               PHP
&1b07: 6a               ROR
&1b08: 49 80            EOR #&80
&1b0a: 29 f8            AND #&f8
&1b0c: 6d a3 08         ADC &08a3 ; object_stack_y_low                          # player y_low
&1b0f: 85 51            STA &51 ; this_object_y_low                             # set object y_low to match
&1b11: 85 0c            STA &0c ; held_object_y_low
&1b13: ad b4 08         LDA &08b4 ; object_stack_y                              # player y
&1b16: 69 00            ADC #&00
&1b18: 28               PLP
&1b19: e9 00            SBC #&00
&1b1b: 85 55            STA &55 ; this_object_y                                 # set object y to match
&1b1d: 85 0d            STA &0d ; held_object_y
&1b1f: bd 0c 5e         LDA &5e0c,X ; sprite_width_lookup
&1b22: 69 0f            ADC #&0f
&1b24: a2 00            LDX #&00
&1b26: 2c c6 08         BIT &08c6 ; object_stack_flags                          # player flags
&1b29: 10 08            BPL &1b33                                               # are we facing left?
&1b2b: a5 3a            LDA &3a ; this_object_width
&1b2d: 69 10            ADC #&10					        # if not, add player width to x_low
&1b2f: ca               DEX
&1b30: 20 56 32         JSR &3256 ; make_positive
&1b33: 18               CLC
&1b34: 6d 80 08         ADC &0880 ; object_stack_x_low                          # player x_low
&1b37: 85 4f            STA &4f ; this_object_x_low                             # set object x_low to match
&1b39: 85 0a            STA &0a ; held_object_x_low
&1b3b: 8a               TXA
&1b3c: 6d 91 08         ADC &0891 ; object_stack_x                              # player x
&1b3f: 85 53            STA &53 ; this_object_x                                 # set objects x to match
&1b41: 85 0b            STA &0b ; held_object_x
&1b43: a0 00            LDY #&00				                # get player velocities
&1b45: 20 b4 0b         JSR &0bb4 ; get_object_velocities	                # set object velocities to match
&1b48: ad c6 08         LDA &08c6 ; object_stack_flags                          # get player flags
&1b4b: 85 37            STA &37 ; this_object_angle		                # set object flags_copy2 to match
; not_held_object
&1b4d: 20 48 2a         JSR &2a48 ; calculate_object_maxes
&1b50: 24 2c            BIT &2c ; object_affected_by_gravity		        # is the object static?
&1b52: 30 63            BMI &1bb7 ; static_object
&1b54: 20 64 2a         JSR &2a64 ; determine_what_supporting
&1b57: a4 aa            LDY &aa ; current_object
&1b59: d0 17            BNE &1b72 ; not_player2                                 # is this the player?
&1b5b: a5 1c            LDA &1c ; wall_collision_angle
&1b5d: e5 de            SBC &de ; player_angle
&1b5f: e9 40            SBC #&40
&1b61: 20 56 32         JSR &3256 ; make_positive
&1b64: 4a               LSR
&1b65: 4a               LSR
&1b66: 69 c0            ADC #&c0
&1b68: 65 1d            ADC &1d ; wall_collision_frict_y_vel
&1b6a: 90 06            BCC &1b72 ; not_player2
&1b6c: 4a               LSR
&1b6d: 20 0c 25         JSR &250c ; damage_object                               # take damage from colliding with scenery
&1b70: 85 15            STA &15 ; this_object_energy
; not_player2
&1b72: a5 18            LDA &18 ; wall_collision_bottom_minus_top
&1b74: 0d e5 29         ORA &29e5 ; object_collision_with_other_object_top_bottom
&1b77: 85 19            STA &19 ; any_collision_top_bottom
&1b79: ad e5 29         LDA &29e5 ; object_collision_with_other_object_top_bottom
&1b7c: 0a               ASL
&1b7d: 05 1a            ORA &1a ; wall_collision_count_bottom
&1b7f: 85 1a            STA &1a ; wall_collision_count_bottom
&1b81: 4e b4 19         LSR &19b4 ; collided_in_last_cycle
&1b84: a5 6f            LDA &6f ; this_object_flags
&1b86: 29 fd            AND #&fd
&1b88: 85 6f            STA &6f ; this_object_flags
&1b8a: 24 1a            BIT &1a ; wall_collision_count_bottom
&1b8c: 30 0a            BMI &1b98
&1b8e: 24 19            BIT &19 ; any_collision_top_bottom
&1b90: 10 25            BPL &1bb7
&1b92: 09 02            ORA #&02                                                # set flags & &02 if a collision has occurred
&1b94: 85 6f            STA &6f ; this_object_flags
&1b96: d0 1f            BNE &1bb7
&1b98: a5 70            LDA &70 ; this_object_flags_old
&1b9a: 29 02            AND #&02
&1b9c: f0 19            BEQ &1bb7
&1b9e: 38               SEC
&1b9f: 6e b4 19         ROR &19b4 ; collided_in_last_cycle                      # set if a collision occurred last cycle
&1ba2: a2 00            LDX #&00
&1ba4: a5 79            LDA &79 ; wall_collision_count_right
&1ba6: c5 77            CMP &77 ; wall_collision_count_left
&1ba8: f0 0d            BEQ &1bb7 ; static_object                               # have there been side collisions?
&1baa: 08               PHP
&1bab: a9 10            LDA #&10
&1bad: 28               PLP
&1bae: 20 56 32         JSR &3256 ; make_positive                               # if so, alter x velocity accordingly
&1bb1: 20 38 2a         JSR &2a38 ; move_object_in_one_direction_with_given_velocity
&1bb4: 20 48 2a         JSR &2a48 ; calculate_object_maxes
; static_object
&1bb7: a4 41            LDY &41 ; this_object_type
&1bb9: b9 54 03         LDA &0354,Y ; object_gravity_flags
&1bbc: 85 9f            STA &9f ; this_object_gravity_flags
&1bbe: 0a               ASL
&1bbf: 85 bf            STA &bf ; this_object_offscreen
&1bc1: 0a               ASL
&1bc2: 29 c0            AND #&c0
&1bc4: 0a               ASL
&1bc5: 2a               ROL
&1bc6: 2a               ROL
&1bc7: f0 30            BEQ &1bf9
&1bc9: aa               TAX
&1bca: e0 02            CPX #&02
&1bcc: d0 0d            BNE &1bdb
&1bce: 20 b6 3b         JSR &3bb6 ; get_biggest_velocity
&1bd1: c9 05            CMP #&05
&1bd3: 6a               ROR
&1bd4: 49 80            EOR #&80
&1bd6: 25 19            AND &19 ; any_collision_top_bottom
&1bd8: 10 01            BPL &1bdb
&1bda: e8               INX
&1bdb: bc a6 19         LDY &19a6,X ; # actually funny_table_19a7
&1bde: a5 07            LDA &07 ; current_object_rotator_low
&1be0: 29 03            AND #&03
&1be2: c9 03            CMP #&03
&1be4: 90 13            BCC &1bf9
&1be6: a5 6f            LDA &6f ; this_object_flags
&1be8: 29 14            AND #&14
&1bea: 18               CLC
&1beb: d0 0c            BNE &1bf9
&1bed: a5 9f            LDA &9f ; this_object_gravity_flags
&1bef: 29 08            AND #&08
&1bf1: 2d b5 19         AND &19b5 ; player_teleporting_flag
&1bf4: d0 03            BNE &1bf9
&1bf6: 20 1d 11         JSR &111d ; is_object_offscreen
&1bf9: 66 bf            ROR &bf ; this_object_offscreen
&1bfb: a5 6f            LDA &6f ; this_object_flags
&1bfd: 29 10            AND #&10                                                # is the object teleporting?
&1bff: f0 46            BEQ &1c47 ; not_teleporting
&1c01: a5 12            LDA &12 ; this_object_timer
&1c03: f0 39            BEQ &1c3e
&1c05: c9 11            CMP #&11
&1c07: d0 0a            BNE &1c13
&1c09: 85 55            STA &55 ; this_object_y
&1c0b: a6 aa            LDX &aa ; current_object
&1c0d: d0 04            BNE &1c13 ; not_player3                                 # is it the player?
&1c0f: ca               DEX
&1c10: 8e b5 19         STX &19b5 ; player_teleporting_flag
; not_player3
&1c13: c9 10            CMP #&10                                                # half way through the teleport, change the square
&1c15: d0 22            BNE &1c39 ; no_teleport_square_change
&1c17: a6 aa            LDX &aa ; current_object
&1c19: d0 03            BNE &1c1e ; not_player4                                 # is it the player?
&1c1b: 8e b5 19         STX &19b5 ; player_teleporting_flag
; not_player4
&1c1e: a2 02            LDX #&02        # in y direction first (X = 2), then x direction (X = 0)
&1c20: b5 3a            LDA &3a,X       # X = 2, &3c = this_object_height ; X = 0, &3a = this_object_width
&1c22: 49 ff            EOR #&ff
&1c24: 4a               LSR
&1c25: 95 4f            STA &4f,X       # X = 2, &51 = this_object_y_low ; X = 0, &4f = this_object_x_low
&1c27: b5 14            LDA &14,X       # X = 2, &16 = this_object_ty ; X = 0, &14 = this_object_tx
&1c29: 95 53            STA &53,X       # X = 2, &55 = this_object_y ; X = 0, &53 = this_object_x
&1c2b: ca               DEX
&1c2c: ca               DEX
&1c2d: 10 f1            BPL &1c20
&1c2f: 20 a3 28         JSR &28a3 ; zero_velocities
&1c32: 20 fa 13         JSR &13fa ; play_sound                                  # teleporting noise
#1c35: 33 f3 63 f3 ; sound data
; no_teleport_square_change
&1c39: c6 12            DEC &12 ; this_object_timer                             # decrement timer for teleporting object
&1c3b: 4c 2e 1d         JMP &1d2e

&1c3e: a5 6f            LDA &6f ; this_object_flags
&1c40: 29 ef            AND #&ef
&1c42: 85 6f            STA &6f ; this_object_flags
&1c44: 20 49 25         JSR &2549 ; gain_one_energy_point
; not_teleporting
&1c47: a5 55            LDA &55 ; this_object_y
&1c49: c9 4f            CMP #&4f                                                # is the object below y = &4f;
&1c4b: b0 45            BCS &1c92 ; no_wind                                     # if so, there's no wind
&1c4d: a9 00            LDA #&00
&1c4f: 85 b4            STA &b4 ; velocity_x
&1c51: 85 b6            STA &b6 ; velocity_y
&1c53: a5 55            LDA &55 ; this_object_y                                 # consider wind for (y - &4e) first
&1c55: e9 4e            SBC #&4e
&1c57: a2 02            LDX #&02
; wind_loop
&1c59: a4 38            LDY &38 ; this_object_weight
&1c5b: c8               INY
&1c5c: 66 9d            ROR &9d
&1c5e: 20 54 32         JSR &3254 ; make_positive_cmp_0
&1c61: c9 1e            CMP #&1e
&1c63: 90 22            BCC &1c87
&1c65: c9 32            CMP #&32
&1c67: 90 06            BCC &1c6f
&1c69: 88               DEY
&1c6a: c9 3c            CMP #&3c
&1c6c: 90 01            BCC &1c6f
&1c6e: 88               DEY
&1c6f: e9 08            SBC #&08
&1c71: 0a               ASL
&1c72: 10 04            BPL &1c78
&1c74: 88               DEY
&1c75: 88               DEY
&1c76: a9 7f            LDA #&7f
&1c78: c8               INY
&1c79: 10 02            BPL &1c7d
&1c7b: a0 00            LDY #&00
&1c7d: 24 9d            BIT &9d
&1c7f: 20 56 32         JSR &3256 ; make_positive
&1c82: 95 b4            STA &b4,X ; # X = 2, &b6 velocity_y; X = 0, &b4 velocity_x 
&1c84: 20 94 3f         JSR &3f94
&1c87: a5 53            LDA &53 ; this_object_x                                 # consider wind for (x - &9b) next
&1c89: e9 9b            SBC #&9b
&1c8b: ca               DEX
&1c8c: ca               DEX
&1c8d: f0 ca            BEQ &1c59 ; wind_loop
&1c8f: 20 73 3f         JSR &3f73 ; do_wind_motion
; no_wind
&1c92: a6 3d            LDX &3d ; ; this_object_data_pointer
&1c94: bd 86 09         LDA &0986,X ; object_data
&1c97: 85 bc            STA &bc ; this_object_data
&1c99: a5 41            LDA &41 ; this_object_type
&1c9b: 18               CLC
&1c9c: 69 14            ADC #&14
&1c9e: a4 3b            LDY &3b ; this_object_supporting
&1ca0: 20 f1 19         JSR &19f1 ; handle_current_object                       # call object handler
&1ca3: a6 aa            LDX &aa ; current_object
&1ca5: e4 dd            CPX &dd ; object_held
&1ca7: d0 3a            BNE &1ce3 ; not_held_object2                            # is this object being held?
&1ca9: a2 02            LDX #&02
&1cab: b5 0a            LDA &0a,X ; held_object_x_low
&1cad: f5 4f            SBC &4f,X ; this_object_x_low
&1caf: 08               PHP
&1cb0: 69 30            ADC #&30
&1cb2: a8               TAY
&1cb3: b5 0b            LDA &0b,X ; held_object_x                               # has its position shifted too much?
&1cb5: 69 00            ADC #&00
&1cb7: 28               PLP
&1cb8: f5 53            SBC &53,X ; this_object_x
&1cba: d0 04            BNE &1cc0
&1cbc: c0 60            CPY #&60
&1cbe: 90 06            BCC &1cc6
&1cc0: 20 c8 32         JSR &32c8 ; drop_object                                 # if so, drop it
&1cc3: 20 aa 28         JSR &28aa ; copy_object_values_from_old
&1cc6: ca               DEX
&1cc7: ca               DEX
&1cc8: f0 e1            BEQ &1cab
&1cca: a5 3b            LDA &3b ; this_object_supporting	                # is it supporting something?
&1ccc: f0 09            BEQ &1cd7
&1cce: aa               TAX
&1ccf: bc 60 08         LDY &0860,X ; object_stack_type		                # type of supporting object
&1cd2: 19 54 03         ORA (&0354),Y ; object_gravity_flags 
&1cd5: 49 80            EOR #&80
&1cd7: 05 1b            ORA &1b ; wall_collision_top_or_bottom
&1cd9: 8d b3 19         STA &19b3 ; can_player_support_held_object
&1cdc: 10 05            BPL &1ce3
&1cde: a0 00            LDY #&00				                # set player velocities
&1ce0: 20 a9 0b         JSR &0ba9 ; set_object_velocities
; not_held_object2
&1ce3: a5 15            LDA &15 ; this_object_energy		                # has it got energy
&1ce5: d0 0f            BNE &1cf6 ; not_exploding
&1ce7: a4 41            LDY &41 ; this_object_type  		                # explosion time!
&1ce9: b9 46 04         LDA &0446,Y ; object_handler_table_h 	                # object_handler_table_h &c0 determines explosion type
&1cec: 29 c0            AND #&c0				
&1cee: 0a               ASL
&1cef: 2a               ROL
&1cf0: 2a               ROL
&1cf1: 69 10            ADC #&10                                
&1cf3: 20 f1 19         JSR &19f1 ; handle_current_object                       # call explosion handler
; not_exploding
&1cf6: 20 87 25         JSR &2587 ; increment_timers
&1cf9: 4a               LSR
&1cfa: 4a               LSR
&1cfb: 09 01            ORA #&01
&1cfd: cd 1a 08         CMP &081a ; red_mushroom_daze
&1d00: 6a               ROR
&1d01: 49 ff            EOR #&ff
&1d03: 05 2b            ORA &2b ; object_is_invisible
&1d05: 85 2b            STA &2b ; object_is_invisible                           # invisible objects are visible when dazed
&1d07: a4 41            LDY &41 ; this_object_type
&1d09: b9 54 03         LDA &0354,Y ; object_gravity_flags
&1d0c: 29 18            AND #&18
&1d0e: f0 1b            BEQ &1d2b
&1d10: aa               TAX
&1d11: a5 bc            LDA &bc ; this_object_data
&1d13: 20 33 25         JSR &2533 ; is_this_object_marked_for_removal
&1d16: b0 0e            BCS &1d26
&1d18: 24 bf            BIT &bf ; this_object_offscreen				# is it offscreen?
&1d1a: 10 0a            BPL &1d26
&1d1c: e0 10            CPX #&10
&1d1e: f0 04            BEQ &1d24 ; mark_offscreen
&1d20: 18               CLC
&1d21: 69 04            ADC #&04
&1d23: 2c 09 80         BIT &8009
; mark_offscreen                                                                # if so, mark it as such:
#1d24:    09 80         ORA #&80						# &80 in data is offscreen 
&1d26: a6 3d            LDX &3d ; this_object_data_pointer
&1d28: 9d 86 09         STA &0986,X ; object_data
&1d2b: 20 01 1f         JSR &1f01 ; accelerate_object                           # accelerate object
&1d2e: a6 aa            LDX &aa ; current_object
&1d30: 18               CLC
&1d31: f0 29            BEQ &1d5c ; is_player
&1d33: 20 33 25         JSR &2533 ; is_this_object_marked_for_removal
&1d36: b0 09            BCS &1d41 ; not_marked_for_removal                      # if the object is marked for removal
&1d38: 24 bf            BIT &bf ; this_object_offscreen
&1d3a: 10 20            BPL &1d5c
&1d3c: 70 03            BVS &1d41 ; not_marked_for_removal
&1d3e: 20 6e 0c         JSR &0c6e ; copy_object_onto_secondary_stack            # move it to the secondary stack
; not_marked_for_removal
&1d41: a5 aa            LDA &aa ; current_object
&1d43: 20 29 1e         JSR &1e29 ; stop_supporting_objects                     # stop other objects resting on it
&1d46: aa               TAX
&1d47: a9 00            LDA #&00
&1d49: ec cb 14         CPX &14cb ; player_object_number
&1d4c: d0 03            BNE &1d51                                               # is it the player? if not
&1d4e: 8d cc 14         STA &14cc ; always_zero
&1d51: 85 53            STA &53 ; this_object_x
&1d53: 85 55            STA &55 ; this_object_y                                 # remove it
&1d55: e4 dd            CPX &dd ; object_held
&1d57: d0 02            BNE &1d5b                                               # were we holding it?
&1d59: 66 dd            ROR &dd ; object_held                                   # if so, forget it
&1d5b: 38               SEC
; is_player
&1d5c: 24 2b            BIT &2b ; object_is_invisible
&1d5e: 30 01            BMI &1d61                                               # is the object invisible?
&1d60: 38               SEC                                                     # set if so, or being removed
&1d61: a5 70            LDA &70 ; this_object_flags_old
&1d63: 6a               ROR
&1d64: 6a               ROR
&1d65: 29 c0            AND #&c0
&1d67: 85 9c            STA &9c
&1d69: 4a               LSR
&1d6a: 4a               LSR
&1d6b: 05 9c            ORA &9c
&1d6d: 85 6e            STA &6e ; skip_sprite_calculation_flags
&1d6f: a5 37            LDA &37 ; this_object_angle
&1d71: 0a               ASL
&1d72: a5 39            LDA &39 ; this_object_flags_lefted
&1d74: 6a               ROR
&1d75: 29 c0            AND #&c0
&1d77: 85 71            STA &71 ; this_object_flipping_flags
&1d79: a5 6f            LDA &6f ; this_object_flags
&1d7b: 29 c0            AND #&c0
&1d7d: 85 72            STA &72 ; this_object_flipping_flags_old
&1d7f: 45 6f            EOR &6f ; this_object_flags
&1d81: 45 71            EOR &71 ; this_object_flipping_flags
&1d83: 29 f3            AND #&f3
&1d85: 85 6f            STA &6f ; this_object_flags
# Push the object's details back into the object stack
&1d87: a5 55            LDA &55 ; this_object_y
&1d89: 9d b4 08         STA &08b4,X ; object_stack_y
&1d8c: a5 53            LDA &53 ; this_object_x
&1d8e: 9d 91 08         STA &0891,X ; object_stack_x
&1d91: a5 4f            LDA &4f ; this_object_x_low
&1d93: 9d 80 08         STA &0880,X ; object_stack_x_low
&1d96: a5 45            LDA &45 ; this_object_vel_y
&1d98: 9d f6 08         STA &08f6,X ; object_stack_vel_y
&1d9b: a5 43            LDA &43 ; this_object_vel_x
&1d9d: 9d e6 08         STA &08e6,X ; object_stack_vel_x
&1da0: a5 6f            LDA &6f ; this_object_flags
&1da2: 9d c6 08         STA &08c6,X ; object_stack_flags
&1da5: a5 51            LDA &51 ; this_object_y_low
&1da7: 9d a3 08         STA &08a3,X ; object_stack_y_low
&1daa: a5 75            LDA &75 ; this_object_sprite
&1dac: 9d 70 08         STA &0870,X ; object_stack_sprite
&1daf: a5 73            LDA &73 ; this_object_palette
&1db1: 9d d6 08         STA &08d6,X ; object_stack_palette
&1db4: a5 41            LDA &41 ; this_object_type
&1db6: 9d 60 08         STA &0860,X ; object_stack_type	
&1db9: a5 3d            LDA &3d ; ; this_object_data_pointer
&1dbb: 9d 66 09         STA &0966,X ; object_stack_data_pointer
&1dbe: a5 3e            LDA &3e ; this_object_target
&1dc0: 29 e0            AND #&e0
&1dc2: 05 0e            ORA &0e ; this_object_target_object
&1dc4: 9d 06 09         STA &0906,X ; object_stack_target
&1dc7: a5 14            LDA &14 ; this_object_tx
&1dc9: 9d 16 09         STA &0916,X ; object_stack_tx
&1dcc: a5 15            LDA &15 ; this_object_energy
&1dce: 9d 26 09         STA &0926,X ; object_stack_energy
&1dd1: a5 16            LDA &16 ; this_object_ty
&1dd3: 9d 36 09         STA &0936,X ; object_stack_ty
&1dd6: a5 3b            LDA &3b ; this_object_supporting
&1dd8: 09 80            ORA #&80
&1dda: 9d 46 09         STA &0946,X ; object_stack_supporting
&1ddd: a5 11            LDA &11 ; this_object_extra
&1ddf: 9d 76 09         STA &0976,X ; object_stack_extra
&1de2: a5 12            LDA &12 ; this_object_timer
&1de4: 9d 56 09         STA &0956,X ; object_stack_timer
&1de7: ec cb 14         CPX &14cb ; player_object_number
&1dea: d0 0e            BNE &1dfa
&1dec: 20 2a 15         JSR &152a ; focus_on_player_maybe
&1def: 20 1f 16         JSR &161f ; refocus_on_player
&1df2: 20 84 36         JSR &3684 ; redraw_screen
&1df5: a2 00            LDX #&00
&1df7: 8e 89 2e         STX &2e89 ; can_we_scroll_screen
&1dfa: 20 a5 0c         JSR &0ca5 ; plot_object
&1dfd: ec cb 14         CPX &14cb ; player_object_number
&1e00: d0 0e            BNE &1e10                                               # is it the player?
&1e02: 20 d2 10         JSR &10d2 ; plot_background_strip_from_cache            # if so, process some other things too
&1e05: 20 58 1f         JSR &1f58 ; scroll_screen 
&1e08: 20 7e 20         JSR &207e ; particle_evolution
&1e0b: 20 e8 0b         JSR &0be8 ; consider_objects_on_secondary_stack
&1e0e: a6 aa            LDX &aa ; current_object
; next_object
&1e10: e8               INX
&1e11: e0 10            CPX #&10		                                # sixteen objects
&1e13: b0 03            BCS &1e18
&1e15: 4c 0d 1a         JMP &1a0d                                               # loop for next one
&1e18: 60               RTS

; swap_direction
&1e19: a9 80            LDA #&80
&1e1b: 45 df            EOR &df ; player_facing
&1e1d: 85 df            STA &df ; player_facing
&1e1f: 60               RTS

; get_object_gravity_flags
&1e20: a9 07            LDA #&07
; get_object_gravity_flags_arbitrary_and
&1e22: be 60 08         LDX &0860,Y ; object_stack_type
&1e25: 3d 54 03         AND &0354,X ; object_gravity_flags
&1e28: 60               RTS

; stop_supporting_objects
&1e29: a2 0f            LDX #&0f                                                # starting at the last object
&1e2b: dd 46 09         CMP &0946,X ; object_stack_supporting                   # are we touching object A?
&1e2e: d0 03            BNE &1e33
&1e30: 7e 46 09         ROR &0946,X ; object_stack_supporting                   # stop supporting object
&1e33: 48               PHA
&1e34: 5d 06 09         EOR &0906,X ; object_stack_target                       # is supporting = target?
&1e37: 29 1f            AND #&1f
&1e39: d0 04            BNE &1e3f
&1e3b: 8a               TXA
&1e3c: 9d 06 09         STA &0906,X ; object_stack_target                       # stop targetting object A too
&1e3f: 68               PLA
&1e40: ca               DEX                                                     # repeat for all sixteen objects
&1e41: 10 e8            BPL &1e2b
&1e43: 60               RTS

#1e44: 00 80 07 70 ; water_orientation_lookup

; pixel_table
#1e48: 00 03 0c 0f 30 33 3c 3f c0 c3 cc cf f0 f3 fc ff

#1e58: ff ; number_of_particles
#1e59: f8 ; number_of_particles_x8

; reserve_object_high_priority
&1e5a: a0 00            LDY #&00
&1e5c: 2c a0 01         BIT &01a0
; reserve_object
#1e5d:    a0 01         LDY #&01
&1e5f: 2c a0 04         BIT &04a0
; reserve_object_low_priority
#1e60:    a0 04         LDY #&04 
; reserve_objects
; A = type of object to create
; Y = number of slots that must be free for success
; &53 = x
; &55 = y
&1e62: 8d c5 1e         STA &1ec5  				                # store desired object type
&1e65: 8e ff 1e         STX &1eff				                # ensure we leave with X unchanged
&1e68: 98               TYA			
&1e69: aa               TAX
&1e6a: d0 49            BNE &1eb5 ; reserve_object_not_y_0	                # Y = 0 is special
&1e6c: 84 2e            STY &2e ; objects_to_reserve
&1e6e: 84 2f            STY &2f ; objects_two_reserve
&1e70: a0 0f            LDY #&0f				                # sixteen objects
&1e72: c4 aa            CPY &aa ; current_object
&1e74: f0 1f            BEQ &1e95				                # keep looking if it's the current object
&1e76: b9 b4 08         LDA &08b4,Y ; object_stack_y		                # is this slot free?
&1e79: f0 49            BEQ &1ec4 ; reserve_object_in_this_slot	                # if so, use it
&1e7b: a9 50            LDA #&50
&1e7d: 20 22 1e         JSR &1e22 ; get_object_gravity_flags_arbitrary_and
&1e80: c9 40            CMP #&40
&1e82: d0 11            BNE &1e95				                # keep looking if gravity_flags & &50 != &40
&1e84: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&1e87: 6a               ROR
&1e88: 90 0b            BCC &1e95
&1e8a: 20 5b 35         JSR &355b
&1e8d: c5 2e            CMP &2e ; objects_to_reserve
&1e8f: 90 04            BCC &1e95
&1e91: 85 2e            STA &2e ; objects_to_reserve
&1e93: 84 2f            STY &2f ; objects_two_reserve
&1e95: 88               DEY					                # consider next one
&1e96: d0 da            BNE &1e72				
&1e98: 38               SEC
&1e99: a4 2f            LDY &2f ; objects_two_reserve
&1e9b: f0 61            BEQ &1efe				                # no free slots leave, unsuccessful
&1e9d: a9 08            LDA #&08
&1e9f: 20 22 1e         JSR &1e22 ; get_object_gravity_flags_arbitrary_and
&1ea2: f0 0b            BEQ &1eaf
&1ea4: be 66 09         LDX &0966,Y ; object_stack_data_pointer
&1ea7: bd 86 09         LDA &0986,X ; background_objects_data
&1eaa: 69 03            ADC #&03
&1eac: 9d 86 09         STA &0986,X ; background_objects_data
&1eaf: 98               TYA
&1eb0: 20 29 1e         JSR &1e29 ; stop_supporting_objects
&1eb3: 30 0f            BMI &1ec4 ; reserve_object_in_this_slot
; reserve_object_not_y_0
&1eb5: a0 00            LDY #&00
&1eb7: c8               INY
&1eb8: c0 10            CPY #&10				                # sixteen objects
&1eba: b0 42            BCS &1efe				                # if no free slots, leave with C set
&1ebc: b9 b4 08         LDA &08b4,Y ; object_stack_y		                # is this slot free?
&1ebf: d0 f6            BNE &1eb7				                # if not, keep searching
&1ec1: ca               DEX					                # have we found our quota of free slots? this counts as one
&1ec2: d0 f3            BNE &1eb7				                # if not, keep searching
; reserve_object_in_this_slot
&1ec4: a2 00            LDX #&00				                # actually LDX #object_type, from &1ec5
&1ec6: bd ef 02         LDA &02ef,X ; object_palette_lookup
&1ec9: 29 7f            AND #&7f
&1ecb: 99 d6 08         STA &08d6,Y ; object_stack_palette	                # store palette & &7f
&1ece: bd 8a 02         LDA &028a,X ; object_sprite_lookup
&1ed1: 99 70 08         STA &0870,Y ; object_stack_sprite	                # store sprite
&1ed4: a9 05            LDA #&05
&1ed6: 99 c6 08         STA &08c6,Y ; object_stack_flags                	# store flags = 5
&1ed9: a9 ff            LDA #&ff
&1edb: 99 46 09         STA &0946,Y ; object_stack_supporting	                # supporting nothing
&1ede: 98               TYA
&1edf: 99 06 09         STA &0906,Y ; object_stack_target	                # store target = object's own number
&1ee2: a9 00            LDA #&00
&1ee4: 99 66 09         STA &0966,Y ; object_stack_data_pointer
&1ee7: 99 76 09         STA &0976,Y ; object_stack_extra		        
&1eea: 99 56 09         STA &0956,Y ; object_stack_timer	                # store timer = 0
&1eed: 99 e6 08         STA &08e6,Y ; object_stack_vel_x	                # store x velocity = 0
&1ef0: 99 f6 08         STA &08f6,Y ; object_stack_vel_y	                # store y velocity = 0
&1ef3: 8a               TXA
&1ef4: 99 60 08         STA &0860,Y ; object_stack_type		                # store object_type
&1ef7: 20 a3 2d         JSR &2da3 ; lookup_and_store_object_energy
&1efa: 20 78 28         JSR &2878 ; store_object_x_y_in_stack	                # store &53 in x, &55 in y
&1efd: 18               CLC
&1efe: a2 00            LDX #&00				                # actually LDX #original_X, from &1e65
&1f00: 60               RTS

; accelerate_object
&1f01: a2 02            LDX #&02	                                        # X = 2, then X = 0
&1f03: e0 02            CPX #&02
&1f05: b5 40            LDA &40,X   	# X = 2, &42 = acceleration_y ; X = 0, &40 = acceleration_x
&1f07: 08               PHP
&1f08: 75 43            ADC (&43,X) 	# X = 2, &45 = this_object_vel_y ; X = 0, &43 = this_object_vel_x
&1f0a: 20 7f 32         JSR &327f ; prevent_overflow
&1f0d: a8               TAY
&1f0e: 28               PLP
&1f0f: 20 56 32         JSR &3256 ; make_positive
&1f12: e9 3f            SBC #&3f
&1f14: c9 40            CMP #&40
&1f16: b0 12            BCS &1f2a
&1f18: b4 43            LDY &43,X	# X = 2, &45 = this_object_vel_y ; X = 0, &43 = this_object_vel_x
&1f1a: 98               TYA
&1f1b: 20 56 32         JSR &3256 ; make_positive
&1f1e: c9 40            CMP #&40
&1f20: b0 08            BCS &1f2a
&1f22: a9 40            LDA #&40
&1f24: c0 00            CPY #&00
&1f26: 20 56 32         JSR &3256 ; make_positive
&1f29: a8               TAY
&1f2a: 24 c3            BIT &c3 ; loop_counter_every_10
&1f2c: 10 08            BPL &1f36
&1f2e: 98               TYA
&1f2f: f0 05            BEQ &1f36
&1f31: 10 02            BPL &1f35
&1f33: c8               INY
&1f34: c9 88            CMP #&88
&1f36: 94 43            STY &43,X	# X = 2, &45 = this_object_vel_y ; X = 0, &43 = this_object_vel_x
&1f38: ca               DEX
&1f39: ca               DEX
&1f3a: 10 c7            BPL &1f03
&1f3c: 60               RTS

; create_jetpack_thrust
&1f3d: a5 40            LDA &40 ; acceleration_x
&1f3f: 05 42            ORA &42 ; acceleration_y
&1f41: f0 4e            BEQ &1f91			                        # leave if we're not accelerating
&1f43: a9 ed            LDA #&ed
&1f45: a4 75            LDY &75 ; this_object_sprite
&1f47: c0 02            CPY #&02
&1f49: b0 02            BCS &1f4d
&1f4b: a9 eb            LDA #&eb
&1f4d: 8d 17 02         STA &0217 ; particle_flags_table                        # for jetpack thrust - set flags to &ed or &eb depending on orientation of player
&1f50: a0 0b            LDY #&0b                                                # &0b = jetpack thrust particles
&1f52: 20 8c 21         JSR &218c ; add_particle	                        # jetpack thrust
&1f55: a9 ff            LDA #&ff
&1f57: 60               RTS

; scroll_screen
&1f58: ad 89 2e         LDA &2e89 ; can_we_scroll_screen
&1f5b: d0 34            BNE &1f91                                               # if not, leave
&1f5d: ce 89 2e         DEC &2e89 ; can_we_scroll_screen                        # don't scroll again until we've redrawn objects
&1f60: ad e4 11         LDA &11e4 ; palette_register_updating
&1f63: c9 02            CMP #&02
&1f65: 90 f9            BCC &1f60
&1f67: a9 00            LDA #&00
&1f69: 8d e4 11         STA &11e4 ; palette_register_updating
&1f6c: 08               PHP
&1f6d: 78               SEI
&1f6e: a5 b0            LDA &b0 ; screen_offset
&1f70: 85 9c            STA &9c
&1f72: a5 b1            LDA &b1 ; screen_offset_h
&1f74: 4a               LSR
&1f75: 66 9c            ROR &9c
&1f77: 4a               LSR
&1f78: 66 9c            ROR &9c
&1f7a: 4a               LSR
&1f7b: 66 9c            ROR &9c
&1f7d: 69 0c            ADC #&0c
&1f7f: a0 0c            LDY #&0c	                                        # do hardware scrolling
&1f81: 8c 00 fe         STY &fe00 	                                        # write to video controller
&1f84: 8d 01 fe         STA &fe01 	                                        # write to video controller
&1f87: a5 9c            LDA &9c
&1f89: c8               INY
&1f8a: 8c 00 fe         STY &fe00 	                                        # write to video controller
&1f8d: 8d 01 fe         STA &fe01 	                                        # write to video controller
&1f90: 28               PLP
&1f91: 60               RTS

; flash_screen_background
&1f92: a0 0b            LDY #&0b						# screen flashes for &0b cycles
&1f94: 84 2a            STY &2a ; screen_background_flash_counter
&1f96: 60               RTS

; process_screen_background_flash
&1f97: a4 2a            LDY &2a ; screen_background_flash_counter		# is the background flashing?
&1f99: f0 f6            BEQ &1f91						# if not, leave
&1f9b: c6 2a            DEC &2a ; screen_background_flash_counter
&1f9d: f0 07            BEQ &1fa6						# if the counter has run out, use &07
&1f9f: 20 87 25         JSR &2587 ; increment_timers
&1fa2: 29 20            AND #&20
&1fa4: f0 02            BEQ &1fa8						# otherwise use either &07 or &00 at random
&1fa6: a9 07            LDA #&07                                                # &07 = colour 0 black; &00 = colour 0 white
&1fa8: 8d e5 11         STA &11e5 ; palette_register_data      			# and store it in the palette register table
&1fab: ee be 14         INC &14be ; palette_register_data_updated		# force it to be refreshed
&1fae: 60               RTS

; is_it_supporting_anything_collidable
&1faf: a4 3b            LDY &3b ; this_object_supporting                        # are we touching anything?
&1fb1: 30 14            BMI &1fc7                                               # if not, leave
&1fb3: b9 60 08         LDA &0860,Y ; object_stack_type
&1fb6: c9 44            CMP #&44	                                        # is it an explosion? (&44)
&1fb8: f0 0b            BEQ &1fc5                                               # if so, leave
&1fba: c9 40            CMP #&40	                                        # is it a bush? (&40)
&1fbc: f0 07            BEQ &1fc5                                               # if so, leave
&1fbe: 38               SEC
&1fbf: e9 25            SBC #&25
&1fc1: c9 02            CMP #&02	                                        # or &25 - &26 ; clawed robot or triax
&1fc3: b0 02            BCS &1fc7                                               # if not, return object number
&1fc5: a0 ff            LDY #&ff
&1fc7: 98               TYA
&1fc8: 60               RTS

; does_it_collide_with_bullets_2
&1fc9: 20 ad 2d         JSR &2dad ; convert_object_to_range
&1fcc: e0 04            CPX #&04                                                # is it range 4? (grenades and bullets)
&1fce: f0 0a            BEQ &1fda                                               # if so, no collision
; does_it_collide_with_bullets
&1fd0: c9 40            CMP #&40	                                        # is it a bush? (&40)
&1fd2: f0 06            BEQ &1fda                                               # if so, no collision
&1fd4: c9 44            CMP #&44	                                        # is it an explosion? (&44)
&1fd6: f0 02            BEQ &1fda                                               # if so, no collision
&1fd8: c9 37            CMP #&37	                                        # is it a fireball? (&37)
&1fda: 60               RTS                                                     # if so, no collision

; plot_pixel
&1fdb: a5 93            LDA &93 ; pixel_y_low                                   # calculate the screen address for the pixel
&1fdd: 46 94            LSR &94 ; pixel_y
&1fdf: 6a               ROR
&1fe0: 46 94            LSR &94 ; pixel_y
&1fe2: 6a               ROR
&1fe3: 46 94            LSR &94 ; pixel_y
&1fe5: 6a               ROR
&1fe6: aa               TAX
&1fe7: 29 07            AND #&07
&1fe9: a8               TAY
&1fea: a5 91            LDA &91 ; pixel_x_low
&1fec: 29 e0            AND #&e0
&1fee: 65 b2            ADC &b2 ; screen_start_square_x_low_copy
&1ff0: 85 8f            STA &8f ; screen_address
&1ff2: 8a               TXA
&1ff3: 29 f8            AND #&f8
&1ff5: 45 92            EOR &92 ; pixel_x
&1ff7: 65 b3            ADC &b3 ; some_screen_address_offset
&1ff9: 6a               ROR
&1ffa: 66 8f            ROR &8f ; screen_address
&1ffc: 4a               LSR
&1ffd: 66 8f            ROR &8f ; screen_address                                
&1fff: a6 99            LDX &99 ; pixel_colour 
&2001: 09 60            ORA #&60
&2003: 85 90            STA &90; screen_address_h
&2005: a5 91            LDA &91 ; pixel_x_low
&2007: 29 10            AND #&10
&2009: c9 10            CMP #&10
&200b: a9 aa            LDA #&aa                                                # &aa = left hand pixel
&200d: 90 01            BCC &2010                                               # or
&200f: 4a               LSR                                                     # &55 = right hand pixel
&2010: 3d 48 1e         AND &1e48,X ; pixel_table
&2013: 51 8f            EOR (&8f),Y	                                        # eor with what's already on screen
&2015: 91 8f            STA (&8f),Y	                                        # plot pixel on screen
&2017: 60               RTS

&2018: 88               DEY
&2019: 10 ea            BPL &2005
&201b: c8               INY
&201c: a5 8f            LDA &8f ; screen_address
&201e: e9 f8            SBC #&f8
&2020: 85 8f            STA &8f ; screen_address
&2022: a5 90            LDA &90; screen_address_h
&2024: e9 01            SBC #&01
&2026: 10 d9            BPL &2001
; plot_particle_in
&2028: 85 99            STA &99 ; pixel_colour
; plot_particle_in_2
&202a: 38               SEC
&202b: bd d8 28         LDA &28d8,X ; particle_stack_x_low
&202e: e5 c7            SBC &c7 ; screen_start_square_x_low
&2030: 85 91            STA &91 ; pixel_x_low
&2032: bd da 28         LDA &28da,X ; particle_stack_x
&2035: e5 c8            SBC &c8 ; screen_start_square_x
&2037: c9 08            CMP #&08                                                # is the particle off the edge of the screen?
&2039: b0 42            BCS &207d                                               # if so, leave
&203b: 85 92            STA &92 ; pixel_x
&203d: bd d9 28         LDA &28d9,X ; particle_stack_y_low
&2040: e5 c9            SBC &c9 ; screen_start_square_y_low
&2042: 29 f8            AND #&f8
&2044: a8               TAY
&2045: bd db 28         LDA &28db,X ; particle_stack_y
&2048: e5 ca            SBC &ca ; screen_start_square_y
&204a: 85 94            STA &94 ; pixel_y
&204c: d0 09            BNE &2057
&204e: c0 00            CPY #&00
&2050: d0 05            BNE &2057
&2052: 24 a3            BIT &a3
&2054: 30 21            BMI &2077
&2056: 60               RTS
&2057: c9 04            CMP #&04
&2059: 90 08            BCC &2063
&205b: d0 20            BNE &207d
&205d: c0 00            CPY #&00
&205f: f0 0c            BEQ &206d
&2061: b0 1a            BCS &207d
&2063: 84 93            STY &93 ; pixel_y_low
&2065: 20 db 1f         JSR &1fdb ; plot_pixel
&2068: 24 a3            BIT &a3
&206a: 70 ac            BVS &2018
&206c: 60               RTS
&206d: 24 a3            BIT &a3
&206f: 50 0c            BVC &207d
&2071: 10 0a            BPL &207d
&2073: c6 94            DEC &94 ; pixel_y
&2075: a0 f8            LDY #&f8
&2077: 84 93            STY &93 ; pixel_y_low
&2079: 20 db 1f         JSR &1fdb ; plot_pixel
&207c: 38               SEC
&207d: 60               RTS

; particle_evolution
&207e: ae 58 1e         LDX &1e58 ; number_of_particles
&2081: 30 fa            BMI &207d		# leave if no particles
&2083: a9 38            LDA #&38
&2085: 8d 22 21         STA &2122		# &2122 = SEC
&2088: a9 4c            LDA #&4c
&208a: 8d 5a 21         STA &215a		# &215a = JMP &2122
&208d: a5 c8            LDA &c8 ; screen_start_square_x
&208f: 20 bc 2c         JSR &2cbc ; get_water_level_for_x
&2092: ae 59 1e         LDX &1e59 ; number_of_particles_x8
&2095: 86 9e            STX &9e
&2097: bd dd 28         LDA &28dd,X ; particle_stack_type
&209a: 85 a3            STA &a3
&209c: 29 07            AND #&07
&209e: 20 28 20         JSR &2028 ; plot_particle_in
&20a1: a6 9e            LDX &9e
&20a3: b0 71            BCS &2116
&20a5: a5 a3            LDA &a3
&20a7: 29 10            AND #&10
&20a9: f0 28            BEQ &20d3
&20ab: a0 01            LDY #&01
&20ad: bd db 28         LDA &28db,X ; particle_stack_y
&20b0: cd d1 14         CMP &14d1 ; water_level
&20b3: 90 15            BCC &20ca
&20b5: d0 08            BNE &20bf
&20b7: bd d9 28         LDA &28d9,X ; particle_stack_y_low
&20ba: cd d0 14         CMP &14d0 ; water_level_low
&20bd: 90 0b            BCC &20ca
&20bf: a0 fd            LDY #&fd
&20c1: 20 87 25         JSR &2587 ; increment_timers
&20c4: 29 07            AND #&07
&20c6: 09 06            ORA #&06
&20c8: 85 99            STA &99
&20ca: 98               TYA
&20cb: 7d d7 28         ADC &28d7,X ; particle_stack_velocity_y
&20ce: 70 03            BVS &20d3
&20d0: 9d d7 28         STA &28d7,X ; particle_stack_velocity_y
&20d3: a5 a3            LDA &a3
&20d5: 29 f7            AND #&f7
&20d7: c5 a3            CMP &a3
&20d9: b0 06            BCS &20e1
&20db: 69 01            ADC #&01
&20dd: 29 07            AND #&07
&20df: 85 99            STA &99
&20e1: de dc 28         DEC &28dc,X ; particle_stack_ttl
&20e4: f0 54            BEQ &213a
&20e6: a0 01            LDY #&01
&20e8: 18               CLC
&20e9: bd d6 28         LDA &28d6,X ; particle_stack_velocity_x
&20ec: 48               PHA
&20ed: 7d d8 28         ADC &28d8,X ; particle_stack_x_low
&20f0: 9d d8 28         STA &28d8,X ; particle_stack_x_low
&20f3: 90 03            BCC &20f8
&20f5: fe da 28         INC &28da,X ; particle_stack_x
&20f8: 68               PLA
&20f9: 10 03            BPL &20fe
&20fb: de da 28         DEC &28da,X ; particle_stack_x
&20fe: e8               INX
&20ff: 88               DEY
&2100: f0 e6            BEQ &20e8
&2102: a6 9e            LDX &9e
&2104: a5 a3            LDA &a3
&2106: 29 f8            AND #&f8
&2108: 05 99            ORA &99
&210a: 9d dd 28         STA &28dd,X ; particle_stack_type
&210d: 29 7f            AND #&7f
&210f: 85 a3            STA &a3
&2111: 20 2a 20         JSR &202a ; plot_particle_in_2
&2114: a6 9e            LDX &9e
&2116: b0 22            BCS &213a
&2118: 29 c0            AND #&c0
&211a: f0 06            BEQ &2122
&211c: a5 a3            LDA &a3
&211e: 29 20            AND #&20
&2120: f0 13            BEQ &2135
&2122: 38               SEC
&2123: 8a               TXA
&2124: e9 08            SBC #&08
&2126: aa               TAX
&2127: 90 03            BCC &212c
&2129: 4c 95 20         JMP &2095
&212c: a9 60            LDA #&60	
&212e: 8d 22 21         STA &2122	# &2122 = RTS
&2131: 8d 5a 21         STA &215a	# &215a = RTS
&2134: 60               RTS

&2135: 20 2a 20         JSR &202a ; plot_particle_in_2
&2138: a6 9e            LDX &9e
&213a: ac 59 1e         LDY &1e59 ; number_of_particles_x8
&213d: b9 d6 28         LDA &28d6,Y ; particle_stack_velocity_x
&2140: 9d d6 28         STA &28d6,X ; particle_stack_velocity_x
&2143: c8               INY
&2144: e8               INX
&2145: 8a               TXA
&2146: 29 07            AND #&07
&2148: d0 f3            BNE &213d
&214a: a6 9e            LDX &9e
&214c: 38               SEC
&214d: ad 59 1e         LDA &1e59 ; number_of_particles_x8
&2150: e9 08            SBC #&08
&2152: 8d 59 1e         STA &1e59 ; number_of_particles_x8
&2155: ce 58 1e         DEC &1e58 ; number_of_particles
&2158: 30 d2            BMI &212c
&215a: 60 # 22 21       RTS
#215a: 4c 22 21		JMP &2111

; add_particle_to_stack
&215d: ae 58 1e	        LDX &1e58 ; number_of_particles
&2160: e0 1f            CPX #&1f
&2162: f0 10            BEQ &2174
&2164: e8               INX
&2165: 8e 58 1e         STX &1e58 ; number_of_particles
&2168: 8a               TXA
&2169: 0a               ASL
&216a: 0a               ASL
&216b: 0a               ASL
&216c: 8d 59 1e         STA &1e59 ; number_of_particles_x8
&216f: 85 9e            STA &9e
&2171: aa               TAX
&2172: 90 17            BCC &218b
&2174: a5 da            LDA &da ; timer_2
&2176: 29 f8            AND #&f8
&2178: aa               TAX
&2179: 86 9e            STX &9e
&217b: bd dd 28         LDA &28dd,X ; particle_stack_type
&217e: 09 80            ORA #&80
&2180: 85 a3            STA &a3
&2182: 29 07            AND #&07
&2184: 20 28 20         JSR &2028 ; plot_particle_in
&2187: a6 9e            LDX &9e
&2189: a4 a1            LDY &a1
&218b: 60               RTS

; add_particle
&218c: a9 01            LDA #&01
; add_particles
&218e: 84 a1            STY &a1 ; particle_type
&2190: 85 9f            STA &9f ; number_of_particles
&2192: b9 0c 02         LDA &020c,Y ; particle_flags_table
&2195: 85 a0            STA &a0 ; particle_flags
&2197: 29 20            AND #&20
&2199: f0 0a            BEQ &21a5
&219b: a2 06            LDX #&06
&219d: b5 4f            LDA &4f,X       # X = 6, &55 = this_object_y ; X = 4, &53 = this_object_x
&219f: 95 87            STA &87,X       # X = 6, &8d = particle_y ;  X = 4, &8b = particle_x
&21a1: ca               DEX
&21a2: ca               DEX
&21a3: 10 f8            BPL &219d
&21a5: a5 c8            LDA &c8 ; screen_start_square_x
&21a7: 18               CLC
&21a8: e5 8b            SBC &8b ; particle_x
&21aa: 38               SEC
&21ab: e9 01            SBC #&01
&21ad: c9 f6            CMP #&f6
&21af: 90 da            BCC &218b
&21b1: a5 8d            LDA &8d ; particle_y
&21b3: e5 ca            SBC &ca ; screen_start_square_y
&21b5: 18               CLC
&21b6: 69 01            ADC #&01
&21b8: c9 06            CMP #&06
&21ba: b0 cf            BCS &218b
&21bc: 24 a0            BIT &a0 ; particle_flags        
&21be: 10 17            BPL &21d7						# if flags & &80, then:
&21c0: a2 40            LDX #&40						# use velocity if flags & &40
&21c2: 70 02            BVS &21c6
&21c4: a2 43            LDX #&43						# use acceleration
&21c6: b5 00            LDA &00,X
&21c8: 85 b4            STA &b4 ; velocity_x
&21ca: b5 02            LDA &02,X
&21cc: 85 b6            STA &b6 ; velocity_y
&21ce: 20 d4 22         JSR &22d4 ; calculate_angle_from_velocities
&21d1: a4 a1            LDY &a1 ; particle_type
&21d3: 49 80            EOR #&80
&21d5: 85 b5            STA &b5 ; angle
&21d7: 20 87 25         JSR &2587 ; increment_timers
&21da: 39 08 02         AND &0208,Y ; particle_velocity_randomness_table
&21dd: 18               CLC
&21de: 79 09 02         ADC &0209,Y ; particle_velocity_table
&21e1: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&21e4: 06 a0            ASL &a0 ; particle_flags # 80
&21e6: 06 a0            ASL &a0 ; particle_flags # 40
&21e8: 06 a0            ASL &a0 ; particle_flags # 20
&21ea: a2 02            LDX #&02
&21ec: a9 00            LDA #&00
&21ee: 06 a0            ASL &a0 ; particle_flags # 10, 4
&21f0: 90 06            BCC &21f8
&21f2: b4 37            LDY &37,X ; X = 2, &39 this_object_flags_lefted ; X = 0, &37 this_object_angle
&21f4: 10 02            BPL &21f8
&21f6: b5 3a            LDA &3a,X ; X = 2, &3c this_object_height ; X = 0, &3a this_object_width
&21f8: 06 a0            ASL &a0 ; particle_flags # 8, 2
&21fa: 90 03            BCC &21ff
&21fc: b5 3a            LDA &3a,X ; X = 2, &3c this_object_height ; X = 0, &3a this_object_width
&21fe: 4a               LSR
&21ff: 75 87            ADC (&87,X) ; particle_x_low
&2201: 95 87            STA &87,X ; particle_x_low
&2203: 90 02            BCC &2207
&2205: f6 8b            INC &8b,X ; particle_x 
&2207: ca               DEX
&2208: ca               DEX
&2209: f0 e1            BEQ &21ec
&220b: a4 a1            LDY &a1 ; particle_type
&220d: a5 da            LDA &da ; timer_2
&220f: 39 0b 02         AND &020b,Y ; particle_colour_randomness_table
&2212: 59 0a 02         EOR &020a,Y ; particle_colour_table
&2215: 48               PHA
&2216: 20 5d 21         JSR &215d ; add_particle_to_stack
&2219: 68               PLA
&221a: 85 a3            STA &a3
&221c: 29 07            AND #&07
&221e: 85 99            STA &99
&2220: 20 87 25         JSR &2587 ; increment_timers
&2223: 39 06 02         AND &0206,Y ; particle_life_randomness_table
&2226: 79 07 02         ADC &0207,Y ; particle_life_table
&2229: 9d dc 28         STA &28dc,X ; particle_stack_ttl
&222c: 86 9c            STX &9c
&222e: a2 fe            LDX #&fe        # first X = &fe, Y = 0 (x direction), then X = &0, Y = 1 (y direction)
&2230: 86 a2            STX &a2
&2232: 20 87 25         JSR &2587 ; increment_timers
&2235: 4a               LSR
&2236: 39 0f 02         AND &020f,Y ; particle_x_velocity_randomness_table    # Y = 0, &020f ; Y = 1, &0210
&2239: 90 02            BCC &223d
&223b: 49 ff            EOR #&ff
&223d: 75 b6            ADC (&b6,X)     # X = &fe, &b4 velocity_x ; X = &00, &b6 velocity_y
&223f: 20 7f 32         JSR &327f ; prevent_overflow
&2242: 48               PHA
&2243: a5 da            LDA &da ; timer_2
&2245: 39 0d 02         AND &020d,Y ; particle_x_randomness_table
&2248: 75 89            ADC (&89,X)     # X = &fe, &87 particle_x_low ; X = &00, &89 particle_y_low
&224a: 48               PHA
&224b: b5 8d            LDA &8d,X ;     # X = &fe, &8b particle_x ; X = &00, &8d particle_y
&224d: 69 00            ADC #&00
&224f: a6 9c            LDX &9c
&2251: 9d da 28         STA &28da,X ; particle_stack_x
&2254: 68               PLA
&2255: 9d d8 28         STA &28d8,X ; particle_stack_x_low
&2258: 68               PLA
&2259: 9d d6 28         STA &28d6,X ; particle_stack_velocity_x
&225c: e6 9c            INC &9c
&225e: a6 a2            LDX &a2
&2260: c8               INY
&2261: e8               INX
&2262: e8               INX
&2263: f0 cb            BEQ &2230
&2265: a6 9e            LDX &9e
&2267: 20 e6 20         JSR &20e6
&226a: 24 a0            BIT &a0 ; particle_flags
&226c: 10 15            BPL &2283
&226e: a0 02            LDY #&02
&2270: e8               INX
&2271: c9 ca            CMP #&ca
&2273: bd d6 28         LDA &28d6,X ; particle_stack_velocity_x
&2276: 79 43 00         ADC &0043,Y
&2279: 20 7f 32         JSR &327f ; prevent_overflow
&227c: 9d d6 28         STA &28d6,X ; particle_stack_velocity_x
&227f: 88               DEY
&2280: 88               DEY
&2281: f0 ef            BEQ &2272
&2283: c6 9f            DEC &9f ; number_of_particles
&2285: d0 84            BNE &220b
&2287: 60               RTS

; get_object_centre
&2288: 86 9d            STX &9d ; temp
&228a: a2 02            LDX #&02
&228c: b5 3a            LDA &3a,X	# X = 2, &3c this_object_height; X = 0, &3a this_object_width
&228e: 4a               LSR		# halve it
&228f: 75 4f            ADC (&4f,X)	
&2291: 95 87            STA &87,X	# X = 2, &89 this_object_y_centre_low; X = 0, &87 this_object_x_centre_low
&2293: b5 53            LDA &53,X	# X = 2, &55 this_object_y ; X = 0, &53 this_object_x
&2295: 69 00            ADC #&00
&2297: 95 8b            STA &8b,X	# X = 2, &8c this_object_y_centre; X = 0, &8b this_object_x_centre
&2299: ca               DEX
&229a: ca               DEX
&229b: f0 ef            BEQ &228c
&229d: a6 9d            LDX &9d ; temp
&229f: 60               RTS

; get_angle_between_objects
# compare two object centres
# returns angle
# this_object
# X = other object
&22a0: 20 88 22         JSR &2288 ; get_object_centre
&22a3: bc 70 08         LDY &0870,X ; object_stack_sprite
&22a6: b9 0c 5e         LDA &5e0c,Y ; sprite_width_lookup
&22a9: 4a               LSR					# add half the width
&22aa: 7d 80 08         ADC &0880,X ; object_stack_x_low
&22ad: 85 88            STA &88 ; stack_object_x_centre_low
&22af: bd 91 08         LDA &0891,X ; object_stack_x
&22b2: 69 00            ADC #&00
&22b4: 85 8c            STA &8c ; stack_object_x_centre
&22b6: b9 89 5e         LDA &5e89,Y ; sprite_height_lookup
&22b9: 4a               LSR					# add half the height
&22ba: 7d a3 08         ADC &08a3,X ; object_stack_y_low
&22bd: 85 8a            STA &8a ; stack_object_y_centre_low
&22bf: bd b4 08         LDA &08b4,X ; object_stack_y
&22c2: 69 00            ADC #&00
&22c4: 85 8e            STA &8e ; stack_object_y_centre
&22c6: 20 fe 22         JSR &22fe ; calculate_object_centre_deltas
&22c9: 4c d7 22         JMP &22d7 ; calculate_angle

; calculate_angle_from_this_object_velocities
&22cc: a5 43            LDA &43 ; this_object_vel_x
&22ce: 85 b4            STA &b4 ; velocity_x
&22d0: a5 45            LDA &45 ; this_object_vel_y
&22d2: 85 b6            STA &b6 ; velocity_y
; calculate_angle_from_velocities
# takes &b4 velocity_x, &b6 velocity_y
# returns &b5 angle
&22d4: 20 3d 23         JSR &233d ; get_opposite_velocities     # a = x_vel &b7 = y_vel
; calculate_angle
# takes A = velocity_x, &b7 = velocity_y
# returns &b5 angle
&22d7: c5 b7            CMP &b7 ; oppositite_velocity_y
&22d9: 90 05            BCC &22e0 ; no_xy_swap          # is support_delta_x_low (A) < support_delta_y_low (&b8) ?
&22db: a8               TAY                             
&22dc: a5 b7            LDA &b7 ; oppositite_velocity_y # if not, swap A and &b7
&22de: 84 b7            STY &b7 ; oppositite_velocity_y # ie, force A < &b7
; no_xy_swap
&22e0: 26 99            ROL &99 ; velocity_signs                        # note the swap in &99 velocity_signs
&22e2: a0 08            LDY #&08
&22e4: 84 b5            STY &b5 ; angle
; calc_angle_loop
&22e6: 0a               ASL
&22e7: c5 b7            CMP &b7 ; oppositite_velocity_y
&22e9: 90 02            BCC &22ed
&22eb: e5 b7            SBC &b7 ; oppositite_velocity_y
&22ed: 26 b5            ROL &b5 ; angle
&22ef: 90 f5            BCC &22e6 ; calc_angle_loop
&22f1: a5 99            LDA &99 ; velocity_signs
&22f3: 29 07            AND #&07
&22f5: a8               TAY
&22f6: a5 b5            LDA &b5 ; angle
&22f8: 59 bf 14         EOR &14bf,Y ; angle_modification_table
&22fb: 85 b5            STA &b5 ; angle
&22fd: 60               RTS

; calculate_object_centre_deltas
# leaves with A = support_delta_x_low, &b7 = support_delta_y_low, &b8 = delta_magnitude
&22fe: a0 04            LDY #&04        # first y direction (Y = 4), then x direction (Y = 2)
&2300: 85 b7            STA &b7 ; tmp
&2302: b9 86 00         LDA &0086,Y     # Y = 4, &8a stack_object_y_centre_low; Y = 2, &88 stack_object_x_centre_low
&2305: f9 85 00         SBC &0085,Y     # Y = 4, &89 this_object_y_centre_low; Y = 2, &87 this_object_x_centre_low
&2308: 99 79 00         STA &0079,Y     # Y = 4, &7d support_delta_y_low; Y = 2, &7b support_delta_x_low
&230b: b9 8a 00         LDA &008a,Y     # Y = 4, &8e stack_object_y_centre; Y = &8c stack_object_x_centre
&230e: f9 89 00         SBC &0089,Y     # Y = 4, &8d this_object_y_centre; Y = 2, &8b this_object_x_centre
&2311: 99 7a 00         STA &007a,Y     # Y = 4, &7e support_delta_y; Y = 2, &7c support_delta_x
&2314: 38               SEC
&2315: 10 03            BPL &231a
&2317: 20 56 32         JSR &3256 ; make_positive
&231a: 26 99            ROL &99 ; velocity-signs
&231c: 88               DEY
&231d: 88               DEY
&231e: d0 e0            BNE &2300       # now do it again for the x direction
&2320: 05 b7            ORA &b7 ; tmp                   # A = support_delta_y | support_delta_x, ie largest of the two
&2322: 0a               ASL
&2323: 46 7c            LSR &7c
&2325: 66 7b            ROR &7b                         # halve support_delta_x
&2327: 46 7e            LSR &7e
&2329: 66 7d            ROR &7d                         # halve support_delta_y
&232b: c8               INY                             # for each halving, increase Y
&232c: 4a               LSR
&232d: d0 f4            BNE &2323                       # keep having A until zero
&232f: 84 b8            STY &b8 ; delta_magnitude
&2331: a5 7d            LDA &7d                         # support_delta_y_low
&2333: 20 56 32         JSR &3256 ; make_positive
&2336: 85 b7            STA &b7 ; some_kind_of_velocity
&2338: a5 7b            LDA &7b                         # support_delta_x_low
&233a: 4c 56 32         JMP &3256 ; make_positive

; get_opposite_velocities
# returns &b7 as y_vel, A as x_vel
&233d: a0 02            LDY #&02                        # first Y = 2, y direction, then Y = 0, x direction
&233f: 20 46 23         JSR &2346
&2342: 85 b7            STA &b7 ; some_kind_of_velocity
&2344: 88               DEY
&2345: 88               DEY
&2346: a9 7f            LDA #&7f                                                # is the velocity negative?
&2348: d9 b4 00         CMP &00b4,Y     # Y = 2, &b6 velocity_y ; Y = 0, &b4 velocity_y
&234b: b9 b4 00         LDA &00b4,Y     # Y = 2, &b6 velocity_y ; Y = 0, &b4 velocity_y
&234e: b0 04            BCS &2354
&2350: 49 ff            EOR #&ff                                                # if not, make it negative
&2352: 69 01            ADC #&01
&2354: 26 99            ROL &99 ; velocity_signs                                # note this in velocity_signs
&2356: 60               RTS

; determine_velocities_from_angle
# A = magnitude, &b5 = angle
&2357: 85 b4            STA &b4 ; velocity_x
&2359: a5 b5            LDA &b5 ; angle
&235b: 85 9d            STA &9d ; temp
&235d: a0 05            LDY #&05
&235f: a9 00            LDA #&00
&2361: 46 9d            LSR &9d ; temp
&2363: 90 03            BCC &2368
&2365: 18               CLC
&2366: 65 b4            ADC &b4 ; velocity_x
&2368: 6a               ROR
&2369: 88               DEY
&236a: d0 f5            BNE &2361
&236c: 46 9d            LSR &9d ; temp
&236e: 90 0a            BCC &237a
&2370: a4 b4            LDY &b4 ; velocity_x
&2372: 85 b4            STA &b4 ; velocity_x
&2374: 98               TYA
&2375: e5 b4            SBC &b4 ; velocity_x
&2377: 85 b4            STA &b4 ; velocity_x
&2379: 98               TYA
&237a: 46 9d            LSR &9d ; temp
&237c: 90 08            BCC &2386
&237e: 49 ff            EOR #&ff
&2380: a8               TAY
&2381: c8               INY
&2382: a5 b4            LDA &b4 ; velocity_x
&2384: 84 b4            STY &b4 ; velocity_x
&2386: 46 9d            LSR &9d ; temp
&2388: 90 0b            BCC &2395
&238a: 49 ff            EOR #&ff
&238c: a8               TAY
&238d: c8               INY
&238e: a9 00            LDA #&00
&2390: e5 b4            SBC &b4 ; velocity_x
&2392: 85 b4            STA &b4 ; velocity_x
&2394: 98               TYA
&2395: 85 b6            STA &b6 ; velocity_y
&2397: 60               RTS

; setup_background_sprite_values
&2398: 20 15 17         JSR &1715 ; determine_background
; setup_background_sprite_values_from_08_09
&239b: a8               TAY                                                     # Y = square_sprite
&239c: b9 2b 05         LDA &052b,Y ; background_palette_lookup                 # what's the palette for this sprite?
&239f: d0 0d            BNE &23ae ; palette_defined
&23a1: a5 97            LDA &97 ; square_y                                      # if 0, it depends on square_y / 16
&23a3: 38               SEC
&23a4: e9 54            SBC #&54
&23a6: 4a               LSR
&23a7: 4a               LSR
&23a8: 4a               LSR
&23a9: 4a               LSR
&23aa: aa               TAX
&23ab: bd 85 11         LDA &1185,X ; wall_palette_lookup
; palette_not_zero
&23ae: c9 03            CMP #&03
&23b0: b0 09            BCS &23bb ; palette_not_two                             # if 1 or 2, it depends on square_y / &80
&23b2: 69 b1            ADC #&b1
&23b4: 24 97            BIT &97 ; square_y
&23b6: 10 54            BPL &240c ; palette_not_six
&23b8: 0a               ASL
&23b9: 69 90            ADC #&90
; palette_not_two
&23bb: c9 03            CMP #&03
&23bd: d0 11            BNE &23d0 ; palette_not_three                           # if 3, it's a function of x, y and orientation
&23bf: a5 09            LDA &09 ; square_orientation
&23c1: 2a               ROL
&23c2: 2a               ROL
&23c3: 2a               ROL
&23c4: e5 97            SBC &97 ; square_y
&23c6: 6a               ROR
&23c7: 18               CLC
&23c8: 65 95            ADC &95 ; square_x
&23ca: 29 03            AND #&03
&23cc: aa               TAX
&23cd: bd 95 11         LDA &1195,X ; wall_palette_three_lookup
; palette_not_three
&23d0: c9 04            CMP #&04
&23d2: d0 0c            BNE &23e0
&23d4: a5 97            LDA &97 ; square_y                                      # if 4, it depends on square_y / 16
&23d6: 2a               ROL
&23d7: 2a               ROL
&23d8: 2a               ROL
&23d9: 2a               ROL
&23da: 29 07            AND #&07
&23dc: aa               TAX
&23dd: bd 8c 11         LDA &118c,X ; wall_palette_four_lookup
; palette_not_four
&23e0: c9 05            CMP #&05
&23e2: d0 1c            BNE &2400
&23e4: a5 97            LDA &97 ; square_y                                      # if 5, it's a function of y and orientation
&23e6: 6a               ROR
&23e7: 6a               ROR
&23e8: 45 97            EOR &97 ; square_y
&23ea: 6a               ROR
&23eb: 90 02            BCC &23ef
&23ed: a0 19            LDY #&19
&23ef: 6a               ROR
&23f0: e5 97            SBC &97 ; square_y
&23f2: 29 40            AND #&40
&23f4: 45 09            EOR &09 ; square_orientation
&23f6: 24 09            BIT &09 ; square_orientation
&23f8: 85 09            STA &09 ; square_orientation
&23fa: a9 b1            LDA #&b1
&23fc: 50 0e            BVC &240c
&23fe: 69 0a            ADC #&0a
; palette_not_five
&2400: c9 06            CMP #&06                                                # if 6, it's a function of orientation
&2402: d0 08            BNE &240c
&2404: a9 9c            LDA #&9c
&2406: 24 09            BIT &09 ; square_orientation
&2408: 50 02            BVC &240c
&240a: a9 cf            LDA #&cf
; palette_not_six
&240c: 85 73            STA &73 ; this_object_palette                           # set the palette for this square
&240e: 85 74            STA &74 ; this_object_palette_old
&2410: a5 09            LDA &09                                                 
&2412: 85 71            STA &71 ; this_object_flipping_flags                    # set the orientation for this square
&2414: 85 72            STA &72 ; this_object_flipping_flags_old
&2416: b9 ab 04         LDA &04ab,Y ; background_sprite_lookup
&2419: 29 7f            AND #&7f
&241b: aa               TAX
&241c: 85 75            STA &75 ; this_object_sprite                            # set the sprite for this square
&241e: 85 76            STA &76 ; this_object_sprite_old
&2420: b9 eb 04         LDA &04eb,Y ; background_y_offset_lookup
&2423: 29 f0            AND #&f0
&2425: 24 09            BIT &09 ; square_orientation
&2427: 50 07            BVC &2430                                       
&2429: 7d 89 5e         ADC &5e89,X ; sprite_height_lookup
&242c: 09 07            ORA #&07
&242e: 49 ff            EOR #&ff
&2430: 85 51            STA &51 ; this_object_y_low                             # y position of start of square sprite
&2432: 85 52            STA &52 ; this_object_y_low_old
&2434: a9 00            LDA #&00
&2436: 24 09            BIT &09 ; square_orientation
&2438: 10 05            BPL &243f                                       
&243a: a9 f2            LDA #&f2
&243c: fd 0c 5e         SBC &5e0c,X ; sprite_width_lookup
&243f: 85 4f            STA &4f ; this_object_x_low
&2441: 85 50            STA &50 ; this_object_x_low_old                         # x position of start of square sprite
&2443: a5 95            LDA &95 ; square_x
&2445: 85 53            STA &53 ; this_object_x
&2447: 85 54            STA &54 ; this_object_x_old
&2449: a5 97            LDA &97 ; square_y
&244b: 85 55            STA &55 ; this_object_y
&244d: 85 56            STA &56 ; this_object_y_old
&244f: 60               RTS

; get_wall_start_80_83
; A determines X on leaving
&2450: a9 04            LDA #&04
&2452: 2c a9 00         BIT &00a9
; get_wall_start_7c_7f
#2453:    a9 00         LDA #&00
&2455: 48               PHA
&2456: 8e 90 24         STX &2490                                               # self modifying code - preserve X
&2459: 20 15 17         JSR &1715 ; determine_background                        # find out background in this square
&245c: a8               TAY                                                     # Y = background
&245d: 68               PLA
&245e: aa               TAX                                                     # X is set based on how we were called
&245f: b9 6b 05         LDA &056b,Y ; background_wall_y_start_base_lookup
&2462: 24 09            BIT &09 ; square_orientation
&2464: 50 04            BVC &246a                                               # is the square flipped vertically? (&40)
&2466: 0a               ASL                                                     # if so, consider lowest nibble
&2467: 0a               ASL
&2468: 0a               ASL
&2469: 0a               ASL
&246a: 29 f0            AND #&f0                                                # otherwise use highest nibble
&246c: f0 02            BEQ &2470
&246e: 09 0f            ORA #&0f
&2470: 95 7e            STA &7e,X       # X = 0, &7e wall_y_start_base; X = 4, &82 wall_y_start_base_4
&2472: a5 09            LDA &09 ; square_orientation
&2474: 0a               ASL                                                     # carry set if horizontally flipped
&2475: 85 9c            STA &9c ; v_flipped                       
&2477: 59 ab 04         EOR &04ab,Y ; background_sprite_lookup                  # sprite_lookup ^ &80 if vertically flipped
&247a: 95 7f            STA &7f,X       # X = 0, &7f wall_sprite; X = 4, &83 wall_sprite_4
&247c: b9 eb 04         LDA &04eb,Y ; background_y_offset_lookup                # offset_lookup * 4
&247f: 2a               ROL                                                     # + h_flipped * 2
&2480: 06 9c            ASL &9c ; v_flipped
&2482: 2a               ROL                                                     # + v_flipped
&2483: 29 3f            AND #&3f                                                
&2485: a8               TAY
&2486: b9 ab 05         LDA &05ab,Y ; background_wall_y_start_lookup
&2489: 95 7c            STA &7c,X       # X = 0, &7c wall_y_start_lookup_pointer; X = 4, &80 wall_y_start_lookup_pointer_4
&248b: a9 01            LDA #&01
&248d: 95 7d            STA &7d,X       # X = 0, &7d wall_y_start_lookup_pointer_h; X = 4, &81 wall_y_start_lookup_pointer_h_4
&248f: a2 00            LDX #&00        # modified by &2456; actually LDX #X
&2491: 60               RTS

; scream_if_damaged
&2492: 20 3c 25         JSR &253c ; is_this_object_damaged                      # is the object damaged?
&2495: 90 0e            BCC &24a5                                               # if not, leave
; scream
&2497: 20 fa 13         JSR &13fa ; play_sound
#249a: 33 03 2d 24 ; sound data
&249e: 20 fa 13         JSR &13fa ; play_sound                                  # scream!
#24a1: 33 03 2b 25 ; sound data
&24a5: 60               RTS

; take_damage
; A = damage, Y = object to damage
&24a6: c0 00            CPY #&00                                                # is it the player being damaged?
&24a8: d0 41            BNE &24eb ; not_player_being_damaged
&24aa: 8d 5f 08         STA &085f ; damage
&24ad: 24 da            BIT &da ; timer_2
&24af: 30 08            BMI &24b9 ; no_daze
&24b1: 46 31            LSR &31 ; player_crawling
&24b3: c5 ba            CMP &ba ; player_immobility_daze        
&24b5: 90 02            BCC &24b9 ; no_daze
&24b7: 85 ba            STA &ba ; player_immobility_daze                        # daze the player when seriously damaged
; no_daze
&24b9: 8a               TXA                                                     # preserve X
&24ba: 48               PHA
&24bb: 2c 13 08         BIT &0813 ; protection_suit_collected                   # have we got the protection suit?
&24be: 10 0d            BPL &24cd ; no_protection_suit
&24c0: a2 05            LDX #&05
&24c2: 20 79 2d         JSR &2d79 ; reduce_weapon_energy_for_x                  # drain its energy
&24c5: 20 79 2d         JSR &2d79 ; reduce_weapon_energy_for_x
&24c8: 20 92 2d         JSR &2d92 ; make_firing_erratic_at_low_energy
&24cb: b0 0d            BCS &24da ; suit_working                                # carry set if suit is working
; no_protection_suit
&24cd: a0 03            LDY #&03
&24cf: 0e 5f 08         ASL &085f ; damage
&24d2: 90 03            BCC &24d7
&24d4: 6e 5f 08         ROR &085f ; damage                                      # if no suit, multiply the damage by 8
&24d7: 88               DEY
&24d8: d0 f5            BNE &24cf
; suit_working
&24da: a5 da            LDA &da ; timer_2
&24dc: 29 07            AND #&07
&24de: cd 5f 08         CMP &085f ; damage                                      # for small damages, scream occasionally
&24e1: b0 03            BCS &24e6
&24e3: 20 97 24         JSR &2497 ; scream                                      # but, always scream for larger ones
&24e6: 68               PLA
&24e7: aa               TAX                                                     # restore X
&24e8: ad 5f 08         LDA &085f ; damage
; not_player_being_damaged
&24eb: 85 9d            STA &9d ; damage
&24ed: c9 08            CMP #&08
&24ef: 90 08            BCC &24f9                                               # if the damage is &08 or more
&24f1: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&24f4: 09 08            ORA #&08                                                # mark the object as being damaged
&24f6: 99 c6 08         STA &08c6,Y ; object_stack_flags
&24f9: b9 26 09         LDA &0926,Y ; object_stack_energy
&24fc: 85 9c            STA &9c ; old_energy
&24fe: 38               SEC
&24ff: e5 9d            SBC &9d ; damage                                        # reduce energy by damage
&2501: b0 05            BCS &2508
&2503: a9 00            LDA #&00                                                # setting to zero if too much
&2505: 2c a9 01         BIT &01a9
; set_stack_object_energy_to_one
#2506:    a9 01         LDA #&01
&2508: 99 26 09         STA &0926,Y ; object_stack_energy
&250b: 60               RTS

; damage_object
&250c: 20 a6 24         JSR &24a6 ; take_damage                                 # have we still got energy?
&250f: d0 04            BNE &2515                                               # if so, leave
&2511: a5 9c            LDA &9c ; old_energy                                    # if we had energy before being damaged,
&2513: d0 f1            BNE &2506 ; set_stack_object_energy_to_one              # set energy to be one
&2515: 60               RTS

; mark_stack_object_for_removal
&2516: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&2519: 09 20            ORA #&20
&251b: 99 c6 08         STA &08c6,Y ; object_stack_flags
&251e: 60               RTS

; reduce_object_energy_by_one
&251f: 18               CLC
&2520: a5 15            LDA &15 ; this_object_energy
&2522: f0 04            BEQ &2528
&2524: e9 00            SBC #&00
&2526: 85 15            STA &15 ; this_object_energy
&2528: 60               RTS

; mark_this_object_for_removal
&2529: 48               PHA
&252a: a5 6f            LDA &6f ; this_object_flags
&252c: 09 20            ORA #&20
&252e: 85 6f            STA &6f ; this_object_flags
&2530: 68               PLA
&2531: 38               SEC
&2532: 60               RTS

; is_this_object_marked_for_removal
&2533: 48               PHA
&2534: a5 6f            LDA &6f ; this_object_flags
&2536: 29 20            AND #&20
&2538: c9 20            CMP #&20
&253a: 68               PLA
&253b: 60               RTS

; is_this_object_damaged
&253c: 48               PHA
&253d: a5 6f            LDA &6f ; this_object_flags
&253f: 29 08            AND #&08
&2541: c9 08            CMP #&08
&2543: 68               PLA
&2544: 60               RTS

&2545: c6 15            DEC &15 ; this_object_energy
&2547: d0 04            BNE &254b
; gain_one_energy_point
&2549: e6 15            INC &15 ; this_object_energy
&254b: f0 f8            BEQ &2545
&254d: 60               RTS
; gain_one_energy_point_if_not_immortal
&254e: e6 15            INC &15 ; this_object_energy
&2550: c6 15            DEC &15 ; this_object_energy
&2552: d0 f5            BNE &2549 ; gain_one_energy_point
&2554: 60               RTS

; get_sprite_from_velocity
# A = modulus
&2555: a2 03            LDX #&03                                                # scale = 8
; get_sprite_from_velocity_X                                                    # scale = 2**X
# A = modulus, X = scale
&2557: 85 9c            STA &9c ; modulus                              
&2559: 20 b6 3b         JSR &3bb6 ; get_biggest_velocity
&255c: 4a               LSR
&255d: ca               DEX
&255e: 10 fc            BPL &255c                                               # get biggest velocity / scale
&2560: 38               SEC
&2561: 65 12            ADC &12 ; this_object_timer                             # add to this_object_timer
&2563: 38               SEC
&2564: e5 9c            SBC &9c ; modulus                                       # mod modulus
&2566: b0 fc            BCS &2564
&2568: 65 9c            ADC &9c ; modulus
&256a: 85 12            STA &12 ; this_object_timer                             # store result in this_object_timer
&256c: 60               RTS

; change_angle_if_wall_collision
&256d: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # have we collided?
&256f: 10 06            BPL &2577
&2571: a5 1c            LDA &1c ; wall_collision_angle                
&2573: 49 ff            EOR #&ff
&2575: 85 37            STA &37 ; this_object_angle                             # if so, change angle to match
&2577: 60               RTS

; flip_object_in_direction_of_travel_on_random_3
&2578: a9 03            LDA #&03
; flip_object_in_direction_of_travel_on_random_a
&257a: 25 d9            AND &d9 ; timer_1
&257c: d0 06            BNE &2584
; flip_object_in_direction_of_travel
&257e: a5 43            LDA &43 ; this_object_vel_x                             # have we got an x velocity?
&2580: f0 02            BEQ &2584
&2582: 85 37            STA &37 ; this_object_angle                             # if so, change angle to match
&2584: a5 37            LDA &37 ; this_object_angle
&2586: 60               RTS

; increment_timers
&2587: 65 dc            ADC &dc ; timer_4                                       # quick and easy pseudo-random numbers
&2589: 65 d9            ADC &d9 ; timer_1
&258b: 85 d9            STA &d9 ; timer_1
&258d: 65 db            ADC &db ; timer_3
&258f: 85 db            STA &db ; timer_3
&2591: 65 da            ADC &da ; timer_2
&2593: 85 da            STA &da ; timer_2
&2595: 65 dc            ADC &dc ; timer_4
&2597: 85 dc            STA &dc ; timer_4
&2599: 60               RTS

; process_events
&259a: a9 67            LDA #&67                                                # desired water level = &67 in endgame
&259c: 2c 1e 08         BIT &081e ; endgame_value                               # are we in the endgame?
&259f: 30 3e            BMI &25df ; no_maggot_machine                           # if not, the maggot machine exists
&25a1: a9 60            LDA #&60
&25a3: 8d 88 09         STA &0988 ; background_object_data	                # reset number of maggots
&25a6: 24 c1            BIT &c1 ; loop_counter_every_40
&25a8: 10 19            BPL &25c3 ; no_maggots                                  # once every &40 cycles,
&25aa: a9 27            LDA #&27				                # &27 = maggot
&25ac: 20 60 1e         JSR &1e60 ; reserve_object_low_priority		        # try to create a maggot
&25af: b0 12            BCS &25c3 ; no_maggots			                # leave if we couldn't find a slot
&25b1: a9 d9            LDA #&d9				                # (&61, &d9)
&25b3: 99 b4 08         STA &08b4,Y ; object_stack_y    	                
&25b6: a9 61            LDA #&61                                                # create maggot at (&61.&61, &d9.&70)
&25b8: 99 91 08         STA &0891,Y ; object_stack_x                            # ie, by the teleporter in the maggot machine
&25bb: 99 80 08         STA &0880,Y ; object_stack_x_low
&25be: a9 70            LDA #&70
&25c0: 99 a3 08         STA &08a3,Y ; object_stack_y_low
; no_maggots
&25c3: ad 48 0a         LDA &0a48 ; background_object_data	                # for stone door at (&6b, &e1)
&25c6: 24 c2            BIT &c2 ; loop_counter_every_20
&25c8: 10 0b            BPL &25d5                                               # once every &20 cycles,
&25ca: 29 fd            AND #&fd
&25cc: ac 33 08         LDY &0833 ; water_level_by_x_range_range1
&25cf: c0 e0            CPY #&e0
&25d1: b0 02            BCS &25d5                                               # open door
&25d3: 09 02            ORA #&02
&25d5: 8d 48 0a         STA &0a48 ; background_object_data                      # for stone door at (&6b, &e1)
&25d8: 29 02            AND #&02
&25da: 0a               ASL
&25db: 0a               ASL
&25dc: 0a               ASL                                                     # desired water level varies depending on door
&25dd: 69 d2            ADC #&d2                                                # around &d2 if maggot machine operational
; no_maggot_machine
&25df: 8d 37 08         STA &0837 ; desired_water_level_by_x_range_range1
&25e2: ad 1f 08         LDA &081f ; earthquake_triggered
&25e5: 10 2b            BPL &2612 ; no_earthquake                               # is the earth quaking?
&25e7: 0a               ASL
&25e8: c5 db            CMP &db ; timer_3
&25ea: 29 10            AND #&10
&25ec: 2a               ROL
&25ed: f0 0b            BEQ &25fa
&25ef: 24 c4            BIT &c4 ; loop_counter_every_08
&25f1: 10 07            BPL &25fa                       
&25f3: c9 21            CMP #&21
&25f5: f0 03            BEQ &25fa
&25f7: ee 1f 08         INC &081f ; earthquake_triggered
&25fa: 4a               LSR
&25fb: d0 15            BNE &2612
&25fd: 20 87 25         JSR &2587 ; increment_timers                            # shudder screen
&2600: 29 01            AND #&01
&2602: 09 5a            ORA #&5a
&2604: a0 02            LDY #&02
&2606: 78               SEI
&2607: 8c 00 fe         STY &fe00 	                                        # write to video controller
&260a: 8d 01 fe         STA &fe01 	                                        # write to video controller
&260d: 58               CLI
&260e: a0 00            LDY #&00
&2610: f0 07            BEQ &2619
; no_earthquake
&2612: 2c 1e 08         BIT &081e ; endgame_value                               # are we in the endgame?
&2615: 30 0f            BMI &2626 ; no_waterfall_sound
&2617: a0 11            LDY #&11
&2619: 84 aa            STY &aa ; current_object                                # use the eighteenth slot for the waterfall
&261b: 24 c4            BIT &c4 ; loop_counter_every_08
&261d: 10 07            BPL &2626                                               # every 8 cycles,
&261f: 20 f8 13         JSR &13f8 ; play_sound2                                 # make a noise if it's close enough
#2622: 70 c2 6e a3 ; sound data
; no_waterfall_sound
&2626: a2 fe            LDX #&fe
&2728: a5 c0            LDA &c0 ; loop_counter
&262a: 29 20            AND #&20                                                # every &40 cycles, there's &20 cycles each
&262c: d0 02            BNE &2630                                               # of &fe or &02 water level movements
&262e: a2 02            LDX #&02                                                # so the water level bobs up and down
&2630: 86 a2            STX &a2 ; water_level_change
&2632: a2 03            LDX #&03
; water_level_loop
&2634: a9 18            LDA #&18
&2636: 38               SEC
&2637: fd 2e 08         SBC &082e,X ; water_level_low_by_x_range                # alter the water levels to match
&263a: bd 36 08         LDA &0836,X ; desired_water_level_by_x_range            # aiming for the desired water level
&263d: fd 32 08         SBC &0832,X ; water_level_by_x_range
&2640: 65 a2            ADC &a2 ; water_level_change
&2642: 08               PHP
&2643: a0 02            LDY #&02
&2645: 20 5e 32         JSR &325e ; keep_within_range
&2648: 7d 2e 08         ADC &082e,X ; water_level_low_by_x_range
&264b: 9d 2e 08         STA &082e,X ; water_level_low_by_x_range
&264e: 90 03            BCC &2653
&2650: fe 32 08         INC &0832,X ; water_level_by_x_range
&2653: 28               PLP
&2654: 10 03            BPL &2659
&2656: de 32 08         DEC &0832,X ; water_level_by_x_range
&2659: ca               DEX
&265a: 10 d8            BPL &2634 ; water_level_loop

&265c: a9 10            LDA #&10
&265e: 85 2d            STA &2d ; background_processing_flag
&2660: a9 07            LDA #&07                                                # consider a random square near the player
&2662: 20 43 27         JSR &2743 ; get_random_square_near_player
&2665: 20 15 17         JSR &1715 ; determine_background
&2668: c9 2d            CMP #&2d                                                # is it empty space?
&266a: d0 5c            BNE &26c8 ; no_emerging_objects
&266c: a5 c3            LDA &c3 ; loop_counter_every_10                         # if so,
&266e: 10 58            BPL &26c8 ; no_emerging_objects                         # once every &10 cycles,
&2670: ad 1e 08         LDA &081e ; endgame_value
&2673: 29 80            AND #&80
&2675: 49 80            EOR #&80                                                # objects less likely to emerge in endgame
&2677: 05 da            ORA &da ; timer_2
&2679: c5 97            CMP &97 ; square_y                                      # objects more likely to emerge deeper down
&267b: b0 4b            BCS &26c8 ; no_emerging_objects
&267d: 2c 1d 08         BIT &081d ; explosion_timer                             # is an explosion in progress?
&2680: 30 06            BMI &2688                                               
&2682: a5 db            LDA &db ; timer_3
&2684: 29 70            AND #&70
&2686: d0 40            BNE &26c8 ; no_emerging_objects                         # if not, objects less likely to emerge
&2688: a0 01            LDY #&01                                # slot 1 ?
&268a: 20 87 25         JSR &2587 ; increment_timers
&268d: c9 08            CMP #&08                                # set if >&8
&268f: 6a               ROR
&2690: 2c 1e 08         BIT &081e ; endgame_value               # or endgame
&2693: 30 06            BMI &269b
&2695: 2c aa 19         BIT &19aa ; player_east_of_76
&2698: 20 56 32         JSR &3256 ; make_positive
&269b: 0a               ASL
&269c: 90 01            BCC &269f
&269e: c8               INY
&269f: 84 bd            STY &bd ; new_object_data_pointer
&26a1: 84 be            STY &be ; new_object_type_pointer
&26a3: b9 86 09         LDA &0986,Y ; background_objects_data
&26a6: 0a               ASL
&26a7: c5 db            CMP &db ; timer_3
&26a9: 90 1d            BCC &26c8 ; no_emerging_objects
&26ab: 20 60 27         JSR &2760 ; store_stack_pointer_and_pull_in_tertiary_object 
&26ae: b0 18            BCS &26c8 ; no_emerging_objects                         # leave if we couldn't allocate an object
&26b0: 99 a3 08         STA &08a3,Y ; object_stack_y_low
&26b3: ad 91 08         LDA &0891 ; object_stack_x                              # for player
&26b6: e5 95            SBC &95 ; square_x
&26b8: 99 e6 08         STA &08e6,Y ; object_stack_vel_x                        # aim the new object at the player
&26bb: ad b4 08         LDA &08b4 ; object_stack_y                              # for player
&26be: e5 97            SBC &97 ; square_y
&26c0: 99 f6 08         STA &08f6,Y ; object_stack_vel_y
&26c3: a9 80            LDA #&80
&26c5: 99 76 09         STA &0976,Y ; object_stack_extra
; no_emerging_objects
&26c8: a5 97            LDA &97 ; square_y
&26ca: c9 4e            CMP #&4e				                # are we above y = &4e ?
&26cc: b0 18            BCS &26e6 ; no_stars
&26ce: 85 8d            STA &8d ; particle_y
&26d0: a5 95            LDA &95 ; square_x
&26d2: 85 8b            STA &8b ; particle_x
&26d4: a9 00            LDA #&00
&26d6: 85 89            STA &89 ; particle_y_low
&26d8: 85 87            STA &87 ; particle_x_low
&26da: ad b5 19         LDA &19b5 ; player_teleporting_flag                     # no stars while player teleporting
&26dd: 05 00            ORA &00 ; square_is_mapped_data                         # no stars inside the spaceships
&26df: 30 05            BMI &26e6 ; no_stars
&26e1: a0 4d            LDY #&4d                                                # &4d = stars
&26e3: 20 8c 21         JSR &218c ; add_particle		                # create star particle
; no_stars
&26e6: ac 1f 08         LDY &081f ; earthquake_triggered                       
&26e9: 88               DEY                             
&26ea: c0 c8            CPY #&c8                                                
&26ec: 6a               ROR
&26ed: 2d 1e 08         AND &081e ; endgame_value
&26f0: 05 c2            ORA &c2 ; loop_counter_every_20                         # in the endgame / earthquake,
&26f2: 10 20            BPL &2714 ; no_triax2                                   # triax is much more likely to appear
&26f4: 20 87 25         JSR &2587 ; increment_timers
&26f7: d0 1b            BNE &2714 ; no_triax2                                   # random probability for triax to appear
&26f9: ad b4 08         LDA &08b4 ; object_stack_y 		
&26fc: e9 14            SBC #&14                                                # triax doesn't appear above y = &94
&26fe: 0d 1e 08         ORA &081e ; endgame_value                               # unless we're in the end game
&2701: 10 0e            BPL &2711 ; no_triax
&2703: a9 26            LDA #&26				                # &26 = triax
&2705: 20 18 3c         JSR &3c18 ; count_objects_of_type_a_in_stack            # does triax already exist?
&2708: d0 07            BNE &2711 ; no_triax                                    # if so, don't create him again
&270a: a9 26            LDA #&26				                # &26 = triax
&270c: 20 60 1e         JSR &1e60 ; reserve_object_low_priority		        # otherwise, find a slot for him
&270f: 90 27            BCC &2738 ; setup_triax 		                # and if we find one, set him up
; no_triax
&2711: 20 4e 39         JSR &394e ; null_function		                # odd null function call?
; no_triax2
&2714: 24 c4            BIT &c4 ; loop_counter_every_08                         # every 8 cycles,
&2716: 10 2a            BPL &2742				
&2718: 20 87 25         JSR &2587 ; increment_timers		
&271b: 29 03            AND #&03				                # pick a random clawed robot
&271d: aa               TAX
&271e: bd 3f 08         LDA &083f,X ; clawed_robot_availability                 
&2721: 30 1f            BMI &2742 ; no_clawed_robots                            # has it been disturbed? if not, leave
&2723: d0 1d            BNE &2742 ; no_clawed_robots                            # is it already in use? if so, leave
&2725: fe 43 08         INC &0843,X ; clawed_robot_energy_when_last_used        # damaged robots take a while to come back
&2728: 10 18            BPL &2742 ; no_clawed_robots
&272a: 8a               TXA
&272b: 18               CLC
&272c: 69 22            ADC #&22				                # &22 - &25 = clawed robots
&272e: 20 60 1e         JSR &1e60 ; reserve_object_low_priority		        # find a slot for it
&2731: b0 0f            BCS &2742				                # leave if there aren't enough free slots
&2733: a9 01            LDA #&01
&2735: 9d 3f 08         STA &083f,X ; clawed_robot_availability                 # mark as being in use
; setup_triax
&2738: a9 fe            LDA #&fe
&273a: 99 b4 08         STA &08b4,Y ; object_stack_y                            # mark as way off screen - will teleport in
&273d: a9 c0            LDA #&c0
&273f: 99 06 09         STA &0906,Y ; object_stack_target                       # target = player | &c0
; no_clawed_robots
&2742: 60               RTS

; get_random_square_near_player
; A = diameter; returns &95, &97
&2743: 85 9d            STA &9d ; diameter
&2745: 4a               LSR
&2746: 85 9c            STA &9c ; radius
&2748: 20 87 25         JSR &2587 ; increment_timers                            # get a random number
&274b: 25 9d            AND &9d ; diameter                                      # modulus the diameter
&274d: 6d 91 08         ADC &0891 ; object_stack_x                              # add the player's x position
&2750: e5 9c            SBC &9c ; radius                                        # subtract the radius
&2752: 85 95            STA &95 ; square_x
&2754: a5 d9            LDA &d9 ; timer_1                                       # do likewise for y
&2756: 25 9d            AND &9d ; diameter
&2758: 6d b4 08         ADC &08b4 ; object_stack_y
&275b: e5 9c            SBC &9c ; radius
&275d: 85 97            STA &97 ; square_y
&275f: 60               RTS

; store_stack_pointer_and_pull_in_tertiary_object
&2760: ba               TSX
&2761: 86 26            STX &26 ; copy_of_stack_pointer
&2763: a2 06            LDX #&06
&2765: 4c 4f 3e         JMP &3e4f ; into_tertiary_pull_in

; find_a_target_and_fire_at_it
# X = bullet type
&2768: 85 9d            STA &9d ; tmp_a
&276a: a5 15            LDA &15 ; this_object_energy
&276c: 4a               LSR
&276d: 4a               LSR
&276e: 4a               LSR
&276f: 69 02            ADC #&02
&2771: c5 da            CMP &da ; timer_2
&2773: 90 14            BCC &2789                                               # use energy to determine probability of firing
&2775: 8e 80 27         STX &2780                                               # self modifying code
&2778: a5 9d            LDA &9d ;tmp_a
&277a: 20 2a 3c         JSR &3c2a ; find_nearest_object
&277d: 30 0a            BMI &2789                                               # is there something to fire at? if not, leave
&277f: a0 18            LDY #&18        # modified by &2775, actually LDY #X    # set bullet type
&2781: 20 8a 27         JSR &278a ; enemy_fire
&2784: 30 03            BMI &2789
&2786: 20 36 31         JSR &3136 ; invert_angle
&2789: 60               RTS

; enemy_fire
# Y = bullet type
# X = target 
&278a: 20 87 25         JSR &2587 ; increment_timers
&278d: 29 3f            AND #&3f
&278f: 69 b4            ADC #&b4
; in_enemy_fire
&2791: 84 a0            STY &a0 ; enemy_bullet_type
&2793: 20 55 33         JSR &3355 ; enemy_fire_velocity_calculation
&2796: 6a               ROR
&2797: 38               SEC
&2798: 30 2e            BMI &27c8
&279a: a5 43            LDA &43 ; this_object_vel_x
&279c: e5 b4            SBC &b4 ; velocity_x
&279e: 20 7f 32         JSR &327f ; prevent_overflow
&27a1: 45 37            EOR &37 ; this_object_angle
&27a3: 10 22            BPL &27c7
&27a5: 8a               TXA
&27a6: 48               PHA
&27a7: a5 dc            LDA &dc ; timer_4
&27a9: 29 03            AND #&03
&27ab: 45 b6            EOR &b6 ; velocity_y
&27ad: 85 b6            STA &b6 ; velocity_y
&27af: a5 a0            LDA &a0 ; enemy_bullet_type
&27b1: 20 b8 33         JSR &33b8 ; create_child_object		                # create enemy bullets
&27b4: 68               PLA
&27b5: b0 0e            BCS &27c5
&27b7: 9d 06 09         STA &0906,X ; object_stack_target                       # set target for bullet
&27ba: 20 87 25         JSR &2587 ; increment_timers
&27bd: 29 07            AND #&07
&27bf: 5d e6 08         EOR &08e6,X ; object_stack_vel_x                        # randomise bullet's x velocity slightly
&27c2: 9d e6 08         STA &08e6,X ; object_stack_vel_x
&27c5: a0 ff            LDY #&ff
&27c7: 18               CLC
&27c8: 60               RTS

; npc_targetting
&27c9: a9 00            LDA #&00
&27cb: 85 21            STA &21 ; npc_fed
&27cd: 86 22            STX &22 ; npc_type
&27cf: a5 06            LDA &06 ; current_object_rotator
&27d1: 29 3f            AND #&3f
&27d3: d0 3b            BNE &2810 ; no_absorb_find                              # search for targets once every &40 cycles
&27d5: bd 6b 31         LDA &316b,X ; npc_find_a
&27d8: bc 75 31         LDY &3175,X ; npc_find_y
&27db: 20 fe 3b         JSR &3bfe ; find_target
&27de: 30 07            BMI &27e7 ; no_target                                   # have we found a target?
&27e0: 26 21            ROL &21 ; npc_fed
&27e2: d0 01            BNE &27e5
&27e4: 38               SEC
&27e5: 26 21            ROL &21 ; npc_fed
; no_target
&27e7: a6 22            LDX &22 ; npc_type
&27e9: 24 11            BIT &11 ; this_object_extra
&27eb: 10 17            BPL &2804 ; no_second_find
&27ed: 70 15            BVS &2804 ; no_second_find
&27ef: a5 21            LDA &21 ; npc_fed
&27f1: f0 08            BEQ &27fb                               
&27f3: 20 11 3c         JSR &3c11 ; flag_target_as_avoid
&27f6: 20 87 25         JSR &2587 ; increment_timers
&27f9: 30 09            BMI &2804 ; no_second_find
&27fb: bd 89 31         LDA &3189,X ; npc_find_ay
&27fe: a8               TAY
&27ff: 20 fe 3b         JSR &3bfe ; find_target
&2802: a6 22            LDX &22 ; npc_type
; no_second_find
&2804: 20 87 25         JSR &2587 ; increment_timers
&2807: 30 07            BMI &2810 ; no_absorb_find
&2809: bd 7f 31         LDA &317f,X ; npc_absorb_lookup
&280c: a8               TAY
&280d: 20 fe 3b         JSR &3bfe ; find_target
; no_absorb_find
&2810: 06 21            ASL &21 ; npc_fed					# mark npc as not being fed
&2812: a6 22            LDX &22 ; npc_type
&2814: bd 7f 31         LDA &317f,X ; npc_absorb_lookup				# find out what it likes to eat
&2817: 20 e1 3b         JSR &3be1 ; absorb_object				# is it touching such an object?
&281a: d0 02            BNE &281e
&281c: e6 21            INC &21 ; npc_fed					# if so, mark it as being fed
&281e: a6 22            LDX &22 ; npc_type
&2820: bc 93 31         LDY &3193,X ; npc_bit_flags_lookup
&2823: a5 21            LDA &21 ; npc_fed
&2825: 84 9c            STY &9c ; npc_bit_flags
&2827: 20 3c 25         JSR &253c ; is_this_object_damaged
&282a: 2a               ROL
&282b: ac 1d 08         LDY &081d ; explosion_timer
&282e: c0 cf            CPY #&cf
&2830: f0 01            BEQ &2833
&2832: 18               CLC
&2833: 2a               ROL
&2834: ac 1e 08         LDY &081e ; endgame_value
&2837: c0 80            CPY #&80
&2839: 2a               ROL
&283a: a4 06            LDY &06 ; current_object_rotator
&283c: c0 ff            CPY #&ff
&283e: 2a               ROL
&283f: 25 da            AND &da ; timer_2
&2841: f0 23            BEQ &2866
&2843: a2 00            LDX #&00
&2845: a0 07            LDY #&07
&2847: 4a               LSR
&2848: 90 07            BCC &2851
&284a: ca               DEX
&284b: 24 9c            BIT &9c ; npc_bit_flags
&284d: 10 02            BPL &2851
&284f: e8               INX
&2850: e8               INX
&2851: 06 9c            ASL &9c ; npc_bit_flags
&2853: 88               DEY
&2854: d0 f1            BNE &2847
&2856: 8a               TXA
&2857: f0 0d            BEQ &2866
&2859: 29 c0            AND #&c0
&285b: 30 02            BMI &285f
&285d: a9 40            LDA #&40
&285f: 18               CLC
&2860: 65 11            ADC &11 ; this_object_extra
&2862: 70 02            BVS &2866
&2864: 85 11            STA &11 ; this_object_extra
&2866: 60               RTS

; set_object_x_y_tx_ty_to_square_x_y
&2867: a5 95            LDA &95 ; square_x
&2869: 99 91 08         STA &0891,Y ; object_stack_x
&286c: 99 16 09         STA &0916,Y ; object_stack_tx
&286f: a5 97            LDA &97 ; square_y
&2871: 99 b4 08         STA &08b4,Y ; object_stack_y
&2874: 99 36 09         STA &0936,Y ; object_stack_ty
&2877: 60               RTS

; store_object_x_y_in_stack
&2878: a5 53            LDA &53 ; this_object_x
&287a: 99 91 08         STA &0891,Y ; object_stack_x
&287d: a5 55            LDA &55 ; this_object_y
&287f: 99 b4 08         STA &08b4,Y ; object_stack_y
&2882: 60               RTS

; get_object_x_y_to_tx_ty
&2883: bd 91 08         LDA &0891,X ; object_stack_x
&2886: 85 14            STA &14 ; this_object_tx
&2888: bd b4 08         LDA &08b4,X ; object_stack_y
&288b: 85 16            STA &16 ; this_object_ty
&288d: 60               RTS

; store_object_tx_ty_to_seventeenth_stack_slot
&288e: a2 10            LDX #&10                                                # seventeenth slot is used for targetting
&2890: a5 14            LDA &14 ; this_object_tx
&2892: 9d 91 08         STA &0891,X ; object_stack_x
&2895: a5 16            LDA &16 ; this_object_ty
&2897: 9d b4 08         STA &08b4,X ; object_stack_y
&289a: a9 80            LDA #&80
&289c: 9d 80 08         STA &0880,X ; object_stack_x_low
&289f: 9d a3 08         STA &08a3,X ; object_stack_y_low
&28a2: 60               RTS

; zero_velocities
&28a3: a9 00            LDA #&00
&28a5: 85 43            STA &43 ; this_object_vel_x
&28a7: 85 45            STA &45 ; this_object_vel_y
&28a9: 60               RTS

; copy_object_values_from_old
&28aa: a5 52            LDA &52 ; this_object_y_low_old
&28ac: 85 51            STA &51 ; this_object_y_low
&28ae: a5 56            LDA &56 ; this_object_y_old
&28b0: 85 55            STA &55 ; this_object_y
&28b2: a5 50            LDA &50 ; this_object_x_low_old
&28b4: 85 4f            STA &4f ; this_object_x_low
&28b6: a5 54            LDA &54 ; this_object_x_old
&28b8: 85 53            STA &53 ; this_object_x
&28ba: 60               RTS

; zero_memory_and_loop_endlessly
&28bb: a9 00            LDA #&00
&28bd: a8               TAY
&28be: 88               DEY
&28bf: 99 08 7f         STA &7f08,Y
&28c2: c8               INY
&28c3: 99 c4 01         STA &01c4,Y     # actually STA &xxc4,Y; modified by 28c9
&28c6: c8               INY
&28c7: d0 fa            BNE &28c3
&28c9: ee c5 28         INC &28c5                                               # self modifying code
&28cc: cd c3 28         CMP &28c3                                               # zero memory &01c4 - &28c3
&28cf: d0 f2            BNE &28c3
&28d1: 6e 8e 02         ROR &028e
&28d4: 30 fe            BMI &28d4 ; endless loop

; particle_stack
#28d6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#28e6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#28f6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2906: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2916: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2926: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2936: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2946: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2956: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2966: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2976: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2986: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#2996: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#29a6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#29b6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#29c6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

#29d6: 00 ; autofire_timeout
#29d7: ff ; object_being_fired
#29d8: ff ; whistle2_played
#29d9: 00 ; object_spans_two_squares_x
#29da: ea ; (unused)
#29db: 00 ; object_spans_two_squares_y
#29dc: 0c ; collision_velocity_flags_x
#29dd: ea ; (unused)
#29de: 03 ; collision_velocity_flags_y
#29df: 0f ; support_granularity_x_or
#29e0: ea ; (unused)
#29e1: 07 ; support_granularity_y_or
#29e2: f0 ; support_granularity_x_and
#29e3: ea ; (unused)
#29e4: f8 ; support_granularity_y_and
#29e5: 00 ; object_collision_with_other_object_top_bottom
#29e6: 00 ; object_collision_with_other_object_sides
#29e7: 20 ; (unused?)
#29e8: ea ; (unused)
#29e9: 80 ; (unused?)
#29ea: ea ; (unused)
#29eb: 10 ; something_used_in_collision_x
#29ec: ea ; (unused)
#29ed: 40 ; something_used_in_collision_y

###############################################################################
#
#   Ranges
#   ======
#   0 : player and allies
#   1 : nests
#   2 : big creatures
#   3 : small creatures
#   4 : bullets and grenades
#   5 : robots and turrets
#   6 : flying enemies
#   7 : lightning, mushroom balls and ifre
#   8 : scenery
#   9 : equipment
#
###############################################################################
;       0  1  2  3  4  5  6  7  8  9
#29ee: 00 04 06 0f 12 1c 22 32 38 4a ; object_type_ranges
#29f8: 7f 3f 7f 07 3f 81 fd 3f ff 7d ; energy_by_range

; move_npc
&2a02: a5 17		LDA &17 ; object_onscreen?				# is it offscreen?
&2a04: 10 0b            BPL &2a11
&2a06: 20 87 25         JSR &2587 ; increment_timers
&2a09: d0 13            BNE &2a1e
; force_object_offscreen
&2a0b: 06 bf            ASL &bf ; this_object_offscreen
&2a0d: 38               SEC
&2a0e: 66 bf            ROR &bf ; this_object_offscreen
&2a10: 60               RTS
&2a11: a5 1b            LDA &1b ; wall_collision_top_or_bottom
&2a13: 25 11            AND &11 ; this_object_extra
&2a15: 10 f9            BPL &2a10
&2a17: 20 fa 13         JSR &13fa ; play_sound
#2a1a: 23 e3 82 12 ; sound data
&2a1e: c6 42            DEC &42 ; acceleration_y
&2a20: a2 02            LDX #&02
&2a22: b5 44            LDA &44,X
&2a24: 20 cd 3b         JSR &3bcd ; return_sign_as_01_or_ff
&2a27: 0a               ASL
&2a28: 95 43            STA &43,X
&2a2a: ca               DEX
&2a2b: ca               DEX
&2a2c: 10 f4            BPL &2a22
&2a2e: 20 aa 28         JSR &28aa ; copy_object_values_from_old

; move_object
&2a31: a2 02            LDX #&02        # in y direction first (X = 2), then x direction (X = 0)
&2a33: 20 36 2a         JSR &2a36 ; move_object_in_one_direction_with_given_velocity
&2a36: b5 43            LDA &43,X       # X = 2, &45 this_object_vel_x; X = 0, &43 this_object_vel_x
; move_object_in_one_direction_with_given_velocity
; A = velocity
; X = direction
&2a38: 10 02            BPL &2a3c
&2a3a: d6 53            DEC &53,X       # X = 2, &55 this_object_y ; X = 0, &53 this_object_x
&2a3c: 18               CLC
&2a3d: 75 4f            ADC (&4f,X)     # X = 2, &51 this_object_y_low ; X = 0, &4f this_object_x_low
&2a3f: 95 4f            STA &4f,X       # X = 2, &51 this_object_y_low ; X = 0, &4f this_object_x_low
&2a41: 90 02            BCC &2a45
&2a43: f6 53            INC &53,X       # X = 2, &55 this_object_y ; X = 0, &53 this_object_x
&2a45: ca               DEX
&2a46: ca               DEX
&2a47: 60               RTS

; calculate_object_maxes
&2a48: a2 02            LDX #&02        # in y direction first (X = 2), then x direction (X = 0)
&2a4a: b5 3a            LDA &3a,X       # X = 2, &3c this_object_height ; X = 0, &3a this_object_width
&2a4c: 18               CLC
&2a4d: 75 4f            ADC (&4f,X)     # X = 2, &51 this_object_y_low ; X = 0, &4f this_object_x_low
&2a4f: 95 47            STA &47,X       # X = 2, &49 this_object_y_max_low ; X = 0, &47 this_object_x_max_low
&2a51: 08               PHP
&2a52: b5 53            LDA &53,X       # X = 2, &55 this_object_y ; X = 0, &53 this_object_x
&2a54: 69 00            ADC #&00
&2a56: 95 48            STA &48,X       # X = 2, &4a this_object_y_max ; X = 0, &48 this_object_x_max
&2a58: 28               PLP
&2a59: 7e d9 29         ROR &29d9,X ;   # X = 2, &29db object_spans_two_squares_y; X = 0, &29d9 object_spans_two_squares_x
&2a5c: ca               DEX
&2a5d: ca               DEX
&2a5e: f0 ea            BEQ &2a4a
&2a60: 60               RTS

; leave_supporting
&2a61: 4c e8 2e         JMP &2ee8 ; do_object_wall_collisions

; determine_what_supporting
&2a64: a5 53            LDA &53 ; this_object_x
&2a66: 18               CLC
&2a67: 69 02            ADC #&02
&2a69: 8d 86 2a         STA &2a86                               	        # self modifying code
&2a6c: e9 02            SBC #&02
&2a6e: 8d 82 2a         STA &2a82                               	        # self modifying code
&2a71: a4 55            LDY &55 ; this_object_y
&2a73: 88               DEY
&2a74: 88               DEY
&2a75: 8c 8d 2a         STY &2a8d                               	        # self modifying code
&2a78: a0 ef            LDY #&ef
&2a7a: 38               SEC
; consider_next_support
&2a7b: c8               INY
&2a7c: f0 e3            BEQ &2a61 ; leave_supporting            	        # have we looked at all sixteen objects? if so, get out
&2a7e: b9 a1 07         LDA &07a1,Y     # actually &0891 (object_stack_x)
&2a81: c9 52            CMP #&52                                	        # modified by &2a6e to be CMP #(this_object_x - 2)
&2a83: 90 f6            BCC &2a7b                               	        # is the other object near us? if not, continue loop
&2a85: c9 54            CMP #&54                                	        # modified by &2a69 to be CMP #(this_object_x + 2)
&2a87: b0 f2            BCS &2a7b                               	        # is the other object near us? if not, continue loop
&2a89: b9 c4 07         LDA &07c4,Y     # actually &08b4 (object_stack_y)
&2a8c: e9 53            SBC #&53
&2a8e: c9 03            CMP #&03                                	        # modified by &2a75 to be CMP #(this_object_y - 2)
&2a90: b0 e9            BCS &2a7b                               	        # is the other object near us? if not, continue loop
&2a92: 98               TYA
&2a93: 69 10            ADC #&10
&2a95: e5 aa            SBC &aa ; current_object                	        # an object does not support itself!
&2a97: f0 e2            BEQ &2a7b ; consider_next_support
&2a99: be 80 07         LDX &0780,Y     # actually &0870 (object_stack_sprite)
&2a9c: bd 0c 5e         LDA &5e0c,X ; sprite_width_lookup
&2a9f: 85 9b            STA &9b ; supporting_object_width
&2aa1: bd 89 5e         LDA &5e89,X ; sprite_height_lookup
&2aa4: 85 9d            STA &9d ; supporting_object_height
&2aa6: b9 c4 07         LDA &07c4,Y     # actually &08b4 (object_stack_y)
&2aa9: 85 98            STA &98 ; supporting_object_xy
&2aab: b9 b3 07         LDA &07b3,Y     # actually &08a3 (object_stack_y_low)
&2aae: a2 02            LDX #&02
; consider_support_direction                                    	        # in y direction first (X = 2), then x direction (X = 0)
&2ab0: 1d df 29         ORA &29df,X	# X = 2, support_granularity_y_or; X = 0, support_granularity_x_or
&2ab3: 38               SEC
&2ab4: f5 47            SBC &47,X ; 	# X = 2, &49 this_object_y_max_low; X = 0, &47 this_object_x_max_low
&2ab6: 08               PHP
&2ab7: 3d e2 29         AND &29e2,X     # X = 2, support_granularity_y_and; X = 0, support_granularity_x_and
&2aba: 18               CLC
&2abb: fd df 29         SBC &29df,X     # X = 2, support_granularity_y_or; X = 0, support_granularity_x_or
&2abe: 95 7b            STA &7b,X	# X = 2, &7d support_delta_y_low; X = 0, &7b support_delta_x_low
&2ac0: a5 98            LDA &98 ; supporting_object_xy
&2ac2: e9 00            SBC #&00					        # is support_y > this_y_max ?
&2ac4: 28               PLP						        # if so, not touching
&2ac5: f5 48            SBC &48,X   	# X = 2, &4a this_object_y_max; X = 0, &49 this object_x_max
&2ac7: 10 b2            BPL &2a7b ; consider_next_support       	        # continue loop if not touching
&2ac9: 95 7c            STA &7c,X	# X = 2, &7e support_delta_y; X = 0, &7c support_delta_x
&2acb: b5 9b            LDA &9b,X   	# X = 2, &9d supporting_object_height; X = 0, &9b supporting_object_width
&2acd: 1d df 29         ORA &29df,X	# X = 2, support_granularity_y_or; X = 0, support_granularity_x_or
&2ad0: 38               SEC
&2ad1: 75 3a            ADC (&3a,X) 	# X = 2, &3c this_object_height; X = 0, &3a this_object_width
&2ad3: 08               PHP
&2ad4: 1d df 29         ORA &29df,X     # X = 2, support_granularity_y_or; X = 0, support_granularity_x_or
&2ad7: 38               SEC
&2ad8: 75 7b            ADC (&7b,X)	# X = 2, &7d support_delta_y_low; X = 0, &7b support_delta_x_low
&2ada: 95 7f            STA &7f,X	# X = 2, &81 support_overlap_y_low; X = 0, &7f support_overlap_x_low
&2adc: b5 7c            LDA &7c,X	# X = 2, &7e support_delta_y; X = 0, &7c support_delta_x
&2ade: 69 00            ADC #&00					        # is (this_y_max - support_y) > (this_size + support_size)?
&2ae0: 28               PLP						        # if so, not touching
&2ae1: 69 00            ADC #&00
&2ae3: 30 96            BMI &2a7b ; consider_next_support		        # continue loop if not touching
&2ae5: 95 80            STA &80,X	# X = 2, &82 support_overlap_y; X = 0, &80 support_overlap_x
&2ae7: 15 7f            ORA &7f,X 	# X = 2, &81 support_overlap_y_low; X = 0, &7f support_overlap_x_low
&2ae9: f0 90            BEQ &2a7b  ; consider_next_support      	# continue loop if not overlapping
&2aeb: b9 a1 07         LDA &07a1,Y     # actually &0891 (object_stack_x)
&2aee: 85 98            STA &98 ; supporting_object_xy
&2af0: b9 90 07         LDA &0790,Y     # actually &0880 (object_stack_x_low)
&2af3: ca               DEX	        					# now do it again for the x direction
&2af4: ca               DEX
&2af5: f0 b9            BEQ &2ab0 ; consider_support_direction		
&2af7: a6 aa            LDX &aa ; current_object			        # we've found two objects which overlap
&2af9: 98               TYA						        # X = current_object
&2afa: 18               CLC
&2afb: 69 10            ADC #&10					        # A = supporting_object
&2afd: d0 04            BNE &2b03 					        # is the player being supported
&2aff: e4 dd            CPX &dd ; object_held				        # by the object they're holding?
&2b01: f0 2c            BEQ &2b2f					        # if so, ignore this and continue loop
&2b03: 2c b3 19         BIT &19b3 ; can_player_support_held_object
&2b06: 30 08            BMI &2b10					        # if set, skip this next check
&2b08: e0 00            CPX #&00					
&2b0a: d0 04            BNE &2b10					        # is the player supporting
&2b0c: c5 dd            CMP &dd ; object_held				        # the object they're holding?
&2b0e: f0 1f            BEQ &2b2f					        # if so, ignore this and continue loop
&2b10: aa               TAX
&2b11: 20 87 25         JSR &2587 ; increment_timers
&2b14: 05 3b            ORA &3b ; this_object_supporting		        # only note the support half the time
&2b16: 10 02            BPL &2b1a
&2b18: 86 3b            STX &3b ; this_object_supporting		        # note the supported object
&2b1a: 20 87 25         JSR &2587 ; increment_timers
&2b1d: 19 56 08		ORA &0856,Y	# actually &0946 (object_stack_supporting)
&2b20: 10 05            BPL &2b27					        # only note the support in the stack half the time
&2b22: a5 aa            LDA &aa ; current_object
&2b24: 99 56 08         STA &0856,Y # actually &0946 (object_stack_supporting) # note the support in the stack
&2b27: be 70 07         LDX &0770,Y # actually &0860 (object_stack_type)
&2b2a: bd 54 03         LDA &0354,X ; object_gravity_flags      
&2b2d: 10 03            BPL &2b32                               	        # is the other object intangible?
&2b2f: 4c 7b 2a         JMP &2a7b ; consider_next_support                       # if so, continue loop
&2b32: 29 07            AND #&07					        # otherwise, consider it
&2b34: 85 90            STA &90 ; other_object_weight
&2b36: a6 41            LDX &41 ; this_object_type              
&2b38: bd 54 03         LDA &0354,X ; object_gravity_flags      	        # is this object intangible?
&2b3b: 30 f2            BMI &2b2f                               	        # if so, continue loop
&2b3d: 29 07            AND #&07                                	        # this object's weight
&2b3f: 38               SEC
&2b40: e5 90            SBC &90 ; other_object_weight			        # consider the difference in weights
&2b42: 66 9e            ROR &9e ; support_weight_direction
&2b44: 20 4c 32         JSR &324c ; make_negative
&2b47: 85 90            STA &90 ; support_weight_delta
&2b49: 84 ab            STY &ab ; other_object_minus_10
&2b4b: a2 06            LDX #&06					        # in y direction first (X = 6), then x direction (X = 4)
&2b4d: a9 ff            LDA #&ff
&2b4f: 85 9c            STA &9c ; biggest_overlap
&2b51: b5 7c            LDA &7c,X	# X = 6, &82 support_overlap_y; X = 4, &80 support_overlap_x
&2b53: 08               PHP
&2b54: 4a               LSR						        # take lowest bit of support_overlap_xy
&2b55: b5 7b            LDA &7b,X	# X = 6, &81 support_overlap_y_low; X = 4, &7f support_overlap_x_low
&2b57: 6a               ROR						        # and seven highest bits of support_overlap_xy_low
&2b58: 28               PLP						
&2b59: 20 56 32         JSR &3256 ; make_positive
&2b5c: c5 9c            CMP &9c ; biggest_overlap			
&2b5e: b0 04            BCS &2b64 ; no_bigger				        # is this bigger than biggest_overlap?
&2b60: 85 9c            STA &9c ; biggest_overlap			        # if so, store it
&2b62: 8a               TXA
&2b63: a8               TAY						        # and make a note of which dimension in Y
; no_bigger
&2b64: ca               DEX
&2b65: ca               DEX
&2b66: 10 e9            BPL &2b51					        # now do it again for the x direction (X = 4)
&2b68: 98               TYA						        # Y = 4 (x direction) or Y = 6 (y direction)
&2b69: 29 02            AND #&02
&2b6b: aa               TAX						        # X = 0 (x direction) or X = 2 (y direction)
&2b6c: bd dc 29         LDA &29dc,X ; collision_velocity_flags_xy	        # &0c (x direction) or &03 (y direction)
&2b6f: 85 9f            STA &9f ; collision_velocity_flags
&2b71: b9 e7 29         LDA &29e7,Y					        # &10 (x direction) or &40 (y direction)
&2b74: 48               PHA
&2b75: 29 c0            AND #&c0
&2b77: 8d e5 29         STA &29e5 ; object_collision_with_other_object_top_bottom
&2b7a: 68               PLA
&2b7b: 0a               ASL
&2b7c: 0a               ASL
&2b7d: 8d e6 29         STA &29e6 ; object_collision_with_other_object_sides
&2b80: b9 7c 00         LDA &007c,Y	# Y = 4, &80 support_overlap_x; Y = 6, &82 support_overlap_y
&2b83: 08               PHP
&2b84: 20 cd 3b         JSR &3bcd ; return_sign_as_01_or_ff
&2b87: 0a               ASL
&2b88: 18               CLC						        # alter velocity to discourage overlap
&2b89: 75 43            ADC (&43,X)	# X = 0, &43 this_object_vel_x; X = 2, &45 this_object_vel_y
&2b8b: 95 43            STA &43,X	# X = 0, &43 this_object_vel_x; X = 2, &45 this_object_vel_y
&2b8d: b9 7b 00         LDA &007b,Y 	# Y = 4, &7f support_overlap_x_low; Y = 6, &81 support_overlap_y_low
&2b90: 28               PLP
&2b91: 20 38 2a         JSR &2a38 ; move_object_in_one_direction_with_given_velocity # move objects to reflect collision
&2b94: 20 48 2a         JSR &2a48 ; calculate_object_maxes
&2b97: a4 ab            LDY &ab ; other_object_minus_10
&2b99: a6 43            LDX &43 ; this_object_vel_x
&2b9b: b9 f6 07         LDA &07f6,Y ; # actually &08e6 (object_stack_vel_x)
&2b9e: 20 b6 2b         JSR &2bb6 ; alter_velocity_in_collision
&2ba1: 86 43            STX &43 ; this_object_vel_x
&2ba3: 99 f6 07         STA &07f6,Y ; # actually &08e6 (object_stack_vel_x)
&2ba6: a6 45            LDX &45 ; this_object_vel_y
&2ba8: b9 06 08         LDA &0806,Y ; # actually &08f6 (object_stack_vel_y)
&2bab: 20 b6 2b         JSR &2bb6 ; alter_velocity_in_collision
&2bae: 86 45            STX &45 ; this_object_vel_y
&2bb0: 99 06 08         STA &0806,Y ; # actually &08f6 (object_stack_vel_y)
&2bb3: 4c 7b 2a         JMP &2a7b ; consider_next_support
; alter_velocity_in_collision
&2bb6: 20 ee 2b         JSR &2bee ; do_momentum_exchange
&2bb9: 20 c6 2b         JSR &2bc6 ; process_collision_velocities
&2bbc: a2 01            LDX #&01
&2bbe: 20 c6 2b         JSR &2bc6 ; process_collision_velocities
&2bc1: a5 a1            LDA &a1; collision_velocity_other
&2bc3: a6 a0            LDX &a0; collision_velocity_this
&2bc5: 60               RTS
; process_collision_velocities
&2bc6: b5 a2            LDA &a2,X 	# X = 0, &a2 collision_velocity_out_this; X = 2, &a3 collision_velocity_out_other
&2bc8: c9 80            CMP #&80
&2bca: 6a               ROR
&2bcb: 46 9f            LSR &9f ; collision_velocity_flags	                # &0c (x direction) or &03 (y direction)
&2bcd: b0 05            BCS &2bd4				                # only add if it's the right direction
&2bcf: 75 a2            ADC (&a2,X) 	# X = 0, &a2 collision_velocity_out_this; X = 2, &a3 collision_velocity_out_other
&2bd1: 20 7f 32         JSR &327f ; prevent_overflow
&2bd4: 24 9e            BIT &9e ; support_weight_direction
&2bd6: 30 08            BMI &2be0
&2bd8: 20 4c 32         JSR &324c ; make_negative
&2bdb: ca               DEX
&2bdc: f0 02            BEQ &2be0
&2bde: a2 01            LDX #&01
&2be0: 48               PHA
&2be1: 20 e5 2b         JSR &2be5
&2be4: 68               PLA
&2be5: 18               CLC
&2be6: 75 a0            ADC (&a0,X) 	# X = 0, &a0 collision_velocity_this; X = 2, &a1 collision_velocity_other
&2be8: 20 7f 32         JSR &327f ; prevent_overflow
&2beb: 95 a0            STA &a0,X	# X = 0, &a0 collision_velocity_this; X = 2, &a1 collision_velocity_other
&2bed: 60               RTS
; do_momentum_exchange
&2bee: 85 a1            STA &a1 ; collision_velocity_other
&2bf0: 86 a0            STX &a0 ; collision_velocity_this
&2bf2: 38               SEC
&2bf3: e5 a0            SBC &a0 ; collision_velocity_other
&2bf5: c9 80            CMP #&80
&2bf7: 6a               ROR
&2bf8: 50 02            BVC &2bfc
&2bfa: 49 80            EOR #&80
&2bfc: 85 a3            STA &a3 ; collision_velocity_delta
&2bfe: a6 90            LDX &90 ; support_weight_delta
&2c00: d0 01            BNE &2c03
&2c02: e8               INX
&2c03: c9 80            CMP #&80
&2c05: 6a               ROR					                # halve the velocity for each support_weight_delta
&2c06: ca               DEX
&2c07: d0 fa            BNE &2c03
&2c09: c9 80            CMP #&80
&2c0b: 69 00            ADC #&00
&2c0d: 85 a2            STA &a2 ; collision_velocity_out_this
&2c0f: 38               SEC
&2c10: e5 a3            SBC &a3 ; collision_velocity_out_other
&2c12: 85 a3            STA &a3 ; collision_velocity_out_other
&2c14: 60               RTS

; scroll_offset_deltas
#2c15: ff 01 ff 01

; scroll_offset_limits
#2c19: fe ; minimum_scroll_x_offset
#2c1a: 02 ; maximum_scroll_x_offset
#2c1b: fc ; minimum_scroll_y_offset
#2c1c: 04 ; maximum_scroll_y_offset

; scroll_viewpoint
&2c1d: 8a               TXA
&2c1e: 38               SEC
&2c1f: e9 0f            SBC #&0f
&2c21: aa               TAX
&2c22: 29 02            AND #&02
&2c24: a8               TAY
&2c25: b9 c8 14         LDA &14c8,Y ; scroll_offset_x                           # consider the current scroll offset
&2c28: dd 19 2c         CMP &2c19,X ; scroll_offset_limits                      # is it already at its limit?
&2c2b: f0 3c            BEQ &2c69                                               # if so, leave
&2c2d: 18               CLC
&2c2e: 7d 15 2c         ADC &2c15,X ; scroll_offset_deltas                      # change the offset accordingly
&2c31: 99 c8 14         STA &14c8,Y ; scroll_offset_x
&2c34: 20 fa 13         JSR &13fa ; play_sound
#2c37: 3d 04 11 d4 ; sound data
&2c3b: 60               RTS

; store_teleport
&2c3c: a5 15            LDA &15 ; this_object_energy	
&2c3e: c9 08            CMP #&08			                        # have we got enough energy to teleport?
&2c40: 90 27            BCC &2c69                                               # if not, leave
&2c42: ac 22 08         LDY &0822 ; teleports_used
&2c45: c0 04            CPY #&04
&2c47: b0 01            BCS &2c4a
&2c49: c8               INY                                                     # increase the number of stored positions
&2c4a: 8c 22 08         STY &0822 ; teleports_used                              # to a maximum of 4
&2c4d: 20 88 22         JSR &2288 ; get_object_centre
&2c50: ac 21 08         LDY &0821 ; teleport_last                               # A = this_object_x_centre
&2c53: 99 23 08         STA &0823,Y ; teleports_x
&2c56: a5 8d            LDA &8d ; this_object_y_centre                          
&2c58: 99 28 08         STA &0828,Y ; teleports_y                               # store teleport position
&2c5b: 20 9d 14         JSR &149d ; play_middle_beep
&2c5e: ee 21 08         INC &0821 ; teleport_last
; fix_teleport_last
&2c61: ad 21 08         LDA &0821 ; teleport_last
&2c64: 29 03            AND #&03
&2c66: 8d 21 08         STA &0821 ; teleport_last
&2c69: 60               RTS

; move_right
&2c6a: e6 40            INC &40 ; acceleration_x
&2c6c: 60               RTS

; move_left
&2c6d: c6 40            DEC &40 ; acceleration_x
&2c6f: 60               RTS

; move_down
&2c70: e6 42            INC &42 ; acceleration_y
&2c72: 60               RTS

; move_up
&2c73: c6 42            DEC &42 ; acceleration_y
&2c75: 2c 8a 35         BIT &358a ; player_can_move                             # can the player move?
&2c78: 10 1e            BPL &2c98                                               # if not, leave
; or_extra_with_0f                       
&2c7a: a5 11            LDA &11 ; this_object_extra
&2c7c: 09 0f            ORA #&0f
&2c7e: 85 11            STA &11 ; this_object_extra
&2c80: 60               RTS

; use_booster
&2c81: ad 8a 35         LDA &358a ; player_can_move                             # is the player able to move?
&2c84: 2d 0e 08         AND &080e ; booster_collected                           # if so, have we got the booster?
&2c87: 10 0f            BPL &2c98                                               # if not, leave
&2c89: a5 42            LDA &42 ; acceleration_y
&2c8b: 30 07            BMI &2c94 ; double_acceleration                         
&2c8d: a5 40            LDA &40 ; acceleration_x
&2c8f: f0 03            BEQ &2c94 ; double_acceleration
&2c91: 20 7a 2c         JSR &2c7a ; or_extra_with_0f     
; double_acceleration
&2c94: 06 40            ASL &40 ; acceleration_x                                # double the player's acceleration
&2c96: 06 42            ASL &42 ; acceleration_y
&2c98: 60               RTS

; play_whistle_2 - activate
&2c99: 2c 17 08         BIT &0817 ; whistle2_collected                          # have we got the whistle?
&2c9c: 10 fa            BPL &2c98                                               # if not, leave
; whistle_sound
&2c9e: 20 fa 13         JSR &13fa ; play_sound                                  # sound a note
#2ca1: b0 24 b6 e2 ; sound data
&2ca5: a5 aa            LDA &aa ; current_object
&2ca7: 8d d8 29         STA &29d8 ; whistle2_played                             # mark the whistle as being played
&2caa: 10 08            BPL &2cb4 ; play_whistle_sound                          

; play_whistle_1 - deactivate
&2cac: 2c 16 08         BIT &0816 ; whistle1_collected		                # have we got the whistle?
&2caf: 10 e7            BPL &2c98				                # if not, leave
&2cb1: 38               SEC
&2cb2: 66 27            ROR &27 ; whistle1_played                               # mark the whistle as being played
; play_whistle_sound
&2cb4: 20 fa 13         JSR &13fa ; play_sound                                  # sound a note
#2cb7: b0 24 b6 b3 ; sound data
&2cbb: 60               RTS

; get_water_level_for_x
&2cbc: a2 04            LDX #&04
&2cbe: ca               DEX
&2cbf: dd d2 14         CMP &14d2,X ; x_ranges
&2cc2: 90 fa            BCC &2cbe
&2cc4: bd 2e 08         LDA &082e,X ; water_level_low_by_x_range                # the water level depends on where we are
&2cc7: 8d d0 14         STA &14d0 ; water_level_low
&2cca: 18               CLC
&2ccb: ed 2f 08         SBC &082f
&2cce: bd 32 08         LDA &0832,X ; water_level_by_x_range
&2cd1: 8d d1 14         STA &14d1 ; water_level
&2cd4: ed 33 08         SBC &0833 ; water_level_by_x_range_range1               # unless range 1 (the endgame water level)
&2cd7: a2 01            LDX #&01                                                # is above, in which case we use that
&2cd9: b0 e9            BCS &2cc4
&2cdb: 60               RTS

# bullet types
#2cdc: 00 nothing
#2cdd: 18 pistol bullet
#2cde: 13 icer bullet
#2cdf: fb suit discharge
#2ce0: 19 plasma
#2ce1: 00 nothing

; change_to_weapon
&2ce2: ca               DEX
&2ce3: 2c 91 12         BIT &1291 ; shift_held_duration	                        # is SHIFT pressed?
&2ce6: 30 1a            BMI &2d02 ; transfer_energy	                        # if so, transfer energy
&2ce8: 8a               TXA
&2ce9: f0 09            BEQ &2cf4			                        # no need to test if the jetpack is present
&2ceb: c9 06            CMP #&06
&2ced: b0 36            BCS &2d25			                        # leave if bad weapon (X >= 6)
&2cef: bd 0e 08         LDA &080e,X; weapon_collected	                        # have we got the weapon?
&2cf2: 10 32            BPL &2d26			                        # if not, then leave
&2cf4: 8e 4d 08         STX &084d ; current_weapon
&2cf7: bd 54 08         LDA &0854,X ; weapon_energy_h	                        # get energy for weapon
&2cfa: 4a               LSR				                        # divide by 8
&2cfb: 4a               LSR
&2cfc: 4a               LSR
&2cfd: 85 25            STA &25 ; bells_to_sound
&2cff: 4c a5 14         JMP &14a5 ; play_high_beep                              # sound bells to reflect energy levels

; transfer_energy
&2d02: 8a               TXA                                                     # X = weapon to take from
&2d03: f0 09            BEQ &2d0e                                               # we always have the jetpack
&2d05: e0 06            CPX #&06                                
&2d07: b0 1d            BCS &2d26                                               # if it's a bad weapon choice, leave
&2d09: bd 0e 08         LDA &080e,X; weapon_collected	        
&2d0c: 10 18            BPL &2d26			                        # if we've not got the weapon, leave
&2d0e: 20 27 2d         JSR &2d27 ; reduce_weapon_energy_high
&2d11: 90 13            BCC &2d26                                               # if it doesn't have enough energy, leave
&2d13: ae 4d 08         LDX &084d ; current_weapon
&2d16: bd 54 08         LDA &0854,X ; weapon_energy_h
&2d19: 18               CLC
&2d1a: 69 08            ADC #&08			                        # increase current weapon energy
&2d1c: b0 03            BCS &2d21
&2d1e: 9d 54 08         STA &0854,X ; weapon_energy_h
&2d21: a9 01            LDA #&01
&2d23: 85 25            STA &25 ; bells_to_sound
&2d25: 60               RTS
&2d26: 60               RTS

; reduce_weapon_energy_high
&2d27: bd 54 08         LDA &0854,X ; weapon_energy_h
&2d2a: 38               SEC
&2d2b: e9 08            SBC #&08
&2d2d: 90 03            BCC &2d32			                        # have we got energy in the weapon?
&2d2f: 9d 54 08         STA &0854,X ; weapon_energy_h
&2d32: 60               RTS

; fire_weapon
&2d33: 20 0f 33         JSR &330f ; setup_bullet_velocities
&2d36: a5 dd            LDA &dd ; object_held
&2d38: 8d d7 29         STA &29d7 ; object_being_fired
&2d3b: 10 54            BPL &2d91			                        # are we carrying something? if so, leave
&2d3d: a9 05            LDA #&05
&2d3f: 8d d6 29         STA &29d6 ; autofire_timeout                            # if we hold fire down, fire again after 5 cycles
&2d42: ae 4d 08         LDX &084d ; current_weapon
&2d45: 20 92 2d         JSR &2d92 ; make_firing_erratic_at_low_energy
&2d48: 90 47            BCC &2d91                                               # carry clear if weapon doesn't work; leave
&2d4a: bd dc 2c         LDA &2cdc,X 			                        # find the bullet type for this weapon
&2d4d: f0 42            BEQ &2d91			                        # if there isn't one, leave
&2d4f: 85 36            STA &36 ; player_bullet
&2d51: 30 23            BMI &2d76 ; reduce_weapon_energy	                # the discharge device has no bullets
&2d53: 20 b8 33         JSR &33b8 ; create_child_object	                        # create the bullet
&2d56: b0 39            BCS &2d91			                        # if we couldn't, leave
&2d58: ae 4d 08         LDX &084d ; current_weapon
&2d5b: ca               DEX
&2d5c: f0 11            BEQ &2d6f ; fire_pistol		                        # is it the pistol?
&2d5e: ca               DEX
&2d5f: f0 05            BEQ &2d66 ; fire_icer		                        # is it the icer?
&2d61: 20 ad 14         JSR &14ad ; play_low_beep	                        # sound for plasma
&2d64: b0 10            BCS &2d76 ; reduce_weapon_energy
; fire_icer
&2d66: 20 fa 13         JSR &13fa ; play_sound		                        # sound for icer
#2d69: 3d 04 2d d3 ; sound data
&2d6d: b0 07            BCS &2d76 ; reduce_weapon_energy
; fire_pistol
&2d6f: 20 fa 13         JSR &13fa ; play_sound		                        # sound for pistol
#2d72: 3d 04 3d 04 ; sound data
; reduce_weapon_energy
&2d76: ae 4d 08         LDX &084d ; current_weapon	                        # reduce energy in weapon by energy_per_shot
; reduce_weapon_energy_for_x
&2d79: bd 4e 08         LDA &084e,X ; weapon_energy
&2d7c: fd 5a 08         SBC &085a,X ; energy_per_shot
&2d7f: 9d 4e 08         STA &084e,X ; weapon_energy
&2d82: bd 54 08         LDA &0854,X ; weapon_energy_h
&2d85: e9 00            SBC #&00
&2d87: b0 05            BCS &2d8e
&2d89: a9 00            LDA #&00
&2d8b: 9d 4e 08         STA &084e,X ; weapon_energy
&2d8e: 9d 54 08         STA &0854,X ; weapon_energy_h
&2d91: 60               RTS

; make_firing_erratic_at_low_energy
&2d92: bd 54 08         LDA &0854,X ; weapon_energy_h
&2d95: c9 04            CMP #&04                                                # does the weapon have &400 of energy?
&2d97: b0 09            BCS &2da2                                               # if so, leave
&2d99: ca               DEX
&2d9a: e0 ff            CPX #&ff                                                # jetpack is much more likely to work
&2d9c: e8               INX
&2d9d: 6a               ROR
&2d9e: 6a               ROR
&2d9f: 6a               ROR
&2da0: c5 da            CMP &da ; timer_2                                       # random probability of it not working
&2da2: 60               RTS                                                     # carry clear = weapon failed

; lookup_and_store_object_energy
&2da3: 20 b0 2d         JSR &2db0 ; convert_object_to_range_a
&2da6: bd f8 29         LDA &29f8,X ; energy_by_range 
&2da9: 99 26 09         STA &0926,Y ; object_stack_energy
&2dac: 60               RTS

; convert_object_to_range
&2dad: b9 60 08         LDA &0860,Y ; object_stack_type
; convert_object_to_range_a
&2db0: a2 0a            LDX #&0a
&2db2: ca               DEX
&2db3: dd ee 29         CMP &29ee,X ; object_type_ranges
&2db6: 90 fa            BCC &2db2
&2db8: 60               RTS

     ;  0  1  2  3  4  5  6  7  8  9
#29ee: 00 04 06 0f 12 22 32 38 4a 7f; object_type_ranges

; sound_data_big_lookup_table
#2db9: 88 03 10 03 f0 80 03 c0 01 04 05 06 82 0c fe 03
#2dc9: 03 80 01 f9 02 01 02 ff 08 f0 08 f8 01 fb 87 03
#2dd9: a1 03 81 80 83 02 a3 02 81 80 3e 00 01 06 0a 0c
#2de9: 0a 00 78 fe 0f 10 0f f4 f8 04 02 05 fe 80 08 f0
#2df9: 0a f8 0c fc 92 03 02 03 01 03 00 03 ff 03 fe 80
#2e09: 03 03 03 01 03 00 0c ff 04 20 05 10 05 08 04 e0
#2e19: 05 f0 05 f8 e1 01 f8 08 01 e1 01 1a 0d fe 80 01
#2e29: 18 64 00 88 02 00 01 40 02 00 01 bc 90 03 00 01
#2e39: 0c 03 00 01 f4 80 10 00 01 2f 10 00 01 f9 10 00
#2e49: 01 f1 83 10 f0 87 04 20 02 fd 02 c0 80 0b 14 83
#2e59: 03 f0 03 10 80 03 bc 07 06 82 02 fe 04 02 80 11
#2e69: ff 0b 14 01 02 02 83 0a 03 04 09 88 01 0b 01 e0
#2e79: 01 15 ac 01 14 01 ec 80 10 ff 14 f8 28 02 01 00
; &2e88 = chatter_pitch

&2e89: ff ; can_we_scroll_screen

; consider_side_collisions
&2e8a: a9 00            LDA #&00
&2e8c: 85 a2            STA &a2 
&2e8e: 85 a3            STA &a3
&2e90: b1 7c            LDA (&7c),Y ; wall_y_start_lookup_pointer               # Y = x_low / 32
&2e92: 18               CLC
&2e93: 65 7e            ADC &7e ; wall_y_start_base
&2e95: 90 02            BCC &2e99
&2e97: a9 ff            LDA #&ff                                        
&2e99: 38               SEC
&2e9a: e5 84            SBC &84 ; this_object_y_low_bumped                      # start of wall - y_low
&2e9c: 90 08            BCC &2ea6                                               # b if object start inside wall
&2e9e: c5 3c            CMP &3c ; this_object_height
&2ea0: 90 02            BCC &2ea4                                               # b if object end inside wall
&2ea2: a5 3c            LDA &3c ; this_object_height
&2ea4: 85 a2            STA &a2                                                 # &a2 = height untouched by wall
&2ea6: a5 3c            LDA &3c ; this_object_height
&2ea8: 2c db 29         BIT &29db ; object_spans_two_squares_y                  # does the object cross a y square boundary?
&2eab: 10 21            BPL &2ece ; no_second_square                            # if so, consider the second square
&2ead: b1 80            LDA (&80),Y ; wall_y_start_lookup_pointer_4
&2eaf: 18               CLC
&2eb0: 65 82            ADC &82 ; wall_y_start_base_4
&2eb2: 90 02            BCC &2eb6
&2eb4: a9 ff            LDA #&ff
&2eb6: c5 85            CMP &85 ; this_object_y_max_low_bumped
&2eb8: 90 02            BCC &2ebc
&2eba: a5 85            LDA &85 ; this_object_y_max_low_bumped
&2ebc: 85 a3            STA &a3
&2ebe: 24 83            BIT &83 ; wall_sprite_4
&2ec0: 30 07            BMI &2ec9
&2ec2: a5 85            LDA &85 ; this_object_y_max_low_bumped
&2ec4: 38               SEC
&2ec5: e5 a3            SBC &a3
&2ec7: 85 a3            STA &a3
&2ec9: a9 00            LDA #&00
&2ecb: 38               SEC
&2ecc: e5 84            SBC &84 ; this_object_y_low_bumped
; no_second_square
&2ece: 24 7f            BIT &7f ; wall_sprite
&2ed0: 30 05            BMI &2ed7
&2ed2: 38               SEC
&2ed3: e5 a2            SBC &a2
&2ed5: 85 a2            STA &a2 # invert things if needed
&2ed7: a5 a2            LDA &a2
&2ed9: 18               CLC
&2eda: 65 a3            ADC &a3 # add results for both squares
&2edc: 69 06            ADC #&06
&2ede: 6a               ROR
&2edf: 4a               LSR     # div 4, rounding up
&2ee0: 29 fe            AND #&fe
&2ee2: 49 ff            EOR #&ff # invert sign
&2ee4: 18               CLC
&2ee5: 69 01            ADC #&01
&2ee7: 60               RTS

; do_object_wall_collisions
&2ee8: a9 20            LDA #&20
&2eea: 85 2d            STA &2d ; background_processing_flag
&2eec: 46 17            LSR &17 ; object_onscreen?
&2eee: a5 49            LDA &49 ; this_object_y_max_low                         # Calculate how much of the object is underwater
&2ef0: 38               SEC
&2ef1: ed d0 14         SBC &14d0 ; water_level_low
&2ef4: aa               TAX
&2ef5: a5 4a            LDA &4a ; this_object_y_max
&2ef7: ed d1 14         SBC &14d1 ; water_level
&2efa: f0 05            BEQ &2f01
&2efc: a2 00            LDX #&00
&2efe: 90 01            BCC &2f01
&2f00: ca               DEX
&2f01: 86 20            STX &20 ; this_object_water_level                       # and store in this_object_water_level

&2f03: a5 53            LDA &53 ; this_object_x
&2f05: 85 95            STA &95 ; square_x
&2f07: a5 55            LDA &55 ; this_object_y
&2f09: 85 97            STA &97 ; square_y
&2f0b: a2 00            LDX #&00
&2f0d: 86 01            STX &01
&2f0f: 20 53 24         JSR &2453 ; get_wall_start_7c_7f                        # leaves with a = #&01
&2f12: 85 81            STA &81
&2f14: 06 01            ASL &01
&2f16: 90 01            BCC &2f19
&2f18: ca               DEX
&2f19: 2c db 29         BIT &29db ; object_spans_two_squares_y                  # does the object span a y square boundary?
&2f1c: 10 0f            BPL &2f2d
&2f1e: e6 97            INC &97 ; square_y
&2f20: 20 50 24         JSR &2450 ; get_wall_start_80_83
&2f23: 06 01            ASL &01
&2f25: 90 12            BCC &2f39
&2f27: 8a               TXA
&2f28: 05 49            ORA &49 ; this_object_y_max_low
&2f2a: aa               TAX
&2f2b: b0 0c            BCS &2f39
&2f2d: a5 7e            LDA &7e ; wall_y_start_base
&2f2f: 85 82            STA &82 ; wall_y_start_base_4
&2f31: a5 7c            LDA &7c ; wall_y_start_lookup_pointer
&2f33: 85 80            STA &80 ; wall_y_start_lookup_pointer_4
&2f35: a5 7f            LDA &7f ; wall_sprite
&2f37: 85 83            STA &83 ; wall_sprite_4
&2f39: e4 20            CPX &20 ; this_object_water_level
&2f3b: b0 02            BCS &2f3f
&2f3d: a6 20            LDX &20 ; this_object_water_level
&2f3f: 86 8f            STX &8f ; screen_address
&2f41: a4 38            LDY &38 ; this_object_weight
&2f43: d0 01            BNE &2f46
&2f45: c8               INY
&2f46: a5 3c            LDA &3c ; this_object_height
&2f48: 4a               LSR
&2f49: 4a               LSR
&2f4a: 85 9a            STA &9a
&2f4c: a2 04            LDX #&04
&2f4e: a5 8f            LDA &8f ; screen_address
&2f50: d0 01            BNE &2f53
&2f52: 38               SEC
&2f53: 66 1f            ROR &1f ; underwater
&2f55: 30 35            BMI &2f8c ; not_underwater
&2f57: e5 9a            SBC &9a
&2f59: 90 0e            BCC &2f69
&2f5b: 88               DEY
&2f5c: 30 04            BMI &2f62
&2f5e: d0 04            BNE &2f64
&2f60: c6 45            DEC &45 ; this_object_vel_y
&2f62: c6 45            DEC &45 ; this_object_vel_y
&2f64: ca               DEX
&2f65: d0 f0            BNE &2f57
&2f67: f0 1c            BEQ &2f85
&2f69: a5 45            LDA &45 ; this_object_vel_y
&2f6b: 30 18            BMI &2f85
&2f6d: a9 c0            LDA #&c0
&2f6f: 85 b5            STA &b5 ; angle
&2f71: 20 88 22         JSR &2288 ; get_object_centre
&2f74: a5 49            LDA &49 ; this_object_y_max_low
&2f76: e5 8f            SBC &8f ; screen_address
&2f78: 85 89            STA &89 ; particle_y_low
&2f7a: a5 4a            LDA &4a ; this_object_y_max
&2f7c: e9 00            SBC #&00
&2f7e: 85 8d            STA &8d ; particle_y
&2f80: a0 63            LDY #&63                                                # &63 = water splash particles
&2f82: 20 8c 21         JSR &218c ; add_particle                                # water splash
&2f85: 24 c5            BIT &c5 ; loop_counter_every_04
&2f87: 10 03            BPL &2f8c
&2f89: 20 22 32         JSR &3222 ; dampen_this_object_vel_xy
; not_underwater
&2f8c: a5 51            LDA &51 ; this_object_y_low
&2f8e: 29 f8            AND #&f8
&2f90: 09 04            ORA #&04
&2f92: 85 84            STA &84 ; this_object_y_low_bumped                      # calculate y_low_bumped
&2f94: a5 49            LDA &49 ; this_object_y_max_low
&2f96: 29 f8            AND #&f8
&2f98: 09 04            ORA #&04
&2f9a: 85 85            STA &85 ; this_object_y_max_low_bumped                  # and y_max_low_bumped
&2f9c: a5 4f            LDA &4f ; this_object_x_low
&2f9e: 4a               LSR
&2f9f: 4a               LSR
&2fa0: 4a               LSR
&2fa1: 4a               LSR
&2fa2: 4a               LSR
&2fa3: a8               TAY
&2fa4: 20 8a 2e         JSR &2e8a ; consider_side_collisions                    # get result for left hand side
&2fa7: 85 77            STA &77 ; wall_collision_count_left
&2fa9: a9 00            LDA #&00
&2fab: 85 78            STA &78 ; wall_collision_count_top
&2fad: 85 7a            STA &7a ; wall_collision_count_bottom
&2faf: a5 3a            LDA &3a ; this_object_width                             # next, consider the top and bottom edges
&2fb1: 4a               LSR
&2fb2: 4a               LSR
&2fb3: 4a               LSR
&2fb4: 4a               LSR
&2fb5: 4a               LSR
&2fb6: 85 ab            STA &ab ; this_object_width_divided_32                  # dividing the object up into chunks of width &20
; collision_width_loop_with_recalc
&2fb8: a5 84            LDA &84 ; this_object_y_low_bumped
&2fba: 38               SEC
&2fbb: e5 7e            SBC &7e ; wall_y_start_base
&2fbd: b0 02            BCS &2fc1
&2fbf: a9 00            LDA #&00
&2fc1: 85 a0            STA &a0 ; y_low_minus_wall_base
&2fc3: a5 85            LDA &85 ; this_object_y_max_low_bumped
&2fc5: 38               SEC
&2fc6: e5 82            SBC &82 ; wall_y_start_base_4
&2fc8: b0 02            BCS &2fcc
&2fca: a9 00            LDA #&00
&2fcc: 85 a1            STA &a1 ; y_max_minus_wall_base
; collision_width_loop
&2fce: b1 7c            LDA (&7c),Y ; wall_y_start_lookup_pointer               # for each chunk, consider:
&2fd0: c5 a0            CMP &a0 ; y_low_minus_wall_base
&2fd2: 6a               ROR
&2fd3: 45 7f            EOR &7f ; wall_sprite
&2fd5: 30 02            BMI &2fd9                                               # is there a wall on our top?
&2fd7: c6 78            DEC &78 ; wall_collision_count_top                      # if so, note in wall_collision_count_top
&2fd9: b1 80            LDA (&80),Y
&2fdb: c5 a1            CMP &a1 ; y_max_minus_wall_base
&2fdd: 6a               ROR
&2fde: 45 83            EOR &83 ; wall_sprite_4
&2fe0: 30 02            BMI &2fe4                                               # is there a wall on our bottom?
&2fe2: c6 7a            DEC &7a ; wall_collision_count_bottom                   # if so, note in wall_collision_count_bottom
&2fe4: c6 ab            DEC &ab ; this_object_width_divided_32
&2fe6: 30 27            BMI &300f ; collision_width_loop_done                   # leave when we've considered our entire width
&2fe8: c8               INY
&2fe9: c0 08            CPY #&08                                                # does the object span a x square boundary?
&2feb: 90 e1            BCC &2fce ; collision_width_loop
&2fed: e6 95            INC &95 ; square_x                                      # if so, recalculate the square
&2fef: 20 50 24         JSR &2450 ; get_wall_start_80_83
&2ff2: 2c db 29         BIT &29db ; object_spans_two_squares_y                  # does the object span a y square boundary?
&2ff5: 10 08            BPL &2fff
&2ff7: c6 97            DEC &97 ; square_y
&2ff9: 20 53 24         JSR &2453 ; get_wall_start_7c_7f                        # if so, calculate top most square
&2ffc: 4c 0b 30         JMP &300b
&2fff: a5 82            LDA &82 ; wall_y_start_base_4                           # otherwise use same square results
&3001: 85 7e            STA &7e ; wall_y_start_base
&3003: a5 80            LDA &80 ; wall_y_start_lookup_pointer_4
&3005: 85 7c            STA &7c ; wall_y_start_lookup_pointer
&3007: a5 83            LDA &83 ; wall_sprite_4
&3009: 85 7f            STA &7f ; wall_sprite
&300b: a0 00            LDY #&00
&300d: f0 a9            BEQ &2fb8 ; collision_width_loop_with_recalc
; collision_width_loop_done
&300f: a5 7a            LDA &7a ; wall_collision_count_bottom
&3011: 0a               ASL
&3012: 0a               ASL
&3013: 0a               ASL
&3014: 85 7a            STA &7a ; wall_collision_count_bottom                   # divide wall_collision_count_top by 8
&3016: a5 78            LDA &78 ; wall_collision_count_top
&3018: 0a               ASL
&3019: 0a               ASL
&301a: 0a               ASL
&301b: 85 78            STA &78 ; wall_collision_count_top                      # divide wall_collision_count_bottom by 8
&301d: 38               SEC
&301e: e5 7a            SBC &7a ; wall_collision_count_bottom
&3020: 85 b4            STA &b4 ; velocity_x                                    # (actually the y velocity change for now)
&3022: 85 1a            STA &1a ; wall_collision_top_minus_bottom
&3024: 49 ff            EOR #&ff
&3026: 18               CLC
&3027: 69 01            ADC #&01
&3029: 85 18            STA &18 ; wall_collision_bottom_minus_top
&302b: a5 7a            LDA &7a ; wall_collision_count_bottom
&302d: 05 78            ORA &78 ; wall_collision_count_top
&302f: c9 01            CMP #&01
&3031: 66 1b            ROR &1b ; wall_collision_top_or_bottom
&3033: 20 8a 2e         JSR &2e8a ; consider_side_collisions                    # get result for right hand side
&3036: 85 79            STA &79 ; wall_collision_count_right
&3038: 38               SEC
&3039: e5 77            SBC &77 ; wall_collision_count_left
&303b: 85 b6            STA &b6 ; velocity_y                                    # (actually the x velocity change for now)
&303d: 05 b4            ORA &b4 ; velocity_x
&303f: d0 2b            BNE &306c ; do_wall_collision                           # has there been a change in velocity?
&3041: a5 77            LDA &77 ; wall_collision_count_left
&3043: 05 78            ORA &78 ; wall_collision_count_top
&3045: f0 24            BEQ &306b                                               # if not, leave
; from_do_wall_collision
&3047: 20 aa 28         JSR &28aa ; copy_object_values_from_old
&304a: a5 43            LDA &43 ; this_object_vel_x
&304c: c9 80            CMP #&80
&304e: 6a               ROR
&304f: 85 43            STA &43 ; this_object_vel_x                             # change sign of this_object_vel_x
&3051: a5 45            LDA &45 ; this_object_vel_y
&3053: c9 80            CMP #&80
&3055: 6a               ROR
&3056: 85 45            STA &45 ; this_object_vel_y                             # change sign of this_object_vel_y
&3058: 20 48 2a         JSR &2a48 ; calculate_object_maxes
&305b: e8               INX                                                     # X = &ff
&305c: 86 18            STX &18 ; wall_collision_bottom_minus_top
&305e: 86 1a            STX &1a ; wall_collision_count_bottom
&3060: 86 17            STX &17 ; object_onscreen?
&3062: e8               INX                                                     # X = &00
&3063: 86 77            STX &77 ; wall_collision_count_left
&3065: 86 79            STX &79 ; wall_collision_count_right
&3067: 86 78            STX &78 ; wall_collision_count_top
&3069: 86 7a            STX &7a ; wall_collision_count_bottom
&306b: 60               RTS

; do_wall_collision
&306c: 20 d4 22         JSR &22d4 ; calculate_angle_from_velocities
&306f: 85 1c            STA &1c ; wall_collision_angle
&3071: 38               SEC
&3072: e9 60            SBC #&60                                               
&3074: 29 c0            AND #&c0
&3076: 0a               ASL
&3077: 2a               ROL                                                     # Y & &02 if angle &80
&3078: 2a               ROL                                                     # Y & &01 if angle &40
&3079: a8               TAY             
&307a: 49 02            EOR #&02
&307c: aa               TAX                                                     # X 
&307d: b9 77 00         LDA &0077,Y     # Y = 0 - 3, &77 - &7a, wall_collision_count_[left|right|top|bottom]
&3080: d5 77            CMP &77,X       # X = 0 - 3, &77 - &7a, wall_collision_count_[top|bottom|left|right]
&3082: b0 02            BCS &3086
&3084: b5 77            LDA &77,X       # X = 0 - 3, &77 - &7a, wall_collision_count_[top|bottom|left|right]
&3086: c9 00            CMP #&00
&3088: d0 02            BNE &308c
&308a: a9 fe            LDA #&fe
&308c: 0a               ASL
&308d: 0a               ASL
&308e: 48               PHA
&308f: 88               DEY
&3090: 98               TYA
&3091: 29 01            AND #&01
&3093: 0a               ASL
&3094: aa               TAX
&3095: 68               PLA
&3096: e0 00            CPX #&00
&3098: d0 06            BNE &30a0
&309a: 69 0f            ADC #&0f
&309c: 90 02            BCC &30a0
&309e: a9 fe            LDA #&fe
&30a0: c0 02            CPY #&02
&30a2: 90 01            BCC &30a5
&30a4: c8               INY
&30a5: 08               PHP
&30a6: 20 4c 32         JSR &324c ; make_negative
&30a9: 28               PLP
&30aa: 20 38 2a         JSR &2a38 ; move_object_in_one_direction_with_given_velocity
&30ad: 20 48 2a         JSR &2a48 ; calculate_object_maxes
&30b0: 20 cc 22         JSR &22cc ; calculate_angle_from_this_object_velocities
&30b3: 85 1e            STA &1e ; wall_collision_post_angle
&30b5: a4 b7            LDY &b7 ; some_kind_of_velocity
&30b7: 84 1d            STY &1d ; wall_collision_frict_y_vel
&30b9: 38               SEC
&30ba: e5 1c            SBC &1c ; wall_collision_angle
&30bc: 85 b5            STA &b5 ; angle
&30be: 10 12            BPL &30d2
&30c0: e9 c0            SBC #&c0
&30c2: 20 56 32         JSR &3256 ; make_positive
&30c5: c9 2a            CMP #&2a
&30c7: b0 32            BCS &30fb
&30c9: a5 b7            LDA &b7 ; some_kind_of_velocity
&30cb: c9 40            CMP #&40
&30cd: 90 2c            BCC &30fb
&30cf: 4c 47 30         JMP &3047 ; from_do_wall_collision
&30d2: 38               SEC
&30d3: e9 3f            SBC #&3f
&30d5: 20 75 32         JSR &3275 ; shift_right_three_while_keeping_sign
&30d8: 65 b5            ADC &b5 ; angle
&30da: 49 ff            EOR #&ff
&30dc: 38               SEC
&30dd: 65 1c            ADC &1c ; wall_collision_angle
&30df: 85 b5            STA &b5 ; angle
&30e1: a5 b7            LDA &b7 ; some_kind_of_velocity
&30e3: c9 20            CMP #&20
&30e5: 90 02            BCC &30e9
&30e7: a9 20            LDA #&20
&30e9: e9 02            SBC #&02
&30eb: b0 02            BCS &30ef
&30ed: a9 00            LDA #&00
&30ef: 20 35 32         JSR &3235 ; seven_eights
&30f2: 20 57 23         JSR &2357 ; determine_velocities_from_angle	        # A = velocity_y
&30f5: 85 45            STA &45 ; this_object_vel_y
&30f7: a5 b4            LDA &b4 ; velocity_x
&30f9: 85 43            STA &43 ; this_object_vel_x
&30fb: 60               RTS

; process_gun_aim
&30fc: a5 d3            LDA &d3 ; gun_aim_acceleration
&30fe: f0 08            BEQ &3108                                               # reset the gun aim speed if no acceleration
&3100: 18               CLC
&3101: 65 33            ADC &33 ; gun_aim_velocity                              # add the acceleration to the velocity
&3103: a0 10            LDY #&10
&3105: 20 5e 32         JSR &325e ; keep_within_range                           # limit the velocity to +/- 10
&3108: 85 33            STA &33 ; gun_aim_velocity                              
&310a: 18               CLC
&310b: 65 32            ADC &32 ; gun_aim_value                                 # add the velocity to the gun aim value
&310d: a0 3f            LDY #&3f
&310f: 20 5e 32         JSR &325e ; keep_within_range                           # limit the value to +/- &3f
&3112: 85 32            STA &32 ; gun_aim_value
&3114: 24 37            BIT &37 ; this_object_angle                             # which way is the player facing?
&3116: 10 05            BPL &311d
&3118: 49 7f            EOR #&7f
&311a: 18               CLC
&311b: 69 01            ADC #&01
&311d: 85 34            STA &34 ; firing_angle                                  # set the firing angle to match
&311f: 60               RTS

; reset_gun_aim
&3120: a9 00            LDA #&00
&3122: 85 32            STA &32 ; gun_aim_value
&3124: 85 33            STA &33 ; gun_aim_velocity
; raise_gun_aim
&3126: c6 d3            DEC &d3 ; gun_aim_acceleration
&3128: 2c e6 d3         BIT &d3e6
; lower_gun_aim
#3129:    e6 d3		INC &d3 ; gun_aim_acceleration
; display_gun_particles
&312b: 20 0f 33         JSR &330f ; setup_bullet_velocities
&312e: 20 36 31         JSR &3136 ; invert_angle
&3131: a0 42            LDY #&42                                                # &42 = gun aim particles
&3133: 20 8c 21         JSR &218c ; add_particle	                        # create gun aim particles
; invert_angle
&3136: a5 37            LDA &37 ; this_object_angle
&3138: 49 80            EOR #&80
&313a: 85 37            STA &37 ; this_object_angle
&313c: 60               RTS

#313d: 00 ; (unused)

# unused code
&313e: b9 58 49         LDA &4958,Y ; switch_effects_table
&3141: 20 78 32         JSR &3278 ; shift_right_two_while_keeping_sign
&3144: 29 15            AND #&15
&3146: 79 58 49         ADC &4958,Y ; switch_effects_table
&3149: 60               RTS

#       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#314a: 62 ad 2a 0b 9d af 9e 45 89 9d b5 a2 72 a7 9f b0 ; teleport_destinations_x
#315a: c7 62 cd 0b 58 62 69 57 71 3c 66 63 54 80 49 80 ; teleport_destinations_y

#316a: ff ; retrieve_object_marker

###############################################################################
#
#   NPCs
#   ====
#   no npc                           absorbs                 fires                   gives                      bit_flags
#   0: &29     red/magenta imp       &11 wasp                &34 blue mushroom ball  &4b energy capsule x 4     &cc
#   1: &2a     red/yellow imp        &2f white/yellow bird   &17 red bullet          &12 active grenade x 10    &f6
#   2: &2b     blue/cyan imp         &10 pirahna             &58 coronium crystal    &47 mysterious weapon x 1  &8c
#   3: &2c     cyan/yellow imp       &34 blue mushroom ball  &33 red mushroom ball   &47 mysterious weapon x 1  &72
#   4: &2d     red/cyan imp          &30 red/magenta bird    &33 red mushroom ball   &12 active grenade x 10    &f2
#   5: &1c-&1e robot                 &35 engine fire                                                            &76
#   6: &03     fluffy                &34 blue mushroom ball                                                     &88
#   7: &01,&38 chatter               &58 coronium crystal                                                       &a4
#   8: &0a     green slime           &58 coronium crystal                                                       &1a
#   9: &06     red frogman           &0f worm                                                                   &0e
#
#   no npc                           find_a                  find_y                          find_ay
#   0: &29     red/magenta imp       &81 active chatter + p  &29 red/magenta imp             &40 bush
#   1: &2a     red/yellow imp        &81 active chatter + p  &29 red/magenta imp             &40 bush
#   2: &2b     blue/cyan imp         &ba giant wall + p      &55 coronium boulder            &40 bush
#   3: &2c     cyan/yellow imp       &cd full flask + p      &37 fireball                    &40 bush
#   4: &2d     red/cyan imp          &81 active chatter + p  &86 range 6 (flying enemies)    &80 range 0 (allies) + p
#   5: &1c-&1e robot                 &a9 red/magenta imp + p &86 range 6 (flying enemies)    &88 range 8 (scenery) + p
#   6: &03     fluffy                &37 fireball            &86 range 6 (flying enemies)    &00 player
#   7: &01,&38 chatter               &37 fireball            &86 range 6 (flying enemies)    &00 player
#   8: &0a     green slime           &8a green slime + p     &86 range 6 (flying enemies)    &37 fireball
#   9: &06     red frogman           &0f worm                &0f worm                        &3a giant wall
#
###############################################################################

;       0  1  2  3  4  5  6  7  8  9
;      im im im im im dk fl ch sl fr
#316b: 81 81 ba cd 81 a9 37 37 8a 0f ; npc_find_a
#3175: 29 29 55 37 86 86 86 86 86 0f ; npc_find_y
#317f: 11 2f 10 34 30 35 34 58 58 0f ; npc_absorb_lookup
#3189: 40 40 40 40 40 88 00 00 37 3a ; npc_find_ay
#3193: cc f6 8c 72 f2 76 88 a4 1a 0e ; npc_bit_flags_lookup
#319d: 34 17 58 33 33 -- -- -- -- -- ; npc_weapon_lookup

#31a2: 0a 50 46 14 13 ; imp_energy_lookup
#31a7: 4b 12 47 47 12 ; imp_gift_lookup

; toggle_door_locked_state
&31ac: 69 40            ADC #&40
&31ae: a5 bc            LDA &bc ; this_object_data
&31b0: 70 04            BVS &31b6
&31b2: 69 60            ADC #&60
&31b4: 4a               LSR
&31b5: b8               CLV
&31b6: 4a               LSR
&31b7: 4a               LSR
&31b8: 4a               LSR
&31b9: 4a               LSR
&31ba: aa               TAX
&31bb: bd 06 08         LDA &0806,X ; keys_collected	                        # have we got the right key?
&31be: 10 17            BPL &31d7			                        # if not, leave
&31c0: a5 bc            LDA &bc ; this_object_data	
&31c2: 49 01            EOR #&01                                                # toggle its state
&31c4: 50 08            BVC &31ce
&31c6: 4a               LSR
&31c7: 29 fe            AND #&fe
&31c9: b0 02            BCS &31cd               
&31cb: 09 01            ORA #&01
&31cd: 2a               ROL
&31ce: 85 bc            STA &bc ; this_object_data
&31d0: 20 fa 13         JSR &13fa ; play_sound
#31d3: 94 64 ba c6 ; sound_data
&31d7: 60		RTS

; move_towards_target
&31d8: a2 ff            LDX #&ff                                                # always
; move_towards_target_with_probability_x
# A = magnitude
&31da: e4 da            CPX &da ; timer_2				        # with probability X
&31dc: 90 17            BCC &31f5					        # if not, leave
&31de: 84 9c            STY &9c ; maximum_speed
&31e0: 48               PHA
&31e1: 20 8e 28         JSR &288e ; store_object_tx_ty_to_seventeenth_stack_slot
&31e4: 68               PLA                                                     # target is in slot seventeen for comparison
&31e5: 20 47 33         JSR &3347 ; get_object_centre_and_determine_velocities_from_angle
&31e8: a2 02            LDX #&02
&31ea: a0 00            LDY #&00
&31ec: b5 b4            LDA &b4,X	# X = 2, &b6 velocity_y ; X = 0, &b4 velocity_x
&31ee: 20 f6 31         JSR &31f6 ; speed_up
&31f1: ca               DEX
&31f2: ca               DEX
&31f3: f0 f5            BEQ &31ea
&31f5: 60               RTS
; speed_up
&31f6: 38               SEC
&31f7: f5 43            SBC &43,X	# X = 2, &45 this_object_vel_y ; X = 0, &43 this_object_vel_x
&31f9: 20 01 32         JSR &3201 ; speed_limit
&31fc: 75 43            ADC (&43,X) 	# X = 2, &45 this_object_vel_y ; X = 0, &43 this_object_vel_x
&31fe: 95 43            STA &43,X	# X = 2, &45 this_object_vel_y ; X = 0, &43 this_object_vel_x
&3200: 60               RTS
; speed_limit
&3201: 20 7f 32         JSR &327f ; prevent_overflow
&3204: 08               PHP
&3205: 20 56 32         JSR &3256 ; make_positive
&3208: 4a               LSR
&3209: 88               DEY
&320a: 10 fc            BPL &3208
&320c: 2a               ROL
&320d: c5 9c            CMP &9c ; maximum_speed		                        # limit the speed to maximum_speed
&320f: 90 02            BCC &3213
&3211: a5 9c            LDA &9c ; maximum_speed
&3213: 28               PLP
&3214: 20 56 32         JSR &3256 ; make_positive
&3217: 18               CLC
&3218: 60               RTS

&3219: 20 22 32         JSR &3222 ; dampen_this_object_vel_xy                   # this entrance unused
&321c: 20 22 32         JSR &3222 ; dampen_this_object_vel_xy
; dampen_this_object_vel_xy_twice						# this_object_vel_[x|y] *= 49/64
&321f: 20 22 32         JSR &3222 ; dampen_this_object_vel_xy
; dampen_this_object_vel_xy							# this_object_vel_[x|y] *= 7/8
&3222: 20 2d 32         JSR &322d ; dampen_this_object_vel_x
; dampen_this_object_vel_y							# this_object_vel_y *= 7/8
&3225: a5 45            LDA &45 ; this_object_vel_y
&3227: 20 35 32         JSR &3235 ; seven_eights
&322a: 85 45            STA &45 ; this_object_vel_y
&322c: 60               RTS
; dampen_this_object_vel_x							# this_object_vel_x *= 7/8
&322d: a5 43            LDA &43 ; this_object_vel_x
&322f: 20 35 32         JSR &3235 ; seven_eights
&3232: 85 43            STA &43 ; this_object_vel_x
&3234: 60               RTS

; seven_eights
&3235: 85 9c            STA &9c ; velocity
&3237: 20 54 32         JSR &3254 ; make_positive_cmp_0
&323a: 69 07            ADC #&07
&323c: 4a               LSR
&323d: 4a               LSR
&323e: 4a               LSR							# velocity / 8, rounded up
&323f: 24 9c            BIT &9c ; velocity					# keep the sign
&3241: 20 56 32         JSR &3256 ; make_positive
&3244: 85 9b            STA &9b ; velocity/8
&3246: a5 9c            LDA &9c ; velocity
&3248: 38               SEC
&3249: e5 9b            SBC &9b ; velocity/8
&324b: 60               RTS

; make_negative
&324c: 18               CLC
&324d: 30 04            BMI &3253
&324f: 49 ff            EOR #&ff
&3251: 69 01            ADC #&01
&3253: 60               RTS

; make_positive_cmp_0
&3254: c9 00            CMP #&00
; make_positive
&3256: 18               CLC ; make_positive
&3257: 10 04            BPL &325d
&3259: 49 ff            EOR #&ff
&325b: 69 01            ADC #&01
&325d: 60               RTS

; keep_within_range
# A = value
# Y = range
# returns A limited to +/- Y
&325e: 84 9c            STY &9c
&3260: 85 9d            STA &9d
&3262: 20 54 32         JSR &3254 ; make_positive_cmp_0
&3265: c5 9c            CMP &9c
&3267: 90 06            BCC &326f
&3269: 98               TYA
&326a: 24 9d            BIT &9d
&326c: 4c 56 32         JMP &3256 ; make_positive
&326f: a5 9d            LDA &9d
&3271: 60               RTS

; shift_right_four_while_keeping_sign
&3272: c9 80            CMP #&80
&3274: 6a               ROR
; shift_right_three_while_keeping_sign
&3275: c9 80            CMP #&80
&3277: 6a               ROR
; shift_right_two_while_keeping_sign
&3278: c9 80            CMP #&80
&327a: 6a               ROR
; shift_right_one_while_keeping_sign
&327b: c9 80            CMP #&80
&327d: 6a               ROR
&327e: 60               RTS

; prevent_overflow
&327f: 50 04            BVC &3285
&3281: a9 7f            LDA #&7f
&3283: 69 00            ADC #&00
&3285: 60               RTS

; convert_object_to_another
# A = object type
&3286: 85 41            STA &41 ; this_object_type                              # store new object type
&3288: a8               TAY
&3289: b9 ef 02         LDA &02ef,Y ; object_palette_lookup		        
&328c: 29 7f            AND #&7f
&328e: 85 73            STA &73 ; this_object_palette                           # store new palette
&3290: a9 00            LDA #&00
; change_sprite
# takes A which we add to the base sprite for this object
&3292: 18               CLC
&3293: a4 41            LDY &41 ; this_object_type
&3295: 79 8a 02         ADC &028a,Y ; object_sprite_lookup
; convert_object_keeping_palette
&3298: c5 75            CMP &75 ; this_object_sprite                            # is it the sprite we already have?
&329a: f0 e9            BEQ &3285                                               # if so, leave
&329c: 85 75            STA &75 ; this_object_sprite
&329e: a8               TAY
&329f: a2 02            LDX #&02                                                # X = 2, y direction
&32a1: a5 3c            LDA &3c ; this_object_height
&32a3: 38               SEC
&32a4: f9 89 5e         SBC &5e89,Y ; sprite_height_lookup
&32a7: 20 b0 32         JSR &32b0 ; change_object_size                          # move the object to reflect its new size
; change_object_width
&32aa: a5 3a            LDA &3a ; this_object_width                             # X = 0, x direction
&32ac: 38               SEC
&32ad: f9 0c 5e         SBC &5e0c,Y ; sprite_width_lookup                       
; change_object_size
&32b0: 6a               ROR
&32b1: 49 80            EOR #&80
&32b3: 4c 38 2a         JMP &2a38 ; move_object_in_one_direction_with_given_velocity

; pick_up_object
&32b6: 20 d5 3b         JSR &3bd5 ; can_we_pick_up_object
&32b9: 30 0c            BMI &32c7                                               # leave if not touching anything
&32bb: bc 60 08         LDY &0860,X ; object_stack_type
&32be: b9 ef 02         LDA &02ef,Y ; object_palette_lookup                     # can the object be picked up? (palette & &80)
&32c1: 25 dd            AND &dd ; object_held                                   # are our hands empty? (object_held >= &80)
&32c3: 10 02            BPL &32c7                                               # if so, pick up this object
&32c5: 86 dd            STX &dd ; object_held
&32c7: 60               RTS

; drop_object
&32c8: 24 dd            BIT &dd ; object_held			                # are we holding an object?
&32ca: 30 fb            BMI &32c7				                # if not, leave
&32cc: 38               SEC
&32cd: 66 dd            ROR &dd ; object_held			                # if so, stop holding it
&32cf: 4c a5 14         JMP &14a5 ; play_high_beep

#32d2: 20 20 20 20 20 10 08 ; throw_velocities
; throw_object
&32d9: 20 0f 33         JSR &330f ; setup_bullet_velocities
&32dc: a4 dd            LDY &dd ; object_held			                # are we holding an object?
&32de: 30 e7            BMI &32c7				                # if not, leave
&32e0: 20 20 1e         JSR &1e20 ; get_object_weight
&32e3: a8               TAY					                # Y = object weight
&32e4: a6 dd            LDX &dd ; object_held
&32e6: 20 c8 32         JSR &32c8 ; drop_object
&32e9: 20 87 25         JSR &2587 ; increment_timers
&32ec: 29 07            AND #&07
&32ee: 79 d2 32         ADC &32d2,Y ; throw_velocities		                # get a velocity based on the weight, plus a random extra
&32f1: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&32f4: 24 19            BIT &19 ; any_collision_top_bottom                      # have we collided with something?
&32f6: 30 08            BMI &3300
&32f8: a5 b6            LDA &b6 ; velocity_y			                # if not,
&32fa: 18               CLC
&32fb: 65 45            ADC &45 ; this_object_vel_y                             # add the y velocity to the firer's
&32fd: 20 7f 32         JSR &327f ; prevent_overflow
&3300: 9d f6 08         STA &08f6,X ; object_stack_vel_y
&3303: a5 b4            LDA &b4 ; velocity_x                                    # add the x velocity to the firer's
&3305: 18               CLC
&3306: 65 43            ADC &43 ; this_object_vel_x
&3308: 20 7f 32         JSR &327f ; prevent_overflow
&330b: 9d e6 08         STA &08e6,X ; object_stack_vel_x
&330e: 60               RTS

; setup_bullet_velocities
&330f: a5 34            LDA &34  ; firing_angle                                 # set angle to firing angle
; setup_bullet_velocities_from_A                                                # or use A as angle
&3311: 85 b5            STA &b5 ; angle
&3313: 20 87 25         JSR &2587 ; increment_timers
&3316: 29 03            AND #&03
&3318: 69 40            ADC #&40                                                # magnitude is between &40 and &43
&331a: 20 57 23         JSR &2357 ; determine_velocities_from_angle             # calculate velocities
; setup_bullet_velocities_with_velocities
&331d: a5 43            LDA &43 ; this_object_vel_x
&331f: 65 b4            ADC &b4 ; velocity_x                                    # the new x velocity is relative
&3321: 20 7f 32         JSR &327f ; prevent_overflow                            
&3324: 08               PHP
&3325: 20 56 32         JSR &3256 ; make_positive
&3328: c9 50            CMP #&50                                                # use this_object_vel_x + velocity_x
&332a: 90 10            BCC &333c                                               # unless > &50
&332c: a5 43            LDA &43 ; this_object_vel_x
&332e: 20 56 32         JSR &3256 ; make_positive
&3331: 69 20            ADC #&20
&3333: 20 7f 32         JSR &327f ; prevent_overflow
&3336: c9 50            CMP #&50                                                # else, use this_object_vel_x + &20
&3338: b0 02            BCS &333c                                               # unless > &50
&333a: a9 50            LDA #&50                                                # in which case, use &50
&333c: 28               PLP
&333d: 20 56 32         JSR &3256 ; make_positive
&3340: 85 b4            STA &b4 ; velocity_x                                    # (curiously, the y velocity isn't relative)
&3342: 60               RTS

; get_object_centre_and_determine_velocities_from_angle_quarter
&3343: 85 a3            STA &a3
&3345: 4a               LSR
&3346: 4a               LSR
; get_object_centre_and_determine_velocities_from_angle
# a = magnitude
# a=&20 from unknown door func
&3347: 85 a2            STA &a2 ; magnitude
&3349: 20 a0 22         JSR &22a0 ; get_angle_between_objects
&334c: a5 b7            LDA &b7 ; some_kind_of_velocity
&334e: 85 84            STA &84 ; some_kind_of_velocity_copy
&3350: a5 a2            LDA &a2 ; magnitude
&3352: 4c 57 23         JMP &2357 ; determine_velocities_from_angle

; enemy_fire_velocity_calculation
&3355: 20 43 33         JSR &3343 ; get_object_centre_and_determine_velocities_from_angle_quarter
&3358: a5 b8            LDA &b8 ; delta_magnitude
&335a: c9 06            CMP #&06
&335c: b0 46            BCS &33a4
&335e: 46 a2            LSR &a2
&3360: 46 a2            LSR &a2
&3362: 06 84            ASL &84 ; some_kind_of_velocity_copy
&3364: a9 00            LDA #&00
&3366: a0 08            LDY #&08
&3368: 06 84            ASL &84 ; some_kind_of_velocity_copy
&336a: 2a               ROL
&336b: c5 a2            CMP &a2
e336d: 90 02            BCC &3371
&336f: e5 a2            SBC &a2
&3371: 26 84            ROL &84 ; some_kind_of_velocity_copy
&3373: 88               DEY
&3374: d0 f4            BNE &336a
&3376: a5 b8            LDA &b8 ; delta_magnitude
&3378: 18               CLC
&3379: 69 04            ADC #&04
&337b: a8               TAY
&337c: a9 00            LDA #&00
&337e: 06 84            ASL &84 ; some_kind_of_velocity_copy
&3380: 2a               ROL
&3381: 88               DEY
&3382: d0 fa            BNE &337e
&3384: 49 ff            EOR #&ff
&3386: 38               SEC
&3387: 65 b6            ADC &b6 ; velocity_y
&3389: 38               SEC
&338a: 70 18            BVS &33a4
&338c: 85 b6            STA &b6 ; velocity_y
&338e: 20 56 32         JSR &3256 ; make_positive
&3391: a8               TAY
&3392: bd e6 08         LDA &08e6,X ; object_stack_vel_x
&3395: 65 b4            ADC &b4 ; velocity_x
&3397: 20 7f 32         JSR &327f ; prevent_overflow
&339a: 85 b4            STA &b4 ; velocity_x
&339c: 20 56 32         JSR &3256 ; make_positive
&339f: 20 c1 3b         JSR &3bc1 ; get_biggest_of_a_and_y
&33a2: c5 a3            CMP &a3
&33a4: 60               RTS

; generate_lightning
&33a5: a2 32            LDX #&32 	                                        # &32 = lightning
&33a7: a9 28            LDA #&28	                                        # x velocity = &28
; add_weapon_discharge
# X = object type to create
# A = x velocity
&33a9: a0 00            LDY #&00
; add_weapon_discharge_y_velocity
# Y = y velocity
&33ab: 24 37            BIT &37 ; this_object_angle                             # alter x velocity to match orientation
&33ad: 20 56 32         JSR &3256 ; make_positive
&33b0: 85 b4            STA &b4 ; velocity_x
&33b2: 84 b6            STY &b6 ; velocity_y
&33b4: 20 1d 33         JSR &331d ; setup_bullet_velocities_with_velocities     # make the velocities relative to the firer
&33b7: 8a               TXA

; create_child_object
; A = type of object to create
; returns X = object number
&33b8: 20 5d 1e         JSR &1e5d ; reserve_object		                # find a free object slot
&33bb: b0 e7            BCS &33a4				                # if none found, leave
&33bd: 38               SEC
&33be: 66 30            ROR &30 ; child_created                                 # note creation in child_created
&33c0: 98               TYA                                                     # Y = new object number
&33c1: aa               TAX                                                     # X = new object number
&33c2: a5 39            LDA &39 ; this_object_flags_lefted
&33c4: 29 80            AND #&80
&33c6: 4a               LSR
&33c7: 09 05            ORA #&05
&33c9: 99 c6 08         STA &08c6,Y ; object_stack_flags                        # set flags for new object
&33cc: 20 2f 34         JSR &342f ; store_velocities_in_stack                   # set velocities for new object
&33cf: bc 70 08         LDY &0870,X ; object_stack_sprite
&33d2: 38               SEC
&33d3: a5 3c            LDA &3c ; this_object_height
&33d5: f9 89 5e         SBC &5e89,Y ; sprite_height_lookup
&33d8: 4a               LSR					
&33d9: 65 51            ADC &51 ; this_object_y_low
&33db: 9d a3 08         STA &08a3,X ; object_stack_y_low                        # set y position for new object
&33de: a5 55            LDA &55 ; this_object_y                                 # at half way down the parent
&33e0: 69 00            ADC #&00
&33e2: 9d b4 08         STA &08b4,X ; object_stack_y
&33e5: a5 43            LDA &43 ; this_object_vel_x
&33e7: 38               SEC
&33e8: e5 b4            SBC &b4 ; velocity_x
&33ea: 20 7f 32         JSR &327f ; prevent_overflow
&33ed: 85 9d            STA &9d ; tmp_vx
&33ef: 45 43            EOR &43 ; this_object_vel_x
&33f1: 18               CLC
&33f2: 08               PHP
&33f3: a5 9d            LDA &9d ; tmp_vx
&33f5: 10 08            BPL &33ff
&33f7: a5 3a            LDA &3a ; this_object_width
&33f9: 69 18            ADC #&18
&33fb: a0 01            LDY #&01
&33fd: d0 07            BNE &3406
&33ff: a9 e9            LDA #&e9
&3401: f9 0c 5e         SBC &5e0c,Y ; sprite_width_lookup
&3404: a0 ff            LDY #&ff
&3406: b0 01            BCS &3409
&3408: 88               DEY
&3409: 18               CLC
&340a: 65 4f            ADC &4f ; this_object_x_low
&340c: 85 9c            STA &9c
&340e: 98               TYA
&340f: 65 53            ADC &53 ; this_object_x
&3411: a8               TAY
&3412: a5 9d            LDA &9d
&3414: 28               PLP
&3415: 30 04            BMI &341b
&3417: a9 01            LDA #&01
&3419: e5 b4            SBC &b4 ; velocity_x
&341b: c9 00            CMP #&00
&341d: 10 01            BPL &3420
&341f: 88               DEY
&3420: 18               CLC
&3421: 65 9c            ADC &9c
&3423: 9d 80 08         STA &0880,X ; object_stack_x_low                        # set x position for new object
&3426: 90 01            BCC &3429
&3428: c8               INY
&3429: 98               TYA
&342a: 9d 91 08         STA &0891,X ; object_stack_x
&342d: 18               CLC
&342e: 60               RTS

; store_velocities_in_stack
&342f: a5 b4            LDA &b4 ; velocity_x
&3431: 9d e6 08         STA &08e6,X ; object_stack_vel_x
&3434: a5 b6            LDA &b6 ; velocity_y
&3436: 9d f6 08         STA &08f6,X ; object_stack_vel_y
&3439: 60               RTS

; suck_or_blow_all_objects
&343a: a9 ff            LDA #&ff
; suck_or_blow_all_objects_limited_angle
# A = range of angles to suck
&343c: 85 a1            STA &a1 ; sucking_angle_range
&343e: a5 b5            LDA &b5 ; angle
&3440: 85 a0            STA &a0 ; sucking_angle
&3442: a2 0f            LDX #&0f                                                # consider each other object in turn
; suck_loop_over_objects
&3444: e4 aa            CPX &aa ; current_object                                # ignoring ourselves
&3446: f0 5c            BEQ &34a4 ; suck_loop_next
&3448: a5 35            LDA &35 ; sucking_distance                              # consider objects closer than sucking_distance
&344a: 20 9c 35         JSR &359c ; is_object_close_enough                      # have we got line of sight to it?
&344d: b0 55            BCS &34a4 ; suck_loop_next                              # if not, ignore it
&344f: a5 b5            LDA &b5 ; angle
&3451: 45 29            EOR &29 ; sucking_angle_modifier
&3453: 85 b5            STA &b5 ; angle
&3455: e5 a0            SBC &a0 ; sucking_angle
&3457: c5 a1            CMP &a1 ; sucking_angle_range                           # is the angle within range?
&3459: 90 06            BCC &3461 ; suck_object_ok
&345b: 49 ff            EOR #&ff
&345d: c5 a1            CMP &a1 ; sucking_angle_range
&345f: b0 43            BCS &34a4 ; suck_loop_next
; suck_object_ok
&3461: bc 60 08         LDY &0860,X ; object_stack_type                         # if angle and line of sight are okay,
&3464: b9 54 03         LDA &0354,Y ; object_gravity_flags
&3467: 29 07            AND #&07
&3469: c9 07            CMP #&07		                                # does it fall under gravity?
&346b: 66 24            ROR &24 ; object_static
&346d: 0a               ASL
&346e: 69 08            ADC #&08
&3470: 65 83            ADC &83 ; distance
&3472: e5 35            SBC &35 ; sucking_distance                              # heavier objects less likely to be sucked
&3474: 49 ff            EOR #&ff
&3476: b0 2c            BCS &34a4 ; suck_loop_next                              # is it too far away? if so, ignore it
&3478: 24 28            BIT &28 ; sucking_damage
&347a: 10 0e            BPL &348a ; suck_no_damage                              # only damage objects if sucking_damage set
&347c: c9 04            CMP #&04
&347e: 90 0a            BCC &348a ; suck_no_damage
&3480: 86 9d            STX &9d
&3482: a4 9d            LDY &9d
&3484: 48               PHA
&3485: 0a               ASL                                                     # damage based on distance
&3486: 20 a6 24         JSR &24a6 ; take_damage                                 # damage object
&3489: 68               PLA
; suck_no_damage
&348a: 24 24            BIT &24 ; object_static
&348c: 30 16            BMI &34a4 ; suck_loop_next                              # don't suck it if it's fixed
&348e: 4a               LSR                                                     # magnitude
&348f: 20 57 23         JSR &2357 ; determine_velocities_from_angle	        # A = velocity_y
&3492: 7d f6 08         ADC &08f6,X ; object_stack_vel_y                        # add velocities to object
&3495: 70 03            BVS &349a                                               # avoiding overflows
&3497: 9d f6 08         STA &08f6,X ; object_stack_vel_y
&349a: a5 b4            LDA &b4 ; velocity_x
&349c: 7d e6 08         ADC &08e6,X ; object_stack_vel_x
&349f: 70 03            BVS &34a4 ; suck_loop_next
&34a1: 9d e6 08         STA &08e6,X ; object_stack_vel_x
; suck_loop_next
&34a4: ca               DEX                                                     # move on to next object
&34a5: 10 9d            BPL &3444 ; suck_loop_over_objects
&34a7: 46 28            LSR &28 ; sucking_damage                                # clear sucking_damage
&34a9: a9 28            LDA #&28
&34ab: 85 35            STA &35 ; sucking_distance                              # reset sucking_distance
&34ad: e8               INX
&34ae: 86 29            STX &29 ; sucking_angle_modifier                        # reset sucking_angle_modifier
&34b0: 60               RTS

; store_object
&34b1: a9 04            LDA #&04
&34b3: 2c a9 05         BIT &05a9
; store_object_five_pockets
#34b4:    a9 05
&34b6: 8d db 34         STA &34db			                        # change number of pockets
&34b9: a4 dd            LDY &dd ; object_held
&34bb: 18               CLC
&34bc: 30 6f            BMI &352d			                        # are we holding something? if not, leave
&34be: be 70 08         LDX &0870,Y  ; object_stack_sprite
&34c1: bd 89 5e         LDA &5e89,X ; sprite_height_lookup
&34c4: c9 38            CMP #&38
&34c6: b0 65            BCS &352d			                        # if object too big, leave
&34c8: b9 60 08         LDA &0860,Y ; object_stack_type	                        # what kind of object is it? 
&34cb: c9 4b            CMP #&4b 			                        # &4b = energy capsule
&34cd: d0 08            BNE &34d7 ; pocket_object	                        # if not an energy capsule, pocket it
&34cf: a2 00            LDX #&00
&34d1: 20 16 2d         JSR &2d16			                        # otherwise increase energy in jetpack
&34d4: 4c f4 34         JMP &34f4                                               # and remove object

; pocket_object 
&34d7: ae 47 08         LDX &0847 ; pockets_used
&34da: e0 05            CPX #&05 # modified by &34b6, actually CPX #A           # are we using all our pockets already?
&34dc: b0 4f            BCS &352d			                        # if so, leave
&34de: a2 05            LDX #&05			
&34e0: 48               PHA
&34e1: bd 46 08         LDA &0846,X                                             # push the contents of the pockets one deeper
&34e4: 9d 47 08         STA &0847,X ; pockets_used
&34e7: ca               DEX
&34e8: d0 f7            BNE &34e1
&34ea: 68               PLA
&34eb: 8d 48 08         STA &0848			                        # store object in pocket
&34ee: ee 47 08         INC &0847 ; pockets_used
&34f1: 20 c8 32         JSR &32c8 ; drop_object                                 # mark the object as no longer being held
&34f4: 18               CLC
&34f5: 4c 16 25         JMP &2516 ; mark_stack_object_for_removal               # and remove it

; retrieve_object
&34f8: 20 b4 34         JSR &34b4 ; store_object_five_pockets
&34fb: 6e 6a 31         ROR &316a ; retrieve_object_marker                      # mark us as due to retrieve an object
&34fe: 60               RTS

; retrieve_object_if_marked
&34ff: 2c 6a 31         BIT &316a ; retrieve_object_marker                      # are we due to retrieve an object?
&3502: 30 29            BMI &352d                                               # if not, leave
; actually_retrieve_object
&3504: a5 37            LDA &37 ; this_object_angle                             # get our angle, but reduce it to either
&3506: 29 80            AND #&80                                                # &00 = straight left, &80 = straight right
&3508: 20 11 33         JSR &3311 ; setup_bullet_velocities_from_A
&350b: ae 47 08         LDX &0847 ; pockets_used	                        # are our pockets empty?
&350e: f0 19            BEQ &3529			                        # if so, clear the mark and leave
&3510: bd 47 08         LDA &0847,X ; pockets_used	                        # get the content of the pocket
&3513: 20 b8 33         JSR &33b8 ; create_child_object	                        # create it as an object; X = new object
&3516: b0 15            BCS &352d			                        # if not possible, keep the mark and leave
&3518: 86 dd            STX &dd	; object_held		                        # mark the new object as being held
&351a: 20 fa 13         JSR &13fa ; play_sound
#351d: 17 82 13 c3 ; sound data
&3521: a4 dd            LDY &dd ; object_held
&3523: 20 a9 0b         JSR &0ba9 ; set_object_velocities                       # set its velocities to match ours
&3526: ce 47 08         DEC &0847 ; pockets_used                                # one fewer full pockets now
&3529: 38               SEC
&352a: 6e 6a 31         ROR &316a ; retrieve_object_marker                      # clear the mark
&352d: 60               RTS

; give_minimum_energy
# Y = minimum energy to give object
&352e: a5 15            LDA &15 ; this_object_energy
&3530: f0 05            BEQ &3537                                               # if the object has no energy, leave
&3532: 20 c1 3b         JSR &3bc1 ; get_biggest_of_a_and_y
&3535: 85 15            STA &15 ; this_object_energy                            # otherwise give it at least its minimum
&3537: 60               RTS

; gain_energy_or_flash_if_damaged_minimum_1e
&3538: a0 1e            LDY #&1e                                                # minimum energy = &1e
; gain_energy_or_flash_if_damaged                                               # or Y
# Y = minimum energy to give object
&353a: 24 c5            BIT &c5 ; loop_counter_every_04                         # every four cycles
&353c: 10 09            BPL &3547
&353e: a5 15            LDA &15 ; this_object_energy
&3540: c9 c0            CMP #&c0
&3542: b0 03            BCS &3547
&3544: 20 4e 25         JSR &254e; gain_one_energy_point_if_not_immortal        # gain energy if < &c0
; give_minimum_energy_and_flash_if_damaged
&3547: 20 2e 35         JSR &352e ; give_minimum_energy
&354a: 0a               ASL
&354b: 08               PHP
&354c: b0 06            BCS &3554                                               # is energy < &80 ?
&354e: a5 06            LDA &06 ; current_object_rotator
&3550: 29 07            AND #&07
&3552: c9 02            CMP #&02
&3554: 20 df 4d         JSR &4ddf ; flash_palette                               # if so, flash palette every 8 cycles
&3557: 28               PLP
&3558: 60               RTS

; get_object_distance_from_screen_centre
&3559: a4 aa            LDY &aa ; current_object
&355b: 38               SEC
&355c: b9 91 08         LDA &0891,Y ; object_stack_x
&355f: e9 04            SBC #&04
&3561: e5 c8            SBC &c8 ; screen_start_square_x                         # object_x - 4 - screen_x
&3563: 20 56 32         JSR &3256 ; make_positive
&3566: 85 9d            STA &9d ; tmp
&3568: b9 b4 08         LDA &08b4,Y ; object_stack_y
&356b: e9 01            SBC #&01
&356d: e5 ca            SBC &ca ; screen_start_square_y                         # object_y - 1 - screen_y
&356f: 20 56 32         JSR &3256 ; make_positive
&3572: 65 9d            ADC &9d ; tmp
&3574: 6a               ROR                                                     # average the two
&3575: 60               RTS

; pause
&3576: 4e bd 14         LSR &14bd ; game_paused
&3579: 20 81 35         JSR &3581		                                # wait for COPY to be released
&357c: 2c 6b 12         BIT &126b ; keys_pressed
&357f: 10 fb            BPL &357c                                               # then pressed
&3581: 2c 6b 12         BIT &126b ; keys_pressed
&3584: 30 fb            BMI &3581                                               # then released again
&3586: 6e bd 14         ROR &14bd ; game_paused
&3589: 60               RTS

#358a: ff ; player_can_move

#358b: ff ; allow_screen_redrawing                                              # apparently constant 

#358c: 00 e0 ; scroll_square_offset_x_low
#358e: 00 07 ; scroll_square_offset_x
#3590: 00 c0 ; scroll_square_offset_y_low
#3592: 00 03 ; scroll_square_offset_y
#3594: 00 1e 1c 1a ; scroll_screen_address_offsets

#3598: 00 ; los_consider_water
#3599: 00 ; door_data_pointer_store

; is_object_close_enough_80
&359a: a9 80            LDA #&80
# X = object
; is_object_close_enough
# A = range
# X = object
&359c: 8d cd 35         STA &35cd                                               # self modifying code
&359f: bd b4 08         LDA &08b4,X ; object_stack_y
&35a2: 38               SEC
&35a3: f0 29            BEQ &35ce                                               # is it an object? branch if not
&35a5: bd 60 08         LDA &0860,X ; object_stack_type
&35a8: e9 3c            SBC #&3c                                                # &3c - &3f various doors
&35aa: c9 04            CMP #&04
&35ac: b0 06            BCS &35b4 ; not_door                                    # if so, is it a door?
&35ae: bd 66 09         LDA &0966,X ; object_stack_data_pointer         
&35b1: 8d 99 35         STA &3599 ; door_data_pointer_store                     # if so, store data pointer for door
; not_door
&35b4: a9 20            LDA #&20                                                # magnitude
&35b6: 20 47 33         JSR &3347 ; get_object_centre_and_determine_velocities_from_angle
&35b9: a4 b8            LDY &b8 ; delta_magnitude
&35bb: c8               INY
&35bc: c8               INY
&35bd: c8               INY
&35be: a9 00            LDA #&00
; closeness_loop                                                
&35c0: 06 84            ASL &84 ; some_kind_of_velocity_copy                    # push bits from some_kind_of_velocity_copy
&35c2: 2a               ROL                                                     # depending on delta_magnitude
&35c3: 90 02            BCC &35c7
&35c5: a9 fd            LDA #&fd                                                # or set to &fd if overflowed
&35c7: 88               DEY
&35c8: d0 f6            BNE &35c0 ; closeness_loop
&35ca: 69 01            ADC #&01
&35cc: c9 40            CMP #&40                                                # modifed by &359c (CMP #range)
&35ce: 90 05            BCC &35d5 ; line_of_sight_without_obstructions          # if not an object, branch 
&35d0: 85 83            STA &83 ; distance
&35d2: 4c 7a 36         JMP &367a ; leave_with_carry_set

; line_of_sight_without_obstructions
# distance to consider
&35d5: 85 84            STA &84 ; distance_left
&35d7: 86 9d            STX &9d ; tmp_x                                         # preserve X
&35d9: a2 02            LDX #&02        # first y direction (X = 2), then x direction (X = 0)
; los_dir
&35db: 8d 34 36         STA &3634       # A = &b0 (BCS) or &90 (BCC)            # self modifying code
&35de: 49 76            EOR #&76
&35e0: 8d 36 36         STA &3636       # A = &c6 (DEC) or &e6 (INC)            # self modifying code
&35e3: 86 83            STX &83 ; distance
&35e5: b5 3a            LDA &3a,X       # X = 2, &3c this_object_height; X = 0, &3a this_object_width
&35e7: 4a               LSR                                                     
&35e8: 75 4f            ADC (&4f,X)     # X = 2, &51 this_object_y_low; X = 0, &4f this_object_x_low
&35ea: 95 80            STA &80,X       # X = 2, &82 square_y_low; X = 0, &80 square_x_low
&35ec: b5 53            LDA &53,X       # X = 2, &55 this_object_y
&35ee: 69 00            ADC #&00
&35f0: 95 95            STA &95,X       # X = 2, &97 square_y                   # get centre of object into square, square_low
&35f2: b5 b4            LDA &b4,X       # X = 2, &b6 velocity_y
&35f4: 4a               LSR
&35f5: 29 20            AND #&20
&35f7: 49 90            EOR #&90        # A = &B0 (BCS) or &90 (BCC)            # is the velocity positive or negative?
&35f9: ca               DEX
&35fa: ca               DEX
&35fb: f0 de            BEQ &35db ; los_dir      # do it again for x direction
&35fd: 8d 42 36         STA &3642       # A = &b0 (BCS) or &90 (BCC)            # self modifying code
&3600: 49 76            EOR #&76
&3602: 8d 44 36         STA &3644       # A = &c6 (DEC) or &e6 (INC)            # self modifying code
&3605: a9 40            LDA #&40
&3607: 85 2d            STA &2d ; background_processing_flag                    # doors
&3609: a5 95            LDA &95 ; square_x
&360b: 20 bc 2c         JSR &2cbc ; get_water_level_for_x
&360e: a5 82            LDA &82 ; square_y_low
&3610: cd d0 14         CMP &14d0 ; water_level_low
&3613: a5 97            LDA &97 ; square_y
&3615: ed d1 14         SBC &14d1 ; water_level
&3618: 6a               ROR
&3619: 6a               ROR
&361a: 6a               ROR
&361b: 29 20            AND #&20                                                # are we underwater or not?
&361d: 49 b0            EOR #&b0        
&361f: 8d 70 36         STA &3670       # A = &b0 (BCS) or &90 (BCC)            # self modifying code
&3622: a6 9d            LDX &9d ; tmp_x
&3624: 20 53 24         JSR &2453 ; get_wall_start_7c_7f
; los_loop
&3627: a5 82            LDA &82 ; square_y_low                                  # consider the next point on our route
&3629: 18               CLC
&362a: 65 b6            ADC &b6 ; velocity_y                                    # (by adding velocities to current point)
&362c: 85 82            STA &82 ; square_y_low
&362e: 29 f8            AND #&f8
&3630: 09 04            ORA #&04
&3632: 85 81            STA &81 ; square_y_low_max
&3634: b0 05            BCS &363b                       # modified by &35db; either BCS &363b or BCC &363b, depending on sign of velocity_x
&3636: e6 97            INC &97 ; square_y              # modified by &35e0; either DEC &97 or &INC &97, depending on sign of velocity_x
&3638: 20 53 24         JSR &2453 ; get_wall_start_7c_7f                        # redundant?
&363b: a5 80            LDA &80 ; square_x_low
&363d: 18               CLC
&363e: 65 b4            ADC &b4 ; velocity_x
&3640: 85 80            STA &80 ; square_x_low
&3642: b0 05            BCS &3649                       # modified by &35fd; either BCS &3649 or BCC &3649, depending on sign of velocity_y
&3644: e6 95            INC &95 ; square_x              # modified by &3602; either DEC &95 or &INC &95, depending on sign of velocity_y
&3646: 20 53 24         JSR &2453 ; get_wall_start_7c_7f
&3649: a5 80            LDA &80 ; square_x_low                                  # check whether there's a wall there
&364b: 29 e0            AND #&e0                                                
&364d: 0a               ASL     
&364e: 2a               ROL
&364f: 2a               ROL
&3650: 2a               ROL
&3651: a8               TAY
&3652: b1 7c            LDA (&7c),Y ; wall_y_start_lookup_pointer
&3654: 65 7e            ADC &7e ; wall_y_start_base
&3656: 90 02            BCC &365a
&3658: a9 ff            LDA #&ff        
&365a: c5 81            CMP &81 ; square_y_low_max      
&365c: 6a               ROR                             
&365d: 45 7f            EOR &7f ; wall_sprite
&365f: 10 19            BPL &367a ; leave_with_carry_set                        # if so, there's an obstruction
&3661: 2c 98 35         BIT &3598 ; los_consider_water
&3664: 10 0c            BPL &3672                                               # is water considered a barrier?
&3666: a5 82            LDA &82 ; square_y_low
&3668: cd d0 14         CMP &14d0 ; water_level_low                             # if so, have we passed through the water?
&366b: a5 97            LDA &97 ; square_y
&366d: ed d1 14         SBC &14d1 ; water_level                                 # if so, there's an obstruction
&3670: 90 08            BCC &367a       # modified by &371f; either BCS &367a or BCC &367a, depending on initial water level
; los_ignore_water
&3672: e6 83            INC &83 ; distance
&3674: c6 84            DEC &84 ; distance_left
&3676: d0 af            BNE &3627 ; los_loop
&3678: 18               CLC                                                     # no obstructions found; return carry clear
&3679: 24 38            BIT &38  
; leave_with_carry_set
#367a:    38            SEC                                                     # obstructions found; return carry set
&367b: a9 ff            LDA #&ff
&367d: 8d 99 35         STA &3599 ; door_data_pointer_store
&3680: 8d 98 35         STA &3598 ; los_consider_water                          # consider water unless otherwise ignored
&3683: 60               RTS

; redraw_screen
&3684: ad 8b 35         LDA &358b ; allow_screen_redrawing                      # should we redraw the screen? (constant)
&3687: 10 fa            BPL &3683                                               # if not, leave
&3689: a5 cf            LDA &cf ; scroll_x_direction
&368b: f0 58            BEQ &36e5 ; not_scrolling_x                             # are we scrolling left or right? if so:
&368d: a4 cc            LDY &cc ; scroll_square_x_velocity_high
&368f: c8               INY                                                     # Y = &00 left, Y = &01 right
&3690: b9 8c 35         LDA &358c,Y ; scroll_square_offset_x_low 
&3693: 18               CLC
&3694: 65 c7            ADC &c7 ; screen_start_square_x_low
&3696: b9 8e 35         LDA &358e,Y ; scroll_square_offset_x
&3699: 65 c8            ADC &c8 ; screen_start_square_x
&369b: 85 95            STA &95 ; square_x                                      # find the square on the edge of the screen
&369d: a5 ca            LDA &ca ; screen_start_square_y
&369f: 85 97            STA &97 ; square_y
&36a1: a5 cb            LDA &cb ; scroll_square_x_velocity_low
&36a3: 24 cc            BIT &cc ; scroll_square_x_velocity_high
&36a5: 20 56 32         JSR &3256 ; make_positive
&36a8: 4a               LSR
&36a9: 4a               LSR
&36aa: 85 9c            STA &9c ; scroll_width                                  # get the width of the scrolled area
&36ac: a2 11            LDX #&11
&36ae: 38               SEC
&36af: a5 b0            LDA &b0 ; screen_offset
&36b1: 24 cc            BIT &cc ; scroll_square_x_velocity_high
&36b3: 30 02            BMI &36b7
&36b5: e5 9c            SBC &9c ; scroll_width
&36b7: 85 8f            STA &8f ; screen_address
&36b9: a5 b1            LDA &b1 ; screen_offset_h
&36bb: e9 00            SBC #&00
&36bd: 18               CLC
&36be: 69 60            ADC #&60			                        # calculate the screen address for the edge
&36c0: 38               SEC
&36c1: c6 9c            DEC &9c ; scroll_width
&36c3: 24 cc            BIT &cc ; scroll_square_x_velocity_high
&36c5: 30 0d            BMI &36d4
&36c7: 10 0d            BPL &36d6
&36c9: a9 00            LDA #&00
&36cb: a4 9c            LDY &9c ; scroll_width
&36cd: 91 8f            STA (&8f),Y		                                # clear the screen memory for the edge
&36cf: 88               DEY
&36d0: 10 fb            BPL &36cd
&36d2: a5 90            LDA &90 ; screen_address_h
&36d4: e9 02            SBC #&02
&36d6: 09 60            ORA #&60
&36d8: 85 90            STA &90	; screen_address_h
&36da: ca               DEX
&36db: d0 ec            BNE &36c9                                               # repeat until we've cleared the edge
&36dd: a0 04            LDY #&04                                                # strip length = 4 squares
&36df: a9 97            LDA #&97                                                # when redrawing strip, increase &97 square_y
&36e1: a2 02            LDX #&02
&36e3: d0 76            BNE &375b ; done_scrolling
; not_scrolling_x
&36e5: a6 d1            LDX &d1 ; scroll_y_direction
&36e7: f0 72            BEQ &375b ; done_scrolling                              # are we scrolling up or down? if so:
&36e9: a4 ce            LDY &ce ; scroll_square_y_velocity_high
&36eb: c8               INY
&36ec: b9 90 35         LDA &3590,Y ; scroll_square_offset_y_low                # Y = &00 up, Y = &01 down
&36ef: 18               CLC
&36f0: 65 c9            ADC &c9 ; screen_start_square_y_low
&36f2: b9 92 35         LDA &3592,Y ; scroll_square_offset_y
&36f5: 65 ca            ADC &ca ; screen_start_square_y
&36f7: 85 97            STA &97 ; square_y                                      # find the square on the edge of the screen
&36f9: a5 c8            LDA &c8 ; screen_start_square_x
&36fb: 85 95            STA &95 ; square_x
&36fd: 98               TYA
&36fe: f0 02            BEQ &3702                                               # are we scrolling down?
&3700: a4 d1            LDY &d1 ; scroll_y_direction                            # if so, Y = scroll_y_velocity
&3702: a5 b0            LDA &b0 ; screen_offset
&3704: 18               CLC
&3705: 85 93            STA &93 ; screen_address_two
&3707: a5 b1            LDA &b1 ; screen_offset_h
&3709: 79 94 35         ADC &3594,Y ; scroll_screen_address_offsets
&370c: 29 1f            AND #&1f
&370e: 09 60            ORA #&60
&3710: 85 94            STA &94 ; screen_address_two_h
&3712: a5 d1            LDA &d1 ; scroll_y_direction
&3714: 20 56 32         JSR &3256 ; make_positive
&3717: 85 a0            STA &a0 ; scroll_height                                 # get the height of the scrolled area
&3719: a5 94            LDA &94 ; screen_address_two_h
&371b: 85 90            STA &90; screen_address_h
&371d: a2 02            LDX #&02
&371f: a4 93            LDY &93 ; screen_address_two
&3721: a9 00            LDA #&00
&3723: 85 8f            STA &8f ; screen_address
&3725: 91 8f            STA (&8f),Y		                                # clear the screen memory for left part of edge
&3727: c8               INY
&3728: d0 fb            BNE &3725
&372a: e6 90            INC &90; screen_address_h
&372c: 10 06            BPL &3734
&372e: a9 60            LDA #&60
&3730: 85 90            STA &90; screen_address_h
&3732: a9 00            LDA #&00
&3734: ca               DEX
&3735: d0 ee            BNE &3725
&3737: c6 90            DEC &90; screen_address_h
&3739: c6 8f            DEC &8f; screen_address
&373b: a4 93            LDY &93 ; screen_address_two
&373d: f0 07            BEQ &3746
&373f: a9 00            LDA #&00
&3741: 91 8f            STA (&8f),Y	                                        # clear the screen memory for right part of edge
&3743: 88               DEY
&3744: d0 fb            BNE &3741
&3746: a5 94            LDA &94 ; screen_address_two_h
&3748: 18               CLC
&3749: 69 02            ADC #&02
&374b: 29 1f            AND #&1f
&374d: 09 60            ORA #&60
&374f: 85 94            STA &94 ; screen_address_two_h
&3751: c6 a0            DEC &a0 ; scroll_height
&3753: d0 c4            BNE &3719
&3755: a9 95            LDA #&95                                                # when redrawing strip, increase &95 square_x
&3757: a0 08            LDY #&08                                                # strip length = 8 squares
&3759: a2 00            LDX #&00
; done_scrolling                                                                # X = 0 for y scrolling, X = 2 for x scrolling
&375b: 8d ec 10         STA &10ec       # self modifying code                   # use square_[x|y] variable depending on direction
&375e: 8d 8b 37         STA &378b       # self modifying code                   # use square_[x|y] variable depending on direction
&3761: 48               PHA
&3762: b5 c7            LDA &c7,X       # X = 2, &c9 screen_start_square_y_low; X = 0, &c7 screen_start_square_x_low
&3764: f0 01            BEQ &3767
&3766: c8               INY                                                     # add one extra square to strip if needed
&3767: 84 af            STY &af ; strip_length
&3769: 84 ae            STY &ae ; strip_length_two
&376b: 68               PLA
&376c: aa               TAX
&376d: b5 00            LDA &00,X       # actually LDA &95|&97 square_[x|y]     # preserve square_[x|y]
&376f: 48               PHA
&3770: 8a               TXA
&3771: 48               PHA
&3772: ad cd 14         LDA &14cd ; call_object_handlers_when_redrawing_screen  # should we call background object handlers?
&3775: 29 80            AND #&80                                      
&3777: 85 2d            STA &2d ; background_processing_flag                    # note this in background_processing_flag
&3779: c6 ae            DEC &ae ; strip_length_two
&377b: 30 12            BMI &378f ; done_strip_plotting
&377d: 20 15 17         JSR &1715 ; determine_background			# this actually plots for movement and teleporting
&3780: a6 ae            LDX &ae ; strip_length_two
&3782: 9d f6 07         STA &07f6,X ; background_strip_cache_sprite             # cache the background
&3785: a5 09            LDA &09 ; square_orientation
&3787: 9d ed 07         STA &07ed,X ; background_strip_cache_orientation
&378a: e6 95            INC &95         # actually &95|&97 square_[x|y], modified by &375e
&378c: 4c 79 37         JMP &3779                                               # loop over the entire strip
; done_strip_plotting
&378f: 68               PLA
&3790: aa               TAX
&3791: 68               PLA
&3792: 95 00            STA &00,X       # actually LDA &95|&97 square_[x|y]     # preserve square_[x|y]
&3794: 60               RTS

; do_player_stuff
&3795: 20 94 2c         JSR &2c94 ; double_acceleration
&3798: 24 c3            BIT &c3 ; loop_counter_every_10                         # every &10 cycles,
&379a: 10 10            BPL &37ac
&379c: a5 15            LDA &15 ; this_object_energy                            # heal the player by &04 energy
&379e: 69 04            ADC #&04
&37a0: b0 02            BCS &37a4                                               # avoiding overflow
&37a2: 85 15            STA &15 ; this_object_energy
&37a4: a2 00            LDX #&00                                                # 0 = jetpack
&37a6: 20 92 2d         JSR &2d92 ; make_firing_erratic_at_low_energy
&37a9: 6e 8a 35         ROR &358a ; player_can_move                             # make the jetpack erratic when energy low
&37ac: a9 10            LDA #&10
&37ae: e5 15            SBC &15 ; this_object_energy
&37b0: 90 02            BCC &37b4                                               # if player's energy < &10, set daze
&37b2: 85 ba            STA &ba ; player_immobility_daze                        # ie, we can't move when severely hurt
&37b4: a5 ba            LDA &ba ; player_immobility_daze
&37b6: c9 06            CMP #&06
&37b8: 90 03            BCC &37bd                                               # if the player is dazed, we can't move
&37ba: 4e 8a 35         LSR &358a ; player_can_move                             
&37bd: a5 bb            LDA &bb ; player_nothrust_daze
&37bf: f0 05            BEQ &37c6
&37c1: c6 bb            DEC &bb ; player_nothrust_daze
&37c3: 4e 8a 35         LSR &358a ; player_can_move
&37c6: 46 31            LSR &31 ; player_crawling
&37c8: a5 de            LDA &de ; player_angle
&37ca: 38               SEC
&37cb: e9 cf            SBC #&cf
&37cd: c9 e1            CMP #&e1
&37cf: 6a               ROR
&37d0: 25 05            AND &05 ; something_about_player_angle
&37d2: 85 05            STA &05 ; something_about_player_angle
&37d4: a5 42            LDA &42 ; acceleration_y
&37d6: d0 20            BNE &37f8
&37d8: a5 40            LDA &40 ; acceleration_x
&37da: d0 0a            BNE &37e6
&37dc: a5 17            LDA &17 ; object_onscreen?
&37de: 0d b4 19         ORA &19b4 ; collided_in_last_cycle
&37e1: 0d 81 12         ORA &1281 ; ctrl_held_duration
&37e4: 85 31            STA &31 ; player_crawling
&37e6: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&37e9: 90 25            BCC &3810
&37eb: 24 19            BIT &19 ; any_collision_top_bottom
&37ed: 10 09            BPL &37f8
&37ef: 20 25 32         JSR &3225 ; dampen_this_object_vel_y
&37f2: 20 25 32         JSR &3225 ; dampen_this_object_vel_y
&37f5: 20 25 32         JSR &3225 ; dampen_this_object_vel_y
&37f8: 2c 8a 35         BIT &358a ; player_can_move
&37fb: 10 13            BPL &3810
&37fd: 20 3d 1f         JSR &1f3d ; create_jetpack_thrust
&3800: f0 0e            BEQ &3810
&3802: a5 c4            LDA &c4 ; loop_counter_every_08
&3804: 0d 80 12         ORA &1280 ; @_pressed
&3807: 25 c6            AND &c6 ; loop_counter_every_02
&3809: 10 05            BPL &3810
&380b: a2 00            LDX #&00
&380d: 20 79 2d         JSR &2d79 ; reduce_weapon_energy_for_x
&3810: a5 ba            LDA &ba ; player_immobility_daze
&3812: f0 45            BEQ &3859
&3814: c6 ba            DEC &ba ; player_immobility_daze
&3816: a5 de            LDA &de ; player_angle
&3818: 0a               ASL
&3819: 85 9c            STA &9c
&381b: a5 1e            LDA &1e ; wall_collision_post_angle
&381d: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&381f: 30 08            BMI &3829
&3821: a5 b9            LDA &b9 ; something_player_collision_value
&3823: 24 3b            BIT &3b ; this_object_supporting
&3825: 30 19            BMI &3840
&3827: a9 40            LDA #&40
&3829: 0a               ASL
&382a: 38               SEC
&382b: e5 9c            SBC &9c
&382d: 6a               ROR
&382e: 08               PHP
&382f: a5 1d            LDA &1d ; wall_collision_frict_y_vel
&3831: 4a               LSR
&3832: 4a               LSR
&3833: 09 01            ORA #&01
&3835: 28               PLP
&3836: 20 56 32         JSR &3256 ; make_positive
&3839: 65 b9            ADC &b9 ; something_player_collision_value
&383b: a0 20            LDY #&20
&383d: 20 5e 32         JSR &325e ; keep_within_range
&3840: 24 c5            BIT &c5 ; loop_counter_every_04
&3842: 10 0b            BPL &384f
&3844: c9 04            CMP #&04
&3846: 90 07            BCC &384f
&3848: c9 fd            CMP #&fd
&384a: b0 03            BCS &384f
&384c: 20 35 32         JSR &3235 ; seven_eights
&384f: 85 b9            STA &b9 ; something_player_collision_value
&3851: 18               CLC
&3852: 65 de            ADC &de ; player_angle
&3854: 85 de            STA &de ; player_angle
&3856: 4c b9 38         JMP &38b9
&3859: a9 00            LDA #&00
&385b: a2 02            LDX #&02
&385d: b4 40            LDY &40,X
&385f: 94 b4            STY &b4,X
&3861: c0 01            CPY #&01
&3863: 2a               ROL
&3864: ca               DEX
&3865: ca               DEX
&3866: f0 f5            BEQ &385d
&3868: aa               TAX
&3869: f0 09            BEQ &3874
&386b: 2c 8a 35         BIT &358a ; player_can_move
&386e: 10 04            BPL &3874
&3870: 20 d4 22         JSR &22d4 ; calculate_angle_from_velocities
&3873: 2c a9 c0         BIT &c0a9
#3874:    a9 c0         LDA #&c0                                                # &c0 = straight up
&3876: 24 31            BIT &31 ; player_crawling
&3878: 10 08            BPL &3882
&387a: a9 fd            LDA #&fd
&387c: 24 df            BIT &df ; player_facing
&387e: 10 02            BPL &3882
&3880: a9 83            LDA #&83
&3882: e5 de            SBC &de ; player_angle
&3884: a8               TAY
&3885: e0 02            CPX #&02
&3887: d0 0a            BNE &3893
&3889: e9 74            SBC #&74
&388b: c9 18            CMP #&18
&388d: b0 04            BCS &3893
&388f: a0 00            LDY #&00
&3891: f0 08            BEQ &389b
&3893: a5 40            LDA &40 ; acceleration_x
&3895: f0 04            BEQ &389b
&3897: 24 05            BIT &05 ; something_about_player_angle
&3899: 30 02            BMI &389d
&389b: a2 00            LDX #&00
&389d: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&38a0: 98               TYA
&38a1: b0 06            BCS &38a9
&38a3: 24 31            BIT &31 ; player_crawling
&38a5: 30 02            BMI &38a9
&38a7: a9 00            LDA #&00
&38a9: 20 78 32         JSR &3278 ; shift_right_two_while_keeping_sign
&38ac: 65 de            ADC &de ; player_angle
&38ae: 85 de            STA &de ; player_angle
&38b0: 45 40            EOR &40 ; acceleration_x
&38b2: 49 80            EOR #&80
&38b4: ca               DEX
&38b5: 30 02            BMI &38b9
&38b7: 85 df            STA &df ; player_facing
&38b9: 20 8f 3a         JSR &3a8f
&38bc: ad 8a 35         LDA &358a ; player_can_move
&38bf: 30 0b            BMI &38cc
&38c1: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&38c4: a9 00            LDA #&00
&38c6: 85 42            STA &42 ; acceleration_y
&38c8: 90 02            BCC &38cc
&38ca: 85 40            STA &40 ; acceleration_x
&38cc: a4 df            LDY &df ; player_facing
&38ce: a5 de            LDA &de ; player_angle
; change_palettes_for_player_like_objects
&38d0: 24 30            BIT &30 ; child_created                                 # has a child object been created?
&38d2: 30 05            BMI &38d9
&38d4: 84 9e            STY &9e
&38d6: 20 06 39         JSR &3906 ; something_from_player
&38d9: a5 06            LDA &06 ; current_object_rotator
&38db: 29 1f            AND #&1f
&38dd: 0a               ASL
&38de: c5 15            CMP &15 ; this_object_energy
&38e0: 08               PHP
&38e1: a4 41            LDY &41 ; this_object_type
&38e3: b9 ef 02         LDA &02ef,Y ; object_palette_lookup
&38e6: 29 7f            AND #&7f
&38e8: a4 41            LDY &41 ; this_object_type
&38ea: d0 10            BNE &38fc
&38ec: a2 05            LDX #&05                                                # 5 = protection suit
&38ee: 20 92 2d         JSR &2d92 ; make_firing_erratic_at_low_energy           # flashes at low energy
&38f1: 6a               ROR
&38f2: 2d 13 08         AND &0813 ; protection_suit_collected                   # but not if we've not got it
&38f5: 2a               ROL
&38f6: a9 33            LDA #&33                                                # palette with suit
&38f8: b0 02            BCS &38fc
&38fa: a9 3e            LDA #&3e                                                # palette without suit
&38fc: 28               PLP
&38fd: 90 04            BCC &3903
&38ff: a5 73            LDA &73 ; this_object_palette		
&3901: 49 0b            EOR #&0b                                                # palette changes when damaged
&3903: 85 73            STA &73 ; this_object_palette
&3905: 60               RTS

; something_from_player
&3906: 4a               LSR
&3907: 4a               LSR
&3908: 4a               LSR
&3909: 4a               LSR
&390a: 4a               LSR
&390b: 69 00            ADC #&00
&390d: 24 9e            BIT &9e
&390f: 30 04            BMI &3915
&3911: 49 07            EOR #&07
&3913: 69 01            ADC #&01
&3915: 48               PHA
&3916: 29 04            AND #&04
&3918: c9 04            CMP #&04
&391a: 6a               ROR
&391b: 85 37            STA &37 ; this_object_angle
&391d: 45 9e            EOR &9e
&391f: 85 39            STA &39 ; this_object_flags_lefted
&3921: 68               PLA
&3922: 29 03            AND #&03
&3924: c9 02            CMP #&02
&3926: d0 23            BNE &394b
&3928: a5 43            LDA &43 ; this_object_vel_x
&392a: 20 56 32         JSR &3256 ; make_positive
&392d: 4a               LSR
&392e: f0 18            BEQ &3948
&3930: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&3933: a9 02            LDA #&02
&3935: b0 14            BCS &394b
&3937: a9 08            LDA #&08
&3939: 20 55 25         JSR &2555
&393c: 4a               LSR
&393d: 48               PHA
&393e: a5 43            LDA &43 ; this_object_vel_x
&3940: 45 37            EOR &37 ; this_object_angle
&3942: 2a               ROL
&3943: 68               PLA
&3944: 90 02            BCC &3948
&3946: 49 03            EOR #&03
&3948: 18               CLC
&3949: 69 04            ADC #&04
&394b: 4c 98 32         JMP &3298 ; convert_object_keeping_palette

; null_function
&394e: 60               RTS

# (unused)
#394f: 00
#3950: 28 43 29 20 31 39 38 39 42 45 45 42 53 4f 46 54
#3960: 00 00

;       0  1  2  3  4  5  6
;            fl sl tu    mg
#3962: 32 80 80 20 20 20 80 ; unknown_lookup_3962
#3969: 06 08 10 03 04 05 08 ; unknown_lookup_3969
#3970: 00 01 01 01 01 01 01 ; unknown_lookup_3970	# these two are
#3977: ea c8 c8 10 00 00 c8 ; unknown_lookup_3977	# something to do with bouncing / tunneling
#397e: ea 40 08 08 00 00 10 ; unknown_lookup_397e	# something to do with sprite changing

; find_wall_underneath_y
&3985: a5 3a            LDA &3a ; this_object_width			        # get centre of object
&3987: 4a               LSR					
&3988: 65 4f            ADC &4f ; this_object_x_low
&398a: 85 87            STA &87 ; this_object_centre_x_low		        # into this_object_centre_x_low
&398c: a5 53            LDA &53 ; this_object_x
&398e: 69 00            ADC #&00
&3990: 85 95            STA &95 ; square_x				        # and square_x
&3992: a5 49            LDA &49 ; this_object_y_max_low			        # get bottom of object
&3994: 85 89            STA &89 ; this_object_centre_y_low		        # into this_object_centre_y_low
&3996: a5 4a            LDA &4a ; this_object_y_max
&3998: 85 97            STA &97 ; square_y				        # and square_y
&399a: d0 29            BNE &39c5 ; no_recalculate_centres		        # assuming it's well defined
; recalc_called_from_bob_up_and_down
&399c: 20 88 22         JSR &2288 ; get_object_centre
&399f: a5 87            LDA &87 ; this_object_centre_x_low		        # otherwise...
&39a1: e9 7f            SBC #&7f
&39a3: 85 87            STA &87 ; this_object_centre_x_low
&39a5: a5 8b            LDA &8b ; this_object_centre_x
&39a7: e9 00            SBC #&00
&39a9: 85 95            STA &95 ; square_x
&39ab: 20 77 3b         JSR &3b77
&39ae: 30 02            BMI &39b2
&39b0: e6 95            INC &95 ; square_x
&39b2: a5 4b            LDA &4b
&39b4: 4a               LSR
&39b5: 65 49            ADC &49 ; this_object_y_max_low
&39b7: 08               PHP
&39b8: e9 7f            SBC #&7f
&39ba: 85 89            STA &89 ; this_object_centre_y_low
&39bc: a5 4a            LDA &4a ; this_object_y_max
&39be: e9 00            SBC #&00
&39c0: 28               PLP
&39c1: 69 00            ADC #&00
&39c3: 85 97            STA &97 ; square_y
; no_recalculate_centres
&39c5: 86 ae            STX &ae ; tmp_x                                         # preserve x
&39c7: a5 87            LDA &87 ; this_object_centre_x_low
&39c9: 4a               LSR
&39ca: 4a               LSR
&39cb: 4a               LSR
&39cc: 4a               LSR
&39cd: 4a               LSR
&39ce: a8               TAY                                                     # Y = x_low / 32, for wall check
&39cf: a9 00            LDA #&00
&39d1: 85 83            STA &83 ; bob_y_low   
&39d3: a9 40            LDA #&40
&39d5: 85 2d            STA &2d ; background_processing_flag
&39d7: a5 89            LDA &89 ; this_object_centre_y_low                      # consider the bottom of the object
&39d9: 29 f8            AND #&f8
&39db: 09 04            ORA #&04
&39dd: 85 81            STA &81 ; square_y_low
&39df: 84 9e            STY &9e ; square_x_low
&39e1: 20 53 24         JSR &2453 ; get_wall_start_7c_7f
&39e4: a4 9e            LDY &9e ; square_x_low                                  # previously calculated Y
&39e6: b1 7c            LDA (&7c),Y ; wall_y_start_lookup_pointer               # is there a wall there?
&39e8: 18               CLC
&39e9: 65 7e            ADC &7e ; wall_y_start_base
&39eb: 90 02            BCC &39ef
&39ed: a9 ff            LDA #&ff
&39ef: aa               TAX                                                     # x = wall start
&39f0: c5 81            CMP &81 ; square_y_low
&39f2: 6a               ROR
&39f3: 45 7f            EOR &7f ; wall_sprite
&39f5: 10 22            BPL &3a19 ; bob_wall_present                            # if so, leave
&39f7: 24 7f            BIT &7f ; wall_sprite
&39f9: 10 10            BPL &3a0b
&39fb: a5 81            LDA &81 ; square_y_low
&39fd: 49 ff            EOR #&ff
&39ff: 65 83            ADC &83 ; bob_y_low   
&3a01: b0 12            BCS &3a15
&3a03: 85 83            STA &83 ; bob_y_low   
&3a05: e6 97            INC &97 ; square_y
&3a07: a9 04            LDA #&04
&3a09: d0 d2            BNE &39dd
&3a0b: 8a               TXA
&3a0c: e8               INX
&3a0d: f0 ec            BEQ &39fb
&3a0f: e5 81            SBC &81
&3a11: 65 83            ADC &83 ; bob_y_low   
&3a13: 90 02            BCC &3a17
&3a15: a9 ff            LDA #&ff
&3a17: 85 83            STA &83 ; bob_y_low   
; bob_wall_present
&3a19: a6 ae            LDX &ae ; tmp_x
&3a1b: a5 83            LDA &83 ; bob_y_low   
&3a1d: 60               RTS

; bob_up_and_down
&3a1e: 24 c5            BIT &c5 ; loop_counter_every_04
&3a20: 10 31            BPL &3a53                                               # once every four cycles
&3a22: a5 3c            LDA &3c ; this_object_height
&3a24: 49 ff            EOR #&ff
&3a26: 4a               LSR
&3a27: 85 8a            STA &8a ; half_minus_height
&3a29: 20 85 39         JSR &3985 ; find_wall_underneath_y                      # where is the wall underneath us?
&3a2c: c9 ff            CMP #&ff
&3a2e: f0 11            BEQ &3a41 ; no_wall_underneath
&3a30: c5 8a            CMP &8a ; half_minus_height
&3a32: b0 1f            BCS &3a53
&3a34: 20 87 25         JSR &2587 ; increment_timers
&3a37: 09 c0            ORA #&c0
&3a39: 65 83            ADC &83 ; bob_y_low
&3a3b: b0 02            BCS &3a3f
&3a3d: c6 42            DEC &42 ; acceleration_y                                # green slimes bob up and down
&3a3f: c6 42            DEC &42 ; acceleration_y
; no_wall_underneath
&3a41: c6 42            DEC &42 ; acceleration_y                                # and float somewhat
&3a43: 4c 25 32         JMP &3225 ; dampen_this_object_vel_y
&3a46: 24 c5            BIT &c5 ; loop_counter_every_04
&3a48: 18               CLC
&3a49: 10 08            BPL &3a53                                               # once every four cycles
&3a4b: 20 9c 39         JSR &399c ; recalc_called_from_bob_up_and_down
&3a4e: 38               SEC
&3a4f: f0 02            BEQ &3a53
&3a51: c9 ff            CMP #&ff
&3a53: 60               RTS

&3a54: 20 86 3b         JSR &3b86 ; compare_extra_with_1_and_f
&3a57: b0 fa            BCS &3a53
&3a59: a5 04            LDA &04 ; npc_speed                                     # velocity magnitude
&3a5b: a8               TAY                                                     # maximum speed
&3a5c: 86 ae            STX &ae
&3a5e: 20 d8 31         JSR &31d8 ; move_towards_target
&3a61: a6 ae            LDX &ae
&3a63: a5 42            LDA &42 ; acceleration_y
&3a65: e9 0a            SBC #&0a
&3a67: 85 42            STA &42 ; acceleration_y
&3a69: 18               CLC
&3a6a: 4c 7a 2c         JMP &2c7a ; or_extra_with_0f

&3a6d: 24 05            BIT &05 ; something_about_player_angle
&3a6f: 10 f9            BPL &3a6a
&3a71: a5 1b            LDA &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&3a73: 0d e5 29         ORA &29e5 ; object_collision_with_other_object_top_bottom
&3a76: 38               SEC
&3a77: 10 03            BPL &3a7c
&3a79: 20 ad 3b         JSR &3bad ; compare_wall_collision_angle_with_3962
&3a7c: a5 11            LDA &11 ; this_object_extra
&3a7e: 29 f0            AND #&f0
&3a80: 90 0a            BCC &3a8c
&3a82: 45 11            EOR &11 ; this_object_extra
&3a84: c9 0f            CMP #&0f
&3a86: b0 e2            BCS &3a6a
&3a88: e6 11            INC &11 ; this_object_extra
&3a8a: a5 11            LDA &11 ; this_object_extra
&3a8c: 85 11            STA &11 ; this_object_extra
&3a8e: 60               RTS

&3a8f: a9 1f            LDA #&1f
&3a91: 85 04            STA &04 ; npc_speed
&3a93: a5 07            LDA &07 ; current_object_rotator_low
&3a95: c9 02            CMP #&02
&3a97: a5 38            LDA &38 ; this_object_weight
&3a99: e9 05            SBC #&05
&3a9b: a8               TAY
&3a9c: 90 1f            BCC &3abd
&3a9e: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&3aa1: 90 1a            BCC &3abd
&3aa3: 24 19            BIT &19 ; any_collision_top_bottom
&3aa5: 30 16            BMI &3abd
&3aa7: a2 02            LDX #&02
&3aa9: b5 40            LDA &40,X
&3aab: c9 80            CMP #&80
&3aad: 6a               ROR
&3aae: 10 02            BPL &3ab2
&3ab0: 69 00            ADC #&00
&3ab2: 95 40            STA &40,X
&3ab4: ca               DEX
&3ab5: ca               DEX
&3ab6: f0 f1            BEQ &3aa9
&3ab8: 88               DEY
&3ab9: 10 ec            BPL &3aa7
&3abb: 30 4e            BMI &3b0b
&3abd: a9 0f            LDA #&0f
&3abf: c8               INY
&3ac0: 4a               LSR
&3ac1: 88               DEY
&3ac2: 10 fc            BPL &3ac0
&3ac4: 69 01            ADC #&01
&3ac6: a4 40            LDY &40 ; acceleration_x
&3ac8: 84 d2            STY &d2 ; something_x_acc
&3aca: d0 04            BNE &3ad0
&3acc: 84 04            STY &04 ; npc_speed
&3ace: a9 01            LDA #&01
&3ad0: 8d 69 39         STA &3969 ; unknown_lookup_3969
&3ad3: a2 00            LDX #&00
&3ad5: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&3ad8: b0 02            BCS &3adc
&3ada: 86 40            STX &40 ; acceleration_x
&3adc: 4c 0b 3b         JMP &3b0b

; commenting this out stops slime from moving
; something_motion_related
turret x = &04 a = &18
slime  x = &03 a = &0c
fluffy x = &02 a = &28
maggot x = &06 a = &08
; A = speed
; X = type
&3adf: 85 04            STA &04 ; npc_speed
&3ae1: 20 08 3b         JSR &3b08 ; some_other_npc_stuff
&3ae4: 20 46 3a         JSR &3a46
&3ae7: 90 13            BCC &3afc
&3ae9: 20 87 25         JSR &2587 ; increment_timers
&3aec: dd 77 39         CMP &3977,X ; unknown_lookup_3977
&3aef: 90 13            BCC &3b04
&3af1: a9 01            LDA #&01
&3af3: 24 d2            BIT &d2 ; something_x_acc
&3af5: 20 4c 32         JSR &324c ; make_negative
&3af8: 65 53            ADC &53 ; this_object_x
&3afa: 85 14            STA &14 ; this_object_tx
&3afc: 20 87 25         JSR &2587 ; increment_timers
&3aff: dd 7e 39         CMP &397e,X ; unknown_lookup_397e
&3b02: b0 03            BCS &3b07
&3b04: 4c 54 3a         JMP &3a54
&3b07: 60               RTS

; some_other_npc_stuff
&3b08: 20 77 3b         JSR &3b77
&3b0b: 20 6d 3a         JSR &3a6d
&3b0e: 29 0f            AND #&0f
&3b10: d0 73            BNE &3b85
&3b12: bc 69 39         LDY &3969,X ; unknown_lookup_3969
&3b15: 84 9c            STY &9c
&3b17: bc 70 39         LDY &3970,X; unknown_lookup_3970
&3b1a: 20 ad 3b         JSR &3bad ; compare_wall_collision_angle_with_3962
&3b1d: e9 2c            SBC #&2c
&3b1f: c9 28            CMP #&28
&3b21: a5 04            LDA &04 ; npc_speed
&3b23: 90 36            BCC &3b5b
&3b25: 24 d2            BIT &d2 ; something_x_acc
&3b27: 20 56 32         JSR &3256 ; make_positive
&3b2a: 38               SEC
&3b2b: e5 43            SBC &43 ; this_object_vel_x
&3b2d: 20 01 32         JSR &3201
&3b30: a8               TAY
&3b31: 29 80            AND #&80
&3b33: 45 1c            EOR &1c ; wall_collision_angle
&3b35: 69 40            ADC #&40
&3b37: 0a               ASL
&3b38: a5 d2            LDA &d2 ; something_x_acc
&3b3a: d0 02            BNE &3b3e
&3b3c: a0 00            LDY #&00
&3b3e: a9 10            LDA #&10
&3b40: 90 02            BCC &3b44
&3b42: a9 6f            LDA #&6f
&3b44: 65 1c            ADC &1c ; wall_collision_angle
&3b46: 85 b5            STA &b5 ; angle
&3b48: 98               TYA
&3b49: 20 56 32         JSR &3256 ; make_positive
&3b4c: 20 57 23         JSR &2357 ; determine_velocities_from_angle	        # A = velocity_y
&3b4f: 85 42            STA &42 ; acceleration_y
&3b51: a5 b4            LDA &b4 ; velocity_x
&3b53: 85 40            STA &40 ; acceleration_x
&3b55: 20 25 32         JSR &3225 ; dampen_this_object_vel_y
&3b58: 4c 25 32         JMP &3225 ; dampen_this_object_vel_y
&3b5b: 24 d4            BIT &d4 ; something_y_acc
&3b5d: 20 56 32         JSR &3256 ; make_positive
&3b60: a2 02            LDX #&02
&3b62: 20 f6 31         JSR &31f6
&3b65: a9 08            LDA #&08
&3b67: 24 1c            BIT &1c ; wall_collision_angle
&3b69: 20 4c 32         JSR &324c ; make_negative
&3b6c: 85 40            STA &40 ; acceleration_x
&3b6e: 20 2d 32         JSR &322d ; dampen_this_object_vel_x
&3b71: 20 2d 32         JSR &322d ; dampen_this_object_vel_x
&3b74: 4c 2d 32         JMP &322d ; dampen_this_object_vel_x
&3b77: a5 16            LDA &16 ; this_object_ty
&3b79: 18               CLC
&3b7a: e5 55            SBC &55 ; this_object_y
&3b7c: 85 d4            STA &d4 ; something_y_acc
&3b7e: a5 14            LDA &14 ; this_object_tx
&3b80: 38               SEC
&3b81: e5 53            SBC &53 ; this_object_x
&3b83: 85 d2            STA &d2 ; something_x_acc
&3b85: 60               RTS

; compare_extra_with_1_and_f
&3b86: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&3b89: c9 01            CMP #&01
&3b8b: 60               RTS

; compare_extra_with_a_and_f
&3b8c: a5 11            LDA &11 ; this_object_extra
&3b8e: 29 0f            AND #&0f
&3b90: c9 0a            CMP #&0a
&3b92: 60               RTS

; p_pressed
&3b93: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&3b96: c9 05            CMP #&05
&3b98: b0 32            BCS &3bcc
&3b9a: a9 f6            LDA #&f6
&3b9c: 2c 80 12         BIT &1280 ; @_pressed                                   # is the booster pressed?
&3b9f: 10 02            BPL &3ba3
&3ba1: a9 f0            LDA #&f0
&3ba3: 65 38            ADC &38 ; this_object_weight
&3ba5: 0a               ASL
&3ba6: 65 45            ADC &45 ; this_object_vel_y
&3ba8: 85 45            STA &45 ; this_object_vel_y
&3baa: 46 05            LSR &05 ; something_about_player_angle
&3bac: 60               RTS

; compare_wall_collision_angle_with_3962
&3bad: a5 1c            LDA &1c ; wall_collision_angle
&3baf: 20 56 32         JSR &3256 ; make_positive
&3bb2: dd 62 39         CMP &3962,X ; unknown_lookup_3962
&3bb5: 60               RTS

; get_biggest_velocity
&3bb6: a5 45            LDA &45 ; this_object_vel_y
&3bb8: 20 56 32         JSR &3256 ; make_positive
&3bbb: a8               TAY
&3bbc: a5 43            LDA &43 ; this_object_vel_x
&3bbe: 20 56 32         JSR &3256 ; make_positive
; get_biggest_of_a_and_y
&3bc1: 84 9d            STY &9d
&3bc3: c5 9d            CMP &9d
&3bc5: b0 05            BCS &3bcc
&3bc7: a8               TAY
&3bc8: a5 9d            LDA &9d
&3bca: 84 9d            STY &9d
&3bcc: 60               RTS

; return_sign_as_01_or_ff
&3bcd: 0a               ASL
&3bce: a9 ff            LDA #&ff
&3bd0: b0 fa            BCS &3bcc
&3bd2: a9 01            LDA #&01
&3bd4: 60               RTS

; can_we_pick_up_object
&3bd5: a6 3b            LDX &3b ; this_object_supporting		        # are we touching anything?
&3bd7: 30 07            BMI &3be0					        # if not, leave
&3bd9: 20 a0 22         JSR &22a0 ; get_angle_between_objects                   # get the angle between us and it
&3bdc: 69 40            ADC #&40                                                # ninety degrees
&3bde: 45 37            EOR &37 ; this_object_angle                             # are we facing it?
&3be0: 60               RTS

; absorb_object
&3be1: a4 3b            LDY &3b ; this_object_supporting
&3be3: d9 60 08         CMP &0860,Y ; object_stack_type			        # consider the object we're supporting
&3be6: d0 0f            BNE &3bf7					        # is it what we want? if not, leave
&3be8: 20 d5 3b         JSR &3bd5 ; can_we_pick_up_object
&3beb: 30 0a            BMI &3bf7					        # if we're not supporting anything, leave
&3bed: a4 3b            LDY &3b ; this_object_supporting
&3bef: 20 16 25         JSR &2516 ; mark_stack_object_for_removal
&3bf2: 20 ad 14         JSR &14ad ; play_low_beep
&3bf5: a9 00            LDA #&00					        # return nothing if collected
&3bf7: 60               RTS

; find_target_occasionally
# A, Y => find
&3bf8: a6 07            LDX &07 ; current_object_rotator_low
&3bfa: e0 0f            CPX #&0f
&3bfc: 30 19            BMI &3c17                                               # once every sixteen cycles
; find_target
&3bfe: 20 2a 3c         JSR &3c2a ; find_nearest_object                         # find nearest object as per A, Y
&3c01: 30 14            BMI &3c17                                               # if nothing found, leave
&3c03: 86 0e            STX &0e ; this_object_target_object
&3c05: a9 40            LDA #&40
&3c07: d0 0c            BNE &3c15

; avoid_fireballs
&3c09: a9 37            LDA #&37                                                # &37 = fireball
&3c0b: a8               TAY                                                     # look only for fireballs
; avoid_a
&3c0c: 20 f8 3b         JSR &3bf8 ; find_target_occasionally
&3c0f: 30 06            BMI &3c17
; flag_target_as_avoid
&3c11: a5 3e            LDA &3e ; this_object_target
&3c13: 09 20            ORA #&20
&3c15: 85 3e            STA &3e ; this_object_target
&3c17: 60               RTS

# A = object type
; count_objects_of_type_a_in_stack
# leaves with Y = count
&3c18: a0 7f            LDY #&7f
&3c1a: 38               SEC
&3c1b: 20 30 3c         JSR &3c30 ; in_find_nearest_object
&3c1e: a4 9f            LDY &9f ; count
&3c20: 60               RTS

#3c21: 80 ff 20 80 ; find_object_probabilities

#3c25: 00 ; nearest_object
#3c26: 00 ; find_first_7f
#3c27: 00 ; find_second
#3c28: 00 ; nearest_distance
#3c29: 00 ; find_first

; find_nearest_object
# A & &80 : note player too
# A & &7f = object type to look for
# Y & &80 : consider objects in range too
# Y & &7f = object range to look for
# else Y &7f = second object type to look for
# if carry set, simply count the number of matching objects in primary stack, return in &9f
# if carry clear, find the nearest matching object and return number in X
&3c2a: 18               CLC
&3c2b: 24 38            BIT &38 ; this_object_weight
&3c2d: 66 9b            ROR &9b ; weight_bit    
&3c2f: 18               CLC
; in_find_nearest_object
&3c30: 66 a1            ROR &a1 ; find_carry                                    # note whether we're finding or counting
&3c32: 8d 29 3c         STA &3c29 ; find_first
&3c35: 29 7f            AND #&7f
&3c37: 8d 26 3c         STA &3c26 ; find_first_7f
&3c3a: 8c 27 3c         STY &3c27 ; find_second
&3c3d: a2 ff            LDX #&ff
&3c3f: 8e 25 3c         STX &3c25 ; nearest_object                              # initially &ff
&3c42: 8e 28 3c         STX &3c28 ; nearest_distance                            # initially &ff
&3c45: e8               INX
&3c46: 86 a0            STX &a0 ; result                                        # initially &00
&3c48: 86 9f            STX &9f ; count                                         # initially &00
&3c4a: 20 87 25         JSR &2587 ; increment_timers
&3c4d: 29 0f            AND #&0f
&3c4f: 85 a3            STA &a3 ; rnd_0f                                        # get a random number &00 - &0f
&3c51: a0 0f            LDY #&0f
; find_object_object_loop
&3c53: 84 9e            STY &9e ; y_store                                       # starting at that random place
&3c55: 98               TYA
&3c56: 45 a3            EOR &a3 ; rnd_0f
&3c58: a8               TAY                                                     
&3c59: b9 b4 08         LDA &08b4,Y ; object_stack_y                            # consider the objects in turn
&3c5c: f0 6b            BEQ &3cc9 ; find_object_next_object                     # does it exist? if not, move to next
&3c5e: c4 aa            CPY &aa ; current_object                               
&3c60: f0 67            BEQ &3cc9 ; find_object_next_object                     # don't consider the npc
&3c62: b9 60 08         LDA &0860,Y ; object_stack_type
&3c65: d0 05            BNE &3c6c ; find_object_object_not_player               # is the object the player?
&3c67: 2c 29 3c         BIT &3c29 ; find_first
&3c6a: 30 05            BMI &3c71                                               # if find_first & &80, then note that in result
; find_object_object_not_player
&3c6c: cd 26 3c         CMP &3c26 ; find_first_7f                               # is it the type we're interested in?
&3c6f: d0 06            BNE &3c77 ; find_object_not_special
&3c71: a5 a0            LDA &a0 ; result
&3c73: 09 01            ORA #&01                                                # if so, note it in the result
&3c75: d0 14            BNE &3c8b ; find_object_found_one
; find_object_not_special
&3c77: 2c 27 3c         BIT &3c27 ; find_second
&3c7a: 10 06            BPL &3c82 ; find_object_y_positive
&3c7c: 20 b0 2d         JSR &2db0 ; convert_object_to_range_a                   # returns object range in X
&3c7f: 8a               TXA
&3c80: 09 80            ORA #&80                                                # A = range | &80
; find_object_y_positive
&3c82: cd 27 3c         CMP &3c27 ; find_second                                 # in other words, if in_Y & &80
&3c85: d0 42            BNE &3cc9 ; find_object_next_object                     # only count results not in our range
&3c87: a5 a0            LDA &a0 ; result                                        # (the range set by find_second &7f)
&3c89: 29 02            AND #&02                                                # clear bottom bit of result
; find_object_found_one
&3c8b: 29 03            AND #&03
&3c8d: 85 a0            STA &a0 ; result
&3c8f: aa               TAX
&3c90: e6 9f            INC &9f ; count                                         # count contains total number of matches
&3c92: 24 a1            BIT &a1 ; find_carry                                    # was the carry set when function called?
&3c94: 30 33            BMI &3cc9 ; find_object_next_object                     # if so, move on to the next object
&3c96: 20 87 25         JSR &2587 ; increment_timers
&3c99: dd 21 3c         CMP &3c21,X ; find_object_probabilities                 # X = result
&3c9c: b0 2b            BCS &3cc9 ; find_object_next_object                     # a random chance based on result to skip
&3c9e: 98               TYA
&3c9f: aa               TAX                                                     # X = object being considered
&3ca0: 24 9b            BIT &9b ; weight_bit
&3ca2: 10 0e            BPL &3cb2 ; find_object_unset_weight_bit
&3ca4: a9 00            LDA #&00
&3ca6: 20 9c 35         JSR &359c ; is_object_close_enough                      # get distance to object
&3ca9: a5 83            LDA &83 ; distance
&3cab: cd 28 3c         CMP &3c28 ; nearest_distance                            # is it nearer than earlier finds?
&3cae: 90 11            BCC &3cc1 ; find_object_store_distance                  # if nearer, store it
&3cb0: b0 17            BCS &3cc9 ; find_object_next_object                     # if further away, ignore it
&3cb2: 20 87 25         JSR &2587 ; increment_timers
&3cb5: 29 4f            AND #&4f
&3cb7: 4d 28 3c         EOR &3c28 ; nearest_distance
&3cba: 20 9c 35         JSR &359c ; is_object_close_enough                      # otherwise, pick one at random
&3cbd: b0 0a            BCS &3cc9
&3cbf: a5 83            LDA &83 ; distance
; find_object_store_distance
&3cc1: 8d 28 3c         STA &3c28 ; nearest_distance
&3cc4: 06 a0            ASL &a0 ; result
&3cc6: 8e 25 3c         STX &3c25 ; nearest_object
; find_object_next_object
&3cc9: a4 9e            LDY &9e ; y_store                                       # move on to considering the next object
&3ccb: 88               DEY
&3ccc: 10 85            BPL &3c53 ; find_object_object_loop                     # until we've done all sixteen
&3cce: 46 a0            LSR &a0 ; result
&3cd0: 46 a0            LSR &a0 ; result                                        # carry set to be result & &02
&3cd2: ae 25 3c         LDX &3c25 ; nearest_object
&3cd5: 60               RTS

; compare_this_object_x_y_tx_ty
&3cd6: a5 16            LDA &16 ; this_object_ty
&3cd8: c5 55            CMP &55 ; this_object_y
&3cda: d0 04            BNE &3ce0
&3cdc: a5 14            LDA &14 ; this_object_tx
&3cde: c5 53            CMP &53 ; this_object_x
&3ce0: 60               RTS

#3ce1: 00 ; angle_randomness
#3ce2: 00 ; angle_minus_half_angle_randomness
#3ce3: 00 ; best_distance 
#3ce4: 00 ; best_angle 
#3ce5: 00 ; route_chooser_loop

; do_we_have_a_target
# returns X = target
&3ce6: a6 0e            LDX &0e ; this_object_target_object                     # consider our target object
&3ce8: bd b4 08         LDA &08b4,X ; object_stack_y
&3ceb: d0 06            BNE &3cf3                                               # does it exist?
&3ced: a6 aa            LDX &aa ; current_object
&3cef: 86 0e            STX &0e ; this_object_target_object                     # if not, set target to be ourself
&3cf1: 86 3e            STX &3e ; this_object_target
&3cf3: e4 aa            CPX &aa ; current_object                                # do we have a target? 
&3cf5: 60               RTS

; set_targetting_flags
# if our target is close, flag with &80 and &40; if avoiding, flee
# if too far and &80 set, unflag both &80 and &40
&3cf6: a5 07            LDA &07 ; current_object_rotator_low
&3cf8: d0 2b            BNE &3d25                                               # once every sixteen cycles
&3cfa: 20 e6 3c         JSR &3ce6 ; do_we_have_a_target                         # X = target
&3cfd: f0 37            BEQ &3d36 ; no_target                                   # if no target, leave
&3cff: 20 9a 35         JSR &359a ; is_object_close_enough_80
&3d02: b0 19            BCS &3d1d ; target_too_far                              # is our target close enough?
&3d04: a5 3e            LDA &3e ; this_object_target
&3d06: 09 c0            ORA #&c0                                                # if so, flag with &80 and &40
&3d08: 85 3e            STA &3e ; this_object_target                            
&3d0a: 29 20            AND #&20
&3d0c: d0 03            BNE &3d11 ; avoiding_target                             # are we avoiding the target?
&3d0e: 4c 83 28         JMP &2883 ; get_object_x_y_to_tx_ty                     # if not, store its position in tx, ty
; avoiding_target
&3d11: 20 a0 22         JSR &22a0 ; get_angle_between_objects                   # get the angle between us and the target
&3d14: 49 80            EOR #&80                                                # use the opposite direction
&3d16: 85 b5            STA &b5 ; angle
&3d18: a9 7f            LDA #&7f                                                # angle randomness = &7f
&3d1a: 4c a7 3d         JMP &3da7 ; choose_route_to_target_a
; target_too_far
&3d1d: a5 3e            LDA &3e ; this_object_target
&3d1f: 10 04            BPL &3d25                                               # if &80 set, unflag both &80 and &40
&3d21: 29 bf            AND #&bf                               
&3d23: 85 3e            STA &3e ; this_object_target
&3d25: 60               RTS

; target_processing
&3d26: 20 f6 3c         JSR &3cf6 ; set_targetting_flags                        # set flags if close enough
&3d29: 24 3e            BIT &3e ; this_object_target                            # have we got a target?
&3d2b: 30 04            BMI &3d31                                               # target &80
&3d2d: 50 39            BVC &3d68                                               # target &c0 = &00
&3d2f: 70 0f            BVS &3d40                                               # V = bit 6 = &40
; target &c0 = &c0 or &80
&3d31: 20 98 3d         JSR &3d98 ; possibly_get_speed_to_y_based_on_same_square
&3d34: d0 09            BNE &3d3f                                               # generally leave with A = &07 or A = &3f
; no_target
&3d36: 38               SEC
&3d37: a5 3e            LDA &3e ; this_object_target
&3d39: e9 40            SBC #&40                                                # &c0 becomes &80, &80 becomes &40, &40 becomes &00
&3d3b: 90 02            BCC &3d3f
&3d3d: 85 3e            STA &3e ; this_object_target
&3d3f: 60               RTS

; target &c0 = &40
&3d40: 20 87 25         JSR &2587 ; increment_timers
&3d43: 29 03            AND #&03
&3d45: f0 21            BEQ &3d68 ; no_target                                   # one in four chance to drop a notch
&3d47: 4a               LSR
&3d48: 05 da            ORA &da ; timer_2
&3d4a: f0 ea            BEQ &3d36
&3d4c: 20 94 3d         JSR &3d94 ; possibly_get_speed_to_y_based_on_same_square_with_bit_1b
&3d4f: d0 53            BNE &3da4
&3d51: a6 0e            LDX &0e ; this_object_target_object
&3d53: a9 20            LDA #&20                                                # magnitude
&3d55: 20 47 33         JSR &3347 ; get_object_centre_and_determine_velocities_from_angle
&3d58: a5 3e            LDA &3e ; this_object_target
&3d5a: 29 20            AND #&20
&3d5c: f0 06            BEQ &3d64
&3d5e: a5 b5            LDA &b5 ; angle
&3d60: 49 80            EOR #&80
&3d62: 85 b5            STA &b5 ; angle
&3d64: a9 3f            LDA #&3f                                                # angle randomness = &3f
&3d66: d0 3f            BNE &3da7 ; choose_route_to_target_a
; target &c0 = &00
&3d68: 20 94 3d         JSR &3d94 ; possibly_get_speed_to_y_based_on_same_square_with_bit_1b
&3d6b: d0 37            BNE &3da4       # rotator
&3d6d: 20 87 25         JSR &2587 ; increment_timers
&3d70: 29 07            AND #&07
&3d72: e9 03            SBC #&03
&3d74: 65 43            ADC &43 ; this_object_vel_x
&3d76: 85 b4            STA &b4 ; velocity_x                                    # velocity_x = object_vel_x + rnd(4) - 7
&3d78: a5 d9            LDA &d9 ; timer_1
&3d7a: 29 07            AND #&07
&3d7c: e9 03            SBC #&03
&3d7e: 65 45            ADC &45 ; this_object_vel_y                             # velocity_y = object_vel_y + rnd(4) - 7
&3d80: 20 d2 22         JSR &22d2 ; essentially calculate_angle_from_velocities
&3d83: a9 ff            LDA #&ff
&3d85: a6 da            LDX &da ; timer_2                                       # randomly pick an angle randomness:
&3d87: e0 08            CPX #&08
&3d89: 90 06            BCC &3d91                                               # &08 probability that A = &ff
&3d8b: 4a               LSR
&3d8c: e0 40            CPX #&40                                                # &38 probability that A = &7f
&3d8e: 90 01            BCC &3d91
&3d90: 4a               LSR                                                     # &c0 probability that A = &3f
&3d91: 4c a7 3d         JMP &3da7 ; choose_route_to_target_a

; possibly_get_speed_to_y_based_on_same_square_with_bit_1b
&3d94: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&3d96: 30 07            BMI &3d9f
; target_&c0 = &80
; possibly_get_speed_to_y_based_on_same_square
&3d98: a0 3f            LDY #&3f
&3d9a: 20 d6 3c         JSR &3cd6 ; compare_this_object_x_y_tx_ty	        # are we at our target?
&3d9d: d0 02            BNE &3da1
&3d9f: a0 07            LDY #&07
&3da1: 98               TYA
&3da2: 24 06            BIT &06 ; current_object_rotator
&3da4: 60               RTS

; choose_route_to_target
&3da5: a9 ff            LDA #&ff
; choose_route_to_target_a
&3da7: 8d e1 3c         STA &3ce1 ; angle_randomness                            # angle_randomness = A
&3daa: 4a               LSR
&3dab: 85 9d            STA &9d ; half_angle_randomness
&3dad: a5 b5            LDA &b5 ; angle
&3daf: e5 9d            SBC &9d ; half_angle_randomness
&3db1: 8d e2 3c         STA &3ce2 ; angle_minus_half_angle_randomness
&3db4: a9 04            LDA #&04
&3db6: 8d e5 3c         STA &3ce5 ; route_chooser_loop
&3db9: 8d e3 3c         STA &3ce3 ; best_distance 
; choose_route_loop
&3dbc: 20 87 25         JSR &2587 ; increment_timers                            # consider four random angles
&3dbf: 2d e1 3c         AND &3ce1 ; angle_randomness
&3dc2: 6d e2 3c         ADC &3ce2 ; angle_minus_half_angle_randomness
&3dc5: 85 b5            STA &b5 ; angle                                         # angle +/- rnd(angle_randomness / 2)
&3dc7: 48               PHA
&3dc8: a9 20            LDA #&20                                                # magnitude
&3dca: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&3dcd: 20 87 25         JSR &2587 ; increment_timers
&3dd0: 29 1f            AND #&1f                                                # consider a random distance &10 - &3f
&3dd2: 69 10            ADC #&10
&3dd4: 4e 98 35         LSR &3598 ; los_consider_water                          # ignore water
&3dd7: 20 d5 35         JSR &35d5 ; line_of_sight_without_obstructions          # are there any obstacles over that distance?
&3dda: 68               PLA
&3ddb: 90 28            BCC &3e05 ; store_square_x_y_in_tx_ty                   # if not, we've got a route - use it
&3ddd: a6 83            LDX &83 ; distance
&3ddf: ec e3 3c         CPX &3ce3 ; best_distance
&3de2: 90 06            BCC &3dea                                               # is this route better than our best?
&3de4: 8e e3 3c         STX &3ce3 ; best_distance                               # if so, note it as the best so far
&3de7: 8d e4 3c         STA &3ce4 ; best_angle
&3dea: ce e5 3c         DEC &3ce5 ; route_chooser_loop
&3ded: d0 cd            BNE &3dbc ; choose_route_loop                           # if none offer a direct route
&3def: ad e4 3c         LDA &3ce4 ; best_angle                                  # pick the one with the maximum distance
&3df2: 85 b5            STA &b5 ; angle
&3df4: a9 20            LDA #&20
&3df6: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&3df9: ad e3 3c         LDA &3ce3 ; best_distance
&3dfc: c9 0a            CMP #&0a
&3dfe: 90 0d            BCC &3e0d                                               # leave if it's a really short distance
&3e00: e9 08            SBC #&08                                                # otherwise move almost to the obstacle
&3e02: 20 d5 35         JSR &35d5 ; line_of_sight_without_obstructions          # note the destination square as our target
; store_square_x_y_in_tx_ty
&3e05: a5 95            LDA &95 ; square_x
&3e07: 85 14            STA &14 ; this_object_tx
&3e09: a5 97            LDA &97 ; square_y
&3e0b: 85 16            STA &16 ; this_object_ty
&3e0d: 60               RTS

&3e0e: 60               RTS

; push_palette_register_data
&3e0f: a0 10            LDY #&10
&3e11: b9 e4 11         LDA &11e4,Y ; palette_register_data
&3e14: 8d 21 fe         STA &fe21                                               # video ULA palette register
&3e17: 88               DEY
&3e18: d0 f7            BNE &3e11
&3e1a: 60               RTS

; handle_background_object_emerging
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3e1b: f0 6b            BEQ &3e88						# is object_data_pointer = 0? if so, leave
&3e1d: a2 05            LDX #&05
&3e1f: a5 2d            LDA &2d ; background_processing_flag
&3e21: 29 90            AND #&90
&3e23: f0 23            BEQ &3e48
&3e25: 10 02            BPL &3e29
&3e27: a2 00            LDX #&00
&3e29: a5 09            LDA &09 ; square_orientation
&3e2b: 0a               ASL
&3e2c: b9 86 09         LDA &0986,Y ; background_objects_data
&3e2f: 10 1c            BPL &3e4d						# is the object already present?
&3e31: 08               PHP
&3e32: 8a               TXA
&3e33: 48               PHA
&3e34: a9 40            LDA #&40						# &40 = bush
&3e36: 20 42 40         JSR &4042 ; pull_objects_in_from_tertiary_stack
&3e39: a9 40            LDA #&40
&3e3b: 99 a3 08         STA &08a3,Y ; object_stack_y_low
&3e3e: 99 80 08         STA &0880,Y ; object_stack_x_low
&3e41: a4 bd            LDY &bd ; new_object_data_pointer
&3e43: 68               PLA
&3e44: aa               TAX
&3e45: 28               PLP
&3e46: 30 05            BMI &3e4d
&3e48: 20 87 25         JSR &2587 ; increment_timers
&3e4b: c9 f7            CMP #&f7
&3e4d: 90 39            BCC &3e88
; into_tertiary_pull_in
&3e4f: 86 a2            STX &a2
&3e51: b9 86 09         LDA &0986,Y ; background_objects_data
&3e54: 85 a3            STA &a3
&3e56: 0a               ASL
&3e57: c9 08            CMP #&08
&3e59: 90 2d            BCC &3e88
&3e5b: 29 06            AND #&06
&3e5d: d0 29            BNE &3e88
&3e5f: a6 be            LDX &be ; new_object_type_pointer
&3e61: bd 71 0a         LDA &0a71,X ; background_objects_type
&3e64: a4 a2            LDY &a2
&3e66: 85 a2            STA &a2
&3e68: 20 54 40         JSR &4054 ; pull_objects_in_from_tertiary_stack_alt
&3e6b: a5 a3            LDA &a3
&3e6d: e9 03            SBC #&03
&3e6f: 9d 86 09         STA &0986,X ; background_objects_data
&3e72: a9 05            LDA #&05
&3e74: 99 c6 08         STA &08c6,Y ; object_stack_flags
&3e77: a6 a2            LDX &a2
&3e79: bd 8a 02         LDA &028a,X ; object_sprite_lookup
&3e7c: aa               TAX
&3e7d: bd 0c 5e         LDA &5e0c,X ; sprite_width_lookup
&3e80: 49 ff            EOR #&ff
&3e82: 4a               LSR
&3e83: 99 80 08         STA &0880,Y ; object_stack_x_low
&3e86: 18               CLC
&3e87: 60               RTS

&3e88: 38               SEC
&3e89: 60               RTS

; handle_background_engine_thruster
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3e8a: f0 fb            BEQ &3e87						# is object_data_pointer = 0? if so, leave
&3e8c: a9 3b            LDA #&3b						# &3b = engine thruster
&3e8e: 4c 42 40         JMP &4042 ; pull_objects_in_from_tertiary_stack

#3e91: 17 19 2a 19 ; door_square_sprite_lookup

; handle_background_stone_door
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3e95: a9 3e            LDA #&3e 						# &3e = horizontal stone door
&3e97: 2c               BIT &85a9
#3e98:    a9 85         LDA #&3c						# &3c = horizontal door
; handle_background_door
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3e9a: 85 9c            STA &9c ; door_type
&3e9c: cc 99 35         CPY &3599 ; door_data_pointer_store
&3e9f: f0 41            BEQ &3ee2                                               # if so, leave
&3ea1: a5 09            LDA &09 ; square_orientation
&3ea3: 0a               ASL
&3ea4: 2a               ROL
&3ea5: 69 00            ADC #&00
&3ea7: 29 01            AND #&01
&3ea9: 48               PHA
&3eaa: b9 86 09         LDA &0986,Y ; background_objects_data
&3ead: 30 01            BMI &3eb0
&3eaf: 4a               LSR
&3eb0: 29 02            AND #&02
&3eb2: 4a               LSR
&3eb3: e9 00            SBC #&00
&3eb5: 85 a3            STA &a3
&3eb7: a5 2d            LDA &2d ; background_processing_flag
&3eb9: 30 09            BMI &3ec4
&3ebb: 68               PLA
&3ebc: 48               PHA
&3ebd: 2a               ROL
&3ebe: aa               TAX
&3ebf: bd 91 3e         LDA &3e91,X ; door_square_sprite_lookup
&3ec2: 85 08            STA &08 ; square_sprite
&3ec4: 68               PLA
&3ec5: 24 2d            BIT &2d ; background_processing_flag
&3ec7: 70 19            BVS &3ee2					        # if so, leave
&3ec9: 48               PHA
&3eca: 18               CLC
&3ecb: 65 9c            ADC &9c ; door_type
&3ecd: 20 42 40         JSR &4042 ; pull_objects_in_from_tertiary_stack
&3ed0: 68               PLA
&3ed1: 0a               ASL
&3ed2: 99 36 09         STA &0936,Y ; object_stack_ty
&3ed5: aa               TAX
&3ed6: b5 95            LDA &95,X ; square_x
&3ed8: e9 00            SBC #&00
&3eda: 99 76 09         STA &0976,Y ; object_stack_extra
&3edd: a5 a3            LDA &a3
&3edf: 99 16 09         STA &0916,Y ; object_stack_tx
&3ee2: 60               RTS

; handle_background_teleport_beam
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3ee3: a9 41            LDA #&41 					        # &41 = teleport beam
&3ee5: 20 42 40         JSR &4042 ; pull_objects_in_from_tertiary_stack
&3ee8: a9 40            LDA #&40
&3eea: 99 80 08         STA &0880,Y ; object_stack_x_low
&3eed: 0a               ASL
&3eee: 99 a3 08         STA &08a3,Y ; object_stack_y_low
&3ef1: 60               RTS

; handle_background_invisible_switch
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3ef2: a6 be            LDX &be ; new_object_type_pointer
&3ef4: bd 71 0a         LDA &0a71,X ; background_objects_type
&3ef7: 30 04            BMI &3efd					        # is it offscreen?
&3ef9: c5 41            CMP &41 ; this_object_type			        # if not, is it the current object?
&3efb: d0 f4            BNE &3ef1					        # if not, leave
&3efd: a4 aa            LDY &aa ; current_object
&3eff: 20 c5 49         JSR &49c5 ; can_object_trigger_switch
&3f02: 90 ed            BCC &3ef1					        # if not, leave
&3f04: a4 bd            LDY &bd ; new_object_data_pointer
&3f06: b9 86 09         LDA &0986,Y ; background_objects_data
&3f09: 48               PHA
&3f0a: 4a               LSR
&3f0b: 09 fc            ORA #&fc
&3f0d: 49 03            EOR #&03
&3f0f: aa               TAX
&3f10: 68               PLA
&3f11: b0 02            BCS &3f15
&3f13: 29 f8            AND #&f8
&3f15: 4c db 49         JMP &49db ; switch_effects

; handle_background_object_random_wind
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3f18: 24 20            BIT &20 ; this_object_water_level                       # is the square underwater?
&3f1a: 30 d5            BMI &3ef1						# if so, leave
&3f1c: 24 09            BIT &09 ; square_orientation
&3f1e: 10 04            BPL &3f24
&3f20: a9 70            LDA #&70                                                # fixed velocity if square inverted
&3f22: 10 23            BPL &3f47
&3f24: a5 c0            LDA &c0 ; loop_counter
&3f26: 2a               ROL
&3f27: 2a               ROL
&3f28: 85 b5            STA &b5 ; angle
&3f2a: a5 da            LDA &da ; timer_2
&3f2c: 29 1f            AND #&1f
&3f2e: 45 97            EOR &97 ; square_y
&3f30: 0a               ASL
&3f31: 29 7f            AND #&7f
&3f33: 24 95            BIT &95 ; square_x
&3f35: 10 04            BPL &3f3b
&3f37: 29 3f            AND #&3f
&3f39: 69 28            ADC #&28
&3f3b: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&3f3e: 4c 4f 3f         JMP &3f4f # becomes reserve_object_for_background

; handle_background_object_fixed_wind
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3f41: 98               TYA                                                     # Y = new_object_data_pointer
&3f42: f0 59            BEQ &3f9d                                               # if no data, do something ?
&3f44: b9 86 09         LDA &0986,Y ; background_objects_data                   # the data encodes the wind direction
&3f47: 85 b6            STA &b6 ; velocity_y
&3f49: 0a               ASL
&3f4a: 0a               ASL
&3f4b: 0a               ASL
&3f4c: 0a               ASL
&3f4d: 85 b4            STA &b4 ; velocity_x
&3f4f: 20 1b 40         JSR &401b ; reserve_object_for_background
&3f52: d0 62            BNE &3fb6			# if so, leave
&3f54: a2 02            LDX #&02
&3f56: a4 38            LDY &38 ; this_object_weight
&3f58: c0 04            CPY #&04
&3f5a: b0 01            BCS &3f5d
&3f5c: c8               INY
&3f5d: 24 20            BIT &20 ; this_object_water_level
&3f5f: 10 01            BPL &3f62
&3f61: c8               INY
&3f62: 24 1f            BIT &1f ; underwater
&3f64: 10 06            BPL &3f6c
&3f66: a5 c0            LDA &c0 ; loop_counter
&3f68: 29 10            AND #&10
&3f6a: f0 4a            BEQ &3fb6
&3f6c: 20 94 3f         JSR &3f94
&3f6f: ca               DEX
&3f70: ca               DEX
&3f71: f0 e3            BEQ &3f56
; do_wind_motion
&3f73: 20 d4 22         JSR &22d4 ; calculate_angle_from_velocities
&3f76: a5 da            LDA &da ; timer_2
&3f78: 4a               LSR
&3f79: c5 b7            CMP &b7 ; some_kind_of_velocity
&3f7b: b0 39            BCS &3fb6			                        # if so, leave
&3f7d: a0 6e            LDY #&6e                                                # &6e = wind particles
; add_wind_like_particles
&3f7f: a2 02            LDX #&02
&3f81: b5 4f            LDA &4f,X       # X = 2, &51 this_object_y_low ; X = 0, &4f this_object_x_low
&3f83: e9 40            SBC #&40
&3f85: 95 87            STA &87,X       # X = 2, &89 this_object_y_centre_low; X = 0, &87 this_object_x_centre_low
&3f87: b5 53            LDA &53,X       # X = 2, &55 this_object_y ; X = 0, &53 this_object_x
&3f89: e9 00            SBC #&00
&3f8b: 95 8b            STA &8b,X       # X = 2, &8c this_object_y_centre; X = 0, &8b this_object_x_centre
&3f8d: ca               DEX
&3f8e: ca               DEX
&3f8f: f0 f0            BEQ &3f81
&3f91: 4c 8c 21         JMP &218c ; add_particle	                        # wind particles

&3f94: a9 0c            LDA #&0c
&3f96: 85 9c            STA &9c
&3f98: b5 b4            LDA &b4,X ; velocity_[x|y]
&3f9a: 4c f6 31         JMP &31f6

&3f9d: a5 c0            LDA &c0 ; loop_counter
&3f9f: 29 10            AND #&10
&3fa1: d0 13            BNE &3fb6
; handle_background_object_water                                                # A = &0d, water
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3fa3: 20 1b 40         JSR &401b ; reserve_object_for_background
&3fa6: d0 0e            BNE &3fb6
&3fa8: a5 09            LDA &09 ; square_orientation
&3faa: 0a               ASL
&3fab: 2a               ROL
&3fac: 2a               ROL
&3fad: aa               TAX
&3fae: bd 44 1e         LDA &1e44,X ; water_orientation_lookup
&3fb1: d0 94            BNE &3f47
&3fb3: 38               SEC
&3fb4: 66 01            ROR &01
&3fb6: 60               RTS

; handle_background_object_from_type
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3fb7: a6 be            LDX &be ; new_object_type_pointer
&3fb9: bd 71 0a         LDA &0a71,X ; background_objects_type
&3fbc: 4c 42 40         JMP &4042 ; pull_objects_in_from_tertiary_stack

; handle_background_object_from_data
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3fbf: b9 86 09         LDA &0986,Y ; background_objects_data
&3fc2: 29 7f            AND #&7f
&3fc4: 20 42 40         JSR &4042 ; pull_objects_in_from_tertiary_stack
&3fc7: a9 49            LDA #&49			                        # &49 = placeholder
&3fc9: 99 60 08         STA &0860,Y ; object_stack_type
&3fcc: 60               RTS

; handle_background_switch
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3fcd: a9 42            LDA #&42					        # &42 = switch
&3fcf: 4c 42 40         JMP &4042 ; pull_objects_in_from_tertiary_stack

; handle_background_mushrooms
# called with:
# A, X = &bc this_object_data
# Y = &bd new_object_data_pointer; CPY #&00
&3fd2: a2 33            LDX #&33					        # &33 = red mushroom ball
&3fd4: 24 09            BIT &09 ; square_orientation
&3fd6: 50 01            BVC &3fd9
&3fd8: e8               INX						        # or blue if &09 & &80.
&3fd9: 20 1d 40         JSR &401d ; reserve_object_for_background_type_X
&3fdc: f0 0c            BEQ &3fea
&3fde: b0 09            BCS &3fe9
&3fe0: 24 09            BIT &09 ; square_orientation
&3fe2: 50 02            BVC &3fe6
&3fe4: a9 00            LDA #&00
&3fe6: 99 a3 08         STA &08a3,Y ; object_stack_y_low
&3fe9: 60               RTS
&3fea: a5 09            LDA &09 ; square_orientation
&3fec: 0a               ASL
&3fed: 0a               ASL
&3fee: a4 aa            LDY &aa ; current_object
; consider_mushrooms_and_player
&3ff0: 98               TYA
&3ff1: d0 06            BNE &3ff9                                               # is it the player?
&3ff3: 69 00            ADC #&00
&3ff5: aa               TAX
&3ff6: 20 05 40         JSR &4005 ; add_to_mushroom_daze
&3ff9: 20 fa 13         JSR &13fa ; play_sound
#3ffc: 33 f3 1d 03 ; sound data
; handle_lightning
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4000: a0 4d		LDY #&4d
&4002: 4c 7f 3f		JMP &3f7f ; add_wind_like_particles

; add_to_mushroom_daze
; X = mushroom flavour - 0 = red, 1 = blue
&4005: a9 3f            LDA #&3f
&4007: 7d 1a 08         ADC &081a,X ; red_mushroom_daze                         # increase the daze duration by &3f
&400a: b0 03            BCS &400f
&400c: 9d 1a 08         STA &081a,X ; red_mushroom_daze                         # but don't overflow - limit to &ff
&400f: 2c 15 08         BIT &0815 ; mushroom_pill_collected                     # do we have immunity?
&4012: 30 2d            BMI &4041				                # if so, leave
&4014: d5 ba            CMP &ba,X ; player_immobility_daze
&4016: 90 29            BCC &4041
&4018: 95 ba            STA &ba,X ; player_immobility_daze                      # extend the player's daze to match
&401a: 60               RTS

; reserve_object_for_background
&401b: a2 35            LDX #&35                                                # &35 = engine thruster
; reserve_object_for_background_type_X
&401d: a9 10            LDA #&10
&401f: 24 2d            BIT &2d ; background_processing_flag
&4021: f0 1e            BEQ &4041				                # if so, leave
&4023: 8a               TXA
&4024: 48               PHA
&4025: 20 18 3c         JSR &3c18 ; count_objects_of_type_a_in_stack            # how many are there already?
&4028: c0 04            CPY #&04
&402a: 68               PLA
&402b: b0 12            BCS &403f                                               # if four or more, then leave
&402d: 20 5a 1e         JSR &1e5a ; reserve_object_high_priority
&4030: b0 0d            BCS &403f
&4032: 20 67 28         JSR &2867 ; set_object_x_y_tx_ty_to_square_x_y
&4035: a5 d9            LDA &d9 ; timer_1
&4037: 99 a3 08         STA &08a3,Y ; object_stack_y_low			# in a random part of the square
&403a: a5 da            LDA &da ; timer_2
&403c: 99 80 08         STA &0880,Y ; object_stack_x_low
&403f: a9 ff            LDA #&ff
&4041: 60               RTS

; pull_objects_in_from_tertiary_stack
&4042: a0 00            LDY #&00
&4044: 2c a0 08         BIT &08a0
#4045:    a0 08         LDY #&08	# ?
&4047: 85 a2            STA &a2 ; new_object_type
&4049: a6 bd            LDX &bd ; new_object_data_pointer
&404b: f0 07            BEQ &4054 ; pull_objects_in_from_tertiary_stack_alt
&404d: bd 86 09         LDA &0986,X ; background_objects_data			# is the object on screen already?
&4050: 10 3f            BPL &4091 ; restore_stack_pointer			# if so, leave
&4052: a5 a2            LDA &a2 ; new_object_type
; pull_objects_in_from_tertiary_stack_alt
&4054: 20 62 1e         JSR &1e62 ; reserve_objects 				# find a slot for it (Y = number to reserve)
&4057: b0 38            BCS &4091 ; restore_stack_pointer			# if no free slots, leave
&4059: 20 67 28         JSR &2867 ; set_object_x_y_tx_ty_to_square_x_y
&405c: a6 a2            LDX &a2 ; new_object_type
&405e: bd 8a 02         LDA &028a,X ; object_sprite_lookup
&4061: aa               TAX
&4062: a5 09            LDA &09 ; square_orientation
&4064: 09 05            ORA #&05
&4066: 99 c6 08         STA &08c6,Y ; object_stack_flags
&4069: a9 00            LDA #&00
&406b: 24 09            BIT &09 ; square_orientation
&406d: 10 03            BPL &4072
&406f: fd 0c 5e         SBC &5e0c,X ; sprite_width_lookup
&4072: 99 80 08         STA &0880,Y ; object_stack_x_low
&4075: a9 00            LDA #&00
&4077: 24 09            BIT &09 ; square_orientation
&4079: 70 03            BVS &407e
&407b: fd 89 5e         SBC &5e89,X ; sprite_height_lookup
&407e: 99 a3 08         STA &08a3,Y ; object_stack_y_low
&4081: a5 bd            LDA &bd ; new_object_data_pointer
&4083: 99 66 09         STA &0966,Y ; object_stack_data_pointer
&4086: aa               TAX
&4087: bd 86 09         LDA &0986,X ; background_objects_data			# mark the object as being onscreen
&408a: 29 7f            AND #&7f
&408c: 9d 86 09         STA &0986,X ; background_objects_data
&408f: 18               CLC
&4090: 60               RTS

; restore_stack_pointer
&4091: a6 26            LDX &26 ; copy_of_stack_pointer
&4093: 9a               TXS
&4094: 38               SEC
&4095: 60               RTS

; handle_explosion_type_00
&4096: a6 aa            LDX &aa ; current_object                                # is it the player?
&4098: d0 fb            BNE &4095                                               # if not, it's an indestructible object - leave
&409a: e6 15            INC &15 ; this_object_energy
&409c: 20 87 25         JSR &2587 ; increment_timers                            # a 50% chance to either:
&409f: 10 0b            BPL &40ac drop_object_from_pocket                       
&40a1: 20 c8 32         JSR &32c8 ; drop_object                                 # drop held object and teleport
&40a4: a2 04            LDX #&04
&40a6: 20 94 12         JSR &1294 ; increment_game_time_X                       # increment player deaths
&40a9: 4c c1 0c         JMP &0cc1 ; teleport_player
; drop_object_from_pocket                                                       # or:
&40ac: a5 da            LDA &da ; timer_2                                       
&40ae: c9 c0            CMP #&c0
&40b0: 6a               ROR
&40b1: 25 dd            AND &dd ; object_held                                   # are we holding something?
&40b3: 10 03            BPL &40b8                                               # if not, with 75% probability
&40b5: 20 04 35         JSR &3504 ; actually_retrieve_object                    # retrieve an object from pocket
&40b8: 4c c8 32         JMP &32c8 ; drop_object                                 # drop whatever we're holding

; handle_explosion_type_80
&40bb: 4c b6 4a         JMP &4ab6 ; turn_to_fireball_energy_7                   # an inorganic object that burns

; handle_explosion_type_40
&40be: 20 fa 13         JSR &13fa ; play_sound                                  # something that squeals and explodes
#40c1 57 07 43 f6 ; sound data
; handle_explosion_type_c0
&40c5: 20 b5 14         JSR &14b5 ; play_squeal
&40c8: a5 41            LDA &41 ; this_object_type
&40ca: 20 b0 2d         JSR &2db0 ; convert_object_to_range_a
&40cd: bd f8 29         LDA &29f8,X ; energy_by_range
&40d0: 4a               LSR
&40d1: 4a               LSR
&40d2: 4a               LSR
&40d3: 4a               LSR
&40d4: 4a               LSR
&40d5: 69 03            ADC #&03
&40d7: 10 02            BPL &40db ; explode_object
&40d9: a5 15            LDA &15 ; this_object_energy

; explode_object
; A = damage
&40db: 20 f8 13         JSR &13f8 ; play_sound2
#40de: 17 03 11 04 ; sound data
; explode_without_sound
&40e2: 85 3d            STA &3d	; this_object_supporting	                # store damage in this_object_supporting
&40e4: a9 44            LDA #&44			                        # &44 = explosion
&40e6: 85 41            STA &41 ; this_object_type                              # change to an explosion
; explode_without_sound_or_damage
&40e8: a9 ce            LDA #&ce
&40ea: 8d 1d 08         STA &081d ; explosion_timer
&40ed: 60               RTS

; handle_cannon
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&40ee: a9 4f            LDA #&4f                                                # &4f = cannon control device
&40f0: 20 c7 0b         JSR &0bc7 ; has_object_been_hit_by_other
&40f3: b0 07            BCS &40fc ; cannon_not_fired                            # has the cannon been fired? if so
&40f5: a2 15            LDX #&15 				                # &15 = cannonball
&40f7: a9 40            LDA #&40				                # x velocity = &40
&40f9: 20 a9 33         JSR &33a9 ; add_weapon_discharge                        # create a cannonabll
; cannon_not fired
&40fc: a9 0f            LDA #&0f                                                # 1 in 15 chance to rotate cannon
&40fe: 4c 7a 25         JMP &257a ; flip_object_in_direction_of_travel_on_random_a      

# unused ???
&4101: 30 0e            BMI &4111
&4103: 20 c9 1f         JSR &1fc9 ; does_it_collide_with_bullets_2
&4106: f0 0c            BEQ &4114
&4108: c9 01            CMP #&01
&410a: f0 05            BEQ &4111
&410c: a9 50            LDA #&50
&410e: 20 a6 24         JSR &24a6 ; take_damage
&4111: 98               TYA
&4112: 49 ff            EOR #&ff
&4114: a6 11            LDX &11 ; this_object_extra
&4116: 05 1b            ORA &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&4118: 49 ff            EOR #&ff
&411a: 05 11            ORA &11 ; this_object_extra
&411c: 30 09            BMI &4127
&411e: 8a               TXA
&411f: 20 4c 32         JSR &324c ; make_negative
&4122: aa               TAX
&4123: d0 02            BNE &4127
&4125: a2 fe            LDX #&fe
&4127: c6 12            DEC &12 ; this_object_timer
&4129: a5 12            LDA &12 ; this_object_timer
&412b: c9 e7            CMP #&e7
&412d: f0 04            BEQ &4133
&412f: e8               INX
&4130: f0 23            BEQ &4155
&4132: 8a               TXA
&4133: a0 04            LDY #&04
&4135: 20 5e 32         JSR &325e ; keep_within_range
&4138: 85 11            STA &11 ; this_object_extra
&413a: 20 54 32         JSR &3254 ; make_positive_cmp_0
&413d: 69 6c            ADC #&6c
&413f: 20 98 32         JSR &3298 ; convert_object_keeping_palette
&4142: a5 06            LDA &06 ; current_object_rotator
&4144: 4a               LSR
&4145: 66 39            ROR &39 ; this_object_flags_lefted
&4147: 4a               LSR
&4148: 66 37            ROR &37 ; this_object_angle
&414a: c6 42            DEC &42 ; acceleration_y
&414c: a5 44            LDA &44 ; this_object_vel_x_old
&414e: 85 43            STA &43 ; this_object_vel_x
&4150: a5 46            LDA &46 ; this_object_vel_y_old
&4152: 85 45            STA &45 ; this_object_vel_y
&4154: 60               RTS

&4155: 4c 29 25         JMP &2529; mark_this_object_for_removal

; handle_grenade_inactive
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4158: 20 9d 4b         JSR &4b9d ; keep_object_floating_until_disturbed        
&415b: 20 bf 0b         JSR &0bbf ; has_object_been_fired
&415e: f0 0b            BEQ &416b
&4160: c5 dd            CMP &dd ; object_held
&4162: d0 03            BNE &4167 
&4164: 85 11            STA &11 ; this_object_extra
&4166: 60               RTS
&4167: a5 11            LDA &11 ; this_object_extra
&4169: f0 fb            BEQ &4166
&416b: a9 12            LDA #&12		                                # &12 = live grenade
&416d: 4c 86 32         JMP &3286 ; convert_object_to_another

; handle_gargoyle
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4170: bd 8b 41         LDA &418b,X ; gargoyle_frequency_lookup
&4173: 25 06            AND &06 ; current_object_rotator
&4175: d0 0f            BNE &4186
&4177: bc 95 41         LDY &4195,X ; gargoyle_y_velocity_lookup	        # Y = y velocity
&417a: bd 90 41         LDA &4190,X ; gargoyle_x_velocity_lookup
&417d: 48               PHA
&417e: bd 9a 41         LDA &419a,X ; gargoyle_bullet_lookup
&4181: aa               TAX						        # X = object type to create
&4182: 68               PLA						        # A = x velocity
&4183: 20 ab 33         JSR &33ab ; add_weapon_discharge_y_velocity
&4186: a0 5a            LDY #&5a                                                # gargoyle minimum energy = &5a
&4188: 4c 3a 35         JMP &353a ; gain_energy_or_flash_if_damaged

#418b: 0f 07 07 07 03 ; gargoyle_frequency_lookup
#4190: 11 7f 7f 7f 01 ; gargoyle_x_velocity_lookup		
#4195: c0 0c 04 f9 9a ; gargoyle_y_velocity_lookup
#419a: 32 19 19 19 32 ; gargoyle_bullet_lookup			                # &32 = plasma, &19 = lightning

; handle_maggot_machine
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&419f: a5 c0            LDA &c0 ; loop_counter
&41a1: 29 3f            AND #&3f
&41a3: aa               TAX
&41a4: d0 17            BNE &41bd
&41a6: a5 55            LDA &55 ; this_object_y
&41a8: cd d1 14         CMP &14d1 ; water_level			                # is the maggot machine above the water level?
&41ab: 90 0a            BCC &41b7				
&41ad: a9 80            LDA #&80
&41af: 8d 1f 08         STA &081f ; earthquake_triggered	                # trigger earthquake!
&41b2: 8d 1e 08         STA &081e ; endgame_value                               # start endgame
&41b5: 30 2e            BMI &41e5                                               # and explode!
&41b7: 20 b5 14         JSR &14b5 ; play_squeal
&41ba: 20 36 31         JSR &3136 ; invert_angle
&41bd: e0 08            CPX #&08
&41bf: 4c df 4d         JMP &4ddf ; flash_palette

; handle_coronium_crystal
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&41c2: a9 0a            LDA #&0a                                                # coronium crystal explosion damage = &0a
&41c4: e6 12            INC &12 ; this_object_timer
&41c6: e6 12            INC &12 ; this_object_timer
&41c8: 30 1e            BMI &41e8                                               # explode it if time runs out
; handle_coronium_boulder
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&41ca: 98               TYA 
&41cb: 30 1e            BMI &41eb				                # is it touching anything?
&41cd: f0 26            BEQ &41f5 ; coronium_on_player		                # is it the player?
&41cf: b9 60 08         LDA &0860,Y ; object_stack_type
&41d2: c9 55            CMP #&55				                # is it a coronium boulder?
&41d4: f0 04            BEQ &41da
&41d6: c9 58            CMP #&58				                # is it a coronium crystal?
&41d8: d0 11            BNE &41eb ; no_explosion                                # if either, it's explosion time
&41da: 20 16 25         JSR &2516 ; mark_stack_object_for_removal
&41dd: 20 20 1e         JSR &1e20 ; get_object_weight
&41e0: 65 38            ADC &38 ; this_object_weight                            # coronium explosion damage
&41e2: 0a               ASL                                                     # boulder weight = 5, crystal weight = 2
&41e3: 69 03            ADC #&03                                                # (combined weights * 2) + 3
&41e5: 20 92 1f         JSR &1f92 ; flash_screen_background
&41e8: 4c db 40         JMP &40db ; explode_object
; no_explosion
&41eb: a5 da            LDA &da ; timer_2
&41ed: 29 c0            AND #&c0                                                # a one in four chance
&41ef: 05 dd            ORA &dd ; object_held
&41f1: c5 aa            CMP &aa ; current_object                                # if its being held,
&41f3: d0 0e            BNE &4203
; coronium_on_player
&41f5: ad 18 08         LDA &0818 ; radiation_pill_collected                    # and we don't have the radiation pill
&41f8: 05 20            ORA &20 ; this_object_water_level                       # and we're not under water
&41fa: 30 07            BMI &4203 ; no_damage_from_coronium
&41fc: a9 08            LDA #&08                                                # to damage the player
&41fe: a0 00            LDY #&00
&4200: 20 a6 24         JSR &24a6 ; take_damage			                # coronium contact damage = &08
; no_damage_from_coronium
&4203: 20 87 25         JSR &2587 ; increment_timers
&4206: 4a               LSR
&4207: 85 73            STA &73 ; this_object_palette		                # change to a random colour
&4209: 60               RTS

; handle_worm
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&420a: a9 86            LDA #&86                                                # &86 = red frogman + player
&420c: a0 07            LDY #&07                                                # &07 green frogman
&420e: a2 00            LDX #&00                                                # no damage from worms
&4210: 20 5e 4e         JSR &4e5e ; from_handle_worm                            # behave like a maggot, except
&4213: 4c 11 3c         JMP &3c11 ; flag_target_as_avoid                        # worms avoid targets

; handle_mysterious_weapon
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4216: 20 4e 25         JSR &254e ; gain_one_energy_point_if_not_immortal
&4219: 20 bf 0b         JSR &0bbf ; has_object_been_fired                       # has it been fired?
&421c: d0 69            BNE &4287				                # if not, leave
&421e: a2 19            LDX #&19 				                # &19 = plasma ball
&4220: a9 40            LDA #&40				                # velocity = &40
&4222: 20 a9 33         JSR &33a9 ; add_weapon_discharge                        # create a plasma ball
&4225: b0 60            BCS &4287				                # leave if we couldn't
&4227: 4c ad 14         JMP &14ad ; play_low_beep

; handle_green_slime
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&422a: 20 78 25         JSR &2578 ; flip_object_in_direction_of_travel_on_random_3
&422d: a2 08            LDX #&08
&422f: 20 c9 27         JSR &27c9 ; npc_targetting
&4232: 20 26 3d         JSR &3d26 ; target_processing
&4235: 20 02 2a         JSR &2a02 ; move_npc
&4238: 46 21            LSR &21 ; npc_fed			                # has the green slime been fed a coronium crystal?
&423a: 90 0c            BCC &4248 ; unfed_slime	                                # if so, convert it into
&423c: a9 0b            LDA #&0b 				                # &0b = yellow ball
&423e: 20 fa 13         JSR &13fa ; play_sound
#4241: b0 24 b6 e2	; sound data
&4245: 4c 86 32         JMP &3286 ; convert_object_to_another
; unfed_slime
&4248: a2 03            LDX #&03				                # type
&424a: a9 0c            LDA #&0c				                # speed
&424c: 20 df 3a         JSR &3adf ; something_motion_related
&424f: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&4252: 90 04            BCC &4258
&4254: a9 0f            LDA #&0f
&4256: 85 12            STA &12 ; this_object_timer
&4258: a9 11            LDA #&11                                                # modulus
&425a: 20 55 25         JSR &2555 ; get_sprite_from_velocity                    # use velocity
&425d: e9 08            SBC #&08                                                # to calculate sprite for slime
&425f: 20 56 32         JSR &3256 ; make_positive
&4262: 4a               LSR                                                     # (&00 - &03)
&4263: 4c 92 32         JMP &3292 ; change_sprite                               # set the sprite based on result

; handle_yellow_ball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4266: d0 02            BNE &426a
&4268: 84 12            STY &12 ; this_object_timer
&426a: a5 da            LDA &da ; timer_2
&426c: 25 1b            AND &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&426e: 10 08            BPL &4278
&4270: e6 12            INC &12 ; this_object_timer
&4272: d0 04            BNE &4278
&4274: a9 0a            LDA #&0a                                                # &0a = green slime
&4276: d0 c6            BNE &423e                                               # convert back to a green slime
&4278: a2 3c            LDX #&3c
&427a: a5 dc            LDA &dc ; timer_4
&427c: 4a               LSR
&427d: 09 80            ORA #&80
&427f: c5 12            CMP &12 ; this_object_timer
&4281: b0 02            BCS &4285
&4283: a2 39            LDX #&39
&4285: 86 73            STX &73 ; this_object_palette
&4287: 60               RTS

; handle_fluffy
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4288: a0 29            LDY #&29                                                # fluffy minimum energy = &29
&428a: 20 2e 35         JSR &352e ; give_minimum_energy
&428d: a2 06            LDX #&06
&428f: 20 c9 27         JSR &27c9 ; npc_targetting
&4292: 20 26 3d         JSR &3d26 ; target_processing
&4295: 20 3c 25         JSR &253c ; is_this_object_damaged
&4298: b0 24            BCS &42be
&429a: a5 11            LDA &11 ; this_object_extra
&429c: 29 c0            AND #&c0
&429e: c9 80            CMP #&80
&42a0: f0 1c            BEQ &42be
&42a2: a5 aa            LDA &aa ; current_object
&42a4: b0 02            BCS &42a8
&42a6: 85 0e            STA &0e ; this_object_target_object
&42a8: a5 06            LDA &06 ; current_object_rotator
&42aa: 29 0b            AND #&0b
&42ac: d0 2d            BNE &42db
&42ae: a9 2a            LDA #&2a
&42b0: a0 86            LDY #&86
&42b2: 20 2c 3c         JSR &3c2c
&42b5: 30 12            BMI &42c9
&42b7: ad 28 3c         LDA &3c28 ; nearest_distance
&42ba: c5 da            CMP &da ; timer_2
&42bc: b0 0b            BCS &42c9
&42be: 20 fa 13         JSR &13fa ; play_sound
#42c1: b0 24 b6 e2 ; sound data
&42c5: 66 12            ROR &12 ; this_object_timer
&42c7: 30 12            BMI &42db
&42c9: a5 11            LDA &11 ; this_object_extra
&42cb: 20 4c 32         JSR &324c ; make_negative
&42ce: c5 da            CMP &da ; timer_2
&42d0: 66 12            ROR &12 ; this_object_timer
&42d2: 10 07            BPL &42db
&42d4: 20 fa 13         JSR &13fa ; play_sound
#42d7: c7 81 c1 f3 ; sound data
&42db: a5 da            LDA &da ; timer_2
&42dd: 29 02            AND #&02
&42df: aa               TAX
&42e0: a5 12            LDA &12 ; this_object_timer
&42e2: 55 37            EOR &37,X
&42e4: 95 37            STA &37,X
&42e6: 25 12            AND &12 ; this_object_timer
&42e8: 10 3b            BPL &4325
&42ea: a5 dd            LDA &dd ; object_held
&42ec: 45 aa            EOR &aa ; current_object                                # is fluffy being held by the player?
&42ee: f0 35            BEQ &4325                                               # if so, leave
&42f0: a2 02            LDX #&02				                # type
&42f2: a9 28            LDA #&28				                # speed
&42f4: 4c df 3a         JMP &3adf ; something_motion_related

; handle_active_grenade
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&42f7: 20 bf 0b         JSR &0bbf ; has_object_been_fired		        # has the grenade just been fired?
&42fa: d0 09            BNE &4305 ; grenade_still_active
&42fc: a9 00            LDA #&00					        # if so, reset the timer
&42fe: 85 12            STA &12 ; this_object_timer			
&4300: a9 50            LDA #&50					        # &50 = inactive grenade
&4302: 4c 86 32         JMP &3286 ; convert_object_to_another                   # and make it inactive
; grenade_still_active
&4305: a9 0a            LDA #&0a
&4307: a6 15            LDX &15 ; this_object_energy			        # otherwise, has it run out of energy?
&4309: f0 08            BEQ &4313					        # if so, explode it, damage = &0a
&430b: a5 12            LDA &12 ; this_object_timer
&430d: c9 60            CMP #&60					        # has it run out of time? (&60 ticks)
&430f: 90 05            BCC &4316 ; grenade_still_ticking
&4311: a9 10            LDA #&10					        # explode it, damage = &10
&4313: 4c db 40         JMP &40db ; explode_object			        
; grenade_still_ticking
&4316: e6 12            INC &12 ; this_object_timer			
&4318: 20 d4 4d         JSR &4dd4 ; rotate_colour                               # cycle its colour
&431b: 8a               TXA
&431c: d0 07            BNE &4325                                               # once every four ticks
&431e: 20 fa 13         JSR &13fa ; play_sound				        # sound the grenade claxon
#4321: 57 07 cb 82 ; sound data
&4325: 60               RTS

; handle_cannonball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4326: c6 42            DEC &42 ; acceleration_y                                # cannonball defies gravity
&4328: 20 af 1f         JSR &1faf ; is_it_supporting_anything_collidable
&432b: 30 05            BMI &4332                                               # has the cannonball hit anything?
&432d: a9 aa            LDA #&aa
&432f: 20 a6 24         JSR &24a6 ; take_damage				        # cannonball damage = &aa - lots!
; handle_death_ball_blue
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4332: 20 af 1f         JSR &1faf ; is_it_supporting_anything_collidable        # has it hit anything?
&4335: a9 10            LDA #&10
&4337: c0 00            CPY #&00
&4339: 10 d8            BPL &4313                                               # if so, explode it, damage = &10
&433b: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&433d: 30 d4            BMI &4313                                               # if so, explode it
&433f: 20 1f 25         JSR &251f ; reduce_object_energy_by_one                 # has it run out of time?
&4342: f0 cf            BEQ &4313					        # if so, explode it
&4344: 20 cc 22         JSR &22cc ; calculate_angle_from_this_object_velocities # calculate angle for particle trail
&4347: 4c d9 46         JMP &46d9 ; create_bullet_particle_trail                # leave a particle trail in its wake

; handle_red_bullet
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&434a: a9 06            LDA #&06                                                # explosion damage = &06
&434c: a2 1e            LDX #&1e                                                # red bullet damage = &1e
&434e: 4c 1b 46         JMP &461b                                               # behave like a finite tracer bullet

; handle_remote_control
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4351: 20 bf 0b         JSR &0bbf  ; has_object_been_fired                      # has the rcd been activated?
&4354: d0 50            BNE &43a6			
&4356: 20 fa 13         JSR &13fa ; play_sound
#4359: 57 07 c1 d3 ; sound data
&435d: 4c 2b 31         JMP &312b ; display_gun_particles                       # if so, display gun sight particles

; handle_energy_capsule
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4360: 20 1f 25         JSR &251f ; reduce_object_energy_by_one                 # reduce its energy
&4363: a5 07            LDA &07 ; current_object_rotator_low
&4365: c9 02            CMP #&02                                                # once every sixteen ticks
&4367: 20 df 4d         JSR &4ddf ; flash_palette                               # flash green, otherwise red
&436a: b0 3a            BCS &43a6 
&436c: 20 fa 13         JSR &13fa ; play_sound                                  # make a noise when flashing
#436f: 50 f2 ff c5 ; sound data
&4373: 60               RTS

; handle_destinator
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4374: 2c ab 19         BIT &19ab ; ship_moving					# is the ship already moving?
&4377: 30 2d            BMI &43a6						# if so, leave
&4379: ad ae 09         LDA &09ae ; background_object_data			# for top engine thruster
&437c: 4a               LSR                                                     # is the thruster active?
&437d: b0 0a            BCS &4389                                       
&437f: 20 fa 13         JSR &13fa ; play_sound
#4382: 91 02 85 47 ; sound data
&4386: 6e ab 19         ROR &19ab ; ship_moving                                 # if so, set ship moving
&4389: a5 06            LDA &06 ; current_object_rotator
&438b: 29 1f            AND #&1f
&438d: c9 01            CMP #&01
&438f: 20 df 4d         JSR &4ddf ; flash_palette                               # flash the destinator every 32 cycles
&4392: b0 12            BCS &43a6
&4394: 20 fa 13         JSR &13fa ; play_sound
#4397: 33 03 85 12 ; sound data
&439b: 60               RTS

; handle_giant_wall
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&439c: a5 20            LDA &20 ; this_object_water_level
&439e: c9 c0            CMP #&c0
&43a0: 90 04            BCC &43a6                                               # is the wall underwater?
&43a2: c6 42            DEC &42 ; acceleration_y                                # if so, cause it to float upwards
&43a4: c6 42            DEC &42 ; acceleration_y
&43a6: 60               RTS

; handle_flask
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&43a7: a9 4d            LDA #&4d				                # &4d = full flask
&43a9: 24 1f            BIT &1f	; underwater			                # are we underwater?
&43ab: 10 37            BPL &43e4				                # if so, convert to a full flask
&43ad: 60               RTS

; handle_flask_full
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&43ae: 30 07            BMI &43b7				                # are we supporting something?
&43b0: 20 b6 3b         JSR &3bb6 ; get_biggest_velocity                        # if not, consider velocities
&43b3: c9 0a            CMP #&0a                                                # are we moving too fast?
&43b5: b0 06            BCS &43bd                                               # if so, disturb flask
&43b7: a5 1d            LDA &1d ; some_kind_of_velocity                        
&43b9: c9 14            CMP #&14                                                # have we collided violently?
&43bb: 90 04            BCC &43c1                                               # if not, leave flask undisturbed
&43bd: a9 10            LDA #&10                                                # disturb flask
&43bf: 85 12            STA &12 ; this_object_timer
&43c1: a5 12            LDA &12 ; this_object_timer                             # has the flask been disturbed?
&43c3: f0 e8            BEQ &43ad                                               # if not, leave
&43c5: a4 3b            LDY &3b ; this_object_supporting
&43c7: 30 0a            BMI &43d3                                               # are we supporting something?
&43c9: b9 60 08         LDA &0860,Y ; object_stack_type
&43cc: c9 37            CMP #&37				                # &37 = fireball
&43ce: d0 03            BNE &43d3                                               # if so, is it a stationary fireball?
&43d0: 20 16 25         JSR &2516 ; mark_stack_object_for_removal               # if so, kill it
&43d3: a9 c0            LDA #&c0
&43d5: 85 b5            STA &b5 ; angle                                         # set angle to point straight up
&43d7: a0 58            LDY #&58                                                # &58 = flask particles
&43d9: a9 08            LDA #&08                                        
&43db: 20 8e 21         JSR &218e ; add_particles                               # create eight particles per tick
&43de: c6 12            DEC &12 ; this_object_timer
&43e0: d0 cb            BNE &43ad				                # when time runs out, convert to an empty flask
&43e2: a9 4c            LDA #&4c				                # &4c = empty flask
&43e4: 4c 86 32         JMP &3286 ; convert_object_to_another

; handle_hover_ball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&43e7: 20 d2 4d         JSR &4dd2 ; rotate_colour_6                             # cycle the colour of the hover ball
&43ea: 98               TYA
; handle_hover_ball_invisible
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&43eb: 30 13            BMI &4400                                               # are we supporting something?
&43ed: b9 60 08         LDA &0860,Y ; object_stack_type
&43f0: 45 41            EOR &41 ; this_object_type                              # if so, is it also a hover ball?
&43f2: f0 0c            BEQ &4400                                               # hover balls don't damage each other
&43f4: a9 03            LDA #&03
&43f6: 20 a6 24         JSR &24a6 ; take_damage			                # hover balls damage = &03
&43f9: 20 fa 13         JSR &13fa ; play_sound
#43fc: 33 03 85 02 ; sound data
&4400: a5 15            LDA &15 ; this_object_energy
&4402: 29 04            AND #&04                                                # hover balls are very weak; energy = &04
&4404: 85 15            STA &15 ; this_object_energy
&4406: c6 12            DEC &12 ; this_object_timer                             # has the timer run out?
&4408: d0 0b            BNE &4415
&440a: 20 0b 2a         JSR &2a0b ; force_object_offscreen                      # if so, cause the hover ball to teleport home
; play_teleport_noise
&440d: 20 fa 13         JSR &13fa ; play_sound
#4410: 29 c2 37 f3 ; sound data
&4414: 60               RTS
&4415: 20 6e 48         JSR &486e ; thrust_and_home_in_on_player
&4418: 4c 7a 48         JMP &487a ; thrust_towards_player                       # annoy the player

; handle_pistol_bullet
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&441b: 20 af 1f         JSR &1faf ; is_it_supporting_anything_collidable
&441e: 30 14            BMI &4434 ; move_bullet                                 # has the bullet hit anything?
&4420: a9 0a            LDA #&0a                                                # if so, damage it
&4422: 20 a6 24         JSR &24a6 ; take_damage				        # pistol bullet damage = &0a
&4425: 20 f8 13         JSR &13f8 ; play_sound2
#4428: 17 03 1b 02 ; sound_data
&442f: a9 02            LDA #&02                                                # then explode
&4431: 4c e2 40         JMP &40e2 ; explode_without_sound                       # explosion damage = &02
; move_bullet
&4434: 20 1f 25         JSR &251f ; reduce_object_energy_by_one                 # has the bullet run out of time?
&4437: f0 ec            BEQ &4425                                               # if so, explode it
&4439: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&443b: 10 0a            BPL &4447                                               # if so, it can either ricochet or explode
&443d: c9 3e            CMP #&3e        
&443f: b0 e4            BCS &4425                                               # if energy > &3e, explode
&4441: e9 14            SBC #&14
&4443: 90 e0            BCC &4425                                               # if energy < &14, explode
&4445: 85 15            STA &15 ; this_object_energy                            # otherwise ricochet
&4447: 20 cc 22         JSR &22cc ; calculate_angle_from_this_object_velocities
&444a: 85 39            STA &39 ; this_object_flags_lefted
&444c: 24 39            BIT &39 ; this_object_flags_lefted
&444e: 50 02            BVC &4452
&4450: 49 ff            EOR #&ff
&4452: 85 37            STA &37 ; this_object_angle                             # change sprite based on bullet's direction
&4454: 29 7f            AND #&7f
&4456: 4a               LSR
&4457: 4a               LSR
&4458: 4a               LSR
&4459: c9 04            CMP #&04
&445b: 90 03            BCC &4460
&445d: 4a               LSR
&445e: 49 06            EOR #&06
&4460: 4c 92 32         JMP &3292 ; change_sprite

; handle_frogman_red
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4463: a2 09            LDX #&09        # type
&4465: 20 c9 27         JSR &27c9 ; npc_targetting
&4468: a9 33            LDA #&33                                                # &33 = red mushroom ball
&446a: a8               TAY
&446b: 20 0c 3c         JSR &3c0c ; avoid_a                                     # red frogman avoids red mushroom balls
&446e: 20 26 3d         JSR &3d26 ; target_processing
&4471: a0 64            LDY #&64                                                # red frogman minimum energy = &64
&4473: d0 15            BNE &448a ; red_frogman
; handle_frogman_cyan
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4475: 46 2b            LSR &2b ; object_is_invisible                           # cyan frogman is invisible
; handle_frogman_green
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4477: a6 3b            LDX &3b ; this_object_supporting
&4479: d0 0d            BNE &4488 ; not_touching_player                         # is the frogman touching the player?
&447b: 20 05 40         JSR &4005 ; add_to_mushroom_daze                        # if so, daze the player
&447e: a9 07            LDA #&07
&4480: 85 12            STA &12 ; this_object_timer
&4482: 0a               ASL                                                     # frogman damage = &0e
&4483: a0 00            LDY #&00
&4485: 20 a6 24         JSR &24a6 ; take_damage                                 # damage player
; not_touching_player
&4488: a0 5a            LDY #&5a                                                # cyan / green frogman minimum energy = &5a
; red_frogman
&448a: 20 2e 35         JSR &352e ; give_minimum_energy
&448d: a0 14            LDY #&14
&448f: 84 04            STY &04 ; npc_speed
&4491: a2 01            LDX #&01
&4493: 20 08 3b         JSR &3b08 ; some_other_npc_stuff
&4496: 20 78 25         JSR &2578 ; flip_object_in_direction_of_travel_on_random_3
&4499: 20 86 3b         JSR &3b86 ; compare_extra_with_1_and_f
&449c: b0 0e            BCS &44ac
&449e: 20 ad 3b         JSR &3bad ; compare_wall_collision_angle_with_3962
&44a1: c9 28            CMP #&28
&44a3: 90 0f            BCC &44b4
&44a5: 20 6d 25         JSR &256d ; change_angle_if_wall_collision              # turn it round if it's hit a wall
&44a8: a2 ff            LDX #&ff
&44aa: d0 0a            BNE &44b6
&44ac: 24 1f            BIT &1f ; underwater
&44ae: 30 2c            BMI &44dc
&44b0: a5 07            LDA &07 ; current_object_rotator_low
&44b2: d0 28            BNE &44dc
&44b4: a2 04            LDX #&04
&44b6: a5 12            LDA &12 ; this_object_timer
&44b8: d0 22            BNE &44dc
&44ba: a9 09            LDA #&09
&44bc: 2c e5 29         BIT &29e5 ; object_collision_with_other_object_top_bottom
&44bf: 30 10            BMI &44d1
&44c1: a5 04            LDA &04 ; npc_speed
&44c3: 4a               LSR
&44c4: 4a               LSR
&44c5: a4 db            LDY &db ; timer_3
&44c7: c0 20            CPY #&20
&44c9: b0 07            BCS &44d2
&44cb: c0 0a            CPY #&0a
&44cd: b0 02            BCS &44d1
&44cf: 69 05            ADC #&05
&44d1: aa               TAX
&44d2: 85 12            STA &12 ; this_object_timer
&44d4: 8a               TXA
&44d5: 30 05            BMI &44dc
&44d7: 0a               ASL
&44d8: 0a               ASL
&44d9: 20 5b 3a         JSR &3a5b
&44dc: a5 12            LDA &12 ; this_object_timer
&44de: 18               CLC
&44df: f0 0b            BEQ &44ec
&44e1: c6 12            DEC &12 ; this_object_timer
&44e3: a5 12            LDA &12 ; this_object_timer
&44e5: f0 05            BEQ &44ec
&44e7: 4a               LSR
&44e8: 4a               LSR
&44e9: 29 01            AND #&01
&44eb: 38               SEC
&44ec: 4c 93 32         JMP &3293

; handle_imp
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&44ef: a5 6f            LDA &6f ; this_object_flags
&44f1: 29 04            AND #&04
&44f3: f0 04            BEQ &44f9
&44f5: a9 80            LDA #&80
&44f7: 85 11            STA &11 ; this_object_extra
&44f9: a0 28            LDY #&28
&44fb: a5 11            LDA &11 ; this_object_extra
&44fd: 0a               ASL
&44fe: 45 11            EOR &11 ; this_object_extra
&4500: 30 02            BMI &4504
&4502: a0 10            LDY #&10
&4504: 84 04            STY &04 ; npc_speed
&4506: a5 41            LDA &41 ; this_object_type
&4508: 38               SEC
&4509: e9 29            SBC #&29
&450b: aa               TAX
&450c: a5 11            LDA &11 ; this_object_extra
&450e: 29 10            AND #&10
&4510: 08               PHP
&4511: a5 08            LDA &08 ; square_sprite
&4513: c9 0a            CMP #&0a                                                # is the square the imp's flowerpot?
&4515: d0 2b            BNE &4542 ; not_in_flowerpot
&4517: 46 04            LSR &04 ; npc_speed
&4519: 46 04            LSR &04 ; npc_speed
&451b: 20 88 22         JSR &2288 ; get_object_centre
&451e: a5 87            LDA &87 ; this_object_centre_x_low
&4520: 20 56 32         JSR &3256 ; make_positive
&4523: c9 68            CMP #&68
&4525: 90 1b            BCC &4542 ; not_in_flowerpot                            # is the imp near the centre of it?
&4527: 24 18            BIT &18 ; wall_collision_bottom_minus_top
&4529: 10 17            BPL &4542 ; not_in_flowerpot
&452b: 28               PLP
&452c: f0 11            BEQ &453f ; no_imp_gift                                 # was the imp previously fed?
&452e: de 3a 08         DEC &083a,X ; imp_gift_counts                           # is there a gift to give?
&4531: 30 0c            BMI &453f ; no_imp_gift
&4533: bd a7 31         LDA &31a7,X ; imp_gift_lookup                           # find out what it is
&4536: aa               TAX
&4537: a0 c8            LDY #&c8
&4539: 20 ab 33         JSR &33ab ; add_weapon_discharge_y_velocity             # and generate it
&453c: 20 b5 14         JSR &14b5 ; play_squeal
; no_imp_gift
&453f: 4c 0b 2a         JMP &2a0b ; force_object_offscreen                      # the imp disappears into the flowerpot
; not_in_flowerpot
&4542: bc a2 31         LDY &31a2,X ; imp_energy_lookup
&4545: 20 2e 35         JSR &352e ; give_minimum_energy
&4548: 20 c9 27         JSR &27c9 ; npc_targetting
&454b: 28               PLP
&454c: d0 04            BNE &4552
&454e: 46 21            LSR &21 ; npc_fed					# has the imp been fed?
&4550: 90 08            BCC &455a ; unfed_imp
&4552: a5 11            LDA &11 ; this_object_extra
&4554: 29 3f            AND #&3f						# mark extra as having been fed
&4556: 09 90            ORA #&90
&4558: 85 11            STA &11 ; this_object_extra
; unfed_imp
&455a: 20 26 3d         JSR &3d26 ; target_processing
&455d: a2 02            LDX #&02
&455f: 20 e1 3a         JSR &3ae1
&4562: a4 3b            LDY &3b ; this_object_supporting
&4564: c4 0e            CPY &0e ; this_object_target_object
&4566: d0 16            BNE &457e
&4568: 24 11            BIT &11 ; this_object_extra
&456a: 30 12            BMI &457e
&456c: 20 d5 3b         JSR &3bd5 ; can_we_pick_up_object
&456f: 30 0d            BMI &457e
&4571: a4 3b            LDY &3b ; this_object_supporting
&4573: a9 05            LDA #&05
&4575: 20 a6 24         JSR &24a6 ; take_damage
&4578: 20 b4 0b         JSR &0bb4 ; get_object_velocities
&457b: 4c 9f 45         JMP &459f
&457e: 20 8c 3b         JSR &3b8c ; compare_extra_with_a_and_f
&4581: b0 30            BCS &45b3
&4583: 29 0f            AND #&0f
&4585: d0 0f            BNE &4596
&4587: 20 ad 3b         JSR &3bad ; compare_wall_collision_angle_with_3962
&458a: c9 28            CMP #&28
&458c: a5 11            LDA &11 ; this_object_extra
&458e: 29 df            AND #&df
&4590: 90 02            BCC &4594
&4592: 09 20            ORA #&20
&4594: 85 11            STA &11 ; this_object_extra
&4596: a5 11            LDA &11 ; this_object_extra
&4598: 29 20            AND #&20
&459a: f0 25            BEQ &45c1
&459c: 20 6d 25         JSR &256d ; change_angle_if_wall_collision              # turn it round if it's hit a wall
&459f: a9 0c            LDA #&0c                                                # modulus
&45a1: a2 02            LDX #&02                                                # velocity / 4
&45a3: 20 57 25         JSR &2557 ; get_sprite_from_velocity_X                  # use velocity
&45a6: 4a               LSR
&45a7: 4a               LSR
&45a8: 4a               LSR
&45a9: a9 67            LDA #&67
&45ab: 69 00            ADC #&00
&45ad: d0 3e            BNE &45ed
&45af: a9 69            LDA #&69
&45b1: d0 35            BNE &45e8
&45b3: 24 1f            BIT &1f ; underwater
&45b5: 30 f8            BMI &45af
&45b7: 20 87 25         JSR &2587 ; increment_timers
&45ba: 29 1f            AND #&1f
&45bc: d0 03            BNE &45c1
&45be: 20 59 3a         JSR &3a59
&45c1: a4 3b            LDY &3b ; this_object_supporting
&45c3: c4 0e            CPY &0e ; this_object_target_object
&45c5: f0 d8            BEQ &459f
&45c7: a0 00            LDY #&00
&45c9: 84 9d            STY &9d
&45cb: a6 22            LDX &22 ; npc_type
&45cd: bd 9d 31         LDA &319d,X ; npc_weapon_lookup
&45d0: aa               TAX
&45d1: a9 08            LDA #&08
&45d3: 20 6d 27         JSR &276d
&45d6: a9 64            LDA #&64
&45d8: a6 43            LDX &43 ; this_object_vel_x
&45da: f0 11            BEQ &45ed
&45dc: a9 0c            LDA #&0c                                                # modulus
&45de: a2 02            LDX #&02                                                # velocity /4
&45e0: 20 57 25         JSR &2557 ; get_sprite_from_velocity_X                  # use velocity
&45e3: 4a               LSR
&45e4: 4a               LSR
&45e5: 18               CLC
&45e6: 69 64            ADC #&64
&45e8: 48               PHA
&45e9: 20 78 25         JSR &2578 ; flip_object_in_direction_of_travel_on_random_3
&45ec: 68               PLA
&45ed: 20 98 32         JSR &3298 ; convert_object_keeping_palette
&45f0: 20 3c 25         JSR &253c ; is_this_object_damaged
&45f3: a9 a5            LDA #&a5
&45f5: b0 12            BCS &4609
&45f7: a5 07            LDA &07 ; current_object_rotator_low
&45f9: d0 18            BNE &4613
&45fb: 20 87 25         JSR &2587 ; increment_timers
&45fe: 4a               LSR
&45ff: 6a               ROR
&4600: 10 11            BPL &4613
&4602: 45 11            EOR &11 ; this_object_extra
&4604: 29 e0            AND #&e0
&4606: 4a               LSR
&4607: 09 05            ORA #&05
&4609: 8d 12 46         STA &4612
&460c: 20 fa 13         JSR &13fa ; play_sound
#460f: 9c 05 a6 a5 ; sound data
&4613: 60               RTS

; handle_tracer_bullet
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4614: 20 49 25         JSR &2549 ; gain_one_energy_point                       # tracer bullets are immortal
&4617: a9 08            LDA #&08                                                # explosion damage = &08
&4619: a2 0f            LDX #&0f                                                # bullet damage = &0f
&461b: 20 c3 46         JSR &46c3 ; bullet_with_particle_trail                  # leave a particle trail like an icer bullet
&461e: 4c 7a 46         JMP &467a ; one_in_four_towards_player                  # but home in on the player like a bird

; handle_bird_red
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4621: a5 da            LDA &da ; timer_2
&4623: d0 1a            BNE &463f ; no_sound_from_bird
&4625: 20 9e 2c         JSR &2c9e ; whistle_sound                               # does this also attract chatter?
&4628: 4c 3f 46         JMP &463f ; no_sound_from_bird
; handle_bird_invisible
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&462b: a5 11            LDA &11 ; this_object_extra
&462d: d0 02            BNE &4631 ; handle_bird
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&462f: 46 2b            LSR &2b ; object_is_invisible                           # invisible bird is invisible
; handle_bird
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4631: 20 87 25         JSR &2587 ; increment_timers
&4634: 29 3f            AND #&3f
&4636: d0 07            BNE &463f ; no_sound_from_bird
&4638: 20 fa 13         JSR &13fa ; play_sound
#463b: 57 07 43 f6 ; sound data
; no_sound_from_bird
&463f: a6 41		LDX &41 ; this_object_type
&4641: 98            	TYA
&4642: d0 06            BNE &464a
&4644: bd 62 46         LDA &4662,X # actually bird_damage_lookup
&4647: 20 a6 24         JSR &24a6 ; take_damage
&464a: bc 66 46         LDY &4666,X # actually bird_minimum_energy_lookup
&464d: 20 2e 35         JSR &352e ; give_minimum_energy
&4650: 29 7f            AND #&7f
&4652: 85 15            STA &15 ; this_object_energy
&4654: 20 3c 25         JSR &253c ; is_this_object_damaged
&4657: 66 11            ROR &11 ; this_object_extra
&4659: d0 2d            BNE &4688
&465b: a9 14            LDA #&14                                                # modulus
&465d: 20 55 25         JSR &2555 ; get_sprite_from_velocity                    # use velocity
&4660: 4a               LSR
&4661: 4a               LSR
&4662: c9 04            CMP #&04                                                # to calculate sprite for bird
&4664: d0 02            BNE &4668                                               # (&00 - &03)
&4666: a9 02            LDA #&02
&4668: 20 92 32         JSR &3292 ; change_sprite                               # set the sprite based on result
&466b: a9 11            LDA #&11				                # &11 = wasp
&466d: 20 e1 3b         JSR &3be1 ; absorb_object                               # birds eat wasps
&4670: a9 11            LDA #&11                                                # &11 = wasp
&4672: a0 00            LDY #&00                                                # &00 = player
&4674: 20 f8 3b         JSR &3bf8 ; find_target_occasionally
&4677: 20 09 3c         JSR &3c09 ; avoid_fireballs
; one_in_four_towards_player
&467a: 20 26 3d         JSR &3d26 ; target_processing
&467d: a0 08            LDY #&08                                                # maximum speed = &08
&467f: a9 40            LDA #&40                                                # velocity magnitude = &40
&4681: a2 40            LDX #&40                                                # probability = &40
&4683: 20 da 31         JSR &31da ; move_towards_target_with_probability_x
&4686: c6 42            DEC &42 ; acceleration_y
&4688: 24 1f            BIT &1f ; underwater
&468a: 30 03            BMI &468f
&468c: 20 1f 32         JSR &321f ; dampen_this_object_vel_xy_twice             # moves slower under water
&468f: 60               RTS
#4690: 00 03 40 14 ; bird_damage_lookup
#4694: 00 00 1e 00 ; bird_minimum_energy_lookup

; handle_mushroom_ball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4698: 30 0c		BMI &46a6				                # are we supporting anything?
&469a: b9 60 08         LDA &0860,Y ; object_stack_type
&469d: c9 37            CMP #&37				                # &37 = fireball
&469f: d0 0a            BNE &46ab                                               # is it a fireball?
# if it isn't a fireball, but we're supporting something, lose no energy - possibly a bug?
&46a1: a9 58            LDA #&58				                # &58 = coronium crystal
&46a3: 4c 86 32         JMP &3286 ; convert_object_to_another                   # if so, convert to a coronium crystal
&46a6: 20 1f 25         JSR &251f ; reduce_object_energy_by_one                 # have we run out of energy?
&46a9: d0 e4            BNE &468f				                # if not, leave
&46ab: a5 db            LDA &db ; timer_3
&46ad: 30 e0            BMI &468f                                               # 1 in 2 chance to leave anyway
&46af: a5 73            LDA &73 ; this_object_palette
&46b1: 4a               LSR
&46b2: 20 f0 3f         JSR &3ff0 ; consider_mushrooms_and_player               # is the player affected by them?
&46b5: a9 20            LDA #&20                                                # create &20 particles
&46b7: a0 4d            LDY #&4d                                                # &4d = mushroom particles
&46b9: 20 8e 21         JSR &218e ; add_particles                               # turn the mushroom ball to particles
&46bc: 4c 29 25         JMP &2529; mark_this_object_for_removal                 # and remove it

; handle_icer_bullet
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&46bf: a9 02            LDA #&02                                                # explosion damage = &02
&46c1: a2 14            LDX #&14                                                # icer bullet damage = &14
; bullet_with_particle_trail
&46c3: 48               PHA
&46c4: 20 af 1f         JSR &1faf ; is_it_supporting_anything_collidable
&46c7: 68               PLA
&46c8: c0 00            CPY #&00
&46ca: 30 0a            BMI &46d6                                               # has the bullet hit anything?
&46cc: 20 db 40         JSR &40db ; explode_object                              # if so, explode, doing damage from A
&46cf: 8a               TXA
&46d0: 20 a6 24         JSR &24a6 ; take_damage                                 # bullet damage is X
&46d3: 4c a3 28         JMP &28a3 ; zero_velocites
&46d6: 20 34 44         JSR &4434 ; move_bullet                                 # if bullet hasn't hit anything, move it
; create_bullet_particle_trail
&46d9: a5 b5            LDA &b5 ; angle
&46db: 49 80            EOR #&80                                                # 180 degrees
&46dd: 85 b5            STA &b5 ; angle                                         # away from bullet's direction of travel
&46df: a6 41            LDX &41 ; this_object_type
&46e1: bd d9 46         LDA &46d9,X # actually bullet_particle_colour_table
&46e4: 8d 36 02         STA &0236 ; particle_colour_table # for bullet          # set the particle colour to match bullet
&46e7: a0 2c            LDY #&2c                                                # &2c = bullet particles
&46e9: 4c 8c 21         JMP &218c ; add_particle                                # create particle
;      13 14 15 16 - icer bullet, tracer bullet, cannonball, blue death ball
#46ec: 02 04 08 08 ; bullet_particle_colour_table


; handle_crew_member
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&46f0: 20 92 24         JSR &2492 ; scream_if_damaged
&46f3: 20 6d 3a         JSR &3a6d
&46f6: 20 4e 25         JSR &254e ; gain_one_energy_point_if_not_immortal
&46f9: a9 07            LDA #&07
&46fb: 20 7a 25         JSR &257a ; flip_object_in_direction_of_travel_on_random_a
&46fe: a8               TAY
&46ff: a9 c0            LDA #&c0
&4701: 4c d0 38         JMP &38d0 ; change_palettes_for_player_like_objects

; handle_triax
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4704: a9 4a            LDA #&4a				                # &4a = destinator
&4706: 20 e1 3b         JSR &3be1 ; absorb_object			        # can triax collect the destinator?
&4709: d0 07            BNE &4712 ; no_destinator_for_triax
&470b: a9 80            LDA #&80
&470d: 8d 23 0a         STA &0a23 ; background_object_data	                # return destinator to triax's lair
&4710: d0 4a            BNE &475c ; teleport_away		                # and teleport away!
; no_destinator_for_triax
&4712: a5 3e            LDA &3e ; this_object_target
&4714: 30 04            BMI &471a
&4716: a5 06            LDA &06 ; current_object_rotator
&4718: f0 42            BEQ &475c
&471a: a5 15            LDA &15 ; this_object_energy
&471c: c9 40            CMP #&40
&471e: b0 06            BCS &4726
&4720: a5 d9            LDA &d9 ; timer_1
&4722: c9 04            CMP #&04
&4724: 90 36            BCC &475c
&4726: a5 db            LDA &db ; timer_3
&4728: c9 08            CMP #&08
&472a: a9 13            LDA #&13
&472c: b0 02            BCS &4730
&472e: a9 12            LDA #&12
&4730: 20 61 48         JSR &4861 ; gain_energy_fire_and_thrust_towards_player  # like a clawed robot
&4733: a5 15            LDA &15 ; this_object_energy
&4735: c9 05            CMP #&05
&4737: 2a               ROL
&4738: 05 dc            ORA &dc ; timer_4
&473a: 05 da            ORA &da ; timer_2
&473c: 4a               LSR
&473d: 90 1d            BCC &475c
&473f: ad aa 19         LDA &19aa ; player_east_of_76   
&4742: 49 80            EOR #&80                                                # if player is west of &76
&4744: 0d 1e 08         ORA &081e ; endgame_value                               # and we're in the end game
&4747: 30 06            BMI &474f                                             
&4749: a5 dc            LDA &dc ; timer_4                                       
&474b: 29 03            AND #&03                                                # then, with a 1 in 4 chance
&474d: f0 0d            BEQ &475c                                               # cause triax to teleport away # ?
&474f: 20 87 25         JSR &2587 ; increment_timers
&4752: f0 08            BEQ &475c                                               # otherwise a 1 in 256 chance to teleport
&4754: 20 f0 46         JSR &46f0 ; handle_crew_member                          # scream if damage, deal with sprite
&4757: a0 00            LDY #&00
&4759: 4c 8b 48         JMP &488b ; teleport_object_near_player

&475c: a9 00            LDA #&00
&475e: 4c 9e 48         JMP &489e ; teleport_away

; handle_big_fish
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4761: a9 10            LDA #&10				                # &10 = pirahna
&4763: 20 e1 3b         JSR &3be1 ; absorb_object                               # big fish eats pirahnas
&4766: a0 19            LDY #&19
&4768: 20 2e 35         JSR &352e ; give_minimum_energy                         # big fish minimum energy = &19
&476b: a5 20            LDA &20 ; this_object_water_level
&476d: c9 32            CMP #&32                                                # is the big fish underwater?
&476f: 90 51            BCC &47c2                                               # if not, leave - it doesn't move
&4771: a9 10            LDA #&10                                                # &10 = pirahna
&4773: a8               TAY
&4774: 20 f8 3b         JSR &3bf8 ; find_target_occasionally                    # look for pirahnas to eat
&4777: 20 26 3d         JSR &3d26 ; target_processing
&477a: a9 10            LDA #&10
&477c: 24 3e            BIT &3e ; this_object_target
&477e: 10 01            BPL &4781                                               # target &80 = &00 ?
&4780: 0a               ASL                                                     # velocity magnitude
&4781: a0 02            LDY #&02                                                # maximum speed
&4783: 20 d8 31         JSR &31d8 ; move_towards_target
&4786: 4c 78 25         JMP &2578 ; flip_object_in_direction_of_travel_on_random_3

; handle_sucker
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4789: 98               TYA                                                     # is the sucker touching anything?
&478a: 05 dc            ORA &dc ; timer_4                                       # if so, a one in two chance
&478c: 30 34            BMI &47c2                                       
&478e: 4c a9 0b         JMP &0ba9 ; set_object_velocities                       # to set its velocities to match

; handle_engine_fire
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4791: 20 1f 25         JSR &251f ; reduce_object_energy_by_one                 # reduce its energy
&4794: d0 2c            BNE &47c2                                               # leave if it still has energy
&4796: 4c 29 25         JMP &2529; mark_this_object_for_removal                 # otherwise remove it

; handle_red_drop
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4799: 30 23            BMI &47be ; red_drop_not_touching			# is it touching anything?
&479b: b9 60 08         LDA &0860,Y ; object_stack_type                         # if so,
&479e: c9 09            CMP #&09			                        # &09 = red slime
&47a0: f0 20            BEQ &47c2			                        # ignore collisions with red slime
&47a2: c9 0b            CMP #&0b			                        # &0b = yellow ball
&47a4: f0 1d            BEQ &47c3 ; convert_to_coronium_boulder                 # convert yellow balls to coronium boulders
&47a6: c9 10            CMP #&10			                        # &10 = pirahna
&47a8: f0 0c            BEQ &47b6                                               # explode on contact with pirahna, no damage
&47aa: 20 f8 13         JSR &13f8 ; play_sound2
#47ad: 17 03 1b 02 ; sound data
&47b1: a9 64            LDA #&64                                                # red drop damage = &64
&47b3: 20 a6 24         JSR &24a6 ; take_damage                                 # otherwise damage object
&47b6: 20 a5 14         JSR &14a5 ; play_high_beep
&47b9: a9 00            LDA #&00			                        # and explode!
&47bb: 4c e2 40         JMP &40e2 ; explode_without_sound
; red_drop_not_touching
&47be: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&47c0: 30 f4            BMI &47b6                                               # if so, explode it
&47c2: 60               RTS
; convert_to_coronium_boulder
&47c3: a9 55            LDA #&55			                        # &55 = coronium boulder
&47c5: 99 60 08         STA &0860,Y ; object_stack_type
&47c8: 60               RTS

; handle_red_slime
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&47c9: a5 07            LDA &07 ; current_object_rotator_low
&47cb: f0 0a            BEQ &47d7 ; no_red_drop
&47cd: 4a               LSR
&47ce: 38               SEC
&47cf: e9 04            SBC #&04
&47d1: 10 26            BPL &47f9 ; no_red_drop2
&47d3: 49 ff            EOR #&ff
&47d5: 10 22            BPL &47f9 ; no_red_drop2
&47d7: 24 da            BIT &da ; timer_2                                       # once in a while, create a red drop
&47d9: 10 1c            BPL &47f7 ; no_red_drop
&47db: a9 36            LDA #&36				                # &36 = red drop
&47dd: 20 60 1e         JSR &1e60 ; reserve_object_low_priority		        # try to reserve slot for it
&47e0: b0 15            BCS &47f7 ; no_red_drop			
&47e2: a9 90            LDA #&90                                                # x_low is either &90 or &30
&47e4: 24 37            BIT &37 ; this_object_angle                             # depending on orientation
&47e6: 30 02            BMI &47ea
&47e8: a9 30            LDA #&30
&47ea: 99 80 08         STA &0880,Y ; object_stack_x_low	                # set x_low for drop
&47ed: a9 40            LDA #&40
&47ef: 99 a3 08         STA &08a3,Y ; object_stack_y_low	                # set y_low for drop
&47f2: a9 04            LDA #&04
&47f4: 99 f6 08         STA &08f6,Y  ; object_stack_vel_y	                # set y velocity for drop
; no_red_drop
&47f7: a9 03            LDA #&03
; no_red_drop2
&47f9: 18               CLC
&47fa: 69 1c            ADC #&1c
&47fc: a8               TAY
&47fd: 85 75            STA &75 ; this_object_sprite
&47ff: a2 00            LDX #&00                                                # X = 0, x direction
&4801: 4c aa 32         JMP &32aa ; change_object_width

; handle_hovering_robot
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4804: 20 10 4f         JSR &4f10 ; towards_gain_energy_or_flash_if_damaged     # hovering robot energy = &14
&4807: 90 b9            BCC &47c2                                               # leave if insufficient energy
&4809: a5 dc            LDA &dc ; timer_4
&480b: 4a               LSR
&480c: d0 07            BNE &4815                                               # once every &80 cycles
&480e: 20 fa 13         JSR &13fa ; play_sound                                  # make a noise
#4811: 33 f3 63 e3 ; sound data
&4815: a5 d9            LDA &d9 ; timer_1
&4817: c9 40            CMP #&40                                                # three out of four times,
&4819: b0 53            BCS &486e ; thrust_and_home_in_on_player                # thrust towards player
&481b: a9 18            LDA #&18                                                # &18 = pistol bullet
&481d: d0 45            BNE &4864                                               # one out of four times shoot as well

; handle_clawed_robot
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&481f: 20 3c 25         JSR &253c ; is_this_object_damaged
&4822: 66 11            ROR &11 ; this_object_extra
&4824: 46 11            LSR &11 ; this_object_extra
&4826: a6 41            LDX &41 ; this_object_type
&4828: bc 81 48         LDY &4881,X 			# actually clawed_robot_minimum_energy_lookup
&482b: 20 2e 35         JSR &352e ; give_minimum_energy
&482e: f0 92            BEQ &47c2                                               # if out of energy, leave
&4830: 29 f8            AND #&f8
&4832: 4a               LSR
&4833: 9d 21 08         STA &0821,X ; teleport_last	# actually clawed_robot_energy_when_last_used
&4836: 0a               ASL
&4837: c9 8c            CMP #&8c
&4839: 90 08            BCC &4843
&483b: a5 3e            LDA &3e ; this_object_target
&483d: 29 c0            AND #&c0
&483f: 05 06            ORA &06 ; current_object_rotator
&4841: d0 0a            BNE &484d
&4843: a5 11            LDA &11 ; this_object_extra
&4845: d0 06            BNE &484d
&4847: 9d 1d 08         STA &081d,X 			# actually clawed_robot_availability
&484a: 4c 9e 48         JMP &489e ; teleport_away
&484d: a0 46            LDY #&46
&484f: 20 8b 48         JSR &488b ; teleport_object_near_player
&4852: 20 87 25         JSR &2587 ; increment_timers
&4855: 4a               LSR
&4856: d0 07            BNE &485f
&4858: 20 fa 13         JSR &13fa ; play_sound
#485b: 17 03 68 a3 ; sound data
&485f: a9 13            LDA #&13                                                # &13 = icer bullet
; gain_energy_fire_and_thrust_towards_player
&4861: 20 49 25         JSR &2549 ; gain_one_energy_point
&4864: 20 49 25         JSR &2549 ; gain_one_energy_point
&4867: aa               TAX
&4868: a8               TAY                                                     # Y = ???
&4869: a9 81            LDA #&81                                                # &81 = active chatter and player
&486b: 20 68 27         JSR &2768 ; find_a_target_and_fire_at_it                # find a target and fire at it
; thrust_and_home_in_on_player
&486e: a9 00            LDA #&00
&4870: 85 0e            STA &0e ; this_object_target_object                     # target the player
&4872: 20 26 3d         JSR &3d26 ; target_processing
&4875: a9 07            LDA #&07
&4877: 20 7a 25         JSR &257a ; flip_object_in_direction_of_travel_on_random_a
; thrust_towards_player
&487a: a9 1c            LDA #&1c                                                # velocity magnitude
&487c: a0 04            LDY #&04                                                # maximum speed
&487e: a2 80            LDX #&80                                                # half of the time
&4880: 20 da 31         JSR &31da ; move_towards_target_with_probability_x
&4883: c6 42            DEC &42 ; acceleration_y
&4885: 20 1e 3a         JSR &3a1e ; bob_up_and_down
&4888: 4c 3d 1f         JMP &1f3d ; create_jetpack_thrust

; teleport_object_near_player
&488b: 24 17            BIT &17 ; object_onscreen?                              # is the object already on screen?
&488d: 10 31            BPL &48c0                                               # if so, leave
&488f: a9 40            LDA #&40
&4891: 85 3e            STA &3e ; this_object_target                            # target the player | &40
&4893: a9 03            LDA #&03
&4895: 20 43 27         JSR &2743 ; get_random_square_near_player
&4898: 20 05 3e         JSR &3e05 ; store_square_x_y_in_tx_ty
&489b: 20 c1 3b         JSR &3bc1 ; get_biggest_of_a_and_y
; teleport_away
&489e: 85 16            STA &16 ; this_object_ty
&48a0: 4c e5 0c         JMP &0ce5

#48a3: 46 5a 80 82 ; clawed_robot_minimum_energy_lookup

; chatter_subroutine
&48a7: a5 27            LDA &27 ; whistle1_played
&48a9: 29 80            AND #&80
&48ab: 10 04            BPL &48b1                                               # has whistle 1 been played?
&48ad: 85 12            STA &12 ; this_object_timer                             # if so, note it in timer and extra
&48af: 85 11            STA &11 ; this_object_extra
&48b1: a2 07            LDX #&07
&48b3: 20 c9 27         JSR &27c9 ; npc_targetting
&48b6: 20 26 3d         JSR &3d26 ; target_processing
&48b9: 46 21            LSR &21 ; npc_fed					# have we just fed chatter a crystal?
&48bb: 90 03            BCC &48c0
&48bd: ee 1c 08         INC &081c ; chatter_energy_level			# if so, increase his energy
&48c0: 60               RTS 

; handle_chatter_inactive
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&48c1: 20 a7 48         JSR &48a7 ; chatter_subroutine                          # absorb crystals and listen for whistle 1
&48c4: a5 12            LDA &12 ; this_object_timer                             # has whistle 1 been played?
&48c6: 10 f8            BPL &48c0
&48c8: 85 15            STA &15 ; this_object_energy                            # if so, give chatter energy
&48ca: ce 1c 08         DEC &081c ; chatter_energy_level                        # reduce reserve energy
&48cd: 30 ee            BMI &48bd                                               # if no reserve energy, keep inactive
&48cf: a9 01            LDA #&01                                                # &01 = active chatter
&48d1: 2c a9 38         BIT &38a9                                               # otherwise activate chatter
; deactivate_chatter
#48d2:    a9 38         LDA #&38                                                # &38 = inactive chatter
&48d4: 4c 86 32         JMP &3286 ; convert_object_to_another

; handle_chatter_active
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&48d7: 20 a7 48         JSR &48a7 ; chatter_subroutine                          # absorb crystals and listen for whistle 1
&48da: a0 00            LDY #&00
&48dc: 20 47 35         JSR &3547 ; give_minimum_energy_and_flash_if_damaged    # chatter minimum energy = &00
&48df: a5 15            LDA &15 ; this_object_energy
&48e1: f0 ef            BEQ &48d2 ; deactivate_chatter                          # deactivate chatter if run out of energy
&48e3: a9 1f            LDA #&1f
&48e5: 20 7a 25         JSR &257a ; flip_object_in_direction_of_travel_on_random_a
&48e8: 24 c4            BIT &c4 ; loop_counter_every_08
&48ea: 10 22            BPL &490e                                               # once every eight cycles,
&48ec: a9 20            LDA #&20                                                # &20 = cyan/red turret
&48ee: a0 86            LDY #&86                                                # &86 = object range 6 (flying enemies)
&48f0: 20 2a 3c         JSR &3c2a ; find_nearest_object
&48f3: 30 19            BMI &490e ; no_enemies_for_chatter                      # is there an enemy near chatter?
&48f5: a5 b5            LDA &b5 ; angle
&48f7: 69 40            ADC #&40
&48f9: 85 37            STA &37 ; this_object_angle
&48fb: 45 6f            EOR &6f ; this_object_flags
&48fd: 30 0f            BMI &490e ; no_enemies_for_chatter                      # is chatter facing the enemy?
&48ff: a5 b5            LDA &b5 ; angle
&4901: 29 7f            AND #&7f
&4903: e9 0a            SBC #&0a
&4905: c9 6c            CMP #&6c
&4907: 90 05            BCC &490e ; no_enemies_for_chatter                      # and they're at a reasonable angle
&4909: 85 12            STA &12 ; this_object_timer
&490b: 20 a5 33         JSR &33a5 ; generate_lightning                          # attack them with lightning
; no_enemies_for_chatter
&490e: a5 12            LDA &12 ; this_object_timer
&4910: f0 21            BEQ &4933 ; no_chatter_song
&4912: c6 12            DEC &12 ; this_object_timer
&4914: a5 d9            LDA &d9 ; timer_1
&4916: c9 c0            CMP #&c0
&4918: 90 19            BCC &4933 ; no_chatter_song
&491a: a5 dc            LDA &dc ; timer_4                                       # pick a random note for chatter
&491c: 4a               LSR
&491d: 4a               LSR
&491e: 45 11            EOR &11 ; this_object_extra
&4920: 69 40            ADC #&40
&4922: 49 c0            EOR #&c0
&4924: 4a               LSR
&4925: 8d 88 2e         STA &2e88 ; chatter_pitch
&4928: 20 fa 13         JSR &13fa ; play_sound                                  # sing chatter's song
#492b: 33 f3 cd 82 ; sound data
&492e: a9 4b		LDA #&4b				                # change colour
&4931: 85 73            STA &73 ; this_object_palette
; no_chatter_song
&4933: ae d8 29         LDX &29d8 ; whistle2_played		                # has whistle 2 been played?
&4936: 30 14            BMI &494c ; no_whistle2
&4938: 20 9a 35         JSR &359a ; is_object_close_enough_80
&493b: b0 0f            BCS &494c                                               # is chatter close enough to the player?
&493d: a0 4b            LDY #&4b                                                # &4b = energy capsule
&493f: a9 40            LDA #&40
&4941: 20 91 27         JSR &2791 ; in_enemy_fire                               # try to create an energy capsule
&4944: 10 06            BPL &494c
&4946: b0 04            BCS &494c                                               # and if successful,
&4948: a9 00            LDA #&00                                                # reduce chatter's energy to zero
&494a: 85 15            STA &15 ; this_object_energy
&494c: a5 3b            LDA &3b ; this_object_supporting
; no_whistle2
&494e: 05 0e            ORA &0e ; this_object_target_object
&4950: d0 02            BNE &4954
&4952: 85 3e            STA &3e ; this_object_target
&4954: 4c 7a 48         JMP &487a ; thrust_towards_player

&4957: 60               RTS

; switch_effects_table
#4958: 00 b0 bb 84 00 0f 29 00 c5 00 e7 8f 00 8a 00 13
#4968: 00 8e 32 00 c2 00 11 aa bd 00 58 cc 55 bc 00 55
#4978: 00 46 a9 00 6a 8b 00 e6 85 d8 00 c7 88 00 68 00
#4988: 14 00 28 4c 00 65 00 89 00 8d 00 64 2a 00 6b 00
#4998: a7 b9 10 00

#499c: ea ; (unused)

; handle_switch
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&499d: 18               CLC
&499e: 30 03            BMI &49a3				                # is it touching something?
&49a0: 20 c5 49         JSR &49c5 ; can_object_trigger_switch                   # is that something sufficiently heavy?
&49a3: 66 14            ROR &14 ; this_object_tx                                # if so, mark the switch as touched
&49a5: 10 16            BPL &49bd ; switch_not_pressed
&49a7: a5 14            LDA &14 ; this_object_tx                        
&49a9: 0a               ASL                                                     # has the switch been recently touched?
&49aa: d0 11            BNE &49bd ; switch_not_pressed                          # if so, don't trigger it again
&49ac: 2a               ROL
&49ad: 45 bc            EOR &bc ; this_object_data
&49af: 85 bc            STA &bc ; this_object_data                              # toggle switch state
&49b1: a2 ff            LDX #&ff
&49b3: 20 db 49         JSR &49db ; switch_effects                              # and do whatever the switch does!
&49b6: 20 fa 13         JSR &13fa ; play_sound
#49b9: 3d 04 11 d4 ; sound data
; switch_not_pressed
&49bd: a5 bc            LDA &bc ; this_object_data
&49bf: 4a               LSR
&49c0: 66 37            ROR &37 ; this_object_angle                             # change switch's appearance (in / out)
&49c2: 4c 38 35         JMP &3538 ; gain_energy_or_flash_if_damaged_minimum_1e  # switch minimum energy = &1e

; can_object_trigger_switch
; returns carry set if object can trigger switches, carry clear if not
;       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
;   00 ok ok ok no -- -- ok ok ok -- ok ok -- -- ok ok
;   10 ok ok ok ok ok ok ok ok no ok ok ok ok ok ok --
;   20 ok ok ok no no no no no -- ok ok ok ok ok ok ok
;   30 ok ok ok no no no ok ok ok ok ok -- -- -- -- --
;   40 ok -- -- ok  n ok ok ok -- ok ok no no ok no no
;   50 ok ok ok ok ok ok ok ok no ok ok ok ok ok ok ok
;   60 ok no no ok --
&49c5: 20 20 1e         JSR &1e20 ; get_object_weight			        # how heavy is what is touching the switch?
&49c8: c9 02            CMP #&02					        # if it has weight less than 3
&49ca: 90 0e            BCC &49da					        # then it doesn't trigger the switch
&49cc: e0 35            CPX #&35					        # X = object type
&49ce: f0 06            BEQ &49d6					        # &35 = engine fire doesn't trigger switch
&49d0: e0 27            CPX #&27					        # &27 = maggot 
&49d2: b0 06            BCS &49da					        # objects &28 - &63 do trigger switch
&49d4: e0 22            CPX #&22					        # objects &00 - &22 do trigger switch 
&49d6: 2a               ROL
&49d7: 49 01            EOR #&01
&49d9: 6a               ROR
&49da: 60               RTS

; switch_effects
; X = &ff if real switch, something else if invisible
; A = switch subtype = &80
; A = this_object_data
&49db: 86 9c            STX &9c
&49dd: 4a               LSR
&49de: 48               PHA
&49df: 29 03            AND #&03
&49e1: 85 9d            STA &9d ; switch_type_and_03
&49e3: 68               PLA
&49e4: 4a               LSR
&49e5: 4a               LSR
&49e6: aa               TAX
&49e7: a0 ff            LDY #&ff
&49e9: c8               INY
&49ea: b9 58 49         LDA &4958,Y ; switch_effects_table                      # find a zero slot in switch_effects_table
&49ed: d0 fa            BNE &49e9
&49ef: ca               DEX
&49f0: 10 f7            BPL &49e9                                               # find the Xth zero slot in switch_effects_table
&49f2: aa               TAX
&49f3: bd 86 09         LDA &0986,X ; background_objects_data
&49f6: 85 9a            STA &9a
&49f8: 25 9c            AND &9c
&49fa: 45 9d            EOR &9d
&49fc: 9d 86 09         STA &0986,X ; background_objects_data
&49ff: c8               INY
&4a00: be 58 49         LDX &4958,Y ; switch_effects_table
&4a03: d0 ee            BNE &49f3
&4a05: c5 9a            CMP &9a
&4a07: f0 07            BEQ &4a10
&4a09: 20 fa 13         JSR &13fa ; play_sound
#4a0c: c7 c3 c1 03 ; sound data
&4a10: 60               RTS

; handle_player_object
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4a11: 30 09            BMI &4a1c                                               # is the player touching something?
&4a13: b9 60 08         LDA &0860,Y ; object_stack_type
&4a16: 49 03            EOR #&03                                                # &03 = fluffy
&4a18: d0 02            BNE &4a1c ; not_supporting_fluffy                       # is it fluffy?
&4a1a: 84 dd            STY &dd ; object_held                                   # if so, it jumps into the player's hands
; not_supporting_fluffy
&4a1c: 6e d7 29         ROR &29d7 ; object_being_fired                          # clear object_being_fired
&4a1f: a5 53            LDA &53 ; this_object_x
&4a21: c9 76            CMP #&76                                                # if player_x >= &76
&4a23: 6e aa 19         ROR &19aa ; player_east_of_76                           # then set player_east_of_76
&4a26: 20 ff 34         JSR &34ff ; retrieve_object_if_marked
&4a29: a5 dd            LDA &dd ; object_held
&4a2b: 48               PHA
&4a2c: 20 a8 01         JSR &01a8 ; process_keys
&4a2f: a9 10            LDA #&10
&4a31: 24 6f            BIT &6f ; this_object_flags
&4a33: d0 03            BNE &4a38
&4a35: 20 95 37         JSR &3795 ; do_player_stuff
&4a38: 20 fc 30         JSR &30fc ; process_gun_aim
&4a3b: 68               PLA                                                     # object_held
&4a3c: a8               TAY                                                     # are we holding anything?
&4a3d: 30 18            BMI &4a57 ; not_holding_anything
&4a3f: a5 37            LDA &37 ; this_object_angle
&4a41: 45 6f            EOR &6f ; this_object_flags
&4a43: 10 12            BPL &4a57 ; not_holding_anything
&4a45: be 70 08         LDX &0870,Y ; object_stack_sprite
&4a48: bd 0c 5e         LDA &5e0c,X ; sprite_width_lookup
&4a4b: 24 37            BIT &37 ; this_object_angle
&4a4d: 20 4c 32         JSR &324c ; make_negative
&4a50: a2 00            LDX #&00
&4a52: 24 6f            BIT &6f ; this_object_flags
&4a54: 20 38 2a         JSR &2a38 ; move_object_in_one_direction_with_given_velocity
; not_holding_anything
&4a57: 24 c5            BIT &c5 ; loop_counter_every_04
&4a59: 10 0d            BPL &4a68
&4a5b: a5 25            LDA &25 ; bells_to_sound
&4a5d: f0 09            BEQ &4a68
&4a5f: c6 25            DEC &25 ; bells_to_sound
&4a61: 20 fa 13         JSR &13fa ; play_sound
#4a64: 17 e3 2f 82 ; sound data
&4a68: ce d6 29         DEC &29d6 ; autofire_timeout
&4a6b: d0 03            BNE &4a70
&4a6d: 4e 78 12         LSR &1278 ; fire_pressed
&4a70: a5 36            LDA &36 ; player_bullet				        # has the player fired the discharge device?
&4a72: 10 13            BPL &4a87					        # if not, leave
&4a74: e6 36            INC &36 ; player_bullet
&4a76: 20 e8 40         JSR &40e8 ; explode_without_sound_or_damage	        # discharge device
&4a79: a9 0a            LDA #&0a
&4a7b: 85 3d            STA &3d ; this_object_data_pointer			# damage ?
&4a7d: 20 f8 13         JSR &13f8 ; play_sound2				        # play sound for discharge device
#4a80: 17 03 11 04 ; sound data
&4a84: 20 9c 4f         JSR &4f9c ; handle_explosion			        # create particles for discharge device
&4a87: 60               RTS

; handle_plasma_ball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4a88: 30 08            BMI &4a92					        # is it touching something?
&4a8a: b9 60 08         LDA &0860,Y ; object_stack_type
&4a8d: 20 d0 1f         JSR &1fd0 ; does_it_collide_with_bullets	        # and it's not a bush, fireball or explosion?
&4a90: d0 21            BNE &4ab3 ; plasma_ball_collision
&4a92: a5 1f            LDA &1f ; underwater                                    # if it's underwater
&4a94: 05 d9            ORA &d9 ; timer_1
&4a96: 05 dc            ORA &dc ; timer_4
&4a98: 10 2e            BPL &4ac8 ; plasma_ball_in_water                        # then 25% of the time fizzle it out
&4a9a: 20 1f 25         JSR &251f ; reduce_object_energy_by_one
&4a9d: f0 2c            BEQ &4acb                                               # if it's run out of energy, remove it
&4a9f: c9 03            CMP #&03
&4aa1: a0 a0            LDY #&a0
&4aa3: a9 03            LDA #&03
&4aa5: b0 04            BCS &4aab                                               # cause it to fizzle if it's low on energy
&4aa7: a0 a1            LDY #&a1
&4aa9: a9 1e            LDA #&1e
&4aab: 8c 0c 02         STY &020c ; particle_flags_table                        # (for plasma ball)
&4aae: a0 00            LDY #&00
&4ab0: 4c 8e 21         JMP &218e ; add_particles
; plasma_ball_collision							        # the plasma ball has collided with something
&4ab3: a9 0d            LDA #&0d
&4ab5: 2c a9 07         BIT &07a9
; turn_to_fireball_energy_7
#4ab6:    a9 07         LDA #&07					        # various entrances to this code
&4ab8: 2c a9 02         BIT &02a9
; turn_to_fireball_energy_2
#4ab9:    a9 02         LDA #&02					        # this one appears to be unused?
&4abb: 85 12            STA &12 ; this_object_timer
&4abd: 85 15            STA &15 ; this_object_energy
&4abf: a9 00            LDA #&00
&4ac1: 85 0e            STA &0e ; this_object_target_object                     # target the player 
&4ac3: a9 37            LDA #&37					        # convert the plasma ball to a fireball
&4ac5: 4c 86 32         JMP &3286 ; convert_object_to_another
; plasma_ball_in_water
&4ac8: 20 a7 4a         JSR &4aa7                                               # cause it to fizzle
&4acb: 4c 29 25         JMP &2529; mark_this_object_for_removal                 # then remove it

#4ace: 10 34 34 34 10 34 10 34 ; fireball_palettes
; handle_fireball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4ad6: a5 20            LDA &20 ; this_object_water_level                       # is it underwater?
&4ad8: 25 db            AND &db ; timer_3
&4ada: 25 da            AND &da ; timer_2
&4adc: 30 ea            BMI &4ac8 ; plasma_ball_in_water                        # 25% chance that it fizzles and dies
&4ade: a5 0e            LDA &0e ; this_object_target_object
&4ae0: d0 68            BNE &4b4a                                               # are we targetting the player?
&4ae2: c6 12            DEC &12 ; this_object_timer
&4ae4: 30 e5            BMI &4acb
&4ae6: a2 0a            LDX #&0a
; check_fireball_collision
# x = 4, &14 from moving fireball
&4ae8: a5 07            LDA &07 ; current_object_rotator_low
&4aea: d0 08            BNE &4af4
&4aec: a5 12            LDA &12 ; this_object_timer
&4aee: c9 08            CMP #&08
&4af0: 90 02            BCC &4af4
&4af2: a2 5a            LDX #&5a
&4af4: 98               TYA
&4af5: 30 14            BMI &4b0b ; no_fireball_collision                       # is it touching anything?
&4af7: d0 06            BNE &4aff                                               # is it the player?
&4af9: 2c 14 08         BIT &0814 ; fire_immunity_collected                     # if so, do they have immunity?
&4afc: 10 01            BPL &4aff
&4afe: aa               TAX                                                     # player without immunity damage = A
&4aff: 8a               TXA                                                     # other objects and immune player damage = X
&4b00: 20 a6 24         JSR &24a6 ; take_damage
&4b03: 20 c9 1f         JSR &1fc9 ; does_it_collide_with_bullets_2
&4b06: f0 03            BEQ &4b0b ; no_fireball_collision
&4b08: 20 b4 0b         JSR &0bb4 ; get_object_velocities
; no_fireball_collision
&4b0b: 20 87 25         JSR &2587 ; increment_timers
&4b0e: 85 37            STA &37 ; this_object_angle
&4b10: 0a               ASL
&4b11: 85 39            STA &39 ; this_object_flags_lefted
&4b13: a5 12            LDA &12 ; this_object_timer
&4b15: 29 07            AND #&07
&4b17: aa               TAX
&4b18: bd ce 4a         LDA &4ace,X ; fireball_palettes			        # change the colour of the fireball
&4b1b: 85 73            STA &73 ; this_object_palette
&4b1d: a9 c0            LDA #&c0                                                # &c0 = straight up
&4b1f: 85 b5            STA &b5 ; angle
&4b21: a0 21            LDY #&21                                                # &21 = fireball particle
&4b23: 4c 8c 21         JMP &218c ; add_particle                                # create firey smoke particles going upward

; handle_moving_fireball
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4b26: a2 04            LDX #&04
&4b28: 20 e8 4a         JSR &4ae8 ; check_fireball_collision                    # has it collided with anything?
&4b2b: 20 aa 28         JSR &28aa ; copy_object_values_from_old
&4b2e: a5 3b            LDA &3b ; this_object_supporting
&4b30: f0 03            BEQ &4b35
&4b32: 20 4c 41         JSR &414c
&4b35: 20 72 46         JSR &4672
&4b38: 24 1f            BIT &1f ; underwater
&4b3a: 30 08            BMI &4b44                                               # is it underwater?
&4b3c: a9 fc            LDA #&fc                                                # if so, accelerate it upwards
&4b3e: 85 42            STA &42 ; acceleration_y
&4b40: 24 20            BIT &20 ; this_object_water_level                       # is it still underwater?
&4b42: 30 84            BMI &4ac8                                               # if so, cause it to fizzle and die
&4b44: 20 01 1f         JSR &1f01 ; accelerate_object
&4b47: 4c 31 2a         JMP &2a31 ; move_object
&4b4a: 20 ae 28         JSR &28ae
&4b4d: 24 da            BIT &da ; timer_2
&4b4f: 10 58            BPL &4ba9
&4b51: a5 da            LDA &da ; timer_2
&4b53: 29 0f            AND #&0f
&4b55: 65 07            ADC &07 ; current_object_rotator_low
&4b57: 0a               ASL
&4b58: 65 51            ADC &51 ; this_object_y_low
&4b5a: 69 18            ADC #&18
&4b5c: 85 51            STA &51 ; this_object_y_low
&4b5e: c6 12            DEC &12 ; this_object_timer
&4b60: a2 14            LDX #&14
&4b62: d0 84            BNE &4ae8 ; check_fireball_collision                    # if it still has energy, check collisions
; handle_placeholder                                                            
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4b64: 30 05            BMI &4b6b                                               # is it touching anything?
&4b66: 20 c5 49         JSR &49c5 ; can_object_trigger_switch
&4b69: b0 14            BCS &4b7f
&4b6b: a4 07            LDY &07 ; current_object_rotator_low
&4b6d: d0 3a            BNE &4ba9 ; handle_bush                                 # if not, make stationary
&4b6f: a5 bc            LDA &bc ; this_object_data
&4b71: 20 b0 2d         JSR &2db0 ; convert_object_to_range_a
&4b74: e0 09            CPX #&09                                                # is it range 9? (indestructible equipment)
&4b76: f0 31            BEQ &4ba9 ; handle_bush                                 # if so, remain stationary
&4b78: a2 00            LDX #&00                                                # X = 0, player object
&4b7a: 20 9a 35         JSR &359a ; is_object_close_enough_80                   # is it close to the player?
&4b7d: b0 2a            BCS &4ba9 ; handle_bush                                 # if set, remain stationary
&4b7f: a5 bc            LDA &bc ; this_object_data
&4b81: 85 41            STA &41 ; this_object_type
&4b83: a9 ff            LDA #&ff
&4b85: 85 15            STA &15 ; this_object_energy
&4b87: 60               RTS

; handle_collectable
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4b88: a5 dd            LDA &dd ; object_held
&4b8a: c5 aa            CMP &aa ; current_object		                # are we holding it?
&4b8c: d0 0f            BNE &4b9d                                               # if so:
&4b8e: a6 41            LDX &41 ; this_object_type
&4b90: de b5 07         DEC &07b5,X				                # set the relevant collected byte
&4b93: 20 fa 13         JSR &13fa ; play_sound
#4b96: 72 a5 7b 85 ; sound data
&4b9a: 4c 29 25		JMP &2529; mark_this_object_for_removal                 # and remove it
; keep_object_floating_until_disturbed
&4b9d: a4 3b            LDY &3b ; this_object_supporting                        # otherwise, is it touching anything?
&4b9f: 30 04            BMI &4ba5
&4ba1: 06 15            ASL &15 ; this_object_energy                            # if so, mark it as disturbed
&4ba3: 46 15            LSR &15 ; this_object_energy
&4ba5: 24 15            BIT &15 ; this_object_energy                            # has it been disturbed?
&4ba7: 10 6b            BPL &4c14				                # if not, keep it stationary
; handle_bush
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4ba9: 20 a3 28         JSR &28a3 ; zero_velocities
&4bac: 4c aa 28         JMP &28aa ; copy_object_values_from_old

; handle_nest
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4baf: 4a               LSR                                                     # data &7c = child type * 4
&4bb0: 4a               LSR
&4bb1: 85 11            STA &11 ; this_object_extra                             # this_object_extra = child type
&4bb3: 20 e1 3b         JSR &3be1 ; absorb_object                               # absorb children if they're near
&4bb6: a9 46            LDA #&46
&4bb8: 20 2e 35         JSR &352e ; give_minimum_energy                         # nest minimum energy = &46
&4bbb: 24 c5            BIT &c5 ; loop_counter_every_04
&4bbd: 10 55            BPL &4c14                                               # every 4 cycles
&4bbf: a5 bc            LDA &bc ; this_object_data
&4bc1: 29 03            AND #&03                                                # is the nest active?
&4bc3: d0 4f            BNE &4c14                                               # if not, leave
&4bc5: a5 11            LDA &11 ; this_object_extra		                # this_object_extra = child type
&4bc7: 20 18 3c         JSR &3c18 ; count_objects_of_type_a_in_stack            # how many children already exist?
&4bca: 20 87 25         JSR &2587 ; increment_timers
&4bcd: 25 d9            AND &d9 ; timer_1
&4bcf: 25 db            AND &db ; timer_3
&4bd1: 29 07            AND #&07                                                # create up to seven children
&4bd3: c5 9f            CMP &9f ; count                                         # probability decreases the more there are
&4bd5: 90 3d            BCC &4c14                                               # if not, leave
&4bd7: a9 0e            LDA #&0e                                                # &0e = big fish
&4bd9: a0 86            LDY #&86                                                # &86 = object range 6 (flying enemies)
&4bdb: 20 2a 3c         JSR &3c2a ; find_nearest_object                         # are there nest enemies around?
&4bde: 10 34            BPL &4c14                                               # if so, leave
&4be0: 20 fa 13         JSR &13fa ; play_sound
#4be3: 33 f3 4f 35 ; sound data
&4be7: a5 37            LDA &37 ; this_object_angle                             # aim the nest's children towards the player
&4be9: 29 80            AND #&80                                                # &00 = straight left, &80 = straight right
&4beb: 85 b5            STA &b5 ; angle
&4bed: a9 20            LDA #&20                                                # velocity magnitude = &20
&4bef: 20 57 23         JSR &2357 ; determine_velocities_from_angle
&4bf2: a5 11            LDA &11 ; this_object_extra                             # this_object_extra = child type
&4bf4: 20 b8 33         JSR &33b8 ; create_child_object                         # create a child
&4bf7: b0 1b            BCS &4c14                                               # if we couldn't, leave
&4bf9: a5 aa            LDA &aa ; current_object
&4bfb: 9d 06 09         STA &0906,X ; object_stack_target                       # child's target is the nest
&4bfe: a9 20            LDA #&20
&4c00: 24 37            BIT &37 ; this_object_angle
&4c02: 30 02            BMI &4c06
&4c04: a9 a0            LDA #&a0
&4c06: 9d 76 09         STA &0976,X ; object_stack_extra
&4c09: 0a               ASL
&4c0a: 90 08            BCC &4c14
&4c0c: bd d6 08         LDA &08d6,X ; object_stack_palette		        # change colour ?
&4c0f: 49 3b            EOR #&3b
&4c11: 9d d6 08         STA &08d6,X ; object_stack_palette
&4c14: 60               RTS

; handle_engine_thruster
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4c15: 29 03            AND #&03
&4c17: d0 5f            BNE &4c78 ; turn_thruster_off                           # is the thruster on?
&4c19: e6 11            INC &11 ; this_object_extra
&4c1b: 10 04            BPL &4c21
&4c1d: e8               INX
&4c1e: e8               INX
&4c1f: 86 bc            STX &bc ; this_object_data
&4c21: a5 dc            LDA &dc ; timer_4
&4c23: c5 11            CMP &11 ; this_object_extra
&4c25: 90 53            BCC &4c7a
&4c27: 0a               ASL
&4c28: 85 37            STA &37 ; this_object_angle
&4c2a: 0a               ASL
&4c2b: 85 39            STA &39 ; this_object_flags_lefted
&4c2d: 98               TYA
&4c2e: 30 04            BMI &4c34
&4c30: aa               TAX
&4c31: fe e6 08         INC &08e6,X ; object_stack_vel_x
&4c34: a0 ff            LDY #&ff
&4c36: 84 87            STY &87 ; particle_x_low
&4c38: a5 db            LDA &db ; timer_3
&4c3a: 85 89            STA &89 ; particle_y_low
&4c3c: a5 53            LDA &53 ; this_object_x
&4c3e: 85 8b            STA &8b ; particle_x 
&4c40: a5 55            LDA &55 ; this_object_y
&4c42: 85 8d            STA &8d ; particle_y
&4c44: c8               INY
&4c45: 84 b5            STY &b5 ; angle
&4c47: a0 37            LDY #&37                                                # &37 = thruster particles
&4c49: 20 8c 21         JSR &218c ; add_particle
&4c4c: a5 c0            LDA &c0 ; loop_counter
&4c4e: 18               CLC
&4c4f: 65 55            ADC &55 ; this_object_y
&4c51: 29 03            AND #&03
&4c53: d0 13            BNE &4c68
&4c55: 38               SEC
&4c56: 66 28            ROR &28 ; sucking_damage                                # cause damage when blowing objects away
&4c58: a9 50            LDA #&50
&4c5a: 85 35            STA &35 ; sucking_distance
&4c5c: a9 14            LDA #&14                                                # angle range
&4c5e: 20 3c 34         JSR &343c ; suck_or_blow_all_objects_limited_angle
&4c61: 20 f8 13         JSR &13f8 ; play_sound2
#4c64: 70 c2 6e a3 ; sound data
&4c68: a0 34            LDY &34 ; firing_angle
&4c6a: a5 c0            LDA &c0 ; loop_counter
&4c6c: 2a               ROL
&4c6d: 2a               ROL
&4c6e: 2a               ROL
&4c6f: 2a               ROL
&4c70: 65 c0            ADC &c0 ; loop_counter
&4c72: 29 3f            AND #&3f
&4c74: 69 90            ADC #&90
&4c76: d0 06            BNE &4c7e
; turn_thruster_off
&4c78: 85 11            STA &11 ; this_object_extra
&4c7a: a0 00            LDY #&00					        # 0 colour = off
&4c7c: a9 40            LDA #&40
&4c7e: 84 73            STY &73 ; this_object_palette			        # change colour
&4c80: 85 4f            STA &4f ; this_object_x_low
&4c82: 60               RTS

; handle_door
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4c83: 30 08            BMI &4c8d					        # is it touching anything?
&4c85: 20 c5 49         JSR &49c5 ; can_object_trigger_switch
&4c88: b0 03            BCS &4c8d
&4c8a: 38               SEC
&4c8b: 66 3b            ROR &3b ; this_object_supporting
&4c8d: 46 39            LSR &39 ; this_object_flags_lefted
&4c8f: a6 16            LDX &16 ; this_object_ty
&4c91: a4 11            LDY &11 ; this_object_extra
&4c93: 94 53            STY &53,X
&4c95: a9 ff            LDA #&ff
&4c97: 95 4f            STA &4f,X
&4c99: a5 3d            LDA &3d ; ; this_object_data_pointer
&4c9b: 8d 99 35         STA &3599 ; door_data_pointer_store
&4c9e: 20 c5 0b         JSR &0bc5 ; has_object_been_hit_by_rcd_beam
&4ca1: b0 05            BCS &4ca8                                               # has it been hit by the rcd beam?
&4ca3: a9 40            LDA #&40
&4ca5: 20 ac 31         JSR &31ac ; toggle_door_locked_state                    # if so, toggle its lock
&4ca8: 6e 99 35         ROR &3599 ; door_data_pointer_store
&4cab: a5 bc            LDA &bc ; this_object_data
&4cad: 09 04            ORA #&04
&4caf: 48               PHA
&4cb0: 4a               LSR
&4cb1: 6a               ROR
&4cb2: 6a               ROR
&4cb3: 85 9f            STA &9f
&4cb5: 4a               LSR
&4cb6: 29 07            AND #&07
&4cb8: 85 9e            STA &9e
&4cba: 29 03            AND #&03
&4cbc: aa               TAX
&4cbd: 08               PHP
&4cbe: a5 15            LDA &15 ; this_object_energy
&4cc0: dd 76 4d         CMP &4d76,X ; unknown_doors_lookup
&4cc3: a9 ff            LDA #&ff
&4cc5: b0 0e            BCS &4cd5
&4cc7: 28               PLP
&4cc8: 08               PHP
&4cc9: a9 00            LDA #&00
&4ccb: b0 08            BCS &4cd5
&4ccd: 28               PLP
&4cce: 68               PLA
&4ccf: 09 08            ORA #&08
&4cd1: 48               PHA
&4cd2: 08               PHP
&4cd3: b0 02            BCS &4cd7
&4cd5: 85 15            STA &15 ; this_object_energy
&4cd7: bd 72 4d         LDA &4d72,X ; unknown_doors_two
&4cda: 28               PLP
&4cdb: 90 02            BCC &4cdf
&4cdd: a9 01            LDA #&01
&4cdf: 24 9f            BIT &9f
&4ce1: 30 09            BMI &4cec
&4ce3: 4a               LSR
&4ce4: 49 ff            EOR #&ff
&4ce6: 24 3b            BIT &3b ; this_object_supporting
&4ce8: 30 02            BMI &4cec
&4cea: a9 ff            LDA #&ff
&4cec: 85 9c            STA &9c
&4cee: a5 14            LDA &14 ; this_object_tx
&4cf0: 49 80            EOR #&80
&4cf2: 38               SEC
&4cf3: e5 9c            SBC &9c
&4cf5: 50 44            BVC &4d3b
&4cf7: 20 7f 32         JSR &327f ; prevent_overflow
&4cfa: a8               TAY
&4cfb: 10 0c            BPL &4d09
&4cfd: 8a               TXA
&4cfe: d0 0d            BNE &4d0d
&4d00: ad 19 08         LDA &0819 ; door_timer
&4d03: c9 14            CMP #&14
&4d05: b0 06            BCS &4d0d
&4d07: 90 19            BCC &4d22
&4d09: 68               PLA
&4d0a: 29 fb            AND #&fb
&4d0c: 48               PHA
&4d0d: 24 3b            BIT &3b ; this_object_supporting
&4d0f: 30 29            BMI &4d3a
&4d11: 24 9f            BIT &9f
&4d13: 70 25            BVS &4d3a
&4d15: 8a               TXA
&4d16: d0 0a            BNE &4d22
&4d18: ad 19 08         LDA &0819 ; door_timer
&4d1b: d0 1d            BNE &4d3a
&4d1d: a9 3c            LDA #&3c
&4d1f: 8d 19 08         STA &0819 ; door_timer
&4d22: 68               PLA
&4d23: 49 02            EOR #&02
&4d25: 48               PHA
&4d26: 29 02            AND #&02
&4d28: f0 09            BEQ &4d33
&4d2a: 20 fa 13         JSR &13fa ; play_sound
#4d2d: c7 c3 c1 13 ; sound data
&4d31: b0 07            BCS &4d3a
&4d33: 20 fa 13         JSR &13fa ; play_sound
#4d36: c7 c3 c1 03 ; sound data
&4d3a: 98               TYA
&4d3b: 49 80            EOR #&80
&4d3d: a6 16            LDX &16 ; this_object_ty
&4d3f: a8               TAY
&4d40: 38               SEC
&4d41: e5 14            SBC &14 ; this_object_tx
&4d43: c9 80            CMP #&80
&4d45: 6a               ROR
&4d46: 95 43            STA &43,X
&4d48: 98               TYA
&4d49: 85 14            STA &14 ; this_object_tx
&4d4b: 18               CLC
&4d4c: 69 10            ADC #&10
&4d4e: 95 4f            STA &4f,X
&4d50: a5 11            LDA &11 ; this_object_extra
&4d52: 69 00            ADC #&00
&4d54: 95 53            STA &53,X
&4d56: 68               PLA
&4d57: a4 15            LDY &15 ; this_object_energy
&4d59: d0 02            BNE &4d5d
&4d5b: 09 04            ORA #&04
&4d5d: 85 bc            STA &bc ; this_object_data
&4d5f: a6 3d            LDX &3d ; this_object_data_pointer
&4d61: 9d 86 09         STA &0986,X ; background_objects_data
&4d64: a6 9e            LDX &9e
&4d66: bd 7a 4d         LDA &4d7a,X ; door_palettes
&4d69: 24 9f            BIT &9f
&4d6b: 70 02            BVS &4d6f
&4d6d: 29 0f            AND #&0f
&4d6f: 85 73            STA &73 ; this_object_palette			        # change colour
&4d71: 60               RTS

#4d72: 20 10 08 20 ; unknown_doors_two
#4d76: 80 74 c0 80 ; unknown_doors_lookup

#4d7a: 2b 2d 15 1c 42 12 26 4e ; door_palettes

#4d82: 52 63 35 21 ; teleport_beam_palettes

; handle_teleport_beam
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4d86: 4a               LSR						        # data & &01 = teleporter inactive
&4d87: 29 0f            AND #&0f                                                # data & &1e = teleport number * 2
&4d89: aa               TAX                                                     # X = teleport number
&4d8a: a9 b0            LDA #&b0					        # &b0 = beam sitting in teleporter base
&4d8c: b0 2f            BCS &4dbd ; stationary_beam
&4d8e: 98               TYA						
&4d8f: 30 1c            BMI &4dad ; deal_with_the_beam_itself		        # is the beam touching something?
&4d91: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&4d94: 29 10            AND #&10                                                # if so, is it already teleporting?
&4d96: d0 15            BNE &4dad ; deal_with_the_beam_itself                   # if so, ignore it; otherwise
&4d98: bd 4a 31         LDA &314a,X ; teleport_destinations_x
&4d9b: 99 16 09         STA &0916,Y ; object_stack_tx		                # start teleporting the object
&4d9e: bd 5a 31         LDA &315a,X ; teleport_destinations_y
&4da1: 99 36 09         STA &0936,Y ; object_stack_ty
&4da4: 20 f0 0c         JSR &0cf0 ; mark_stack_object_as_teleporting
&4da7: 20 a9 0b         JSR &0ba9 ; set_object_velocities		        # set the object velocities to those of the beam
&4daa: 20 0d 44         JSR &440d ; play_teleport_noise
; deal_with_the_beam_itself
&4dad: a5 6f            LDA &6f ; this_object_flags
&4daf: 29 04            AND #&04                                                # is the beam active?
&4db1: d0 15            BNE &4dc8 ; no_beam_motion                              # if not, don't move it
&4db3: a5 11            LDA &11 ; this_object_extra                             # this_object_extra = beam position
&4db5: 69 20            ADC #&20
&4db7: c9 b1            CMP #&b1                                                # scan beam through teleporter
&4db9: 90 02            BCC &4dbd
&4dbb: e9 b0            SBC #&b0                                                # restarting when it gets to the bottom
; stationary_beam
&4dbd: 85 11            STA &11 ; this_object_extra			        # this_object_extra = beam position
&4dbf: 24 39            BIT &39 ; this_object_flags_lefted
&4dc1: 20 4c 32         JSR &324c ; make_negative
&4dc4: 85 51            STA &51 ; this_object_y_low
&4dc6: c6 51            DEC &51 ; this_object_y_low
; no_beam_motion
&4dc8: 20 c5 0b         JSR &0bc5 ; has_object_been_hit_by_rcd_beam             # has the beam been hit by the rcd beam?
&4dcb: b0 05            BCS &4dd2 ; rotate_colour_6                             
&4dcd: a9 00            LDA #&00
&4dcf: 20 ac 31         JSR &31ac ; toggle_door_locked_state                    # if so, toggle its state
; rotate_colour_6
&4dd2: a5 06            LDA &06 ; current_object_rotator
; rotate_colour
&4dd4: 4a               LSR
&4dd5: 4a               LSR
&4dd6: 29 03            AND #&03
&4dd8: aa               TAX
&4dd9: bd 82 4d         LDA &4d82,X ; teleport_beam_palettes
&4ddc: 85 73            STA &73 ; this_object_palette		                # change colour
&4dde: 60               RTS

; flash_palette
&4ddf: a4 41            LDY &41 ; this_object_type
&4de1: b9 ef 02         LDA &02ef,Y ; object_palette_lookup
&4de4: 29 7f            AND #&7f                                                # use the object's default palette
&4de6: b0 02            BCS &4dea
&4de8: 49 30            EOR #&30                                                # eor &30 if carry is set
&4dea: 85 73            STA &73 ; this_object_palette
&4dec: 60               RTS

; handle_sucker_deadly
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
; X = this_object_data
; A = this_object_data
; Y = this_object_supporting ?
&4ded: bd 49 4e         LDA &4e49,X ; sucker_palettes			        # X = this_object_data
&4df0: 4a               LSR
&4df1: 85 73            STA &73 ; this_object_palette                           # set colour of sucker
&4df3: a5 07            LDA &07 ; current_object_rotator_low
&4df5: f0 14            BEQ &4e0b
&4df7: bd 37 4e         LDA &4e37,X ; sucker_attracted_lookup                   # what does the sucker like to suck?
&4dfa: 30 0d            BMI &4e09 ; no_attraction                               # if nothing, skip
&4dfc: a8               TAY
&4dfd: c9 55            CMP #&55                                                # &55 = coronium boulder
&4dff: d0 02            BNE &4e03                                               # if so, then also suck
&4e01: a0 0b            LDY #&0b                                                # &0b = yellow ball
&4e03: 20 2a 3c         JSR &3c2a ; find_nearest_object
&4e06: 8a               TXA                                                     # X = object number of nearest object
&4e07: 49 ff            EOR #&ff
; no_attraction
&4e09: 85 11            STA &11 ; this_object_extra                             # this_object_extra = attracted object
&4e0b: a5 11            LDA &11 ; this_object_extra
&4e0d: 10 18            BPL &4e27 ; no_attraction_2                             # if no attracted object, skip
&4e0f: a6 bc            LDX &bc ; this_object_data
&4e11: bd 49 4e         LDA &4e49,X ; sucker_palettes
&4e14: 4a               LSR
&4e15: 66 29            ROR &29 ; sucking_angle_modifier
&4e17: bd 40 4e         LDA &4e40,X ; sucker_sucking_distances
&4e1a: 85 35            STA &35 ; sucking_distance
&4e1c: 20 3a 34         JSR &343a ; suck_or_blow_all_objects                    # suck/blow objects towards/away from us
&4e1f: a5 db            LDA &db ; timer_3
&4e21: 85 37            STA &37 ; this_object_angle
&4e23: c9 50            CMP #&50
&4e25: f0 02            BEQ &4e29
; no_attraction_2
&4e27: a9 02            LDA #&02
&4e29: a4 3b            LDY &3b ; this_object_supporting                        # are we supporting anything?
&4e2b: 30 b1            BMI &4dde                                               # if not, leave
&4e2d: 20 fa 13         JSR &13fa ; play_sound                          
#4e30: 57 07 57 95 ; sound data
&4e34: 4c a6 24         JMP &24a6 ; take_damage                                 # if so, damage it! (damage = 2)
#4e37: ff 3e 11 55 10 ff 55 10 0f ; sucker_attracted_lookup ; &3e = door, &10 = pirahna, &55 = coronium, &11 = wasp, &0f = worm, &ff = nothing
#4e40: 50 30 7f 40 50 7f 7f 50 40 ; sucker_sucking_distances
#4e49: 5f ac bf 3d f9 58 a2 d8 4b ; sucker_palettes

; handle_maggot
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4e52: a5 15            LDA &15 ; this_object_energy
&4e54: 29 7f            AND #&7f
&4e56: 85 15            STA &15 ; this_object_energy
&4e58: a9 82            LDA #&82                                                # &82 = crew member + player
&4e5a: a0 2f            LDY #&2f                                                # &2f = white/yellow bird
&4e5c: a2 14            LDX #&14                                                # maggot damage = &14
; from_handle_worm
&4e5e: 8e 86 4e         STX &4e86                                               # self modifying code
&4e61: 20 f8 3b         JSR &3bf8 ; find_target_occasionally
&4e64: 20 26 3d         JSR &3d26 ; target_processing
&4e67: 20 02 2a         JSR &2a02 ; move_npc
&4e6a: 30 57            BMI &4ec3 ; maggot_moved
&4e6c: 20 87 25         JSR &2587 ; increment_timers
&4e6f: 24 1f            BIT &1f ; underwater
&4e71: 30 02            BMI &4e75
&4e73: a9 ff            LDA #&ff
&4e75: 06 11            ASL &11 ; this_object_extra
&4e77: c9 f6            CMP #&f6
&4e79: 66 11            ROR &11 ; this_object_extra
&4e7b: a4 3b            LDY &3b ; this_object_supporting
&4e7d: c4 0e            CPY &0e ; this_object_target_object                     # is it touching its target?
&4e7f: d0 09            BNE &4e8a
&4e81: a9 0a            LDA #&0a
&4e83: 85 12            STA &12 ; this_object_timer
&4e85: a9 14            LDA #&14        # modified by &4e5e; actually LDA #X    # only maggots cause damage
&4e87: 20 a6 24         JSR &24a6 ; take_damage
&4e8a: a6 20            LDX &20 ; this_object_water_level
&4e8c: ca               DEX
&4e8d: 30 05            BMI &4e94                                               # is it underwater?
&4e8f: a6 c3            LDX &c3 ; loop_counter_every_10
&4e91: 8e e5 29         STX &29e5 ; object_collision_with_other_object_top_bottom 
&4e94: a9 10            LDA #&10
&4e96: 24 3e            BIT &3e ; this_object_target
&4e98: 10 1e            BPL &4eb8                                               # target &80 = &00 ?
&4e9a: 0a               ASL
&4e9b: 48               PHA
&4e9c: 20 59 35         JSR &3559 ; get_object_distance_from_screen_centre
&4e9f: c9 0f            CMP #&0f                                                # is it close to the screen?
&4ea1: b0 14            BCS &4eb7
&4ea3: 49 0f            EOR #&0f                                                # the nearer it is, the noisier it is
&4ea5: c5 db            CMP &db ; timer_3
&4ea7: 90 0e            BCC &4eb7
&4ea9: 20 fa 13         JSR &13fa ; play_sound                                  # make a noise
#4eac: 33 f3 09 b4 ; sound data
&4eb0: 20 fa 13         JSR &13fa ; play_sound
#4eb3: 33 f3 07 b5 ; sound data
&4eb7: 68		PLA
&4eb8: a2 06            LDX #&06				                # type ; A = speed
&4eba: 20 df 3a         JSR &3adf ; something_motion_related
&4ebd: b0 04            BCS &4ec3
&4ebf: a9 06            LDA #&06
&4ec1: 85 12            STA &12 ; this_object_timer
; maggot_moved
&4ec3: 20 78 25         JSR &2578 ; flip_object_in_direction_of_travel_on_random_3
&4ec6: a5 45            LDA &45 ; this_object_vel_y
&4ec8: e9 04            SBC #&04
&4eca: 85 39            STA &39 ; this_object_flags_lefted
&4ecc: a5 06            LDA &06 ; current_object_rotator
&4ece: 29 04            AND #&04
&4ed0: 4a               LSR
&4ed1: 05 12            ORA &12 ; this_object_timer
&4ed3: 85 12            STA &12 ; this_object_timer
&4ed5: 4c dc 44         JMP &44dc

; handle_turret
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4ed8: 4a               LSR                                                     # if lowest bit of this_object_data set,
&4ed9: b0 35            BCS &4f10 ; no_firing                                   # the turret is switched off; don't fire
&4edb: aa               TAX                                                     # this_object_data / 2 = bullet type
&4edc: d0 1b            BNE &4ef9 ; turret_firing                               # which is presumably non-zero, so turret is stationary
; handle_robot
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4ede: 24 15            BIT &15 ; this_object_energy                            # consider the object's energy
&4ee0: 10 2e            BPL &4f10 ; no_firing                                   # don't move or fire if energy is low
; handle_robot_blue                                                             # unless the robot is the blue one
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4ee2: a2 05            LDX #&05
&4ee4: 20 c9 27         JSR &27c9 ; npc_targetting
&4ee7: 20 26 3d         JSR &3d26 ; target_processing
&4eea: a2 04            LDX #&04				                # type
&4eec: a9 18            LDA #&18				                # speed
&4eee: 20 df 3a         JSR &3adf ; something_motion_related
&4ef1: 20 78 25         JSR &2578 ; flip_object_in_direction_of_travel_on_random_3
&4ef4: a4 41            LDY &41 ; this_object_type
&4ef6: be 02 4f         LDX &4f02,Y ; robot_bullet_lookup       # actually &4f1e
; turret_firing
&4ef9: 24 15            BIT &15 ; this_object_energy                            # consider the object's energy
&4efb: 10 13            BPL &4f10                                               # don't fire if energy is low
&4efd: a0 84            LDY #&84
&4eff: a5 55            LDA &55 ; this_object_y
&4f01: c9 b4            CMP #&b4                                                # is y > &b4 ?
&4f03: b0 06            BCS &4f0b
&4f05: 24 db            BIT &db ; timer_3
&4f07: 70 02            BVS &4f0b
&4f09: a0 86            LDY #&86                                                # &86 = range 6 (flying enemies)
&4f0b: a9 81            LDA #&81                                                # &81 = active chatter + player
&4f0d: 20 68 27         JSR &2768 ; find_a_target_and_fire_at_it                # find a target and fire at it
; no_firing
&4f10: a6 41            LDX &41 ; this_object_type
&4f12: bc fc 4e         LDY &4efc,X ; robot_energy_lookup       # actually &4f18 # minimum energy
&4f15: 4c 3a 35         JMP &353a ; gain_energy_or_flash_if_damaged
#4f18: 14 46 46 14 7f 14 ; robot_energy_lookup
;      1c 1d 1e ; magenta robot, red robot, blue robot
#4f1e: 18 13 14 ; robot_bullet_lookup   # &18 = pistol bullet, &13 = icer bullet, &14 = tracer bullet

; handle_nest_dweller
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4f21: a9 05            LDA #&05
&4f23: a4 41            LDY &41 ; this_object_type
&4f25: c0 11            CPY #&11 				                # &11 = wasp
&4f27: 66 39            ROR &39 ; this_object_flags_lefted                      # note whether it's a wasp for later
&4f29: 30 06            BMI &4f31
&4f2b: a9 04            LDA #&04
&4f2d: 85 42            STA &42 ; acceleration_y                                # acceleration for pirahna
&4f2f: a9 04            LDA #&04
&4f31: c6 42            DEC &42 ; acceleration_y                                # wasp float somewhat
&4f33: 24 db            BIT &db ; timer_3                                       # sometimes find targets, sometimes not
&4f35: 70 0b            BVS &4f42
&4f37: a6 11            LDX &11 ; this_object_extra
&4f39: e4 da            CPX &da ; timer_2                                       # sometimes target the player, sometimes not
&4f3b: b0 02            BCS &4f3f
&4f3d: a9 00            LDA #&00                                                # &00 = player
&4f3f: 20 f8 3b         JSR &3bf8 ; find_target_occasionally                    # Y = object_type, so other nest dwellers
&4f42: 20 26 3d         JSR &3d26 ; target_processing
&4f45: 20 87 25         JSR &2587 ; increment_timers
&4f48: f0 0d            BEQ &4f57
&4f4a: c5 11            CMP &11 ; this_object_extra
&4f4c: 90 10            BCC &4f5e
&4f4e: a4 3b            LDY &3b ; this_object_supporting                        # are we supporting something?
&4f50: d0 0c            BNE &4f5e                                               # if so, is it the player?
&4f52: a9 18            LDA #&18
&4f54: 20 a6 24         JSR &24a6 ; take_damage                                 # wasp / pirahna damage = &18
&4f57: 20 fa 13         JSR &13fa ; play_sound
#4f5a: 33 f3 4f 35 ; sound data
&4f5e: a9 0c            LDA #&0c                                                # modulus
&4f60: 20 55 25         JSR &2555 ; get_sprite_from_velocity                    # use velocity
&4f63: 4a               LSR                                                     # to calculate sprite for wasp / pirahna
&4f64: 4a               LSR                                                     # (&00 - &02)
&4f65: 20 92 32         JSR &3292 ; change_sprite                               # set the sprite based on result
&4f68: 20 7e 25         JSR &257e ; flip_object_in_direction_of_travel
&4f6b: 24 1b            BIT &1b ; wall_collision_top_or_bottom                  # has it collided with a wall?
&4f6d: 30 06            BMI &4f75                                               # if so, keep it moving regardless
&4f6f: a5 39            LDA &39 ; this_object_flags_lefted
&4f71: 45 1f            EOR &1f ; underwater                                    # is the creature out of its element?
&4f73: 30 26            BMI &4f9b                                               # if so, it doesn't move
&4f75: a9 30            LDA #&30                                                # velocity magnitude = &30
&4f77: a0 18            LDY #&18                                                # maximum speed = &18
&4f79: a2 28            LDX #&28                                                # probability = &28
&4f7b: 20 da 31         JSR &31da ; move_towards_target_with_probability_x      # move towards target
&4f7e: 24 c4            BIT &c4 ; loop_counter_every_08                         
&4f80: 10 19            BPL &4f9b                                               # every 8 cycles,
&4f82: 20 87 25         JSR &2587 ; increment_timers
&4f85: 29 02            AND #&02                                                # pick a direction at random, x or y
&4f87: aa               TAX                                             
&4f88: a5 db            LDA &db ; timer_3
&4f8a: 29 1f            AND #&1f                                                # pick a acceleration at random
&4f8c: e9 10            SBC #&10                                                # from -16 to +15
&4f8e: 75 40            ADC (&40,X)     # X = 2, &42 acceleration_y ; X = 0, &40 acceleration_x
&4f90: 95 40            STA &40,X       # X = 2, &42 acceleration_y ; X = 0, &40 acceleration_x
&4f92: a5 15            LDA &15 ; this_object_energy
&4f94: c9 0a            CMP #&0a						# increase energy if < 10
&4f96: b0 03            BCS &4f9b
&4f98: 4c 4e 25         JMP &254e ; gain_one_energy_point_if_not_immortal
&4f9b: 60               RTS

; handle_explosion
# called with:
# X = this_object_data
# A = this_object_data
# Y = this_object_supporting ; CPY #&00
&4f9c: a9 80            LDA #&80                                                # &80 = call background object handlers
&4f9e: 85 2d            STA &2d ; background_processing_flag
&4fa0: a6 53            LDX &53 ; this_object_x                                 # loop over
&4fa2: ca               DEX                                                     # this_object_x - 1 to this_object_x + 1
&4fa3: 86 95            STX &95 ; square_x
; explosion_loop_x
&4fa5: a6 55            LDX &55 ; this_object_y                                 # loop over
&4fa7: ca               DEX                                                     # this_object_y - 1 to this_object_y + 1
&4fa8: 86 97            STX &97 ; square_y
; explosion_loop_y
&4faa: 20 15 17         JSR &1715 ; determine_background                        # call for each square
&4fad: a6 55            LDX &55 ; this_object_y
&4faf: e4 97            CPX &97 ; square_y
&4fb1: e6 97            INC &97 ; square_y
&4fb3: b0 f5            BCS &4faa ; explosion_loop_y
&4fb5: a6 53            LDX &53 ; this_object_x
&4fb7: e4 95            CPX &95 ; square_x
&4fb9: e6 95            INC &95 ; square_x
&4fbb: b0 e8            BCS &4fa5 ; explosion_loop_x
&4fbd: a5 da            LDA &da ; timer_2
&4fbf: 29 13            AND #&13
&4fc1: 85 73            STA &73 ; this_object_palette
&4fc3: a9 0a            LDA #&0a                                                # &0a particles
&4fc5: a0 16            LDY #&16                                                # &16 = explosion particles
&4fc7: 20 8e 21         JSR &218e ; add_particles
&4fca: a5 3d            LDA &3d ; this_object_data_pointer                      # data_pointer is used as a timer
&4fcc: f0 17            BEQ &4fe5 ; explosion_remove_object                     # when it runs out, remove the explosion
&4fce: c6 3d            DEC &3d ; this_object_data_pointer                      
&4fd0: a5 dc            LDA &dc ; timer_4
&4fd2: 29 07            AND #&07
&4fd4: c5 3d            CMP &3d ; this_object_data_pointer                      # towards the end of the explosion,
&4fd6: b0 c3            BCS &4f9b                                               # a random chance of not blowing objects away
&4fd8: a5 3d            LDA &3d ; this_object_data_pointer
&4fda: c9 08            CMP #&08
&4fdc: 66 28            ROR &28 ; sucking_damage                                # cause damage for first 8 cycles
&4fde: 0a               ASL
&4fdf: 0a               ASL
&4fe0: 85 35            STA &35 ; sucking_distance
&4fe2: 4c 3a 34         JMP &343a ; suck_or_blow_all_objects
; explosion_remove_object
&4fe5: 4c 29 25         JMP &2529; mark_this_object_for_removal

#4fe8: f3 97 52 4a ; (unused?)

; map_data
#4fec: 95 b6 19 ef 6f 6e 70 5e d4 a9 a9 57 6d 06 6e ed
#4ffc: 2d 6e 6e 06 ca 70 ad 07 5e 5e 53 62 53 9b 35 9e
#500c: 15 16 e9 22 57 97 0c cc 8c 78 3f bd 05 ed e2 0a
#501c: f0 05 2d 6e d3 07 e4 24 63 a1 a5 64 53 07 a4 63
#502c: 66 7e 3e dc 8c 72 e8 bc 06 19 22 6d de d3 19 71
#503c: f1 7e 29 f4 39 a9 d3 06 53 a1 e4 07 d4 a9 d3 1a
#504c: c1 77 d7 41 6f a1 6d 53 f5 d3 21 19 a1 53 06 e5
#505c: ee 19 97 d3 13 ea 75 02 d3 9b 53 ea 5f 85 72 21
#506c: 6e 2c 2d 07 ad ed b1 25 19 2f 53 3b 9e e2 d3 62
#507c: 02 f0 2d 06 a4 d3 19 21 53 21 ed 30 d3 6a 59 a4
#508c: 6d 70 6f 04 a4 64 a2 a2 1e 04 d3 01 4a 3b 64 63
#509c: f0 2d 17 ed f4 2f 12 30 d3 21 fa a2 a1 e2 8d 2e
#50ac: 64 6e 02 ee 04 05 13 ee 4a 6a 2d 05 9b 2d 25 65
#50bc: ed fe 31 6f f0 14 ee bf df 8d d3 6a de 53 8b 1e
#50cc: ee ad 70 7a 24 a1 22 6d 22 d3 21 93 df 01 02 dc
#50dc: ae 7c 06 af df b2 07 29 03 5e cd ea 53 cd 07 8f
#50ec: fc 94 66 69 30 07 62 35 d6 9d bf 2f 9d 62 62 1f
#50fc: 53 21 d3 43 fe 45 93 74 9e f0 91 ae a1 62 02 07
#510c: 6a cc d9 3d e2 ed ed b0 b4 15 e6 19 57 17 9d 4c
#511c: ed a2 93 65 03 21 9e 05 b4 b0 06 ee 5e a1 5e 25
#512c: 49 f9 07 7c de de ea 07 67 04 bd 68 53 cc 26 a8
#513c: 7a 21 de e2 9e 06 53 a1 1e e2 04 e8 9e 04 64 06
#514c: b9 06 da 13 e3 4a 21 f8 05 c2 32 97 07 62 ed 70
#515c: ef ea d3 6a e4 19 c6 f3 03 19 a8 1e 28 9e f5 29
#516c: 07 04 70 21 1e 1e 06 fa ee 2c 2d f0 13 53 bb f0
#517c: 56 21 ed a1 aa c0 c4 53 62 ef 2f f0 70 5e a1 19
#518c: 6f de 1e a1 24 02 5f 62 6d 06 71 8d 13 71 b0 af
#519c: 56 ea de a5 21 e5 4b 8d 03 2f 29 2d 57 38 6e 07
#51ac: d3 19 2a e3 b5 6e 49 e5 70 62 b0 12 53 d3 22 6d
#51bc: df 8d 53 a1 d4 df 21 1e 2d f0 22 70 6e 35 12 e2
#51cc: 9a 23 a1 61 68 05 a5 d3 04 2e 06 19 07 d3 e1 2e
#51dc: 24 9b 53 cd 07 cd ca 0f 52 ed e2 2e 05 34 78 04
#51ec: 3a 7b 04 ad 53 e1 b1 07 df 21 13 fa 7e 19 5e 7b
#51fc: 05 96 3f bd 54 dd 19 b1 32 bc 69 2b 21 6f ee 19
#520c: b8 b2 2d 2d 64 20 53 03 53 a1 3e fe d3 07 53 fb
#521c: a8 b7 29 2b e8 bc 68 dd 19 39 a2 b1 f0 53 1e ad
#522c: 70 3b 03 d6 53 1e 7a a5 07 1b 53 de 1e 9e d3 21
#523c: d6 19 68 fd 02 6a 34 66 b0 9e 04 ef 04 de ed f1
#524c: ed 18 a4 69 17 53 53 e2 ed 30 de ea 9e 19 19 47
#525c: ef 06 8c 72 ef 19 2f f0 ed b9 99 b1 de 23 a3 78
#526c: a2 2f 30 ef 04 b5 e4 a1 d3 19 7a a1 cd da 1b d3
#527c: 6d 06 ed 71 b1 6e 04 6d ee af 4a d1 5e 1e 53 7c
#528c: ef 18 f0 2d 02 b8 7f 62 7c 8d 12 de c6 e4 8b ae
#529c: 0d ed ad 8d e2 df b1 6e e4 04 64 07 25 f0 e4 19
#52ac: 2e ef 19 b0 4f 32 75 07 e4 8d 5f 21 d4 cd cb 53
#52bc: 8f ae af ed 4a 21 a1 79 23 ea 07 13 54 f5 62 24
#52cc: 6f 4a ee 11 13 93 1e a9 25 5f a1 7a 24 a5 5e 0f
#52dc: a4 1e ee 19 a0 53 e1 a1 93 93 d3 e1 32 97 93 53
#52ec: d3 19 21 1e f9 19 a5 03 6b 21 ae 12 7c 6a fa 2d
#52fc: 38 72 bf b0 21 ef 11 b5 56 36 02 3d 68 01 8c 30
#530c: d3 21 64 7e 64 a1 7c 21 54 fe f2 6e e4 29 5f 04
#531c: 19 19 2a af 2d e2 6a 6f a7 69 f7 e9 32 a8 fc 28
#532c: fa 07 d3 6a 64 32 53 05 4a 62 04 56 d3 6a 54 a4
#533c: 6d 53 e2 ed 69 14 1e ef 37 00 40 28 d3 05 2d 74
#534c: ed 05 ef 5e 53 e3 19 a5 30 05 17 a1 a8 5f 21 05
#535c: 22 ed e2 b1 62 02 64 65 6d 2c 12 cc 6d e2 04 d3
#536c: 53 a1 19 ab a2 cd 8b 13 01 af 21 ed 51 94 f5 29
#537c: 39 2e f0 1a 5e 02 1e 7a ad ed 39 70 b1 ee 03 b4
#538c: d6 8d 53 21 c2 de 8b 2d ed 19 2f 2f 01 af ff 3f
#539c: 53 00 ed 25 06 ef 24 e2 2d ed ed de 5e 7b 31 07
#53ac: 13 cd d3 1b d4 cd 07 06 a2 6f a2 31 f0 06 f8 62
#53bc: a1 53 aa 00 64 05 00 25 0f 6d 53 ed d3 19 13 93
#53cc: 22 d3 22 e1 05 64 65 2d 70 19 62 06 22 63 63 bb
#53dc: 64 63 53 04 22 72 63 7e 64 63 64 05 22 65 5b a1

###############################################################################
#
#   Sprites
#   =======
#   &00 spaceman, flying horizontally
#   &01 spaceman, reclined forwards
#   &02 spaceman, upright, jumping
#   &03 spaceman, reclined backwards
#   &04 spaceman, upright, stationary
#   &05 spaceman, upright, walking
#   &06 spaceman, upright, walking
#   &07 spaceman, upright, walking
#   &08 bullet
#   &09 bullet
#   &0a bullet
#   &0b bullet
#   &0c bullet
#   &0d bullet
#   &0e grass frond
#   &0f red drop
#   &10 frogman
#   &11 frogman
#   &12 frogman
#   &13 robot
#   &14 chatter
#   &15 hovering robot
#   &16 clawed robot
#   &17 fireball
#   &18 grass tuft
#   &19 half bush
#   &1a bush
#   &1b full nest
#   &1c half nest / slime
#   &1d half nest / slime
#   &1e small round nest / slime
#   &1f small nest / slime
#   &20 rock
#   &21 plasma ball
#   &22 coronium crystal
#   &23 spaceship support
#   &24 spaceship corner with pipes
#   &25 spaceship tiny corner
#   &26 spaceship wall left quarter
#   &27 spaceship wall \ from top left to top 3/4 right
#   &28 spaceship wall \ from top 3/4 left to middle right
#   &29 spaceship wall \ from middle left to 1/4 right
#   &2a spaceship wall \ from 1/4 right to bottom left
#   &2b spaceship corner
#   &2c spaceship wall bottom half
#   &2d switch box
#   &2e switch
#   &2f pipe corner, bottom left
#   &30 pipe left side, with top corner
#   &31 pipe bottom side, with right corner
#   &32 spaceship wall bottom half with pipework and pipe
#   &33 spaceship corner with pipes
#   &34 brick wall \ from top left to middle right
#   &35 brick wall \ from middle left to bottom right
#   &36 stone wall \ from top left to middle right
#   &37 stone wall \ from middle left to bottom right
#   &38 stone wall \, filled bottom left
#   &39 brick wall, full
#   &3a brick wall, bottom three quarters
#   &3b brick wall, bottom half
#   &3c brick wall, bottom quarter
#   &3d stone wall, full
#   &3e stone wall, bottom half with edging
#   &3f very thin edge, bottom
#   &40 stone wall, bottom half with edging
#   &41 brick wall, left quarter
#   &42 brick wall, left quarter, steep slope
#   &43 brick wall, \, filled bottom left
#   &44 brick wall, \, filled bottom left 3/4s
#   &45 gargoyle
#   &46 brick wall, bottom quarter
#   &47 spaceship wall with pipework
#   &48 spaceship wall, bottom half
#   &49 spaceship wall, bottom quarter
#   &4a horizontal door
#   &4b vertical door
#   &4c hydraulic leg
#   &4d key 
#   &4e teleporter
#   &4f wasp
#   &50 wasp
#   &51 wasp
#   &52 maggot
#   &53 maggot
#   &54 maggot
#   &55 pillar
#   &56 cannon
#   &57 mysterious weapon
#   &58 rcd
#   &59 bird
#   &5a bird 
#   &5b bird
#   &5c bird
#   &5d chest
#   &5e turret
#   &5f flagpole
#   &60 destinator
#   &61 big fish
#   &62 mushrooms
#   &63 mushroom ball
#   &64 imp
#   &65 imp
#   &66 imp
#   &67 imp
#   &68 imp
#   &69 imp
#   &6a large pipe top
#   &6b jetpack booster
#   &6c plasma gun
#   &6d quarter lightning
#   &6e half lightning
#   &6f lightning
#   &70 sucker
#   &71 teleporter beam
#   &72 pirahna
#   &73 pirahna
#   &74 pirahna
#   &75 fluffy
#   &76 flask
#   &77 (nothing)
#   &78 hoverball
#   &79 pill
#   &7a fire immunity device
#   &7b energy capsule
#   &7c whistle
#
#   Sprite data is 128 x 128, 20 bytes per row.
#
###############################################################################

; sprite_data
#53ec: c0 00 00 00 32 11 80 10 00 00 00 20 06 08 00 00 01 8c 00 66 80 00 00 00 01 02 08 64 90 80 00 66 
#540c: 8c 00 00 00 56 a3 c0 ca 00 00 00 07 2d 66 00 00 00 00 00 60 c0 00 00 00 01 0b 88 42 f0 3e 64 4c 
#542c: 3c 00 00 00 03 01 19 68 00 00 13 21 2d 00 00 00 0b 8d 00 40 68 00 00 00 02 ab 00 cb f8 18 90 4c 
#544c: df 00 00 00 46 23 00 1c 00 00 37 07 06 00 00 00 ca 35 04 42 fc 80 00 00 13 19 0a e8 74 99 83 1e 
#546c: 3c c0 00 00 46 23 00 0a 00 00 1f 21 00 00 00 00 cb bd c5 63 4f c0 00 00 15 9f 0b e2 33 00 87 78 
#548c: ff 0c 00 00 07 83 59 0e 00 01 3f 07 00 00 03 0f 4b ad f5 7b 6f e0 00 00 47 ff 26 c0 65 01 96 c0 
#54ac: c7 f4 00 00 04 02 11 08 00 03 1f 07 00 00 0f 0f 4a 25 b5 db ff ac 00 00 4f ff 4e 80 61 0b 1e 00 
#54cc: ff ef 00 00 06 13 11 5c 00 21 3f 21 00 01 0f 0f 4b ad a5 4b 7a 9e 80 00 37 fb ce 80 f8 01 96 e0 
#54ec: 79 79 c0 00 06 13 11 1e 00 07 1f 21 00 03 1f 2f 4b ad 85 43 6f 7c c0 00 13 f9 8c 40 e0 00 87 3c 
#550c: 2f 3d cc 00 26 03 00 8c 00 21 3f 07 00 03 0e 0d 4a 25 04 42 df 4f ca 00 13 f0 8c 10 80 11 87 1e 
#552c: ff ff 3c 00 04 03 28 24 00 07 3f 07 00 07 0f 0f 0b 8d 00 40 bd ef 9e 00 0d f0 8f 00 0c 10 80 84 
#554c: 96 c7 f7 00 04 06 68 30 00 21 1f 21 00 06 0b 0d 00 00 00 40 9f 3e 5e 80 15 f1 ae 00 cc 32 32 00 
#556c: ff ff de 80 40 40 40 10 00 07 3f 21 00 11 44 22 03 0e 00 42 ff a7 fc 84 37 eb cc 01 0e 00 12 08 
#558c: b6 1e 8f 68 60 60 00 03 00 21 3f 07 01 0f 0f 0f 0e 0b 08 41 a7 bf 9f 68 6f ef 0f 11 ca 00 25 0c 
#55ac: ff ff ff 8e 00 00 00 ca 00 07 1f 07 01 0f 0f 0f 88 88 88 62 6f 9f 3f f8 07 bf 0d 03 2d 00 48 44 
#55cc: 69 c7 78 be 00 11 91 06 00 21 3f 07 00 80 00 90 00 12 c0 71 cf ff ef fe 11 9b 88 33 ed 00 4b 0e 
#55ec: 6d 6f 3d 8f 00 23 c0 0c 00 21 3f 21 30 e8 30 b9 0c 25 e0 50 6f 8f d6 af 01 8a 08 07 0f 08 00 00 
#560c: ff ff ff ff 00 01 19 1a 11 07 1f 21 73 fc 73 bb ce 25 c0 66 ed af cf cb 00 0b 8c ff 8f 1d ff ff 
#562c: 3c 9e c7 3c 00 23 11 2a 13 07 3f 07 74 f2 74 b0 ce 00 31 06 cf ff 9f df 01 09 00 07 0f 08 dc e0 
#564c: ff ff ff ff 00 03 59 08 04 21 3f 07 64 b2 64 90 ed ff e2 ff 7f bf df 7f 22 00 88 33 6f 11 dd ff 
#566c: e3 3d 0f e3 00 01 11 4c 17 21 1f 07 64 32 32 07 ed ff 80 06 7b 3e 7f 1f 74 11 c0 03 07 00 dc e0 
#568c: ff ff ff ff 00 02 11 7e 0c 07 3f 07 64 77 b0 27 eb ff ee ff 2f e7 3f bf 40 10 00 11 46 11 dd ff 
#56ac: 3c 8f 79 2d 00 07 00 3c 97 07 3f 21 64 72 80 05 eb 00 33 06 7f 3f 7e ef 60 10 80 01 0e 00 cc 00 
#56cc: ff ff ff ff 00 27 00 0c 0c 21 1f 21 fe 00 20 07 e7 25 c0 66 df ff cf 4f 70 10 c0 00 cc 00 11 cc 
#56ec: cb 6b d6 c7 08 0d 00 40 97 21 1f 07 f4 20 20 27 6f 25 e0 05 9e cf c7 6d dc 33 40 11 00 00 d1 88 
#570c: 87 e7 1e de 18 81 00 60 0c 07 3f 07 00 32 64 05 69 00 00 05 8f 4f 5f ef 8e 23 08 c1 60 00 00 00 
#572c: ff ff ff ff 98 10 00 00 0c 07 3f 07 64 32 32 06 6f 88 40 20 df fe ff b7 0d 03 04 61 c0 8e 30 80 
#574c: a7 1e c7 4b 90 10 80 00 97 07 1f 07 64 77 b0 00 6f 08 90 22 f7 3f ef 3f 8c 23 04 01 11 4a 07 0c 
#576c: ff ff ff ff 88 22 00 00 1f 21 1f 21 64 72 80 20 6f 98 b0 64 5f b7 2f ef 8f ab 08 11 11 ed f0 f7 
#578c: 9e c7 79 1e 08 74 00 88 0c 21 3f 21 e0 00 30 e2 6f 78 70 bc 5f af 7b 8f 8b ab 2e 9f 01 bd 00 00 
#57ac: ff ff ff ff 88 40 11 c0 84 07 3f 07 e8 20 73 ee 6f 7c a0 06 cf ff 6f ed cc 22 3f 99 99 2f 73 ee 
#57cc: 7b 5a 8f c7 80 60 10 00 1f 07 1f 07 c0 3a 30 e0 6f 3c 04 9c 8f 7d cf f7 37 11 11 ff 99 0f 30 c4 
#57ec: e3 0f 1e e7 08 70 10 80 00 11 ee 0f 01 3a 04 20 6f d8 a0 0e ff c7 ef 5f 07 09 dd 99 88 9f 00 00 
#580c: ff ff ff ff 88 dc 10 c0 00 11 ee 0f 1b 3a 06 0e 6f 1c c0 04 d7 6f 7f 4f 07 0d 0c 9f 00 ee 73 ee 
#582c: 3c 9e e3 1e 0c 8e 33 40 00 01 0e 44 0a 3a 04 0e 6f bc 80 2a 1f ff fd cf 07 0d 08 00 00 5c 30 cc 
#584c: ff ff ff ff cc 0d 23 08 00 11 ee 0b 0b 3a 02 4e 6f e8 80 9f bf bd 9f ff 0e 81 08 00 00 2c 30 c4 
#586c: 4f 79 0f e3 c0 8d 03 04 00 05 0e 0f 1b 3a 06 0a 6f 5f 48 03 ef 0f 9f 7b 0c c5 08 00 00 6e 30 cc 
#588c: ff ff ff ff 8c 8e 23 00 00 04 00 0f 0a 2a 0e 0e 6f 1f 0c 06 7b 2f ff 2f 80 c1 00 00 00 2c 00 00 
#58ac: 3d bc 79 0f 88 8f ab 2e 00 1d ee 78 09 09 4e 4e 6f ef 4e 40 1f ff eb 2f c4 10 00 00 00 5c 33 cc 
#58cc: 3c 8f 7d 3c c8 8b aa 2e 00 0d 0e 08 0c 03 0a 0a 6f 8f df 60 ff bd 3f 6f c0 10 88 00 00 00 30 cc 
#58ec: ff ff ff ff cc 44 33 00 01 08 00 0f 0e 07 0e 0e f0 f0 f0 c0 bd 1f 1f ff 00 10 80 00 00 00 30 cc 
#590c: e3 1e 8f e3 48 37 01 cc 01 5d ee 78 2f 27 4e 4e 6f ff ef ec 9f 7f df 3d 00 88 00 00 00 00 30 cc 
#592c: ff ff ff ff 88 07 01 0e 03 01 0e 08 0d 05 0a 0a 6f ff ef ec df de ff 8f 22 91 40 40 00 00 30 c4 
#594c: 0f c7 79 2d c4 03 01 0e 03 c4 01 0f 0f 07 0e 0e 6f ff ef de 7f 4f cb ef 20 54 40 41 00 00 30 cc 
#596c: ff ff ff ff ce cb 63 0e 06 00 03 f0 0a 02 0a 0a 6f ff ef de 6f 6f 8f bf 45 42 61 c3 ac 85 30 cc 
#598c: 6b 79 0f c7 4a c3 61 20 16 d5 8f 00 55 55 55 55 6f ff ef be ff a7 ff bd 61 00 a9 81 7f ce 30 cc 
#59ac: 7f ff ff ff cc 90 40 31 0e 01 0f 0f 0f 0f 0f 0f 6f ff ef be 3d bf df 9f 20 b8 01 03 88 07 30 cc 
#59cc: cf c7 b5 3c c6 10 88 30 0f 0f 0f 0f 0f 0f 0f 0f f0 f0 f0 7e 8f ef 4f ff 89 a4 99 00 cc ce 30 c4 
#59ec: f7 ff ff ce 00 10 80 00 0f 0f 0f 0f 0f 07 0e 0f 00 30 00 02 f0 f2 f3 f4 a0 90 80 00 77 cd 30 cc 
#5a0c: b5 0f e3 68 00 00 00 10 0f 0f 0f 0f 0f 07 19 1e 00 31 00 55 60 f0 70 e0 51 40 11 22 0f 0f 30 cc 
#5a2c: 79 ad 7b 0c 00 00 00 10 0c 03 00 00 0e 02 47 69 00 20 11 20 40 a0 20 40 12 39 32 31 f0 6f 30 c4 
#5a4c: ff ff 8f c0 00 00 00 30 3c c3 f0 f0 19 55 1e 83 00 02 00 e0 00 2b 04 00 22 c6 31 3e 00 f6 30 cc 
#5a6c: 2f 6b df 88 00 00 00 21 0f 0f 0f 0f 47 0f 69 4f 00 06 01 51 00 22 09 44 10 50 33 3f 06 6f 30 cc 
#5a8c: ef 6b 5a 80 00 00 00 61 00 06 00 00 0f 1e 87 0f 00 0e c0 c0 11 7f 26 44 00 28 33 33 60 0f 30 cc 
#5aac: 7f ff cf 00 00 00 00 43 f0 96 f0 f0 0f 69 0f 0e 01 0d ea 82 15 55 67 4c 10 0c 11 22 00 44 30 c4 
#5acc: 96 c7 78 00 00 00 00 43 0f 0f 0f 0f 1e 83 0f 1b 67 0b 50 c0 33 df ef ee 00 08 00 00 0f cd 30 cc 
#5aec: ff ff ca 00 00 00 00 a5 00 0c 00 03 69 4f 0e 4d 46 00 10 22 aa 9d aa aa 00 08 55 00 09 f0 30 cc 
#5b0c: 2d 3c e8 00 00 00 10 87 f0 3c f0 c3 87 0f 1b 07 4d 2e 10 80 ef 17 23 bf 65 11 60 00 69 49 30 cc 
#5b2c: ef 1e 0c 00 00 00 10 d7 0f 0f 0f 0f 0f 0e 4d 0c 8f 2e 30 44 46 0e 37 99 33 8a b0 88 69 6e 00 00 
#5b4c: 7b cf c0 00 00 00 30 7f 0f 0f 0f 0f 0f 1b 07 00 8f 00 20 00 0f 07 1b 06 55 9d 55 02 0f 08 70 ee 
#5b6c: ef 6f 88 00 00 00 30 7b 0a 0d 0a 0d 0e 4d 0c 00 ce 00 00 44 0b 06 1f 0b 66 0a fa 27 09 01 00 ac 
#5b8c: 2d 5e 80 00 00 00 21 2f 55 22 55 22 1b 07 00 00 20 00 00 22 30 01 08 11 33 8c a0 fd 09 21 91 3d 
#5bac: f3 ef 00 00 00 00 53 a7 0f 0f 0f 0f 4d 0c 00 00 e0 00 00 22 43 0b 0c 32 80 19 50 27 69 25 91 0f 
#5bcc: ef 3c 00 00 00 00 53 af 0f 0f 0f 0f 07 00 00 00 c0 00 00 01 04 82 44 20 00 04 55 02 6f 3d 80 0e 
#5bec: b4 2e 00 00 00 00 a7 ef 05 0f 0f 0a 0c 00 00 00 80 00 00 88 06 03 00 30 00 24 24 24 6f 2c 91 8c 
#5c0c: ff 68 00 00 00 10 a5 7f 84 aa 55 12 08 10 4c 00 e8 00 11 c0 07 0b 0c 30 80 24 ff 24 69 37 3a 0c 
#5c2c: 6b 4c 00 00 00 01 0f ff 84 00 00 12 08 32 2e 00 44 00 10 00 00 00 00 66 80 00 f6 24 09 33 47 07 
#5c4c: ff c0 00 00 00 10 6f 8f 85 0f 0f 1a 2e 03 2e 00 00 00 10 80 71 9a 0c 47 00 fb 64 99 09 22 47 09 
#5c6c: a5 08 00 00 00 30 7f df 87 0b 0d 1e 17 01 0c 00 00 00 10 c0 a7 12 28 06 19 fd 80 f6 0f 02 47 2e 
#5c8c: 5e 80 00 00 00 30 7b f5 83 49 29 1c 21 88 6e c1 00 00 33 40 aa 52 70 46 18 ff 88 64 0f 22 23 a6 
#5cac: 9f 00 00 00 00 53 3f 7f c9 6c 63 39 47 88 6a ac 08 00 27 00 ff 12 c0 47 00 fa 00 00 09 22 11 0c 
#5ccc: 78 00 00 00 00 c3 2f 4f 64 3f cf 62 df 03 1f ba 04 00 cf 09 af 9a d0 47 4c 66 00 00 69 22 00 0a 
#5cec: ce 00 00 00 00 d3 6f e7 33 04 02 cc 8e 02 1f 9f 82 00 8f 09 aa ce 60 45 4c 00 00 44 69 33 00 0e 
#5d0c: 68 00 00 00 00 97 7f 3f f0 0f 0f 0f 8f 04 17 99 c8 00 4f 19 ff cf 08 22 00 00 00 e8 0f 08 01 0f 
#5d2c: 8c 00 00 00 10 0f ff ff c3 87 0f 0f 8f 1d 2e 8f ec 01 4e 1d af 8d 0c 13 88 00 df 80 f0 0f 0f f0 
#5d4c: 48 00 00 00 10 7a 6d bf f0 0f 0f 0f 65 23 e6 88 ee cb 2e 2e aa ee 00 03 08 02 ff c0 00 1c 83 00 
#5d6c: 88 00 00 00 30 3f 4f af 77 ff ff ee 23 23 08 f0 f0 c3 0c 26 77 bb cc c5 1d 85 4f e0 06 1d 8b 06 
#5d8c: 80 00 00 00 61 ff df ef 70 a5 0f 0e 03 19 0c ff ff 83 00 01 00 00 00 80 0c 03 4f 28 60 1d 8b 60 
#5dac: ff ff 00 04 52 cf ff 3f 70 c3 0f 0e 47 0c 04 00 00 44 08 01 70 91 08 e3 1d 87 4f 0c 00 1c 83 00 
#5dcc: ff ff 2d 2a d3 ef cf f7 70 2d 0f 0e 47 c4 0c 31 00 61 08 00 87 59 0c 61 18 87 46 1f 0f 0f 0f 0f 
#5dec: 00 00 22 11 97 2f 6f cf 70 87 0f 0e 23 80 0c 31 00 41 00 00 0f 1d cc 40 10 06 00 17 f0 80 10 f0 

; sprite_width_lookup
#5e0c: c0 a0 50 90 40 50 60 40 21 20 20 21 11 11 50 30
#5e1c: 60 51 50 50 80 50 50 b0 b0 80 80 50 90 70 50 30
#5e2c: 40 20 10 f1 f1 71 30 f0 f0 f0 f0 f1 f0 30 60 30
#5e3c: 30 f0 f0 f1 f0 f0 f0 f0 f1 f0 f0 f0 f0 f0 f0 f0
#5e4c: f0 30 60 f0 f0 70 00 f0 f0 f0 f0 30 31 41 f0 20
#5e5c: 40 20 50 50 30 70 c0 40 40 20 60 60 40 f0 70 20
#5e6c: 70 90 c0 30 40 50 60 40 40 30 f0 20 30 31 70 b1
#5e7c: f0 70 51 41 50 51 30 80 30 30 50 50 40

; sprite_height_lookup
#5e89: 40 80 98 91 a8 a0 a0 a0 09 08 10 19 19 18 58 18
#5e99: 60 78 81 98 78 70 98 90 28 48 78 69 20 28 38 48
#5ea9: 38 20 08 f8 f8 68 f9 f9 b9 79 39 f8 78 38 38 38
#5eb9: f8 38 78 f8 f8 78 f8 78 f8 f8 c9 78 38 f8 89 09
#5ec9: 49 f8 f8 f9 f9 68 00 f8 78 38 39 f9 f9 28 48 18
#5ed9: 11 19 20 29 41 f8 70 30 20 20 19 18 28 60 48 80
#5ee9: 58 58 39 19 68 68 68 58 68 58 38 38 28 48 48 48
#5ef9: 48 08 30 20 28 39 70 38 30 20 20 20 20

; sprite_offset_a_lookup
#5f06: 36 44 c5 04 66 06 91 41 60 43 d0 d4 e4 e4 a4 03
#5f16: 97 63 03 05 77 97 65 06 06 06 06 e6 c6 d6 e6 f6
#5f26: 37 d6 65 02 03 12 c2 03 03 03 03 02 02 04 96 c4
#5f36: 04 04 43 43 00 00 05 05 01 00 00 00 00 05 05 05
#5f46: 05 00 c0 00 00 44 c0 03 03 03 07 07 53 17 02 d4
#5f56: 80 d4 07 f6 c6 87 04 84 47 67 c6 c6 96 02 44 d4
#5f66: c3 67 36 86 01 51 31 b1 b1 c4 02 67 47 15 55 35
#5f76: 05 00 16 37 e6 76 04 b6 c4 47 84 b6 a4

; sprite_offset_b_lookup
#5f83: 42 02 e9 81 98 98 e0 e0 7a 00 72 e1 5a 3a 81 00
#5f93: e1 0a 02 e9 60 68 e9 00 00 49 49 50 68 68 58 50
#5fa3: d0 d9 a0 00 28 01 01 09 49 89 c9 01 81 41 81 41
#5fb3: 80 41 80 20 00 00 00 00 89 80 80 80 31 80 09 89
#5fc3: 49 80 80 71 01 d0 00 80 01 41 4a 89 a8 e9 f9 c0
#5fd3: 72 c0 00 20 00 e0 00 18 11 e1 c0 c8 51 b1 78 00
#5fe3: 2a 00 02 02 00 00 70 00 60 e0 4a 0a b1 99 99 99
#5ff3: 99 72 c9 61 59 c1 d0 11 88 89 90 e8 90

#6000 - 7fff is used as screen memory
#6000: 16 16 16 16 16 16 16 16 06 06 06 06 a9 ; (unused)

; intro1
&600c: a9 01            LDA #&01
&600e: a2 28            LDX #&28
&6010: 8d 00 fe         STA &fe00 	                                        # write to video controller
&6013: 8e 01 fe         STX &fe01 	                                        # write to video controller
&6016: a9 0c            LDA #&0c
&6018: a2 28            LDX #&28
&601a: 8d 00 fe         STA &fe00 	                                        # write to video controller
&601d: 8e 01 fe         STX &fe01 	                                        # write to video controller
&6020: a9 0d            LDA #&0d
&6022: a2 00            LDX #&00
&6024: 8d 00 fe         STA &fe00 	                                        # write to video controller
&6027: 8e 01 fe         STX &fe01 	                                        # write to video controller
&602a: a2 83            LDX #&83
&602c: a0 fc            LDY #&fc
&602e: a9 00            LDA #&00
&6030: 4d f8 07         EOR &07f8       # actually EOR &xxyy
&6033: ee 31 60         INC &6031                                               # self modifying code
&6036: d0 03            BNE &603b
&6038: ee 32 60         INC &6032                                               # self modifying code
&603b: e8               INX
&603c: d0 f2            BNE &6030
&603e: c8               INY
&603f: d0 ef            BNE &6030
&6041: 8d 85 60         STA &6085                                               # self modifying code
&6044: 38               SEC
&6045: f8               SED
&6046: a9 82            LDA #&82
&6048: 85 02            STA &02 ; intro_two
&604a: a9 fc            LDA #&fc
&604c: 85 03            STA &03 ; intro_three
&604e: a0 00            LDY #&00
&6050: a9 6e            LDA #&6e
&6052: 85 01            STA &01 ; intro_one
&6054: a9 92            LDA #&92
&6056: 65 01            ADC &01 ; intro_one
&6058: 69 15            ADC #&15
&605a: 85 01            STA &01 ; intro_one
&605c: 59 f8 07         EOR &07f8,Y     # actually EOF &xxf8,Y
&605f: 99 f8 07         STA &07f8,Y     # actually STA &xxf8,Y
&6062: 45 01            EOR &01 ; intro_one
&6064: c8               INY
&6065: d0 06            BNE &606d
&6067: ee 5e 60         INC &605e                                               # self modifying code
&606a: ee 61 60         INC &6061                                               # self modifying code
&606d: e6 02            INC &02 ; intro_two
&606f: d0 e5            BNE &6056
&6071: e6 03            INC &03 ; intro_three
&6073: d0 e1            BNE &6056
&6075: d8               CLD
; teleport_fallback_wrong
&6076: ad 27 08         LDA &0827 ; teleport_fallback_x
&6079: c9 99            CMP #&99
&607b: d0 f9            BNE &6076 ; teleport_fallback_wrong
&607d: ad 2c 08         LDA &082c ; teleport_fallback_y
&6080: c9 3c            CMP #&3c
&6082: d0 f2            BNE &6076 ; teleport_fallback_wrong		        # loop until teleport_fallback_x,y are correct
&6084: a9 64            LDA #&64        # actually LDA #A from &6041
&6086: 4d 75 0b         EOR &0b75 ; maybe_another_checksum
&6089: 49 9f            EOR #&9f
&608b: 8d 52 0b         STA &0b52 ; possible_checksum
&608e: a9 43            LDA #&43
&6090: 8d 75 0b         STA &0b75 ; maybe_another_checksum
&6093: a0 07            LDY #&07
; restore_zero_page_loop
&6095: b9 f7 07         LDA &07f7,Y					        # copy &7f8 - &7fe
&6098: 99 d8 00         STA &00d8,Y					        # to &d9 - &df
&609b: 88               DEY
&609c: d0 f7            BNE &6095 ; restore_zero_page_loop
&609e: a0 0f            LDY #&0f
&60a0: b9 c6 08         LDA &08c6,Y ; object_stack_flags
&60a3: 09 01            ORA #&01
&60a5: 99 c6 08         STA &08c6,Y ; object_stack_flags
&60a8: 88               DEY
&60a9: d0 f5            BNE &60a0
&60ab: a9 0f            LDA #&0f
&60ad: 8d 42 fe         STA &fe42					        # system via
&60b0: a9 0c            LDA #&0c
&60b2: 8d 40 fe         STA &fe40					        # system via
&60b5: a9 05            LDA #&05
&60b7: 8d 40 fe         STA &fe40					        # system via
&60ba: a9 00            LDA #&00
&60bc: 8d 4b fe         STA &fe4b					        # system via
&60bf: a9 00            LDA #&00
&60c1: 8d 6b fe         STA &fe6b					        # user via Auxiliary Control Register
&60c4: a9 04            LDA #&04
&60c6: 8d 4c fe         STA &fe4c					        # system via
&60c9: a9 0e            LDA #&0e
&60cb: 8d 6c fe         STA &fe6c					        # user via Peripheral Control Register
&60ce: a9 7f            LDA #&7f
&60d0: 8d 4e fe         STA &fe4e					        # system VIA interrupt enable register
&60d3: 8d 6e fe         STA &fe6e					        # user VIA interrupt enable register
&60d6: a9 c2            LDA #&c2
&60d8: 8d 4e fe         STA &fe4e					        # system VIA interrupt enable register
&60db: a2 0a            LDX #&0a
&60dd: a0 09            LDY #&09
; video_controller_write_loop
&60df: bd f5 60         LDA &60f5,X
&60e2: 8c 00 fe         STY &fe00 					        # write to video controller
&60e5: 8d 01 fe         STA &fe01 					        # write to video controller
&60e8: ca               DEX
&60e9: 88               DEY
&60ea: 10 f3            BPL &60df ; video_controller_write_loop
&60ec: bd f5 60         LDA &60f5,X                                             # push &14 to 
&60ef: 8d 20 fe         STA &fe20					        # video ULA control register (20 columns, 2Mhz)
&60f2: 4c d0 01         JMP &01d0 ; intro2
# data written to video controller
     ;  0  1  2  3  4  5  6  7  8  9  a
#60f5: 14 7f 00 5b 28 26 00 10 1b 00 07

; intro
&7200: 78               SEI
&7201: d8               CLD
&7202: a9 7f            LDA #&7f
&7204: 8d 4e fe         STA &fe4e                                               # system VIA interrupt enable register
&7207: 8d 6e fe         STA &fe6e                                               # user VIA interrupt enable register
&720a: 8d 4d fe         STA &fe4d                                               # set system VIA interrupt flag register
&720d: 8d 6d fe         STA &fe6d                                               # user VIA interrupt flag register
&7210: a9 00            LDA #&00
&7212: a2 df            LDX #&df
&7214: 95 00            STA &00,X
&7216: ca               DEX
&7217: d0 fb            BNE &7214
&7219: a9 28            LDA #&28
&721b: 85 35            STA &35 ; sucking_distance 
&721d: a9 c0            LDA #&c0
&721f: 85 de            STA &de ; player_angle
&7221: c6 dd            DEC &dd ; object_held
&7223: a2 ff            LDX #&ff
&7225: 9a               TXS
&7226: a9 82            LDA #&82
&7228: 85 02            STA &02 ; intro_two
&722a: a9 fc            LDA #&fc
&722c: 85 03            STA &03 ; intro_three
&722e: a0 ff            LDY #&ff
&7230: b9 7e 06         LDA &067e,Y
&7233: 99 76 1b         STA &1b76,Y
&7236: 88               DEY
&7237: c0 ff            CPY #&ff
&7239: d0 07            BNE &7242
&723b: 18               CLC
&723c: ce 32 72         DEC &7232
&723f: ce 35 72         DEC &7235
&7242: e6 02            INC &02 ; intro_two
&7244: d0 ea            BNE &7230
&7246: e6 03            INC &03 ; intro_three
&7248: d0 e6            BNE &7230
&724a: ad 00 12         LDA &1200 ; copy 1200 - 7300
&724d: 8d 00 01         STA &0100 ;   to 0100 - 6200
&7250: ee 4b 72         INC &724b
&7253: ee 4e 72         INC &724e
&7256: d0 f2            BNE &724a
&7258: ee 4c 72         INC &724c
&725b: ee 4f 72         INC &724f
&725e: ad 4c 72         LDA &724c
&7261: c9 73            CMP #&73
&7263: d0 e5            BNE &724a
&7265: a9 ff            LDA #&ff
&7267: 8d 43 fe         STA &fe43
&726a: a2 03            LDX #&03
&726c: bd 78 72         LDA &7278,X
&726f: 20 e4 13         JSR &13e4 ; push_sound_to_chip
&7272: ca               DEX
&7273: 10 f7            BPL &726c
&7275: 4c 0c 60         JMP &600c ; intro1

#7278: ff df bf 9f 00 14 01 89 ; (unused)
