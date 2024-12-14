# SONIC-CLEAN-ENGINE-S.C.E.-

## Disclaimer

Cleaned up and optimized the source code of Sonic 3 & Knuckles. Free use. You use it at your own risk. All code is provided “as is”. This source code uses software from other authors. Check their licenses before using it. You assume any and all responsibility for using this content responsibly. I claims no responsibility or warranty.

## Additional links

#### Main source code:

- [Sonic-Clean-Engine-S.C.E.-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-)

#### Extended source code:

- [Sonic-Clean-Engine-S.C.E.-Extended-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-Extended-)

#### Sonic 1 in Sonic 3 & Knuckles (S.C.E. Version):

- [Sonic-1-in-Sonic-3-S.C.E.-](https://github.com/TheBlad768/Sonic-1-in-Sonic-3-S.C.E.-)

## Quick start

- For editing sprites you can use [SonMapEd](https://info.sonicretro.org/SonMapEd), [ClownMapEd](https://info.sonicretro.org/ClownMapEd) or [Flex2](https://info.sonicretro.org/Flex_2) (Read the issues).

- For editing levels you can use official [SonLVL](https://info.sonicretro.org/SonLVL) or [SonLVL-64x64-Compatible](https://github.com/Project1114/SonLVL-64x64-Compatible). Unfortunately, [SonED2](https://info.sonicretro.org/SonED2) is no longer supported.

- To convert SMPS music to asm format you can use [smps2asm](https://forums.sonicretro.org/index.php?threads/smps2asm-and-improved-s-k-driver.26876).

## Current issues

1. S.C.E. uses [Kosinski Plus algorithm](https://github.com/flamewing/mdcomp/blob/master/src/asm/KosinskiPlus.asm), but **Flex2** program does not support **Kosinski Plus Module**. Therefore, **Flex2.json** project file is partially useless. **SonMapEd** program does not support **Kosinski Plus** at all. You can only open uncompressed graphics.

#### Alternative programs:
- [mdcomp](https://github.com/flamewing/mdcomp/releases)
- [ClownMapEd](https://github.com/Clownacy/ClownMapEd/releases)
- [FW-KENSC-ShellExt](https://github.com/MainMemory/FW-KENSC-ShellExt/releases)

## FAQ

- If you want to convert levels from previous Sonic games, you have to use [LevelConverter](https://info.sonicretro.org/LevelConverter) from [SonLVL](https://info.sonicretro.org/SonLVL). Then change the layout format using [Layout converter](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Levels/_tools/Layout).

- If you want to make a different text for Title Card, you need to create a file of letters from [List.unc](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Objects/Title%20Card/KosinskiPM%20Art/Levels). This will be loaded before the level starts.
You don't have to add the letters **'ENOZ' (ZONE)** because those letters are already in VRAM. Then you have to create a mapping of your zone name in [Map - Title Card.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Objects/Title%20Card/Object%20Data).

- If you want to use other SMPS music you can use [Valley Bell's SMPS Research](https://forums.sonicretro.org/index.php?threads/valley-bells-smps-research.32473) or [vgm2smps](https://github.com/Ivan-YO/vgm2smps/releases).

## Special Credits

- pixelcat — New smooth ring graphics, act 3 and 4 numbers graphics.
- FoxConED — Level Select font graphics.
- Dolphman — Robotnik Head graphics.

## Discord

- [redmisostudios](https://discords.com/servers/redmisostudios)

## These projects are based on this source code

- Sonic 3 Rebuilt by TomatoWave_0
- [Sonic The Hedgehog in Hellfire Saga](https://github.com/TheBlad768/Hellfire-Saga-Public-Source)
- Sonic 3 & Knuckles: Epilogue
- TishaProject (2019)
- Sonic Virtual Adventure (2017) (Cancelled) — In the past I made this source code specifically for this project (:

## Check out the Sonic Retro source code

- [s1disasm](https://github.com/sonicretro/s1disasm)
- [s2disasm](https://github.com/sonicretro/s2disasm)
- [skdisasm](https://github.com/sonicretro/skdisasm)
