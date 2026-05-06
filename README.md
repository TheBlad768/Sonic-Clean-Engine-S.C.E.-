# SONIC-CLEAN-ENGINE-S.C.E.-

![Title](https://i.imgur.com/2K6zGld.png)

![GitHub Release](https://img.shields.io/github/v/release/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub top language](https://img.shields.io/github/languages/top/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub Repo stars](https://img.shields.io/github/stars/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub watchers](https://img.shields.io/github/watchers/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/TheBlad768/Sonic-Clean-Engine-S.C.E.-?style=flat-square)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/TheBlad768/Sonic-Clean-Engine-S.C.E.-/total?style=flat-square)

# Download

- [Current version](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/archive/refs/heads/Clone-Driver-v2.zip)
- [Releases](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/releases)
- [ROMs](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/actions)

## Disclaimer

Heavily modified and improved Sonic 3 & Knuckles engine.

Please read the [license](LICENSE) before using this project.

## Features

- Cleaned up and optimized disassembly of Sonic 3 & Knuckles:

    - There are no hardcoded things as there were in the original Sonic 3 & Knuckles. Complete freedom in your work;

- Changed level layout format. Now there are two bytes for chunk IDs:

    - This will allow you to create more chunks for levels because there will be no one-byte limit here. This will allow you to port levels even from Sonic CD;

- All current level settings in one file:
    - No more searching through the entire Sonic disassembly to replace chunks, layout, palette, music, and other things. Just open [Pointer.asm](Levels/DEZ/Pointers) located in each level folder;

- Many original subroutines have been replaced with faster equivalents. These new subroutines do not break compatibility with the original Sonic 3 & Knuckles. Therefore, there is no need to worry about this:

    - Updated Ultra DMA Queue subroutines and compression algorithms(Kosinski Plus, Kosinski Plus Module, Updated Enigma) have optimized S3K's performance very well;

- I rewrote the code of all the screens, objects, and other things to get maximum performance:

    - Poorly written object code can significantly reduce game performance, regardless of whether other subroutines have been optimized very well. All code has been rewritten in S3K style. If you are familiar with Sonic 3 & Knuckles disassembly, you will have no problems with the S1S3/SCE code;

- The size of the object slots is now 0x50 bytes:
    - Additional free bytes will facilitate work on complex objects;
    - You can easily change the object slot size without breaking anything, since there's no slot-size-based multiplication like in Sonic 1 and Sonic 2;

- Various sound drivers:
    - There are Z80 Sound Flamedriver and M68K Sonic 2 Clone Driver v2 (Mega PCM 2.0 version). It all depends on your tasks.

## Additional links

#### If you are interested in the Sonic Clean Engine (S.C.E.) with the Z80 Sound Driver:

- [Sonic-Clean-Engine-S.C.E.-Flamedriver-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/tree/flamedriver)

#### Sonic Clean Engine (S.C.E.) Extended version:

- [Sonic-Clean-Engine-S.C.E.-Extended-](https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-Extended-)

#### Sonic 1 in Sonic 3 & Knuckles (S.C.E. Version):

- [Sonic-1-in-Sonic-3-S.C.E.-](https://github.com/TheBlad768/Sonic-1-in-Sonic-3-S.C.E.-)

## How to build the ROM

To build this, use build.bat if you're a Windows user, or build.sh if you're a Linux user. The built ROM will be called 'S3CE.gen'. Use build_debug for debug things. The built ROM will be called 'S3CE.debug.gen'.

## Quick start

- For editing sprites you can use [SonMapEd](https://info.sonicretro.org/SonMapEd), [ClownMapEd](https://info.sonicretro.org/ClownMapEd) or [Flex2](https://info.sonicretro.org/Flex_2) (Read the issues).

- For editing levels you can use official [SonLVL](https://info.sonicretro.org/SonLVL) or [SonLVL-64x64-Compatible](https://github.com/Project1114/SonLVL-64x64-Compatible). Unfortunately, [SonED2](https://info.sonicretro.org/SonED2) is no longer supported.

- To convert SMPS music to asm format you can use [smps2asm](https://forums.sonicretro.org/index.php?threads/smps2asm-and-improved-s-k-driver.26876).

- For counting instruction cycles you can use [68kCounter](https://68kcounter.grahambates.com).

- Recommended emulators for debugging: [BizHawk](https://github.com/TASEmulators/BizHawk/releases), [BlastEm](https://www.retrodev.com/blastem/nightlies/), [ClownMDEmu](https://github.com/Clownacy/clownmdemu-frontend/releases), [Exodus](https://www.exodusemulator.com/downloads/current-release), [Gens KMod](https://segaretro.org/Gens_KMod), [Gens r57shell Mod](https://www.romhacking.net/utilities/1123/), [Regen](https://segaretro.org/Regen).

- Recommended emulators for Mode 1 (MSU): [BlastEm](https://www.retrodev.com/blastem/nightlies/), [RetroArch](https://www.retroarch.com/).

## Current issues

1. S.C.E. uses [Kosinski Plus algorithm](https://github.com/flamewing/mdcomp/blob/master/src/asm/KosinskiPlus.asm), but **Flex2** program does not support **Kosinski Plus Module**. Therefore, **Flex2.json** project file is partially useless. **SonMapEd** program does not support **Kosinski Plus** at all. You can only open uncompressed graphics.

### Solution: Use the fork from Nichloya:

- [Flex2](https://github.com/Nichloya/Flex2/releases)

#### Alternative programs:
- [mdcomp](https://github.com/flamewing/mdcomp/releases)
- [ClownMapEd](https://github.com/Clownacy/ClownMapEd/releases)
- [FW-KENSC-ShellExt](https://github.com/MainMemory/FW-KENSC-ShellExt/releases)

## FAQ

#### How do I add levels from previous Sonic games?

- If you want to convert levels from previous Sonic games, you have to use [LevelConverter](https://info.sonicretro.org/LevelConverter) from [SonLVL](https://info.sonicretro.org/SonLVL). Then change the layout format using [Layout converter](Utilities/Layout).

#### How do I make different text for Title Card?

- If you want to make different text for the Title Card, you need to open the [Constants.asm](Engine) file and look for \
`Title Card zone names`. There you'll find a list of zones whose names you can modify.

    ```m68k
    ; ---------------------------------------------------------------------------
    ;  Title Card zone names
    ; ---------------------------------------------------------------------------

    TitleCardName_ZONE =					"ZONE"
    TitleCardName_DEZ =					"DEATH EGG"
    ```

If you still want to use direct mappings instead of a macro to create Title Card mappings [S3TCG](https://github.com/RobiTheGit/S3TCG).

#### Where can I find other SMPS music?

- If you want to use other SMPS music you can use [Valley Bell's SMPS Research](https://forums.sonicretro.org/index.php?threads/valley-bells-smps-research.32473) or [vgm2smps](https://github.com/Ivan-YO/vgm2smps/releases).

#### Why don't mappings use MapMacros?

- Unfortunately, not all programs support MapMacros, so I wanted to maintain compatibility with older programs. I don't want to just throw away **SonMapEd**. But there is support for MapMacros here, and you can use it if you want.

# Tutorials

Here you can find tutorials for Sonic Clean Engine (S.C.E.):

- https://github.com/TheBlad768/S.C.E.-Tutorials-

## Assembler

Sonic Clean Engine (S.C.E.) is designed for use with The Macro Assembler AS:

- http://john.ccac.rwth-aachen.de:8000/as/

The assembler used here is Flamewing's modified version of The Macro Assembler AS, found here:

- https://github.com/Clownacy/asl-releases
- https://github.com/flamewing/asl-releases

## Why The Macro Assembler AS?

<details>
<summary>Answer</summary>

![AS]

[AS]: https://i.imgur.com/dYq4mPl.gif

</details>

## The Macro Assembler AS issues

#### Why does the ROM take so long to build?

- The speed of the ROM build process depends entirely on the power of your computer. A high-performance machine will build the ROM quickly, while a slower one will take significantly more time. If you're a Linux user and you're using Wine and Windows batch script, that will affect build speed too.

- Always specify jump sizes for instructions. Writing code without specifying jump sizes will significantly slow down the ROM build. The Macro Assembler AS will perform multiple passes until it can successfully build the ROM, which increases build time.

Example of problematic code:

```m68k
		beq	sub_1234	; and any other branch instructions
		bsr	sub_1234
		bra	sub_1234
		jsr	sub_1234
		jmp	sub_1234
		lea	sub_1234,a1
		pea	sub_1234
```

Example of correct code:

```m68k
		beq.s	sub_1234	; and any other branch instructions
		bsr.s	sub_1234
		bra.s	sub_1234
		jsr	(sub_1234).l
		jmp	(sub_1234).l
		lea	(sub_1234).l,a1
		pea	(sub_1234).l
```

#### Pay close attention to your code to avoid such issues.

### Here you can find more information about Macro Assembler AS and errors:

- [Flamewing's Enhanced AS](https://html-preview.github.io/?url=https://github.com/TheBlad768/Sonic-Clean-Engine-S.C.E.-/blob/Clone-Driver-v2/Tools/AS/asl.html)
- [Flamewing's Enhanced AS wiki](https://github.com/flamewing/asl-releases/wiki)
- [Sonic Retro](https://forums.sonicretro.org/index.php?threads/guide-to-common-as-assembler-errors.43731/)
- [SSRG](https://sonicresearch.org/community/index.php?threads/guide-to-common-as-assembler-errors.7201/)

> [!WARNING]\
> Please always specify the jump sizes for instructions. Macro Assembler AS may display random and misleading errors if the jump size is not specified. You will try to fix something that wasn't actually broken, but these errors are caused only because you didn't specify the jump size in the instruction.

### Macro Assembler AS Passes

I've added console messages about Macro AS passes.

![AS1](https://i.imgur.com/gr5H1zl.png)

Try to keep 2 passes at all times. If you see 3, 4 or more passes, you should figure out what's causing the extra passes and try to fix it. This will save you a lot of time during the ROM build.

![AS2](https://i.imgur.com/dR923wk.png)

## Credits

### Red Miso Studios Staff

- TheBlad768 — Project lead, sole programmer, S.C.E. Game Engine
- Nichloya — Technical and other support
- pixelcat — New smooth ring graphics, act 3 and 4 numbers graphics
- FoxConED — Level Select font graphics
- Dolphman — Robotnik Head graphics

### Special Support

- cuberoot

### Special Thanks

- Clownacy and other contributors for work on the Sonic Retro disassemblies
- SSRG and Sonic Retro

## Links

- [YouTube channel](https://www.youtube.com/@TheBlad768)
- [Telegram channel](http://t.me/theblad768channel)
- [Red Miso Studios Discord](https://discords.com/servers/redmisostudios)

## These projects are based on the Sonic Clean Engine (S.C.E.)

<details>
<summary><b>Sonic Vania (2025 Demo)</b> by JvneTh</summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2025/1212" target="_blank">SHC Page</a>
  <br><br>
  <img src="https://i.imgur.com/rLUkT3j.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>Sonic 3 Rebuilt</b> by TomatoWave_0</summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2025/1224" target="_blank">SHC Page</a>
  <br><br>
  <img src="https://i.imgur.com/GgXGebt.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>Sonic The Hedgehog in Hellfire Saga (2023)</b></summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2023/916" target="_blank">SHC Page</a> &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/TheBlad768/Hellfire-Saga-Public-Source" target="_blank">Source</a>
  <br><br>
  <img src="https://i.imgur.com/GRyUeZD.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>Sonic 3 & Knuckles: Epilogue (2021)</b></summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2021/477" target="_blank">SHC Page</a> &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/TheBlad768/Sonic-3-Knuckles-Epilogue-Public-Source" target="_blank">Source</a>
  <br><br>
  <img src="https://i.imgur.com/bawDZSn.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>TishaProject (2019)</b></summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2019/50" target="_blank">SHC Page</a>
  <br><br>
  <img src="https://i.imgur.com/fV2d77k.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>Sonic Virtual Adventure (2017)</b> Cancelled</summary>
  <br>
  In the past I made the Sonic Clean Engine (S.C.E.) specifically for this project (:
  <br><br>
<p align="center">
  <img src="https://i.imgur.com/2S9MEIj.png" style="max-width:100%;">
</p>
</details>

#### Mini projects

<details>
<summary><b>Sonic With A Pogo Stick</b> by RobiWanKenobi</summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2025/1358" target="_blank">SHC Page</a>
  <br><br>
  <img src="https://i.imgur.com/iJzZzI0.png" style="max-width:100%;">
</p>
</details>

<details>
<summary><b>Sunky MD</b> by RobiWanKenobi</summary>
<p align="center">
  <a href="https://shc.zone/entries/contest2025/1336" target="_blank">SHC Page</a>
  <br><br>
  <img src="https://i.imgur.com/M9CwAkX.png" style="max-width:100%;">
</p>
</details>

## Check out the Sonic Retro Disassemblies

- [s1disasm](https://github.com/sonicretro/s1disasm)
- [s2disasm](https://github.com/sonicretro/s2disasm)
- [skdisasm](https://github.com/sonicretro/skdisasm)
