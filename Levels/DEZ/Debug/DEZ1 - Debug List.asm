; ---------------------------------------------------------------------------
; DEZ debug mode item lists
; ---------------------------------------------------------------------------

				; object, mappings, subtype, frame, VRAM, palette, priority
Debug_DEZ1: dbglistheader
	dbglistobj Obj_Ring, Map_Ring, 0, 0, ArtTile_Ring, 1, TRUE
	dbglistobj Obj_Monitor, Map_Monitor, 2, 3, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 3, 4, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 4, 5, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 5, 6, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 6, 7, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 7, 8, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_Monitor, Map_Monitor, 8, 9, ArtTile_Monitors, 0, FALSE
	dbglistobj Obj_PathSwap, Map_PathSwap, 9, 1, ArtTile_Ring, 1, FALSE
	dbglistobj Obj_PathSwap, Map_PathSwap, $D, 5, ArtTile_Ring, 1, FALSE
	dbglistobj Obj_Spring, Map_Spring, 1, 0, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring, $81, 0, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, 2, 0, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, $82, 0, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring, $10, 3, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring, $90, 3, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, $12, 3, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, $92, 3, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring, $20, 6, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring, $A0, 6, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, $22, 6, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spring, Map_Spring2, $A2, 6, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spikes, Map_Spikes, 0, 0, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spikes, Map_Spikes, $40, 4, ArtTile_SpikesSprings, 0, FALSE
	dbglistobj Obj_Spikebonker, Map_Spikebonker, $40, 0, $500, 0, TRUE
	dbglistobj Obj_Animal, Map_Animals1, 0, 2, $592, 0, FALSE
	dbglistobj Obj_Button,	Map_Button, 0, 2, $47E, 0, FALSE
	dbglistobj Obj_StarPost, Map_StarPost, 1, 0, ArtTile_StarPost, 0, FALSE
	dbglistobj Obj_EggCapsule, Map_EggCapsule, 1, 0, $43E, 0, FALSE
	dbglistobj Obj_EggCapsule_Flying, Map_EggCapsule, 1, 0, $43E, 0, FALSE
	dbglistend
