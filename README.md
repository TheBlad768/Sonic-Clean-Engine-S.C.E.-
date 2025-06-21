# SONIC-CLEAN-ENGINE-S.C.E.-

![Title](https://i.imgur.com/2K6zGld.png)

## Disclaimer

Cleaned up and optimized the source code of Sonic 3 & Knuckles. Free use. You use it at your own risk. All code is provided “as is”. This source code uses software from other authors. Check their licenses before using it. You assume any and all responsibility for using this content responsibly. I claims no responsibility or warranty. Commercial usage is expressly prohibited.

# Download

- [Current version](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/archive/refs/heads/flamedriver.zip)

## Additional links

#### If you are interested in the source code with the Z80 Sound Driver:

- [Sonic-Clean-Engine-S.C.E.-Flamedriver-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver)

#### Extended source code:

- [Sonic-Clean-Engine-S.C.E.-Extended-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-Extended-)

#### Sonic 1 in Sonic 3 & Knuckles (S.C.E. Version):

- [Sonic-1-in-Sonic-3-S.C.E.-](https://github.com/TheBlad768/Sonic-1-in-Sonic-3-S.C.E.-)

## How to build the ROM

To build this, use build.bat if you're a Windows user, or build.sh if you're a Linux user. The built ROM will be called 'S3CE.gen'. Use build_debug for debug things. The built ROM will be called 'S3CE.Debug.gen'.

## Quick start

- For editing sprites you can use [SonMapEd](https://info.sonicretro.org/SonMapEd), [ClownMapEd](https://info.sonicretro.org/ClownMapEd) or [Flex2](https://info.sonicretro.org/Flex_2) (Read the issues).

- For editing levels you can use official [SonLVL](https://info.sonicretro.org/SonLVL) or [SonLVL-64x64-Compatible](https://github.com/Project1114/SonLVL-64x64-Compatible). Unfortunately, [SonED2](https://info.sonicretro.org/SonED2) is no longer supported.

- To convert SMPS music to asm format you can use [smps2asm](https://forums.sonicretro.org/index.php?threads/smps2asm-and-improved-s-k-driver.26876).

## Current issues

1. S.C.E. uses [Kosinski Plus algorithm](https://github.com/flamewing/mdcomp/blob/master/src/asm/KosinskiPlus.asm), but **Flex2** program does not support **Kosinski Plus Module**. Therefore, **Flex2.json** project file is partially useless. **SonMapEd** program does not support **Kosinski Plus** at all. You can only open uncompressed graphics.

### Solution: Fork the program from Nichloya:

- [Flex2](https://github.com/Nichloya/Flex2/releases)

#### Alternative programs:
- [mdcomp](https://github.com/flamewing/mdcomp/releases)
- [ClownMapEd](https://github.com/Clownacy/ClownMapEd/releases)
- [FW-KENSC-ShellExt](https://github.com/MainMemory/FW-KENSC-ShellExt/releases)

## FAQ

#### How do I add levels from previous Sonic games?

- If you want to convert levels from previous Sonic games, you have to use [LevelConverter](https://info.sonicretro.org/LevelConverter) from [SonLVL](https://info.sonicretro.org/SonLVL). Then change the layout format using [Layout converter](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Utilities/Layout).

#### How do I make different text for Title Card?

- If you want to make a different text for Title Card, you need to create a file of letters from [List.unc](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Objects/Main/Title%20Card/KosinskiPM%20Art/Levels). This will be loaded before the level starts.
You don't have to add the letters **'ENOZ' (ZONE)** because those letters are already in VRAM. Then you have to create a mapping of your zone name in [Map - Title Card.asm](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver/Objects/Main/Title%20Card/Object%20Data).

#### Where can I find other SMPS music?

- If you want to use other SMPS music you can use [Valley Bell's SMPS Research](https://forums.sonicretro.org/index.php?threads/valley-bells-smps-research.32473) or [vgm2smps](https://github.com/Ivan-YO/vgm2smps/releases).

#### Why don't mappings use MapMacros?

- Unfortunately, not all programs support MapMacros, so I wanted to maintain compatibility with older programs. I don't want to just throw away **SonMapEd**. But there is support for MapMacros here, and you can use it if you want.

## The Macro Assembler AS issues

#### Why does the ROM take so long to build?

- The speed of the ROM build process depends entirely on the power of your computer. A high-performance machine will build the ROM quickly, while a slower one will take significantly more time. If you're a Linux user and you're using Wine and Windows batch script, that will affect build speed too.

- Always specify jump sizes for instructions. Writing code without specifying jump sizes will significantly slow down the ROM build. The Macro Assembler AS will perform multiple passes until it can successfully build the ROM, which increases build time.

Example of problematic code:

```
		beq	sub_1234	; and any other branch instructions
		bsr	sub_1234
		bra	sub_1234
		jsr	sub_1234
		jmp	sub_1234
		lea	sub_1234,a1
		pea	sub_1234
```

Example of correct code:

```
		beq.s	sub_1234	; and any other branch instructions
		bsr.s	sub_1234
		bra.s	sub_1234
		jsr	(sub_1234).l
		jmp	(sub_1234).l
		lea	(sub_1234).l,a1
		pea	(sub_1234).l
```

#### Pay close attention to your code to avoid such issues.

### Here you can find more information about Macro AS errors:

- [Sonic Retro](https://forums.sonicretro.org/index.php?threads/guide-to-common-as-assembler-errors.43731/)
- [SSRG](https://sonicresearch.org/community/index.php?threads/guide-to-common-as-assembler-errors.7201/)

### <code style="color : RED">For God's sake, always specify the jump sizes for instructions. Don't try to play around with Macro Assembler AS. Sometimes you may see random and meaningless errors just because you didn't specify the code size. You will try to fix something that wasn't actually broken, but these errors were caused only because you didn't specify the jump size in instruction.</code>

## Special Credits

- Nichloya — Technical and other support.
- pixelcat — New smooth ring graphics, act 3 and 4 numbers graphics.
- FoxConED — Level Select font graphics.
- Dolphman — Robotnik Head graphics.

## Links

- [YouTube channel](https://www.youtube.com/@TheBlad768)
- [Telegram channel](http://t.me/theblad768channel)
- [Red Miso Studios Discord](https://discords.com/servers/redmisostudios)

## These projects are based on this source code

- Sonic 3 Rebuilt by TomatoWave_0
- [Sonic The Hedgehog in Hellfire Saga](https://github.com/TheBlad768/Hellfire-Saga-Public-Source)
- [Sonic 3 & Knuckles: Epilogue](https://github.com/TheBlad768/Sonic-3-Knuckles-Epilogue-Public-Source)
- TishaProject (2019)
- Sonic Virtual Adventure (2017) (Cancelled) — In the past I made this source code specifically for this project (:

## Check out the Sonic Retro source code

- [s1disasm](https://github.com/sonicretro/s1disasm)
- [s2disasm](https://github.com/sonicretro/s2disasm)
- [skdisasm](https://github.com/sonicretro/skdisasm)
