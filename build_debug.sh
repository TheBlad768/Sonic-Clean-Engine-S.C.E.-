#!/bin/bash

# Delete some intermediate assembler output just in case
rm -f S3CE.debug.gen
rm -f S3CE.debug.p
rm -f S3CE.debug.h
rm -f S3CE.debug.log

# Run the assembler:
AS_MSGPATH=Tools/AS/Linux
USEANSI=n

# Allow the user to choose to print error messages out by supplying the -pe parameter
${AS_MSGPATH}/asl @Tools/AS/Linux/asflags_debug Engine/Includes.asm

test -f S3CE.debug.log && cat S3CE.debug.log
if [ ! -f S3CE.debug.p ]; then
    echo "Assembler did not produce S3CE.debug.p"
    exit 1
fi

# Convert the assembled file to binary
${AS_MSGPATH}/p2bin -p=FF -z=0,kosinskiplus,Size_of_DAC_driver_guess,after S3CE.debug.p S3CE.debug.gen S3CE.debug.h

# Delete temporary files
rm -f S3CE.debug.p
rm -f S3CE.debug.h

# Generate debug information
${AS_MSGPATH}/convsym S3CE.debug.lst S3CE.debug.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a
${AS_MSGPATH}/convsym S3CE.debug.lst "Engine/_RAM.debug.lst" -in as_lst -out asm -range FF0000 FFFFFF

# Make ROM padding (commented out as in the original)
#${AS_MSGPATH}/rompad S3CE.debug.gen 255 0

# Fix the ROM header
${AS_MSGPATH}/fixheader S3CE.debug.gen

# Copy rom to CD folder
if [ -f "S3CE.debug.gen" ]; then
    cp S3CE.debug.gen _CD/
    if [ $? -ne 0 ]; then
        echo "Failed to copy S3CE.debug.gen"
        exit 1
    fi
fi

if test -f S3CE.debug.gen
then
  exit 0
fi
exit 1
