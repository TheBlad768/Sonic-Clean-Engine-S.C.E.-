; ===========================================================================
; Constants
; ===========================================================================

Ref_Checksum_String				= 'INIT'

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

RingTable_Count:					= 512	; The maximum rings on the level. Even addresses only
ObjectTable_Count:				= 768	; The maximum objects on the level. Even addresses only

; ---------------------------------------------------------------------------
; PLC queues
; ---------------------------------------------------------------------------

PLCKosM_Count:					= 32		; The greater the queues, the more RAM is used for the buffer

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

; ---------------------------------------------------------------------------
; Sonic routines
; ---------------------------------------------------------------------------

offset :=	Sonic_Index
ptrsize :=	1
idstart :=	0

id_SonicInit =					id(ptr_Sonic_Init)			; 0
id_SonicControl =					id(ptr_Sonic_Control)		; 2
id_SonicHurt =					id(ptr_Sonic_Hurt)		; 4
id_SonicDeath =					id(ptr_Sonic_Death)		; 6
id_SonicRestart =					id(ptr_Sonic_Restart)		; 8

id_SonicDrown =					id(ptr_Sonic_Drown)		; C

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

btnR:		equ %00001000		; Right ($08)
btnL:		equ %00000100		; Left ($04)
btnUD:		equ %00000011		; Up or Down ($03)
btnDn:		equ %00000010		; Down ($02)
btnUp:		equ %00000001		; Up	($01)
btnLR:		equ %00001100		; Left or Right ($0C)
btnDir:		equ %00001111		; Any direction ($0F)
btnABCS:	equ %11110000		; A, B, C or Start ($F0)
btnStart:		equ %10000000		; Start button	($80)
btnABC:		equ %01110000		; A, B or C ($70)
btnAC:		equ %01100000		; A or C ($60)
btnAB:		equ %01010000		; A or B ($50)
btnA:		equ %01000000		; A ($40)
btnBC:		equ %00110000		; B or C ($30)
btnC:		equ %00100000		; C ($20)
btnB:		equ %00010000		; B ($10)

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
; property of all objects
; ---------------------------------------------------------------------------

object_size =				$4A	; the size of an object's status table entry
next_object =				object_size

; ---------------------------------------------------------------------------
; Object Status Table offsets
; Universally followed object conventions:
; ---------------------------------------------------------------------------

id =						  0 ; long
address =				  id ; long
render_flags =		 	  4 ; bitfield ; refer to SCHG for details
height_pixels =			  6 ; byte
width_pixels =		 	  7 ; byte
priority =		 	 	  8 ; word ; in units of $80
art_tile =		 		$A ; word ; PCCVH AAAAAAAAAAA ; P = priority, CC = palette line, V = y-flip; H = x-flip, A = starting cell index of art
mappings =				$C ; long
x_pos =					$10 ; word, or long when extra precision is required
x_sub =					x_pos+2 ; word
y_pos =					$14 ; word, or long when extra precision is required
y_sub =					y_pos+2 ; word
mapping_frame =			$22 ; byte

; ---------------------------------------------------------------------------
; Conventions followed by most objects:
; ---------------------------------------------------------------------------

routine =		 	 	    	    5 ; byte
x_vel =					$18 ; word
y_vel =					$1A ; word
y_radius =				$1E ; byte ; collision height / 2
x_radius =				$1F ; byte ; collision width / 2
anim =					$20 ; byte
next_anim =				$21 ; byte ; when this isn't equal to anim the animation restarts
prev_anim =				$21 ; byte ; when this isn't equal to anim the animation restarts
anim_frame =			$23 ; byte
anim_frame_timer =		$24 ; byte
angle =					$26 ; byte ; angle about axis into plane of the screen (00 = vertical, 360 degrees = 256)
status =					$2A ; bitfield ; refer to SCHG for details

; ---------------------------------------------------------------------------
; Conventions followed by many objects but not Sonic/Tails/Knuckles:
; ---------------------------------------------------------------------------

x_pixel =				x_pos ; word ; x-coordinate for objects using screen positioning
y_pixel =					y_pos ; word ; y-coordinate for objects using screen positioning
collision_flags =			$28 ; byte ; TT SSSSSS ; TT = collision type, SSSSSS = size
collision_property =		$29 ; byte ; usage varies, bosses use it as a hit counter
shield_reaction =			$2B ; byte ; bit 3 = bounces off shield, bit 4 = negated by fire shield, bit 5 = negated by lightning shield, bit 6 = negated by bubble shield
subtype =				$2C ; byte
wait =					$2E ; word
aniraw =					$30 ; long
jump =					$34 ; long
count =					$39 ; byte
ros_bit =					$3B ; byte ; the bit to be cleared when an object is destroyed if the ROS flag is set
ros_addr =				$3C ; word ; the RAM address whose bit to clear when an object is destroyed if the ROS flag is set
routine_secondary =		$3C ; byte ; used by monitors for this purpose at least
vram_art =   				$40 ; word ; address of art in VRAM (same as art_tile * $20)
parent =					$42 ; word ; address of the object that owns or spawned this one, if applicable
child_dx = 				$42 ; byte ; X offset of child relative to parent
child_dy = 				$43 ; byte ; Y offset of child relative to parent
parent4 = 				$44 ; word
parent3 = 				$46 ; word ; parent of child objects
parent2 =				$48 ; word ; several objects use this instead
respawn_addr =			$48 ; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; Conventions specific to Sonic/Tails/Knuckles:
; ---------------------------------------------------------------------------

ground_vel =				$1C ; word ; overall velocity along ground, not updated when in the air
double_jump_property =	$25 ; byte ; remaining frames of flight / 2 for Tails, gliding-related for Knuckles
flip_angle =				$27 ; byte ; angle about horizontal axis (360 degrees = 256)
status_secondary =		$2B ; byte ; see SCHG for details
air_left =				$2C ; byte
flip_type =				$2D ; byte ; bit 7 set means flipping is inverted, lower bits control flipping type
object_control =			$2E ; byte ; bit 0 set means character can jump out, bit 7 set means he can't
double_jump_flag =		$2F ; byte ; meaning depends on current character, see SCHG for details
flips_remaining =			$30 ; byte
flip_speed =				$31 ; byte
move_lock =				$32 ; word ; horizontal control lock, counts down to 0
invulnerability_timer =	$34 ; byte ; decremented every frame
invincibility_timer =		$35 ; byte ; decremented every 8 frames
speed_shoes_timer =		$36 ; byte ; decremented every 8 frames
status_tertiary =			$37 ; byte ; see SCHG for details
character_id =			$38 ; byte ; 0 for Sonic, 1 for Tails, 2 for Knuckles
scroll_delay_counter =		$39 ; byte ; incremented each frame the character is looking up/down, camera starts scrolling when this reaches 120
next_tilt =				$3A ; byte ; angle on ground in front of character
tilt =					$3B ; byte ; angle on ground
stick_to_convex =			$3C ; byte ; used to make character stick to convex surfaces such as the rotating discs in CNZ
spin_dash_flag =			$3D ; byte ; bit 1 indicates spin dash, bit 7 indicates forced roll
spin_dash_counter =		$3E ; word
restart_timer =			$3E ; word
jumping =				$40 ; byte
interact =				$42 ; word ; RAM address of the last object the character stood on
default_y_radius =		$44 ; byte ; default value of y_radius
default_x_radius =		$45 ; byte ; default value of x_radius
top_solid_bit =			$46 ; byte ; the bit to check for top solidity (either $C or $E)
lrb_solid_bit =			$47 ; byte ; the bit to check for left/right/bottom solidity (either $D or $F)

; ---------------------------------------------------------------------------
; Conventions followed by some/most bosses:
; ---------------------------------------------------------------------------

boss_invulnerable_time =	$1C ; byte ; flash time
collision_restore_flags =	$25 ; byte ; restore collision after hit
boss_hitcount2 =			$29 ; byte ; usage varies, bosses use it as a hit counter

; ---------------------------------------------------------------------------
; Object variables
; ---------------------------------------------------------------------------

obId =					0
obRender =				4	; bitfield for x/y flip, display mode
obRoutine =				5	; routine number
obHeight	 =				6	; height/2
obWidth =				7	; width/2
obPriority =				8	; word ; sprite stack priority -- 0 is front
obGfx =					$A	; palette line & VRAM setting (2 bytes)
obMap =					$C	; mappings address (4 bytes)
obX =					$10	; x-axis position (2-4 bytes)
obY =					$14	; y-axis position (2-4 bytes)
obVelX =					$18	; x-axis velocity (2 bytes)
obVelY =					$1A	; y-axis velocity (2 bytes)
obInertia	 =				$1C	; potential speed (2 bytes)
obAnim =				$20	; current animation
obNextAni =				$21	; next animation
obFrame =				$22	; current frame displayed
obAniFrame =			$23 ; byte
obTimeFrame =			$24 ; byte
obAngle =				$26	; angle
obColType =				$28	; collision response type
obColProp =				$29	; collision extra property
obStatus =				$2A	; orientation or mode
obSubtype =				$2C	; object subtype
obTimer =				$2E	; object timer
obParent =				$42 	; word ; parent of child objects
obParent4 =				$44 	; word ; parent of child objects
obParent3 =				$46 	; word ; parent of child objects
obParent2 =				$48 	; word ; parent of child objects
obRespawnNo =			$48 ; word ; the address of this object's entry in the respawn table

; ---------------------------------------------------------------------------
; When childsprites are activated (i.e. bit #6 of render_flags set)
; ---------------------------------------------------------------------------

mainspr_childsprites 		= $16	; word ; amount of child sprites

sub2_x_pos				= $18
sub2_y_pos				= $1A
sub2_mapframe			= $1D
sub3_x_pos				= $1E
sub3_y_pos				= $20
sub3_mapframe			= $23
sub4_x_pos				= $24
sub4_y_pos				= $26
sub4_mapframe			= $29
sub5_x_pos				= $2A
sub5_y_pos				= $2C
sub5_mapframe			= $2F
sub6_x_pos				= $30
sub6_y_pos				= $32
sub6_mapframe			= $35
sub7_x_pos				= $36
sub7_y_pos				= $38
sub7_mapframe			= $3B
sub8_x_pos				= $3C
sub8_y_pos				= $3E
sub8_mapframe			= $41
sub9_x_pos				= $42
sub9_y_pos				= $44
sub9_mapframe			= $47

next_subspr				= 6		; size

; ---------------------------------------------------------------------------
; Unknown or inconsistently used offsets that are not applicable to Sonic:
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
ArtTile_DashDust			= $7F0

; ---------------------------------------------------------------------------
; VRAM data
; ---------------------------------------------------------------------------

vram_fg:					= $C000 ; foreground namespace
vram_window:			= $C000 ; window namespace
vram_bg:				= $E000 ; background namespace
vram_sprites:				= $D400 ; sprite table
vram_hscroll:				= $F000 ; horizontal scroll table

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

palette_line_size			= 16*2				; 16 word entries

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
high_priority_bit			= 7
high_priority				= (1<<15)
palette_mask				= $6000
tile_size					= $20
tile_mask				= $7FF
nontile_mask				= $F800
drawing_mask			= $7FFF

; ---------------------------------------------------------------------------
; VRAM and tile art base addresses.
; VRAM Reserved regions.
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

arfEnd						= $FC	; return to beginning of animation
arfBack						= $F8	; go back (specified number) bytes
arfJump						= $F4	; jump from $34(a0) address
