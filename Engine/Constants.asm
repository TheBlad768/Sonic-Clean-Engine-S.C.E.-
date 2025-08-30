; ===========================================================================
; Constants
; ===========================================================================

Ref_Checksum_String						= 'S3CE'

; ---------------------------------------------------------------------------
; VDP addresses
; ---------------------------------------------------------------------------

VDP_data_port =							$C00000						; (8=r/w, 16=r/w)
VDP_control_port =						$C00004						; (8=r/w, 16=r/w)
VDP_counter =							$C00008

PSG_input =							$C00011

; alias from Sonic 1 (GitHub)
vdp_data_port =							VDP_data_port
vdp_control_port =						VDP_control_port
vdp_counter =							VDP_counter

psg_input =							PSG_input

; ---------------------------------------------------------------------------
; Address equates
; ---------------------------------------------------------------------------

; Z80 addresses
Z80_RAM =							$A00000						; start of Z80 RAM
Z80_RAM_end =							$A02000						; end of non-reserved Z80 RAM
Z80_bus_request =						$A11100
Z80_reset =							$A11200

; alias from Sonic 1 (GitHub)
z80_ram =							Z80_RAM
z80_ram_end =							Z80_RAM_end
z80_bus_request =						Z80_bus_request
z80_reset =							Z80_reset

; alias from Sonic 2 (GitHub)
Z80_Bus_Request =						Z80_bus_request
Z80_Reset =							Z80_reset

ym2612_a0 =							$A04000
ym2612_d0 =							$A04001
ym2612_a1 =							$A04002
ym2612_d1 =							$A04003

; ---------------------------------------------------------------------------
; I/O Area
; ---------------------------------------------------------------------------

HW_Version =							$A10001
HW_Port_1_Data =						$A10003
HW_Port_2_Data =						$A10005
HW_Expansion_Data =						$A10007
HW_Port_1_Control =						$A10009
HW_Port_2_Control =						$A1000B
HW_Expansion_Control =						$A1000D
HW_Port_1_TxData =						$A1000F
HW_Port_1_RxData =						$A10011
HW_Port_1_SCtrl =						$A10013
HW_Port_2_TxData =						$A10015
HW_Port_2_RxData =						$A10017
HW_Port_2_SCtrl =						$A10019
HW_Expansion_TxData =						$A1001B
HW_Expansion_RxData =						$A1001D
HW_Expansion_SCtrl =						$A1001F

; alias from Sonic 1 (GitHub)
z80_version =							HW_Version
z80_port_1_data =						HW_Port_1_Data
z80_port_2_data =						HW_Port_2_Data
z80_expansion_data =						HW_Expansion_Data
z80_port_1_control =						HW_Port_1_Control
z80_port_2_control =						HW_Port_2_Control
z80_expansion_control =						HW_Expansion_Control

; ---------------------------------------------------------------------------
; SRAM addresses
; ---------------------------------------------------------------------------

SRAM_access_flag =						$A130F1
Security_addr =							$A14000

; alias from Sonic 1 (GitHub)
sram_port =							SRAM_access_flag
security_addr =							Security_addr

; alias from Sonic 2 (GitHub)
Security_Addr =							Security_addr

; ---------------------------------------------------------------------------
; Level Misc
; ---------------------------------------------------------------------------

RingTable_Count:						= 512						; the maximum rings on the level. Even numbers only
ObjectTable_Count:						= 768						; the maximum objects on the level. Even numbers only

; ---------------------------------------------------------------------------
; PLC queues
; ---------------------------------------------------------------------------

PLCKosPlusM_Count:						= 32						; the greater the queues, the more RAM is used for the buffer. Even numbers only

; ---------------------------------------------------------------------------
; V-Int routines
; ---------------------------------------------------------------------------

offset :=	VInt_Table
ptrsize :=	1
idstart :=	0

VintID_Lag =							id(ptr_VInt_Lag)				; 0
VintID_Main =							id(ptr_VInt_Main)				; 2
VintID_Sega =							id(ptr_VInt_Sega)				; 4
VintID_Menu =							id(ptr_VInt_Menu)				; 6
VintID_Level =							id(ptr_VInt_Level)				; 8
VintID_Fade =							id(ptr_VInt_Fade)				; A
VintID_LevelSelect =						id(ptr_VInt_LevelSelect)			; C

; ---------------------------------------------------------------------------
; Game mode routines
; ---------------------------------------------------------------------------

offset :=	Game_Modes
ptrsize :=	1
idstart :=	0

GameModeID_LevelSelectScreen =					id(GameMode_LevelSelectScreen)			; 0
GameModeID_LevelScreen =					id(GameMode_LevelScreen)			; 4

GameModeFlag_TitleCard =					7						; flag bit
GameModeID_TitleCard =						setBit(GameModeFlag_TitleCard)			; flag mask

; ---------------------------------------------------------------------------
; Player IDs
; ---------------------------------------------------------------------------

PlayerID_Sonic							equ 0
PlayerID_Tails							equ 1
PlayerID_Knuckles						equ 2

; ---------------------------------------------------------------------------
; Player routines (Sonic)
; ---------------------------------------------------------------------------

offset :=	Sonic_Index
ptrsize :=	1
idstart :=	0

PlayerID_Init =							id(ptr_Sonic_Init)				; 0
PlayerID_Control =						id(ptr_Sonic_Control)				; 2
PlayerID_Hurt =							id(ptr_Sonic_Hurt)				; 4
PlayerID_Death =						id(ptr_Sonic_Death)				; 6
PlayerID_Restart =						id(ptr_Sonic_Restart)				; 8

PlayerID_Drown =						id(ptr_Sonic_Drown)				; C

; ---------------------------------------------------------------------------
; palette IDs
; ---------------------------------------------------------------------------

offset :=	PalPointers
ptrsize :=	8
idstart :=	0

; Main
PalID_Sonic =							id(PalPtr_Sonic)				; 0
PalID_WaterSonic =						id(PalPtr_WaterSonic)				; 1

; Levels
PalID_DEZ =							id(PalPtr_DEZ)					; 2
PalID_WaterDEZ =						id(PalPtr_WaterDEZ)				; 3

; ---------------------------------------------------------------------------
; Sonic animation IDs
; ---------------------------------------------------------------------------

offset :=	AniSonic
ptrsize :=	2
idstart :=	0

AniIDSonAni_Walk =						id(ptr_SonAni_Walk)				; 00
AniIDSonAni_Run =						id(ptr_SonAni_Run)				; 01
AniIDSonAni_Roll =						id(ptr_SonAni_Roll)				; 02
AniIDSonAni_Roll2 =						id(ptr_SonAni_Roll2)				; 03
AniIDSonAni_Push =						id(ptr_SonAni_Push)				; 04
AniIDSonAni_Wait =						id(ptr_SonAni_Wait)				; 05
AniIDSonAni_Balance =						id(ptr_SonAni_Balance)				; 06
AniIDSonAni_LookUp =						id(ptr_SonAni_LookUp)				; 07
AniIDSonAni_Duck =						id(ptr_SonAni_Duck)				; 08
AniIDSonAni_SpinDash =						id(ptr_SonAni_SpinDash)				; 09
AniIDSonAni_Whistle =						id(ptr_SonAni_Whistle)				; 0A (Unused)
AniIDSonAni_0B =						id(ptr_AniSonic0B)				; 0B (Unused?)
AniIDSonAni_Balance2 =						id(ptr_SonAni_Balance2)				; 0C
AniIDSonAni_Stop =						id(ptr_SonAni_Stop)				; 0D
AniIDSonAni_Float1 =						id(ptr_SonAni_Float1)				; 0E
AniIDSonAni_Float2 =						id(ptr_SonAni_Float2)				; 0F
AniIDSonAni_Spring =						id(ptr_SonAni_Spring)				; 10
AniIDSonAni_Hang =						id(ptr_SonAni_Hang)				; 11
AniIDSonAni_12 =						id(ptr_AniSonic12)				; 12
AniIDSonAni_Landing =						id(ptr_SonAni_Landing)				; 13
AniIDSonAni_Hang2 =						id(ptr_SonAni_Hang2)				; 14
AniIDSonAni_GetAir =						id(ptr_SonAni_GetAir)				; 15
AniIDSonAni_DeathBW =						id(ptr_SonAni_DeathBW)				; 16 (Unused)
AniIDSonAni_Drown =						id(ptr_SonAni_Drown)				; 17
AniIDSonAni_Death =						id(ptr_SonAni_Death)				; 18
AniIDSonAni_Hurt =						id(ptr_SonAni_Hurt)				; 19
AniIDSonAni_Hurt2 =						id(ptr_SonAni_Hurt2)				; 1A
AniIDSonAni_Slide =						id(ptr_SonAni_Slide)				; 1B
AniIDSonAni_Blank =						id(ptr_SonAni_Blank)				; 1C
AniIDSonAni_Hurt3 =						id(ptr_SonAni_Hurt3)				; 1D
AniIDSonAni_Float3 =						id(ptr_SonAni_Float3)				; 1E
AniIDSupSonAni_Transform =					id(ptr_SonAni_Transform)			; 1F
AniIDSonAni_20 =						id(ptr_AniSonic20)				; 20 (Unused?)
AniIDSonAni_21 =						id(ptr_AniSonic21)				; 21 (Unused?)
AniIDSonAni_Carry =						id(ptr_SonAni_Carry)				; 22
AniIDSonAni_Carry2 =						id(ptr_SonAni_Carry2)				; 23

; ---------------------------------------------------------------------------
; Levels
; ---------------------------------------------------------------------------

LevelID_DEZ:							equ 0						; Death Egg
LevelID_NULL:							equ $FF						; NULL

; ---------------------------------------------------------------------------
; Buttons bit numbers
; ---------------------------------------------------------------------------

button_up:							equ 0
button_down:							equ 1
button_left:							equ 2
button_right:							equ 3
button_B:							equ 4
button_C:							equ 5
button_A:							equ 6
button_start:							equ 7

; ---------------------------------------------------------------------------
; Buttons masks (1 << x == pow(2, x))
; ---------------------------------------------------------------------------

button_up_mask:							equ setBit(button_up)				; $01
button_down_mask:						equ setBit(button_down)				; $02
button_left_mask:						equ setBit(button_left)				; $04
button_right_mask:						equ setBit(button_right)			; $08
button_B_mask:							equ setBit(button_B)				; $10
button_C_mask:							equ setBit(button_C)				; $20
button_A_mask:							equ setBit(button_A)				; $40
button_start_mask:						equ setBit(button_start)			; $80

; ---------------------------------------------------------------------------
; Joypad input
; ---------------------------------------------------------------------------

btnABCS:							equ %11110000					; A, B, C or Start ($F0)
btnStart:							equ %10000000					; Start button ($80)
btnABC:								equ %01110000					; A, B or C ($70)
btnAC:								equ %01100000					; A or C ($60)
btnAB:								equ %01010000					; A or B ($50)
btnA:								equ %01000000					; A ($40)
btnBC:								equ %00110000					; B or C ($30)
btnC:								equ %00100000					; C ($20)
btnB:								equ %00010000					; B ($10)
btnDir:								equ %00001111					; Any direction ($0F)
btnDLR:								equ %00001110					; Down, Left or Right ($0E)
btnULR:								equ %00001101					; Up, Left or Right ($0D)
btnLR:								equ %00001100					; Left or Right ($0C)
btnUDR:								equ %00001011					; Up, Down or Right ($0B)
btnDR:								equ %00001010					; Down or Right ($0A)
btnUR:								equ %00001001					; Down or Right ($09)
btnR:								equ %00001000					; Right ($08)
btnUDL:								equ %00000111					; Up, Down or Left ($07)
btnDL:								equ %00000110					; Down or Left ($06)
btnUL:								equ %00000101					; Up or Left ($05)
btnL:								equ %00000100					; Left ($04)
btnUD:								equ %00000011					; Up or Down ($03)
btnDn:								equ %00000010					; Down ($02)
btnUp:								equ %00000001					; Up ($01)

; ---------------------------------------------------------------------------
; Joypad bits
; ---------------------------------------------------------------------------

bitStart:							equ 7
bitA:								equ 6
bitC:								equ 5
bitB:								equ 4
bitR:								equ 3
bitL:								equ 2
bitDn:								equ 1
bitUp:								equ 0

; ---------------------------------------------------------------------------
; Condition Code Register (CCR) bits
; ---------------------------------------------------------------------------

ccr_x_bit							= 4						; extend ($10)
ccr_n_bit							= 3						; negative ($08)
ccr_z_bit							= 2						; zero ($04)
ccr_v_bit							= 1						; overflow ($02)
ccr_c_bit							= 0						; carry ($01)

; ---------------------------------------------------------------------------
; Unknown or inconsistently used offsets that are not applicable to Sonic
; ---------------------------------------------------------------------------

 enum		objoff_00=$00,objoff_01,objoff_02,objoff_03,objoff_04,objoff_05,objoff_06
 nextenum	objoff_07,objoff_08,objoff_09,objoff_0A,objoff_0B,objoff_0C,objoff_0D
 nextenum	objoff_0E,objoff_0F,objoff_10,objoff_11,objoff_12,objoff_13,objoff_14
 nextenum	objoff_15,objoff_16,objoff_17,objoff_18,objoff_19,objoff_1A,objoff_1B
 nextenum	objoff_1C,objoff_1D,objoff_1E,objoff_1F,objoff_20,objoff_21,objoff_22
 nextenum	objoff_23,objoff_24,objoff_25,objoff_26,objoff_27,objoff_28,objoff_29
 nextenum	objoff_2A,objoff_2B,objoff_2C,objoff_2D,objoff_2E,objoff_2F,objoff_30
 nextenum	objoff_31,objoff_32,objoff_33,objoff_34,objoff_35,objoff_36,objoff_37
 nextenum	objoff_38,objoff_39,objoff_3A,objoff_3B,objoff_3C,objoff_3D,objoff_3E
 nextenum	objoff_3F,objoff_40,objoff_41,objoff_42,objoff_43,objoff_44,objoff_45
 nextenum	objoff_46,objoff_47,objoff_48,objoff_49,objoff_4A,objoff_4B,objoff_4C
 nextenum	objoff_4D,objoff_4E,objoff_4F

; ---------------------------------------------------------------------------
; property of all objects
; ---------------------------------------------------------------------------

object_size_bits =						6
object_size =							$50						; the size of an object's status table entry
next_object =							object_size

; ---------------------------------------------------------------------------
; Object Status Table offsets
; Universally followed object conventions
; ---------------------------------------------------------------------------

id =								objoff_00					; long
address =							id						; long
render_flags =							objoff_04					; bitfield ; refer to SCHG for details
height_pixels =							objoff_06					; byte ; height / 2
width_pixels =							objoff_07					; byte ; width / 2
priority =							objoff_08					; word ; in units of $80
art_tile =							objoff_0A					; word ; PCCVH AAAAAAAAAAA ; P = priority, CC = palette line, V = y-flip; H = x-flip, A = starting cell index of art
mappings =							objoff_0C					; long
x_pos =								objoff_10					; word, or long when extra precision is required
x_sub =								x_pos+2						; word
y_pos =								objoff_14					; word, or long when extra precision is required
y_sub =								y_pos+2						; word
mapping_frame =							objoff_22					; byte

; ---------------------------------------------------------------------------
; Conventions followed by most objects
; ---------------------------------------------------------------------------

routine =							objoff_05					; byte
x_vel =								objoff_18					; word
y_vel =								objoff_1A					; word
y_radius =							objoff_1E					; byte ; collision height / 2
x_radius =							objoff_1F					; byte ; collision width / 2
anim =								objoff_20					; byte
prev_anim =							objoff_21					; byte ; when this isn't equal to anim the animation restarts
next_anim =							prev_anim					; byte ; when this isn't equal to anim the animation restarts
anim_frame =							objoff_23					; byte
anim_frame_timer =						objoff_24					; byte
angle =								objoff_26					; byte ; angle about axis into plane of the screen (00 = vertical, 360 degrees = 256)
status =							objoff_2A					; bitfield ; refer to SCHG for details

; ---------------------------------------------------------------------------
; Conventions followed by many objects but not Sonic/Tails/Knuckles
; ---------------------------------------------------------------------------

x_pixel =							x_pos						; word ; x-coordinate for objects using screen positioning
y_pixel =							y_pos						; word ; y-coordinate for objects using screen positioning
collision_flags =						objoff_28					; byte ; TT SSSSSS ; TT = collision type, SSSSSS = size
collision_property =						objoff_29					; byte ; usage varies, bosses use it as a hit counter
shield_reaction =						objoff_2B					; byte ; bit 3 = bounces off shield, bit 4 = negated by fire shield, bit 5 = negated by lightning shield, bit 6 = negated by bubble shield
subtype =							objoff_2C					; byte
wait_timer =							objoff_2E					; word
aniraw =							objoff_30					; long
jump =								objoff_34					; long
count =								objoff_39					; byte
ros_bit =							objoff_3B					; byte ; the bit to be cleared when an object is destroyed if the ROS flag is set
ros_addr =							objoff_3C					; word ; the RAM address whose bit to clear when an object is destroyed if the ROS flag is set
routine_secondary =						objoff_3C					; byte ; used by monitors for this purpose at least
parent =							objoff_42					; word ; address of the object that owns or spawned this one, if applicable
child_dx =							objoff_42					; byte ; X offset of child relative to parent
child_dy =							objoff_43					; byte ; Y offset of child relative to parent
parent4 =							objoff_44					; word
parent3 =							objoff_46					; word ; parent of child objects
parent2 =							objoff_48					; word ; several objects use this instead
respawn_addr =							objoff_4E					; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; Conventions specific to Sonic/Tails/Knuckles
; ---------------------------------------------------------------------------

ground_vel =							objoff_1C					; word ; overall velocity along ground, not updated when in the air
double_jump_property =						objoff_25					; byte ; remaining frames of flight / 2 for Tails, gliding-related for Knuckles
flip_angle =							objoff_27					; byte ; angle about horizontal axis (360 degrees = 256)
status_secondary =						objoff_2B					; byte ; see SCHG for details
air_left =							objoff_2C					; byte
flip_type =							objoff_2D					; byte ; bit 7 set means flipping is inverted, lower bits control flipping type
object_control =						objoff_2E					; byte ; bit 0 set means character can jump out, bit 7 set means he can't
double_jump_flag =						objoff_2F					; byte ; meaning depends on current character, see SCHG for details
flips_remaining =						objoff_30					; byte
flip_speed =							objoff_31					; byte
move_lock =							objoff_32					; word ; horizontal control lock, counts down to 0
invulnerability_timer =						objoff_34					; byte ; decremented every frame
invincibility_timer =						objoff_35					; byte ; decremented every 8 frames
speed_shoes_timer =						objoff_36					; byte ; decremented every 8 frames
status_tertiary =						objoff_37					; byte ; see SCHG for details
character_id =							objoff_38					; byte ; 0 for Sonic, 1 for Tails, 2 for Knuckles
scroll_delay_counter =						objoff_39					; byte ; incremented each frame the character is looking up/down, camera starts scrolling when this reaches 120
next_tilt =							objoff_3A					; byte ; angle on ground in front of character
tilt =								objoff_3B					; byte ; angle on ground
stick_to_convex =						objoff_3C					; byte ; used to make character stick to convex surfaces such as the rotating discs in CNZ
spin_dash_flag =						objoff_3D					; byte ; bit 1 indicates spin dash, bit 7 indicates forced roll
spin_dash_counter =						objoff_3E					; word
restart_timer =							objoff_3E					; word
jumping =							objoff_40					; byte
interact =							objoff_42					; word ; RAM address of the last object the character stood on
default_y_radius =						objoff_44					; byte ; default value of y_radius
default_x_radius =						objoff_45					; byte ; default value of x_radius
top_solid_bit =							objoff_46					; byte ; the bit to check for top solidity (either $C or $E)
lrb_solid_bit =							objoff_47					; byte ; the bit to check for left/right/bottom solidity (either $D or $F)

; ---------------------------------------------------------------------------
; Conventions followed by some/most bosses
; ---------------------------------------------------------------------------

boss_invulnerable_time =					objoff_1D					; byte ; flash time
boss_backup_collision =						objoff_25					; byte ; restore boss collision after hit
boss_hitcount2 =						objoff_29					; byte ; usage varies, bosses use it as a hit counter

; ---------------------------------------------------------------------------
; Object variables
; Alias from Sonic 1 (GitHub)
; ---------------------------------------------------------------------------

obId =								address						; long
obRender =							render_flags					; byte ; bitfield for x/y flip, display mode
obRoutine =							routine						; byte ; routine number
obHeight =							height_pixels					; byte ; height/2
obWidth =							width_pixels					; byte ; width/2
obPriority =							priority					; word ; sprite stack priority -- 0 is front
obGfx =								art_tile					; word ; palette line & VRAM setting (2 bytes)
obMap =								mappings					; long ; mappings address (4 bytes)
obX =								x_pos						; word ; x-axis position (2-4 bytes)
obY =								y_pos						; word ; y-axis position (2-4 bytes)
obVelX =							x_vel						; word ; x-axis velocity (2 bytes)
obVelY =							y_vel						; word ; y-axis velocity (2 bytes)
obInertia =							ground_vel					; word ; potential speed (2 bytes)
obAnim =							anim						; byte ; current animation
obNextAni =							next_anim					; byte ; next animation
obFrame =							mapping_frame					; byte ; current frame displayed
obAniFrame =							anim_frame					; byte
obTimeFrame =							anim_frame_timer				; byte
obAngle =							angle						; byte
obColType =							collision_flags					; byte ; collision response type
obColProp =							collision_property				; byte ; collision extra property
obStatus =							status						; byte ; orientation or mode
obSubtype =							subtype						; byte ; object subtype
obTimer =							wait_timer					; word ; object timer
obParent =							parent						; word ; parent of child objects
obParent4 =							parent4						; word ; parent of child objects
obParent3 =							parent3						; word ; parent of child objects
obParent2 =							parent2						; word ; parent of child objects
obRespawnNo =							respawn_addr					; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; When childsprites are activated (i.e. bit #6 of render_flags set)
; ---------------------------------------------------------------------------

mainspr_childsprites						= objoff_16					; word ; amount of child sprites

subspr_data							= objoff_18
sub2_x_pos							= objoff_18
sub2_y_pos							= objoff_1A
sub2_mapframe							= objoff_1D
sub3_x_pos							= objoff_1E
sub3_y_pos							= objoff_20
sub3_mapframe							= objoff_23
sub4_x_pos							= objoff_24
sub4_y_pos							= objoff_26
sub4_mapframe							= objoff_29
sub5_x_pos							= objoff_2A
sub5_y_pos							= objoff_2C
sub5_mapframe							= objoff_2F
sub6_x_pos							= objoff_30
sub6_y_pos							= objoff_32
sub6_mapframe							= objoff_35
sub7_x_pos							= objoff_36
sub7_y_pos							= objoff_38
sub7_mapframe							= objoff_3B
sub8_x_pos							= objoff_3C
sub8_y_pos							= objoff_3E
sub8_mapframe							= objoff_41
sub9_x_pos							= objoff_42
sub9_y_pos							= objoff_44
sub9_mapframe							= objoff_47
subA_x_pos							= objoff_48
subA_y_pos							= objoff_4A
subA_mapframe							= objoff_4D

next_subspr							= 6						; size

; ---------------------------------------------------------------------------
; Bits 3-6 of an object's status after a SolidObject call is a
; bitfield with the following meaning:
; ---------------------------------------------------------------------------

p1_standing_bit							= 3
p2_standing_bit							= p1_standing_bit + 1
p1_standing							= setBit(p1_standing_bit)
p2_standing							= setBit(p2_standing_bit)
pushing_bit_delta						= 2
p1_pushing_bit							= p1_standing_bit + pushing_bit_delta
p2_pushing_bit							= p1_pushing_bit + 1
p1_pushing							= setBit(p1_pushing_bit)
p2_pushing							= setBit(p2_pushing_bit)
standing_mask							= p1_standing|p2_standing
pushing_mask							= p1_pushing|p2_pushing

; ---------------------------------------------------------------------------
; The high word of d6 after a SolidObject call is a bitfield
; with the following meaning:
; ---------------------------------------------------------------------------

p1_touch_side_bit						= 0
p2_touch_side_bit						= p1_touch_side_bit + 1
p1_touch_side							= setBit(p1_touch_side_bit)
p2_touch_side							= setBit(p2_touch_side_bit)
touch_side_mask							= p1_touch_side|p2_touch_side
p1_touch_bottom_bit						= p1_touch_side_bit + pushing_bit_delta
p2_touch_bottom_bit						= p1_touch_bottom_bit + 1
p1_touch_bottom							= setBit(p1_touch_bottom_bit)
p2_touch_bottom							= setBit(p2_touch_bottom_bit)
touch_bottom_mask						= p1_touch_bottom|p2_touch_bottom
p1_touch_top_bit						= p1_touch_bottom_bit + pushing_bit_delta
p2_touch_top_bit						= p1_touch_top_bit + 1
p1_touch_top							= setBit(p1_touch_top_bit)
p2_touch_top							= setBit(p2_touch_top_bit)
touch_top_mask							= p1_touch_top|p2_touch_top

; ---------------------------------------------------------------------------
; Sprite priority
; ---------------------------------------------------------------------------

priority_0							= sprite_priority(0)				; high priority
priority_1							= sprite_priority(1)
priority_2							= sprite_priority(2)
priority_3							= sprite_priority(3)
priority_4							= sprite_priority(4)
priority_5							= sprite_priority(5)
priority_6							= sprite_priority(6)
priority_7							= sprite_priority(7)				; low priority

; ---------------------------------------------------------------------------
; Sprite render screen bits
; ---------------------------------------------------------------------------

render_flags.x_flip						= 0						; sprite mirrored horizontally
render_flags.y_flip						= 1						; sprite mirrored vertically
render_flags.level						= 2						; move with level

render_flags.static_mappings					= 5						; mappings pointer points directly to a lone sprite piece instead of a list of sprites
render_flags.multi_sprite					= 6						; object SST holds metadata for multiple sprites
render_flags.on_screen						= 7						; object is on-screen and was rendered on the previous frame

; ---------------------------------------------------------------------------
; Player status variables
; ---------------------------------------------------------------------------

status.player.x_flip						= render_flags.x_flip				; facing left
status.player.in_air						= 1						; airborne
status.player.rolling						= 2						; spinning, i.e. jumping or rolling
status.player.on_object						= 3						; stood on an object rather than the level

status.player.pushing						= 5						; pressing against an object
status.player.underwater					= 6						; submersed
status.player.prevent_tails_respawn				= 7						; prevents AI Tails from respawning

; ---------------------------------------------------------------------------
; Player status secondary variables
; ---------------------------------------------------------------------------

status_secondary.shield						= 0
status_secondary.invincible					= 1
status_secondary.speed_shoes					= 2

status_secondary.fire_shield					= 4
status_secondary.lightning_shield				= 5
status_secondary.bubble_shield					= 6
status_secondary.sliding					= 7

; ---------------------------------------------------------------------------
; Player shield reaction variables
; ---------------------------------------------------------------------------

shield_reaction.shield						= 0
shield_reaction.invincible					= 1
shield_reaction.speed_shoes					= 2
shield_reaction.all_shields					= 3
shield_reaction.fire_shield					= 4
shield_reaction.lightning_shield				= 5
shield_reaction.bubble_shield					= 6

; ---------------------------------------------------------------------------
; Object status variables
; ---------------------------------------------------------------------------

status.npc.x_flip						= render_flags.x_flip				; facing right ; used by Animate_Sprite
status.npc.y_flip						= render_flags.y_flip				; facing up ; used by Animate_Sprite
status.npc.dplc_slot						= 2						; set if DPLC is used ; used by SetUp_ObjAttributesSlotted
status.npc.p1_standing						= 3						; stood on by player 1
status.npc.p2_standing						= 4						; stood on by player 2
status.npc.p1_pushing						= 5						; pushed by player 1
status.npc.p2_pushing						= 6						; pushed by player 2
status.npc.no_balancing						= 7						; prevents player from performing their balancing animation whilst stood upon this object

; bosses
status.npc.touch						= 6						; set if a player hit the boss
status.npc.defeated						= 7						; set if a player defeated the enemy or boss

; ---------------------------------------------------------------------------
; Object collision variables
; ---------------------------------------------------------------------------

collision_flags.npc.touch					= (0<<6)
collision_flags.npc.item					= (1<<6)
collision_flags.npc.hurt					= (2<<6)
collision_flags.npc.special					= (3<<6)

collision_flags.npc.size_mask					= $3F
collision_flags.npc.type_mask					= $C0

; ---------------------------------------------------------------------------
; Water wind tunnels variables
; ---------------------------------------------------------------------------

WindTunnel_holding_flag.player_1				= 0
WindTunnel_holding_flag.player_2				= 1

; ---------------------------------------------------------------------------
; Universal (used on all standard levels)
; ---------------------------------------------------------------------------

ArtTile_VRAM_Start						= 0
ArtTile_SpikesSprings						= $484
ArtTile_Monitors						= $4AC
ArtTile_Explosion						= $5A0
ArtTile_StarPost						= $5E4
ArtTile_Sonic							= $680
ArtTile_Ring							= $6BC
ArtTile_Ring_Sparks						= ArtTile_Ring+4
ArtTile_HUD							= $6C4
ArtTile_Shield							= $79C
ArtTile_Shield_Sparks						= ArtTile_Shield+$1F
ArtTile_DashDust						= $7E0

; ---------------------------------------------------------------------------
; Values for the type and rwd argument
; ---------------------------------------------------------------------------

VRAM = %100001
CRAM = %101011
VSRAM = %100101

READ = %001100
WRITE = %000111
DMA = %100111

; ---------------------------------------------------------------------------
; VRAM and tile art base addresses
; VRAM Reserved regions
; ---------------------------------------------------------------------------

VRAM_Plane_A_Name_Table						= $C000						; extends until $CFFF
VRAM_Plane_W_Name_Table						= $C000						; extends until $CFFF
VRAM_Plane_B_Name_Table						= $E000						; extends until $EFFF
VRAM_Plane_Table_Size						= $1000						; 64 cells x 32 cells x 2 bytes per cell
VRAM_Sprite_Attribute_Table					= $F800						; extends until $FA7F
VRAM_Sprite_Attribute_Table_Size				= $280						; 640 bytes
VRAM_Horiz_Scroll_Table						= $F000						; extends until $FF7F
VRAM_Horiz_Scroll_Table_Size					= 224*2*2					; 224 lines * 2 bytes per entry * 2 PNTs

; ---------------------------------------------------------------------------
; VRAM data
; ---------------------------------------------------------------------------

vram_fg:							= VRAM_Plane_A_Name_Table			; foreground namespace
vram_window:							= VRAM_Plane_W_Name_Table			; window namespace
vram_bg:							= VRAM_Plane_B_Name_Table			; background namespace
vram_hscroll:							= VRAM_Horiz_Scroll_Table			; horizontal scroll table
vram_sprites:							= VRAM_Sprite_Attribute_Table			; sprite table

; ---------------------------------------------------------------------------
; Colours
; ---------------------------------------------------------------------------

cBlack:								equ 0						; colour black
cWhite:								equ $EEE					; colour white
cBlue:								equ $E00					; colour blue
cGreen:								equ $E0						; colour green
cRed:								equ $E						; colour red
cYellow:							equ cGreen+cRed					; colour yellow
cAqua:								equ cGreen+cBlue				; colour aqua
cMagenta:							equ cBlue+cRed					; colour magenta

; ---------------------------------------------------------------------------
; Art tile stuff
; ---------------------------------------------------------------------------

flip_x								= (1<<11)
flip_y								= (1<<12)
flip_bit_x							= 3
flip_bit_y							= 4
palette_bit_0							= 5
palette_bit_1							= 6
palette_line0							= (0<<13)
palette_line_0							= (0<<13)
palette_line1							= (1<<13)
palette_line_1							= (1<<13)
palette_line2							= (2<<13)
palette_line_2							= (2<<13)
palette_line3							= (3<<13)
palette_line_3							= (3<<13)
palette_line_size						= 16*2						; 16 word entries
high_priority_bit						= 7
high_priority							= setBit(15)
palette_mask							= $6000
tile_size							= 8*8/2
plane_size_64x32						= 64*32*2
tile_mask							= $7FF
nontile_mask							= $F800
drawing_mask							= $7FFF

; ---------------------------------------------------------------------------
; Animation flags
; ---------------------------------------------------------------------------

afEnd								= $FF						; return to beginning of animation
afBack								= $FE						; go back (specified number) bytes
afChange							= $FD						; run specified animation
afRoutine							= $FC						; increment routine counter and continue load next anim bytes
afReset								= $FB						; move offscreen for remove(Using the Sprite_OnScreen_Test, etc...)

; ---------------------------------------------------------------------------
; Animation Raw flags
; ---------------------------------------------------------------------------

arfIndex							= $FF						; go to animate raw index
arfEnd								= $FE						; return to beginning of animation
arfChange							= $FC						; run specified animation (specified offset)
arfJump								= $FA						; jump from $34(a0) address

; ---------------------------------------------------------------------------
; Subroutine constants
; ---------------------------------------------------------------------------

; main
JoypadInit							= Init_Controllers				; alias from Sonic 1/2 (Hivebrain/GitHub)
ReadJoypads							= Poll_Controllers				; alias from Sonic 1/2 (Hivebrain/GitHub)
Joypad_Read							= Poll_Controller				; alias from Sonic 2 (GitHub)
VDPSetupGame							= Init_VDP					; alias from Sonic 1/2 (Hivebrain/GitHub)
InitDMAQueue							= Init_DMA_Queue				; alias from Sonic 2 (GitHub)
ProcessDMAQueue							= Process_DMA_Queue				; alias from Sonic 1/2 (Hivebrain/GitHub)
QueueDMATransfer						= Add_To_DMA_Queue				; alias from Sonic 1/2 (Hivebrain/GitHub)
ClearScreen							= Clear_DisplayData				; alias from Sonic 1/2 (Hivebrain/GitHub)
ShowVDPGraphics							= Plane_Map_To_VRAM				; alias from Sonic 1 (Hivebrain)
PlaneMapToVRAM							= Plane_Map_To_VRAM				; alias from Sonic 2 (GitHub)
TilemapToVRAM							= Plane_Map_To_VRAM				; alias from Sonic 1 (GitHub)
PlaneMapToVRAM2							= Plane_Map_To_VRAM_2				; alias from Sonic 2 (GitHub)
PlaneMapToVRAM3							= Plane_Map_To_VRAM_3				; alias from Sonic 2 (GitHub)
EniDec								= Eni_Decomp					; alias from Sonic 1/2 (Hivebrain/GitHub)
KosPlusDec							= KosPlus_Decomp				; alias from Sonic 1/2 (Hivebrain/GitHub)
Pal_FadeTo							= Pal_FadeFromBlack				; alias from Sonic 1 (Hivebrain)
PaletteFadeIn							= Pal_FadeFromBlack				; alias from Sonic 1 (GitHub)
Pal_FadeIn							= Pal_FromBlack					; alias from Sonic 1 (Hivebrain)
FadeIn_FromBlack						= Pal_FromBlack					; alias from Sonic 1 (GitHub)
Pal_FadeFrom							= Pal_FadeToBlack				; alias from Sonic 1 (Hivebrain)
PaletteFadeOut							= Pal_FadeToBlack				; alias from Sonic 1 (GitHub)
Pal_FadeOut							= Pal_ToBlack					; alias from Sonic 1 (Hivebrain)
FadeOut_ToBlack							= Pal_ToBlack					; alias from Sonic 1 (GitHub)
Pal_FromBlackWhite						= Pal_FadeFromWhite				; alias from S3K Disassembly (2011)
PalLoad1							= LoadPalette					; alias from Sonic 1 (Hivebrain)
PalLoad_Fade							= LoadPalette					; alias from Sonic 1 (GitHub)
PalLoad_ForFade							= LoadPalette					; alias from Sonic 2 (GitHub)
PalLoad2							= LoadPalette_Immediate				; alias from Sonic 1 (Hivebrain)
PalLoad								= LoadPalette_Immediate				; alias from Sonic 1 (GitHub)
PalLoad_Now							= LoadPalette_Immediate				; alias from Sonic 2 (GitHub)
PalLoad3_Water							= LoadPalette2					; alias from Sonic 1 (Hivebrain)
PalLoad_Fade_Water						= LoadPalette2					; alias from Sonic 1 (GitHub)
PalLoad_Water_Now						= LoadPalette2					; alias from Sonic 2 (GitHub)
PalLoad4_Water							= LoadPalette2_Immediate			; alias from Sonic 1 (Hivebrain)
PalLoad_Water							= LoadPalette2_Immediate			; alias from Sonic 1 (GitHub)
PalLoad_Water_ForFade						= LoadPalette2_Immediate			; alias from Sonic 2 (GitHub)
DelayProgram							= Wait_VSync					; alias from Sonic 1 (Hivebrain)
WaitForVBla							= Wait_VSync					; alias from Sonic 1 (GitHub)
WaitForVint							= Wait_VSync					; alias from Sonic 2 (GitHub)
RandomNumber							= Random_Number					; alias from Sonic 1/2 (Hivebrain/GitHub)
CalcAngle							= GetArcTan					; alias from Sonic 1/2 (Hivebrain/GitHub)
CalcSine							= GetSineCosine					; alias from Sonic 1/2 (Hivebrain/GitHub)
PauseGame							= Pause_Game					; alias from Sonic 1/2 (Hivebrain/GitHub)

; objects
RunObjects							= Process_Sprites				; alias from Sonic 2 (GitHub)
ObjectsLoad							= Process_Sprites				; alias from Sonic 1 (Hivebrain)
ExecuteObjects							= Process_Sprites				; alias from Sonic 1 (GitHub)
BuildSprites							= Render_Sprites				; alias from Sonic 1/2 (Hivebrain/GitHub)
AddPoints							= HUD_AddToScore				; alias from Sonic 1/2 (Hivebrain/GitHub)
AnimateSprite							= Animate_Sprite				; alias from Sonic 1/2 (Hivebrain/GitHub)
ObjectFall							= MoveSprite					; alias from Sonic 1 (Hivebrain)
ObjectMoveAndFall						= MoveSprite					; alias from Sonic 2 (GitHub)
SpeedToPos							= MoveSprite2					; alias from Sonic 1 (Hivebrain)
ObjectMove							= MoveSprite2					; alias from Sonic 2 (GitHub)
DisplaySprite							= Draw_Sprite					; alias from Sonic 1/2 (Hivebrain/GitHub)
DeleteObject							= Delete_Current_Sprite				; alias from Sonic 1/2 (Hivebrain/GitHub)
DeleteChild							= Delete_Referenced_Sprite			; alias from Sonic 1 (GitHub)
DeleteObject2							= Delete_Referenced_Sprite			; alias from Sonic 1/2 (Hivebrain/GitHub)
SingleObjLoad							= Create_New_Sprite				; alias from Sonic 1 (Hivebrain)
AllocateObject							= Create_New_Sprite				; alias from Sonic 2/3K (GitHub)
FindFreeObj							= Create_New_Sprite				; alias from Sonic 1 (GitHub)
SingleObjLoad2							= Create_New_Sprite3				; alias from Sonic 1 (Hivebrain)
FindNextFreeObj							= Create_New_Sprite3				; alias from Sonic 1 (GitHub)
AllocateObjectAfterCurrent					= Create_New_Sprite3				; alias from Sonic 2/3K (GitHub)
Find_Sonic							= Find_SonicObject				; alias for SCE
Find_SonicTails							= Find_SonicObject				; alias from Sonic 3K (GitHub)
Find_SonicTails8Way						= Find_Sonic8Way				; alias from Sonic 3K (GitHub)
Shot_ObjectInSonic						= Shot_Object					; alias for SCE
MarkObjGone							= Sprite_OnScreen_Test				; alias from Sonic 1/2 (Hivebrain/GitHub)
RememberState							= Sprite_OnScreen_Test				; alias from Sonic 1 (GitHub)
MarkObjGone_Collision						= Sprite_CheckDeleteTouch3			; alias for SCE
RememberState_Collision						= Sprite_CheckDeleteTouch3			; alias for SCE
Sprite_OnScreen_Test_Collision					= Sprite_CheckDeleteTouch3			; alias for SCE
ObjHitFloor							= ObjCheckFloorDist				; alias from Sonic 1 (Hivebrain)
ObjFloorDist							= ObjCheckFloorDist				; alias from Sonic 1 (GitHub)
ObjHitFloor2							= ObjCheckFloorDist2				; alias from Sonic 1 (Hivebrain)
ObjFloorDist2							= ObjCheckFloorDist2				; alias from Sonic 1 (GitHub)
ObjHitWallRight							= ObjCheckRightWallDist				; alias from Sonic 1 (GitHub)
ObjHitCeiling							= ObjCheckCeilingDist				; alias from Sonic 1 (GitHub)
ObjHitWallLeft							= ObjCheckLeftWallDist				; alias from Sonic 1 (GitHub)
ObjHitFloor_DoRoutine						= ObjCheckFloorDist_DoRoutine			; alias from Sonic 3K (GitHub)
ObjHitFloor2_DoRoutine						= ObjCheckFloorDist2_DoRoutine			; alias from Sonic 3K (GitHub)
ObjHitCeiling_DoRoutine						= ObjCheckCeilingDist_DoRoutine			; alias from Sonic 3K (GitHub)
ObjHitWall_DoRoutine						= ObjCheckRightWallDist_DoRoutine		; alias from Sonic 3K (GitHub)
ObjHitWall2_DoRoutine						= ObjCheckLeftWallDist_DoRoutine		; alias from Sonic 3K (GitHub)
SolidObject							= SolidObjectFull				; alias from Sonic 1/2 (Hivebrain/GitHub)
SolidObject_Always						= SolidObjectFull2				; alias from Sonic 2 (GitHub)
CollectRing							= GiveRing					; alias from Sonic 1/2 (Hivebrain/GitHub)
ReactToItem							= TouchResponse					; alias from Sonic 1 (GitHub)
HurtSonic							= HurtCharacter					; alias from Sonic 1 (Hivebrain/GitHub)
KillSonic							= Kill_Character				; alias from Sonic 1 (Hivebrain/GitHub)
Lamp_StoreInfo							= Save_StarPost_Settings			; alias from Sonic 1 (GitHub)
Lamp_LoadInfo							= Load_StarPost_Settings			; alias from Sonic 1 (GitHub)

; ---------------------------------------------------------------------------
; RAM constants
; ---------------------------------------------------------------------------

; RAM variables
v_ram_start							= RAM_start					; alias from Sonic 1 (GitHub)

; object variables
v_player							= Player_1					; alias from Sonic 1 (GitHub)

; scroll variables
v_hscrolltablebuffer						= H_scroll_buffer				; alias from Sonic 1 (GitHub)
Horiz_Scroll_Buf						= H_scroll_buffer				; alias from Sonic 2 (GitHub)
v_hscrolltablebuffer_end					= H_scroll_buffer_end				; alias from Sonic 1 (GitHub)
HScroll_table							= H_scroll_table				; alias from Sonic 3K (GitHub)

; table variables
v_tracksonic							= Pos_table					; alias from Sonic 1 (GitHub)

; DMA variables
VDP_Command_Buffer						= DMA_queue					; alias from Sonic 2 (GitHub)
VDP_Command_Buffer_Slot						= DMA_queue_slot				; alias from Sonic 2 (GitHub)

; camera variables
v_screenposx							= Camera_X_pos					; alias from Sonic 1 (GitHub)
v_screenposy							= Camera_Y_pos					; alias from Sonic 1 (GitHub)
v_trackpos							= Pos_table_index				; alias from Sonic 1 (GitHub)
v_trackbyte							= Pos_table_index+1				; alias from Sonic 1 (GitHub)
v_lookshift							= Distance_from_top				; alias from Sonic 1 (GitHub)
Screen_shake_flag						= Screen_shaking_flag				; alias from Sonic 3K (GitHub)
Screen_shake_offset						= Screen_shaking_offset				; alias from Sonic 3K (GitHub)
Screen_shake_last_offset					= Screen_shaking_last_offset			; alias from Sonic 3K (GitHub)

; misc variables
v_gamemode							= Game_mode					; alias from Sonic 1 (GitHub)
v_vbla_routine							= V_int_routine					; alias from Sonic 1 (GitHub)
SonicControl							= Ctrl_1_logical				; alias from Sonic 1 (Vladikcomper)
v_jpadhold2							= Ctrl_1_held_logical				; alias from Sonic 1 (GitHub)
v_jpadpress2							= Ctrl_1_pressed_logical			; alias from Sonic 1 (GitHub)
Joypad								= Ctrl_1					; alias from Sonic 1 (Vladikcomper)
Ctrl_1_hold							= Ctrl_1_held					; alias from Sonic 2 (GitHub)
v_jpadhold1							= Ctrl_1_held					; alias from Sonic 1 (GitHub)
v_jpadpress1							= Ctrl_1_pressed				; alias from Sonic 1 (GitHub)
Ctrl_1_press							= Ctrl_1_pressed				; alias from Sonic 2 (GitHub)
Ctrl_2_hold							= Ctrl_2_held					; alias from Sonic 2 (GitHub)
v_jpad2hold1							= Ctrl_2_held					; alias from Sonic 1 (GitHub)
v_jpad2press1							= Ctrl_2_pressed				; alias from Sonic 1 (GitHub)
Ctrl_2_press							= Ctrl_2_pressed				; alias from Sonic 2 (GitHub)
v_vdp_buffer1							= VDP_reg_1_command				; alias from Sonic 1 (GitHub)
v_demolength							= Demo_timer					; alias from Sonic 1 (GitHub)
v_scrposy_dup							= V_scroll_value				; alias from Sonic 1 (GitHub)
v_scrposy_vdp							= V_scroll_value_FG				; alias from Sonic 1 (GitHub)
v_bgscrposy_vdp							= V_scroll_value_BG				; alias from Sonic 1 (GitHub)
v_scrposx_dup							= H_scroll_value				; alias from Sonic 1 (GitHub)
v_scrposx_vdp							= H_scroll_value_FG				; alias from Sonic 1 (GitHub)
v_bgscrposx_vdp							= H_scroll_value_BG				; alias from Sonic 1 (GitHub)
v_hbla_hreg							= H_int_counter_command				; alias from Sonic 1 (GitHub)
v_hbla_line							= H_int_counter					; alias from Sonic 1 (GitHub)
v_random							= RNG_seed					; alias from Sonic 1 (GitHub)
v_pfade_start							= Palette_fade_index				; alias from Sonic 1 (GitHub)
v_pfade_size							= Palette_fade_count				; alias from Sonic 1 (GitHub)

; lag variables
f_hbla_pal							= H_int_flag					; alias from Sonic 1 (GitHub)
Hint_flag							= H_int_flag					; alias from Sonic 2 (GitHub)
f_doupdatesinhblank						= Do_Updates_in_H_int				; alias from Sonic 1 (GitHub)
f_lockctrl							= Ctrl_1_locked					; alias from Sonic 1 (GitHub)
v_framecount							= Level_frame_counter				; alias from Sonic 1 (GitHub)
v_framebyte							= Level_frame_counter+1				; alias from Sonic 1 (GitHub)
f_pause								= Game_paused					; alias from Sonic 1 (GitHub)
f_restart							= Restart_level_flag				; alias from Sonic 1 (GitHub)
v_spritecount							= Sprites_drawn					; alias from Sonic 1 (GitHub)
v_sonspeedmax							= Max_speed					; alias from Sonic 1 (GitHub)
Sonic_top_speed							= Max_speed					; alias from Sonic 2 (GitHub)
v_sonspeedacc							= Acceleration					; alias from Sonic 1 (GitHub)
Sonic_acceleration						= Acceleration					; alias from Sonic 2 (GitHub)
v_sonspeeddec							= Deceleration					; alias from Sonic 1 (GitHub)
Sonic_deceleration						= Deceleration					; alias from Sonic 2 (GitHub)
v_sonframenum							= Player_prev_frame				; alias from Sonic 1 (GitHub)
Sonic_LastLoadedDPLC						= Player_prev_frame				; alias from Sonic 2 (GitHub)
f_lockscreen							= Boss_flag

; water variables
Water_Level_1							= Water_level					; alias from Sonic 2 (GitHub)
Water_Level_2							= Mean_water_level				; alias from Sonic 2 (GitHub)
Water_Level_3							= Target_water_level				; alias from Sonic 2 (GitHub)
Water_on							= Water_speed					; alias from Sonic 2 (GitHub)
Water_move							= Water_full_screen_flag			; alias from Sonic 2 (GitHub)
Water_fullscreen_flag						= Water_full_screen_flag			; alias from Sonic 2 (GitHub)

; water variables
v_pal_water_dup							= Target_water_palette				; alias from Sonic 1 (GitHub)
v_pal_water							= Water_palette					; alias from Sonic 1 (GitHub)
v_pal_dry							= Normal_palette				; alias from Sonic 1 (GitHub)
v_pal_dry_dup							= Target_palette				; alias from Sonic 1 (GitHub)

; main variables
v_vbla_count							= V_int_run_count				; alias from Sonic 1 (GitHub)
v_vbla_word							= V_int_run_count+2				; alias from Sonic 1 (GitHub)
v_vbla_byte							= V_int_run_count+3				; alias from Sonic 1 (GitHub)
Vint_runcount							= V_int_run_count				; alias from Sonic 2 (GitHub)
v_zone								= Current_zone					; alias from Sonic 1 (GitHub)
v_act								= Current_act					; alias from Sonic 1 (GitHub)
Last_star_pole_hit						= Last_star_post_hit				; alias from Sonic 2 (GitHub)
f_timeover							= Time_over_flag				; alias from Sonic 1 (GitHub)
v_score								= Score						; alias from Sonic 1 (GitHub)
f_ringcount							= Update_HUD_ring_count				; alias from Sonic 1 (GitHub)
f_timecount							= Update_HUD_timer				; alias from Sonic 1 (GitHub)
f_scorecount							= Update_HUD_score				; alias from Sonic 1 (GitHub)
v_rings								= Ring_count					; alias from Sonic 1 (GitHub)
v_ringbyte							= Ring_count+1					; alias from Sonic 1 (GitHub)
v_time								= Timer						; alias from Sonic 1 (GitHub)
v_timemin							= Timer_minute					; alias from Sonic 1 (GitHub)
v_timesec							= Timer_second					; alias from Sonic 1 (GitHub)
v_timecent							= Timer_frame					; alias from Sonic 1 (GitHub)
