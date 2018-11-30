SMPS_z80_ram =		$A00000

SMPS_HW_Port_1_Data =	$A10003

SMPS_z80_bus_request =	$A11100
SMPS_z80_reset =	$A11200

SMPS_ym2612_a0 =	$A04000
SMPS_ym2612_d0 =	$A04001
SMPS_ym2612_a1 =	$A04002
SMPS_ym2612_d1 =	$A04003

    if SMPS_EnablePWM
SMPS_pwm_comm =		$A15128
    endif

SMPS_psg_input =	$C00011

SMPS_MUSIC_TRACK_COUNT = ((SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/SMPS_Track.len)
SMPS_MUSIC_FM_DAC_TRACK_COUNT = ((SMPS_RAM.v_music_fmdac_tracks_end-SMPS_RAM.v_music_fmdac_tracks)/SMPS_Track.len)
SMPS_MUSIC_FM_TRACK_COUNT = ((SMPS_RAM.v_music_fm_tracks_end-SMPS_RAM.v_music_fm_tracks)/SMPS_Track.len)
SMPS_MUSIC_PSG_TRACK_COUNT = ((SMPS_RAM.v_music_psg_tracks_end-SMPS_RAM.v_music_psg_tracks)/SMPS_Track.len)
    if SMPS_EnablePWM
SMPS_MUSIC_PWM_TRACK_COUNT = ((SMPS_RAM.v_music_pwm_tracks_end-SMPS_RAM.v_music_pwm_tracks)/SMPS_Track.len)
    endif

SMPS_SFX_TRACK_COUNT = ((SMPS_RAM.v_sfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len)
SMPS_SFX_FM_TRACK_COUNT = ((SMPS_RAM.v_sfx_fm_tracks_end-SMPS_RAM.v_sfx_fm_tracks)/SMPS_Track.len)
SMPS_SFX_PSG_TRACK_COUNT = ((SMPS_RAM.v_sfx_psg_tracks_end-SMPS_RAM.v_sfx_psg_tracks)/SMPS_Track.len)

SMPS_SPECIAL_SFX_TRACK_COUNT = ((SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_spcsfx_track_ram)/SMPS_Track.len)
SMPS_SPECIAL_SFX_FM_TRACK_COUNT = ((SMPS_RAM.v_spcsfx_fm_tracks_end-SMPS_RAM.v_spcsfx_fm_tracks)/SMPS_Track.len)
SMPS_SPECIAL_SFX_PSG_TRACK_COUNT = ((SMPS_RAM.v_spcsfx_psg_tracks_end-SMPS_RAM.v_spcsfx_psg_tracks)/SMPS_Track.len)
