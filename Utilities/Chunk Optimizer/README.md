DESCRIPTION:
        Finds duplicate level chunks across acts, moves them to a primary `main` file, and patches 2-byte IDs in layouts

USAGE:
        ChunkOptimizer --chunks CH1 CH2 [MORE...] --layouts L1 L2 [MORE...] [-o OUTPUT]

OPTIONS:
        --chunks   - List of input chunk files
        --layouts  - List of layout files to patch
        -o         - Name of the common chunks file (default: ChunksMain.unc)
