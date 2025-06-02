SonLayout v.0.1 - Sonic layout conversion utility
(c) 2024, Vladikcomper

USAGE:
        sonlayout [-q] -i INFORMAT -o OUTFORMAT INFILE OUTFILE

OPTIONS:
        -i INFORMAT - Specifies input format
        -o OUTFORMAT - Specifies output format (format to convert to)
        -q - Quiet mode (log errors only)

SUPPORTED FORMATS:
        s1 - Sonic 1 layout (256x256, FG and BG separated)
        s3k - Sonic 3K combined layout (FG+BG)
        sce - Sonic Clean Engine combined layout (FG+BG)
        scex - Extended Sonic Clean Engine combined layout (WORD-sized chunk IDs, FG+BG)

ONLY LOWERCASE LETTERS ARE SUPPORTED