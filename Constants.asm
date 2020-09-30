; ===========================================================================
; Constants
; ===========================================================================

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

PLCNem_Count:					= 32		; The larger the queues, the more RAM is used for the buffer
PLCKosM_Count:					= 32

; ---------------------------------------------------------------------------
; function using these variables
id function ptr,((ptr-offset)/ptrsize+idstart)

; ---------------------------------------------------------------------------
; Game modes
; ---------------------------------------------------------------------------

offset :=	GameModes
ptrsize :=	1
idstart :=	0

id_LevelSelect =					id(ptr_GM_LevelSelect)		; 0
id_Level =						id(ptr_GM_Level)				; 4

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
VintID_Title =					id(ptr_VInt_Title)			; 6
VintID_Menu =					id(ptr_VInt_Menu)		; 8
VintID_Level =					id(ptr_VInt_Level)		; A
VintID_TitleCard =				id(ptr_VInt_TitleCard)		; C
VintID_Fade =					id(ptr_VInt_Fade)		; E

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
; Buttons masks
; ---------------------------------------------------------------------------

JoyUp:							equ	1
JoyDown:						equ	2
JoyUpDown:						equ	3
JoyLeft:							equ	4
JoyRight:						equ	8
JoyLeftRight:						equ	$C
JoyCursor:						equ	$F
JoyB:							equ	$10
JoyC:							equ	$20
JoyA:							equ	$40
JoyAB:							equ	$50
JoyAC:							equ	$60
JoyABC:							equ	$70
JoyStart:							equ	$80
JoyBStart:						equ	$90
JoyABCS:						equ	$F0
; ---------------------------------------------------------------------------
; Buttons masks (1 << x == pow(2, x))
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
btnStart:		equ %10000000		; Start button	($80)
btnA:		equ %01000000		; A ($40)
btnC:		equ %00100000		; C ($20)
btnB:		equ %00010000		; B ($10)
btnR:		equ %00001000		; Right ($08)
btnL:		equ %00000100		; Left ($04)
btnDn:		equ %00000010		; Down ($02)
btnUp:		equ %00000001		; Up	($01)
btnDir:		equ %00001111		; Any direction ($0F)
btnABC:		equ %01110000		; A, B or C ($70)
bitStart:		equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0
; ---------------------------------------------------------------------------
; property of all objects:
object_size =				$4A	; the size of an object's status table entry
next_object =				object_size
; ---------------------------------------------------------------------------
; Object struct
; ---------------------------------------------------------------------------
	phase 0 ; pretend we're at address 0
id:								; long ; object ID
obId:							; long ; object ID
address:					ds.l 1	; long ; object ID
obRender:						; byte(bitfield) ; refer to SCHG for details
render_flags:				ds.b 1	; byte(bitfield) ; refer to SCHG for details
routine:							; byte
obRoutine:				ds.b 1	; byte
obHeight:						; byte
height_pixels:			ds.b 1	; byte
obWidth:						; byte
width_pixels:				ds.b 1	; byte
priority:							; word ; in units of $80
obPriority:				ds.w 1	; word ; in units of $80
obGfx:							; word ; PCCVH AAAAAAAAAAA ; P = priority, CC = palette line, V = y-flip; H = x-flip, A = starting cell index of art
art_tile:					ds.w 1	; word ; PCCVH AAAAAAAAAAA ; P = priority, CC = palette line, V = y-flip; H = x-flip, A = starting cell index of art
obMap:							; long
mappings:				ds.l 1	; long

obX:							; word, or long when extra precision is required
x_pos:							; word, or long when extra precision is required
x_pixel:					ds.w 1	; word ; x-coordinate for objects using screen positioning
x_sub:					ds.w 1	; word
obY:								; word, or long when extra precision is required
y_pos:							; word, or long when extra precision is required
y_pixel:					ds.w 1	; word ; y-coordinate for objects using screen positioning
y_sub:					ds.w 1	; word
x_vel:							; word ; horizontal velocity
obVelX:					ds.w 1	; word ; horizontal velocity
y_vel:							; word ; vertical velocity
obVelY:					ds.w 1	; word ; vertical velocity

obInertia:						; word ; used by sonic
ground_vel:						; word ; used by sonic
boss_invulnerable_time:	ds.w 1	; byte

y_radius:				ds.b 1	; byte ; collision height / 2
x_radius:				ds.b 1	; byte ; collision width / 2

anim:							; byte
obAnim:					ds.b 1	; byte
obNextAni:						; byte ; when this isn't equal to anim the animation restarts
next_anim:						; byte ; when this isn't equal to anim the animation restarts
prev_anim:				ds.b 1	; byte ; when this isn't equal to anim the animation restarts
obFrame:						; byte
mapping_frame:			ds.b 1	; byte
anim_frame:				ds.b 1	; byte
anim_frame_timer:		ds.b 1	; byte

collision_restore_flags:				; byte ; restore collision after hit (maybe it's used only bosses)
double_jump_property:	ds.b 1	; byte ; used by sonic ; remaining frames of flight / 2 for Tails, gliding-related for Knuckles

angle:							; byte, or word ; angle about axis into plane of the screen (00 = vertical, 360 degrees = 256)
obAngle:					ds.b 1	; byte, or word ; angle about axis into plane of the screen (00 = vertical, 360 degrees = 256)
flip_angle:				ds.b 1	; byte ; used by sonic
obColType:						; byte ; TT SSSSSS ; TT = collision type, SSSSSS = size
collision_flags:			ds.b 1	; byte ; TT SSSSSS ; TT = collision type, SSSSSS = size
obColProp:						; byte ; usage varies, bosses use it as a hit counter
boss_hitcount2:					; byte ; usage varies, bosses use it as a hit counter
collision_property:		ds.b 1	; byte ; usage varies, bosses use it as a hit counter
status:							; byte(bitfield) ; refer to SCHG for details
obStatus:				ds.b 1	; byte(bitfield) ; refer to SCHG for details
shield_reaction:					; byte ; bit 3 = bounces off shield, bit 4 = negated by fire shield, bit 5 = negated by lightning shield, bit 6 = negated by bubble shield
status_secondary:			ds.b 1	; byte ; used by sonic
subtype:							; byte, or word
obSubtype:						; byte, or word
air_left:					ds.b 1	; byte ; used by sonic
flip_type:				ds.b 1	; byte ; used by sonic
obTimer:							; word
object_control:			ds.b 1	; byte ; used by sonic
double_jump_flag:		ds.b 1	; byte ; used by sonic
flips_remaining:			ds.b 1	; byte ; used by sonic
flip_speed:				ds.b 1	; byte ; used by sonic
move_lock:				ds.w 1	; word ; used by sonic
invulnerability_timer:		ds.b 1	; byte ; used by sonic
invincibility_timer:		ds.b 1	; byte ; used by sonic
speed_shoes_timer:		ds.b 1	; byte ; used by sonic
status_tertiary:			ds.b 1	; byte ; used by sonic
character_id:				ds.b 1	; byte ; used by sonic
scroll_delay_counter:		ds.b 1	; byte ; used by sonic
next_tilt:				ds.b 1	; byte ; used by sonic
tilt:								; byte ; used by sonic
ros_bit:					ds.b 1	; byte ; the bit to be cleared when an object is destroyed if the ROS flag is set
ros_addr:						; word ; the RAM address whose bit to clear when an object is destroyed if the ROS flag is set
stick_to_convex:					; byte ; used by sonic
routine_secondary:		ds.b 1	; byte ; used by monitors for this purpose at least
spin_dash_flag:			ds.b 1	; byte ; used by sonic
spin_dash_counter:		ds.w 1	; word ; used by sonic
jumping:							; byte ; used by sonic
vram_art:				ds.w 1	; word ; address of art in VRAM (same as art_tile * $20)
interact:							; word ; used by sonic
parent:							; word
obParent:						; word
child_dx:				ds.b 1	; byte
child_dy:				ds.b 1	; byte
default_y_radius:			ds.b 1	; byte ; used by sonic
default_x_radius:			ds.b 1	; byte ; used by sonic
parent3:							; word ; parent of child objects
obParent3:						; word ; parent of child objects
top_solid_bit:			ds.b 1	; byte ; used by sonic
lrb_solid_bit:				ds.b 1	; byte ; used by sonic
parent2:							; several objects use this instead
obParent2:						; word ; several objects use this instead
respawn_addr:			ds.w 1	; word ; the address of this object's entry in the respawn table
	if * > object_size
		fatal "The size should be $\{object_size} bytes, but it has size $\{*} bytes."
	endif
    if MOMPASS=1
	message "The objects RAM size is $\{*-1} bytes."
    endif

	dephase		; Stop pretending
	!org	0		; Reset the program counter
; ---------------------------------------------------------------------------
; when childsprites are activated (i.e. bit #6 of render_flags set)
mainspr_childsprites 		= $16	; amount of child sprites
sub2_x_pos				= $18	; x_vel
sub2_y_pos				= $1A	; y_vel
sub2_mapframe			= $1D
sub3_x_pos				= $1E	; y_radius
sub3_y_pos				= $20	; anim
sub3_mapframe			= $23	; anim_frame
sub4_x_pos				= $24	; anim_frame_timer
sub4_y_pos				= $26	; angle
sub4_mapframe			= $29	; collision_property
sub5_x_pos				= $2A	; status
sub5_y_pos				= $2C	; subtype
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
next_subspr				= $6
; ---------------------------------------------------------------------------
; unknown or inconsistently used offsets that are not applicable to sonic/tails:
objoff_12 =				2+x_pos
objoff_16 =				2+y_pos
objoff_1C =				$1C
objoff_1D =				$1D
objoff_27 =				$27
objoff_2B =				$2B
objoff_2C =				$2C
objoff_2D =				$2D
objoff_2E =				$2E
objoff_2F =				$2F
objoff_30 =				$30
 enum	objoff_31=$31,objoff_32=$32,objoff_33=$33,objoff_34=$34,objoff_35=$35,objoff_36=$36,objoff_37=$37
 enum	objoff_38=$38,objoff_39=$39,objoff_3A=$3A,objoff_3B=$3B,objoff_3C=$3C,objoff_3D=$3D,objoff_3E=$3E
 enum	objoff_3F=$3F,objoff_40=$40,objoff_41=$41,objoff_42=$42,objoff_43=$43,objoff_44=$44,objoff_45=$45
 enum	objoff_46=$46,objoff_47=$47,objoff_48=$48,objoff_49=$49
; ---------------------------------------------------------------------------
; Bits 3-6 of an object's status after a SolidObject call is a
; bitfield with the following meaning:
p1_standing_bit				= 3
p2_standing_bit				= p1_standing_bit + 1
p1_standing					= 1<<p1_standing_bit
p2_standing					= 1<<p2_standing_bit
pushing_bit_delta				= 2
p1_pushing_bit				= p1_standing_bit + pushing_bit_delta
p2_pushing_bit				= p1_pushing_bit + 1
p1_pushing					= 1<<p1_pushing_bit
p2_pushing					= 1<<p2_pushing_bit
standing_mask				= p1_standing|p2_standing
pushing_mask				= p1_pushing|p2_pushing
; ---------------------------------------------------------------------------
; The high word of d6 after a SolidObject call is a bitfield
; with the following meaning:
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
; Player Status Variables
Status_Facing				= 0
Status_InAir					= 1
Status_Roll					= 2
Status_OnObj				= 3
Status_RollJump				= 4
Status_Push					= 5
Status_Underwater			= 6
; ---------------------------------------------------------------------------
; Player status_secondary variables
Status_Shield					= 0
Status_Invincible				= 1
Status_SpeedShoes			= 2

Status_FireShield				= 4
Status_LtngShield				= 5
Status_BublShield				= 6
; ---------------------------------------------------------------------------
; Object Status Variables
Status_ObjOrienX				= 0
Status_ObjOrienY				= 1
Status_ObjHurt				= 6
Status_ObjDefeated			= 7
; ---------------------------------------------------------------------------
; Universal (used on all standard levels).
ArtTile_ArtUnc_Sonic			= $680
ArtTile_ArtNem_Ring			= $6B4
ArtTile_ArtNem_Powerups		= $4AC
ArtTile_ArtUnc_Shield			= $79C
ArtTile_ArtUnc_Shield_Sparks	= $7BB
; ---------------------------------------------------------------------------
; VRAM data
vram_fg:				= $C000 ; foreground namespace
vram_window:		= $C000 ; window namespace
vram_bg:			= $E000 ; background namespace
vram_sprites:			= $D400 ; sprite table
vram_hscroll:			= $F000 ; horizontal scroll table
; ---------------------------------------------------------------------------
; Colours
cBlack:				equ $000			; colour black
cWhite:				equ $EEE			; colour white
cBlue:				equ $E00			; colour blue
cGreen:				equ $0E0			; colour green
cRed:				equ $00E			; colour red
cYellow:				equ cGreen+cRed		; colour yellow
cAqua:				equ cGreen+cBlue		; colour aqua
cMagenta:			equ cBlue+cRed		; colour magenta
; ---------------------------------------------------------------------------
; Art tile stuff
palette_line0			= (0<<13)
palette_line_0		= (0<<13)
palette_line1			= (1<<13)
palette_line_1		= (1<<13)
palette_line2			= (2<<13)
palette_line_2		= (2<<13)
palette_line3			= (3<<13)
palette_line_3		= (3<<13)
high_priority			= (1<<15)
tile_mask			= $7FF
drawing_mask		= $7FFF
; ---------------------------------------------------------------------------
; VRAM and tile art base addresses.
; VRAM Reserved regions.
VRAM_Plane_A_Name_Table	= $C000	; Extends until $CFFF
VRAM_Plane_B_Name_Table	= $E000	; Extends until $EFFF
; ---------------------------------------------------------------------------
; Animation flags
afEnd:						= $FF	; return to beginning of animation
afBack:						= $FE	; go back (specified number) bytes
afChange:					= $FD	; run specified animation
afRoutine:					= $FC	; increment routine counter
afReset:						= $FB	; reset animation and 2nd object routine counter