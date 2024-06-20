; ===========================================================================
; Constants
; ===========================================================================

Ref_Checksum_String				= 'S3CE'

; ---------------------------------------------------------------------------
; VDP addresses
; ---------------------------------------------------------------------------

VDP_data_port =					$C00000
VDP_control_port =				$C00004
VDP_counter =					$C00008

PSG_input =						$C00011

; ---------------------------------------------------------------------------
; Address equates
; ---------------------------------------------------------------------------

; Z80 addresses
Z80_RAM =						$A00000	; start of Z80 RAM
Z80_RAM_end =					$A02000	; end of non-reserved Z80 RAM
Z80_bus_request =				$A11100
Z80_reset =						$A11200

; ---------------------------------------------------------------------------
; I/O Area
; ---------------------------------------------------------------------------

HW_Version =					$A10001
HW_Port_1_Data =				$A10003
HW_Port_2_Data =				$A10005
HW_Expansion_Data =			$A10007
HW_Port_1_Control =				$A10009
HW_Port_2_Control =				$A1000B
HW_Expansion_Control =			$A1000D
HW_Port_1_TxData =				$A1000F
HW_Port_1_RxData =				$A10011
HW_Port_1_SCtrl =				$A10013
HW_Port_2_TxData =				$A10015
HW_Port_2_RxData =				$A10017
HW_Port_2_SCtrl =				$A10019
HW_Expansion_TxData =			$A1001B
HW_Expansion_RxData =			$A1001D
HW_Expansion_SCtrl =			$A1001F

; ---------------------------------------------------------------------------
; SRAM addresses
; ---------------------------------------------------------------------------

SRAM_access_flag =				$A130F1
Security_addr =					$A14000

; ---------------------------------------------------------------------------
; Level Misc
; ---------------------------------------------------------------------------

RingTable_Count:					= 512	; the maximum rings on the level. Even numbers only
ObjectTable_Count:				= 768	; the maximum objects on the level. Even numbers only

; ---------------------------------------------------------------------------
; PLC queues
; ---------------------------------------------------------------------------

PLCKosM_Count:					= 32		; the greater the queues, the more RAM is used for the buffer. Even numbers only

; ---------------------------------------------------------------------------
; Game modes
; ---------------------------------------------------------------------------

offset :=	Game_Modes
ptrsize :=	1
idstart :=	0

id_LevelSelectScreen =				id(ptr_LevelSelect)			; 0
id_LevelScreen =					id(ptr_Level)					; 4

GameModeFlag_TitleCard =		7							; flag bit
GameModeID_TitleCard =			1<<GameModeFlag_TitleCard	; flag mask

; ---------------------------------------------------------------------------
; V-Int routines
; ---------------------------------------------------------------------------

offset :=	VInt_Table
ptrsize :=	1
idstart :=	0

VintID_Lag =						id(ptr_VInt_Lag)			; 0
VintID_Main =					id(ptr_VInt_Main)		; 2
VintID_Sega =					id(ptr_VInt_Sega)			; 4
VintID_Menu =					id(ptr_VInt_Menu)		; 6
VintID_Level =					id(ptr_VInt_Level)		; 8
VintID_Fade =					id(ptr_VInt_Fade)		; A
VintID_LevelSelect =				id(ptr_VInt_LevelSelect)	; C

; ---------------------------------------------------------------------------
; Player routines (Sonic)
; ---------------------------------------------------------------------------

offset :=	Sonic_Index
ptrsize :=	1
idstart :=	0

id_PlayerInit =					id(ptr_Sonic_Init)			; 0
id_PlayerControl =				id(ptr_Sonic_Control)		; 2
id_PlayerHurt =					id(ptr_Sonic_Hurt)		; 4
id_PlayerDeath =					id(ptr_Sonic_Death)		; 6
id_PlayerRestart =				id(ptr_Sonic_Restart)		; 8

id_PlayerDrown =					id(ptr_Sonic_Drown)		; C

; ---------------------------------------------------------------------------
; Levels
; ---------------------------------------------------------------------------

id_DEZ:							equ 0
id_LNull:						equ $FF

; ---------------------------------------------------------------------------
; Buttons bit numbers
; ---------------------------------------------------------------------------

button_up:						equ	0
button_down:					equ	1
button_left:						equ	2
button_right:						equ	3
button_B:						equ	4
button_C:						equ	5
button_A:						equ	6
button_start:						equ	7

; ---------------------------------------------------------------------------
; Buttons masks (1 << x == pow(2, x))
; ---------------------------------------------------------------------------

button_up_mask:					equ	1<<button_up	; $01
button_down_mask:				equ	1<<button_down	; $02
button_left_mask:					equ	1<<button_left	; $04
button_right_mask:				equ	1<<button_right	; $08
button_B_mask:					equ	1<<button_B		; $10
button_C_mask:					equ	1<<button_C		; $20
button_A_mask:					equ	1<<button_A		; $40
button_start_mask:				equ	1<<button_start	; $80

; ---------------------------------------------------------------------------
; Joypad input
; ---------------------------------------------------------------------------

btnABCS:	equ %11110000		; A, B, C or Start ($F0)
btnStart:		equ %10000000		; Start button	($80)
btnABC:		equ %01110000		; A, B or C ($70)
btnAC:		equ %01100000		; A or C ($60)
btnAB:		equ %01010000		; A or B ($50)
btnA:		equ %01000000		; A ($40)
btnBC:		equ %00110000		; B or C ($30)
btnC:		equ %00100000		; C ($20)
btnB:		equ %00010000		; B ($10)
btnDir:		equ %00001111		; Any direction ($0F)
btnDLR:		equ %00001110		; Down, Left or Right ($0E)
btnULR:		equ %00001101		; Up, Left or Right ($0D)
btnLR:		equ %00001100		; Left or Right ($0C)
btnUDR:		equ %00001011		; Up, Down or Right ($0B)
btnDR:		equ %00001010		; Down or Right ($0A)
btnUR:		equ %00001001		; Down or Right ($09)
btnR:		equ %00001000		; Right ($08)
btnUDL:		equ %00000111		; Up, Down or Left ($07)
btnDL:		equ %00000110		; Down or Left ($06)
btnUL:		equ %00000101		; Up or Left ($05)
btnL:		equ %00000100		; Left ($04)
btnUD:		equ %00000011		; Up or Down ($03)
btnDn:		equ %00000010		; Down ($02)
btnUp:		equ %00000001		; Up	($01)

; ---------------------------------------------------------------------------
; Joypad bits
; ---------------------------------------------------------------------------

bitStart:		equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

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
 nextenum	objoff_46,objoff_47,objoff_48,objoff_49

; ---------------------------------------------------------------------------
; property of all objects
; ---------------------------------------------------------------------------

object_size =				$4A					; the size of an object's status table entry
next_object =				object_size

; ---------------------------------------------------------------------------
; Object Status Table offsets
; Universally followed object conventions
; ---------------------------------------------------------------------------

id =						objoff_00			; long
address =				  id					; long
render_flags =			objoff_04			; bitfield ; refer to SCHG for details
height_pixels =			objoff_06			; byte
width_pixels =		 	objoff_07			; byte
priority =		 	 	objoff_08			; word ; in units of $80
art_tile =		 		objoff_0A			; word ; PCCVH AAAAAAAAAAA ; P = priority, CC = palette line, V = y-flip; H = x-flip, A = starting cell index of art
mappings =				objoff_0C			; long
x_pos =					objoff_10			; word, or long when extra precision is required
x_sub =					x_pos+2				; word
y_pos =					objoff_14			; word, or long when extra precision is required
y_sub =					y_pos+2				; word
mapping_frame =			objoff_22			; byte

; ---------------------------------------------------------------------------
; Conventions followed by most objects
; ---------------------------------------------------------------------------

routine =		 	 	    	    5					; byte
x_vel =					objoff_18			; word
y_vel =					objoff_1A			; word
y_radius =				objoff_1E			; byte ; collision height / 2
x_radius =				objoff_1F			; byte ; collision width / 2
anim =					objoff_20			; byte
prev_anim =				objoff_21			; byte ; when this isn't equal to anim the animation restarts
next_anim =				prev_anim			; byte ; when this isn't equal to anim the animation restarts
anim_frame =			objoff_23			; byte
anim_frame_timer =		objoff_24			; byte
angle =					objoff_26			; byte ; angle about axis into plane of the screen (00 = vertical, 360 degrees = 256)
status =					objoff_2A			; bitfield ; refer to SCHG for details

; ---------------------------------------------------------------------------
; Conventions followed by many objects but not Sonic/Tails/Knuckles
; ---------------------------------------------------------------------------

x_pixel =				x_pos				; word ; x-coordinate for objects using screen positioning
y_pixel =					y_pos				; word ; y-coordinate for objects using screen positioning
collision_flags =			objoff_28			; byte ; TT SSSSSS ; TT = collision type, SSSSSS = size
collision_property =		objoff_29			; byte ; usage varies, bosses use it as a hit counter
shield_reaction =			objoff_2B			; byte ; bit 3 = bounces off shield, bit 4 = negated by fire shield, bit 5 = negated by lightning shield, bit 6 = negated by bubble shield
subtype =				objoff_2C			; byte
wait =					objoff_2E			; word
aniraw =					objoff_30			; long
jump =					objoff_34			; long
count =					objoff_39			; byte
ros_bit =					objoff_3B			; byte ; the bit to be cleared when an object is destroyed if the ROS flag is set
ros_addr =				objoff_3C			; word ; the RAM address whose bit to clear when an object is destroyed if the ROS flag is set
routine_secondary =		objoff_3C			; byte ; used by monitors for this purpose at least
vram_art =   				objoff_40			; word ; address of art in VRAM (same as art_tile * $20)
parent =					objoff_42			; word ; address of the object that owns or spawned this one, if applicable
child_dx = 				objoff_42			; byte ; X offset of child relative to parent
child_dy = 				objoff_43			; byte ; Y offset of child relative to parent
parent4 = 				objoff_44			; word
parent3 = 				objoff_46			; word ; parent of child objects
parent2 =				objoff_48			; word ; several objects use this instead
respawn_addr =			objoff_48			; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; Conventions specific to Sonic/Tails/Knuckles
; ---------------------------------------------------------------------------

ground_vel =				objoff_1C			; word ; overall velocity along ground, not updated when in the air
double_jump_property =	objoff_25			; byte ; remaining frames of flight / 2 for Tails, gliding-related for Knuckles
flip_angle =				objoff_27			; byte ; angle about horizontal axis (360 degrees = 256)
status_secondary =		objoff_2B			; byte ; see SCHG for details
air_left =				objoff_2C			; byte
flip_type =				objoff_2D			; byte ; bit 7 set means flipping is inverted, lower bits control flipping type
object_control =			objoff_2E			; byte ; bit 0 set means character can jump out, bit 7 set means he can't
double_jump_flag =		objoff_2F			; byte ; meaning depends on current character, see SCHG for details
flips_remaining =			objoff_30			; byte
flip_speed =				objoff_31				; byte
move_lock =				objoff_32			; word ; horizontal control lock, counts down to 0
invulnerability_timer =	objoff_34			; byte ; decremented every frame
invincibility_timer =		objoff_35			; byte ; decremented every 8 frames
speed_shoes_timer =		objoff_36			; byte ; decremented every 8 frames
status_tertiary =			objoff_37			; byte ; see SCHG for details
character_id =			objoff_38			; byte ; 0 for Sonic, 1 for Tails, 2 for Knuckles
scroll_delay_counter =		objoff_39			; byte ; incremented each frame the character is looking up/down, camera starts scrolling when this reaches 120
next_tilt =				objoff_3A			; byte ; angle on ground in front of character
tilt =					objoff_3B			; byte ; angle on ground
stick_to_convex =			objoff_3C			; byte ; used to make character stick to convex surfaces such as the rotating discs in CNZ
spin_dash_flag =			objoff_3D			; byte ; bit 1 indicates spin dash, bit 7 indicates forced roll
spin_dash_counter =		objoff_3E			; word
restart_timer =			objoff_3E			; word
jumping =				objoff_40			; byte
interact =				objoff_42			; word ; RAM address of the last object the character stood on
default_y_radius =		objoff_44			; byte ; default value of y_radius
default_x_radius =		objoff_45			; byte ; default value of x_radius
top_solid_bit =			objoff_46			; byte ; the bit to check for top solidity (either $C or $E)
lrb_solid_bit =			objoff_47			; byte ; the bit to check for left/right/bottom solidity (either $D or $F)

; ---------------------------------------------------------------------------
; Conventions followed by some/most bosses
; ---------------------------------------------------------------------------

boss_invulnerable_time =	objoff_1C			; byte ; flash time
collision_restore_flags =	objoff_25			; byte ; restore collision after hit
boss_hitcount2 =			objoff_29			; byte ; usage varies, bosses use it as a hit counter

; ---------------------------------------------------------------------------
; Object variables
; ---------------------------------------------------------------------------

obId =					address				; long
obRender =				render_flags			; byte ; bitfield for x/y flip, display mode
obRoutine =				routine				; byte ; routine number
obHeight	 =				height_pixels			; byte ; height/2
obWidth =				width_pixels			; byte ; width/2
obPriority =				priority				; word ; sprite stack priority -- 0 is front
obGfx =					art_tile				; word ; palette line & VRAM setting (2 bytes)
obMap =					mappings			; long ; mappings address (4 bytes)
obX =					x_pos				; word ; x-axis position (2-4 bytes)
obY =					y_pos				; word ; y-axis position (2-4 bytes)
obVelX =					x_vel				; word ; x-axis velocity (2 bytes)
obVelY =					y_vel				; word ; y-axis velocity (2 bytes)
obInertia	 =				ground_vel			; word ; potential speed (2 bytes)
obAnim =				anim				; byte ; current animation
obNextAni =				next_anim			; byte ; next animation
obFrame =				mapping_frame		; byte ; current frame displayed
obAniFrame =			anim_frame			; byte
obTimeFrame =			anim_frame_timer	; byte
obAngle =				angle				; byte
obColType =				collision_flags		; byte ; collision response type
obColProp =				collision_property		; byte ; collision extra property
obStatus =				status				; byte ; orientation or mode
obSubtype =				subtype				; byte ; object subtype
obTimer =				wait					; word ; object timer
obParent =				parent				; word ; parent of child objects
obParent4 =				parent4				; word ; parent of child objects
obParent3 =				parent3				; word ; parent of child objects
obParent2 =				parent2				; word ; parent of child objects
obRespawnNo =			respawn_addr		; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; When childsprites are activated (i.e. bit #6 of render_flags set)
; ---------------------------------------------------------------------------

mainspr_childsprites 		= objoff_16			; word ; amount of child sprites

subspr_data				= objoff_18
sub2_x_pos				= objoff_18
sub2_y_pos				= objoff_1A
sub2_mapframe			= objoff_1D
sub3_x_pos				= objoff_1E
sub3_y_pos				= objoff_20
sub3_mapframe			= objoff_23
sub4_x_pos				= objoff_24
sub4_y_pos				= objoff_26
sub4_mapframe			= objoff_29
sub5_x_pos				= objoff_2A
sub5_y_pos				= objoff_2C
sub5_mapframe			= objoff_2F
sub6_x_pos				= objoff_30
sub6_y_pos				= objoff_32
sub6_mapframe			= objoff_35
sub7_x_pos				= objoff_36
sub7_y_pos				= objoff_38
sub7_mapframe			= objoff_3B
sub8_x_pos				= objoff_3C
sub8_y_pos				= objoff_3E
sub8_mapframe			= objoff_41
sub9_x_pos				= objoff_42
sub9_y_pos				= objoff_44
sub9_mapframe			= objoff_47

next_subspr				= 6					; size

; ---------------------------------------------------------------------------
; Bits 3-6 of an object's status after a SolidObject call is a
; bitfield with the following meaning:
; ---------------------------------------------------------------------------

p1_standing_bit			= 3
p2_standing_bit			= p1_standing_bit + 1
p1_standing				= 1<<p1_standing_bit
p2_standing				= 1<<p2_standing_bit
pushing_bit_delta			= 2
p1_pushing_bit			= p1_standing_bit + pushing_bit_delta
p2_pushing_bit			= p1_pushing_bit + 1
p1_pushing				= 1<<p1_pushing_bit
p2_pushing				= 1<<p2_pushing_bit
standing_mask			= p1_standing|p2_standing
pushing_mask			= p1_pushing|p2_pushing

; ---------------------------------------------------------------------------
; The high word of d6 after a SolidObject call is a bitfield
; with the following meaning:
; ---------------------------------------------------------------------------

p1_touch_side_bit		= 0
p2_touch_side_bit		= p1_touch_side_bit + 1
p1_touch_side			= 1<<p1_touch_side_bit
p2_touch_side			= 1<<p2_touch_side_bit
touch_side_mask			= p1_touch_side|p2_touch_side
p1_touch_bottom_bit		= p1_touch_side_bit + pushing_bit_delta
p2_touch_bottom_bit		= p1_touch_bottom_bit + 1
p1_touch_bottom			= 1<<p1_touch_bottom_bit
p2_touch_bottom			= 1<<p2_touch_bottom_bit
touch_bottom_mask		= p1_touch_bottom|p2_touch_bottom
p1_touch_top_bit			= p1_touch_bottom_bit + pushing_bit_delta
p2_touch_top_bit			= p1_touch_top_bit + 1
p1_touch_top				= 1<<p1_touch_top_bit
p2_touch_top			= 1<<p2_touch_top_bit
touch_top_mask			= p1_touch_top|p2_touch_top

; ---------------------------------------------------------------------------
; Player status variables
; ---------------------------------------------------------------------------

Status_Facing			= 0
Status_InAir				= 1
Status_Roll				= 2
Status_OnObj			= 3
Status_RollJump			= 4
Status_Push				= 5
Status_Underwater		= 6

; ---------------------------------------------------------------------------
; Player status secondary variables
; ---------------------------------------------------------------------------

Status_Shield				= 0
Status_Invincible			= 1
Status_SpeedShoes		= 2

Status_FireShield			= 4
Status_LtngShield			= 5
Status_BublShield			= 6

; ---------------------------------------------------------------------------
; Object Status Variables
; ---------------------------------------------------------------------------

Status_ObjOrienX			= 0
Status_ObjOrienY			= 1
Status_ObjTouch			= 6
Status_ObjDefeated		= 7

; ---------------------------------------------------------------------------
; Universal (used on all standard levels)
; ---------------------------------------------------------------------------

ArtTile_SpikesSprings		= $484
ArtTile_Monitors			= $4AC
ArtTile_StarPost			= $5E4
ArtTile_Sonic				= $680
ArtTile_Ring				= $6BC
ArtTile_Ring_Sparks		= ArtTile_Ring+4
ArtTile_HUD				= $6C4
ArtTile_Shield			= $79C
ArtTile_Shield_Sparks		= ArtTile_Shield+$1F
ArtTile_DashDust			= $7E0

; ---------------------------------------------------------------------------
; VRAM data
; ---------------------------------------------------------------------------

vram_fg:					= $C000 ; foreground namespace
vram_window:			= $C000 ; window namespace
vram_bg:				= $E000 ; background namespace
vram_hscroll:				= $F000 ; horizontal scroll table
vram_sprites:				= $F800 ; sprite table

; ---------------------------------------------------------------------------
; Colours
; ---------------------------------------------------------------------------

cBlack:					equ $000			; colour black
cWhite:					equ $EEE			; colour white
cBlue:					equ $E00			; colour blue
cGreen:					equ $0E0			; colour green
cRed:					equ $00E			; colour red
cYellow:					equ cGreen+cRed		; colour yellow
cAqua:					equ cGreen+cBlue		; colour aqua
cMagenta:				equ cBlue+cRed		; colour magenta

; ---------------------------------------------------------------------------
; Art tile stuff
; ---------------------------------------------------------------------------

flip_x					= (1<<11)
flip_y					= (1<<12)
palette_bit_0				= 5
palette_bit_1				= 6
palette_line0				= (0<<13)
palette_line_0			= (0<<13)
palette_line1				= (1<<13)
palette_line_1			= (1<<13)
palette_line2				= (2<<13)
palette_line_2			= (2<<13)
palette_line3				= (3<<13)
palette_line_3			= (3<<13)
palette_line_size			= 16*2				; 16 word entries
high_priority_bit			= 7
high_priority				= (1<<15)
palette_mask				= $6000
tile_size					= 8*8/2
plane_size_64x32			= 64*32*2
tile_mask				= $7FF
nontile_mask				= $F800
drawing_mask			= $7FFF

; ---------------------------------------------------------------------------
; VRAM and tile art base addresses
; VRAM Reserved regions
; ---------------------------------------------------------------------------

VRAM_Plane_A_Name_Table	= $C000	; Extends until $CFFF
VRAM_Plane_B_Name_Table	= $E000	; Extends until $EFFF
VRAM_Plane_Table_Size		= $1000	; 64 cells x 32 cells x 2 bytes per cell

; ---------------------------------------------------------------------------
; Sprite render screen flags
; ---------------------------------------------------------------------------

rfCoord						= %00000100	; screen coordinates flag ($04)

rfStatic						= %00100000	; static mappings flag ($20)
rfMulti						= %01000000	; multi-draw flag ($40)
rfOnscreen					= %10000000	; on-screen flag ($80)

; ---------------------------------------------------------------------------
; Sprite render screen bits
; ---------------------------------------------------------------------------

rbCoord						= 2		; screen coordinates bit

rbStatic						= 5		; static mappings bit
rbMulti						= 6		; multi-draw bit
rbOnscreen					= 7		; on-screen bit

; ---------------------------------------------------------------------------
; Animation flags
; ---------------------------------------------------------------------------

afEnd						= $FF	; return to beginning of animation
afBack						= $FE	; go back (specified number) bytes
afChange						= $FD	; run specified animation
afRoutine					= $FC	; increment routine counter and continue load next anim bytes
afReset						= $FB	; move offscreen for remove(Using the Sprite_OnScreen_Test, etc...)

; ---------------------------------------------------------------------------
; Animation Raw flags
; ---------------------------------------------------------------------------

arfIndex						= $FF	; go to animate raw index
arfEnd						= $FE	; return to beginning of animation
arfBack						= $FC	; go back (specified number) bytes
arfJump						= $FA	; jump from objoff_34(a0) address
