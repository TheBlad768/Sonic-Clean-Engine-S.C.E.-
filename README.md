# SONIC-CLEAN-ENGINE-S.C.E.-

## Disclaimer

Cleaned up and slightly optimized the source code of Sonic 3 & Knuckles. Free use. You use it at your own risk. All code is provided “as is”. This source code uses software from other authors. Check their licenses before using it. You assume any and all responsibility for using this content responsibly. I claims no responsibility or warranty.

## Additional links

#### Main source code:

- [Sonic-Clean-Engine-S.C.E.-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-)

#### Extended source code:

- [Sonic-Clean-Engine-S.C.E.-Extended-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-Extended-)

## Quick start

- For editing sprites you can use [SonMapEd](https://info.sonicretro.org/SonMapEd), [ClownMapEd](https://info.sonicretro.org/ClownMapEd) or [Flex2](https://info.sonicretro.org/Flex_2) (Read the issues).

- For editing levels you can use official [SonLVL](https://info.sonicretro.org/SonLVL) or [SonLVL-64x64-Compatible](https://github.com/Project1114/SonLVL-64x64-Compatible). Unfortunately, [SonED2](https://info.sonicretro.org/SonED2) is no longer supported.

## Current issues

1. S.C.E. uses [Kosinski Plus algorithm](https://github.com/flamewing/mdcomp/blob/master/src/asm/KosinskiPlus.asm), but **Flex2** program does not support **Kosinski Plus Module**. Therefore, **Flex2.json** project file is partially useless. **SonMapEd** program does not support **Kosinski Plus** at all. You can only open uncompressed graphics.

#### Alternative programs:
- [mdcomp](https://github.com/flamewing/mdcomp/releases)
- [ClownMapEd](https://github.com/Clownacy/ClownMapEd/releases)
- [FW-KENSC-ShellExt](https://github.com/MainMemory/FW-KENSC-ShellExt/releases)

2. S.C.E. uses a different layout format to support two-byte IDs chunks. Unfortunately there are no converters here for the new layout format. You just won't be able to use the original layouts from Sonic 3 & Knuckles.
You could try using different [Layout.cs](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/master/SonLVL%20INI%20Files/Common/Layout) for **SonLVL** to convert layout to the new format.

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
