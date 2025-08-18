#!/bin/bash

# Delete some intermediate assembler output just in case
rm -f S3CE.gen
rm -f S3CE.p
rm -f S3CE.h
rm -f S3CE.log

# Run the assembler:
AS_MSGPATH=Tools/AS/Linux
USEANSI=n

# Allow the user to choose to print error messages out by supplying the -pe parameter
${AS_MSGPATH}/asl @Tools/AS/Linux/asflags Engine/Includes.asm

test -f S3CE.log && cat S3CE.log
if [ ! -f S3CE.p ]; then
    echo "Assembler did not produce S3CE.p"
    exit 1
fi

# Convert the assembled file to binary
${AS_MSGPATH}/p2bin -p=FF -z=0,kosinskiplus,Size_of_DAC_driver_guess,after S3CE.p S3CE.gen S3CE.h

# Delete temporary files
rm -f S3CE.p
rm -f S3CE.h

# Generate debug information
${AS_MSGPATH}/convsym S3CE.lst S3CE.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a
${AS_MSGPATH}/convsym S3CE.lst "Engine/_RAM.lst" -in as_lst -out asm -range FF0000 FFFFFF

# Make ROM padding (commented out as in the original)
#${AS_MSGPATH}/rompad S3CE.gen 255 0

# Fix the ROM header
${AS_MSGPATH}/fixheader S3CE.gen

# Copy rom to CD folder
if [ -f "S3CE.gen" ]; then
    cp S3CE.gen _CD/
    if [ $? -ne 0 ]; then
        echo "Failed to copy S3CE.gen"
        exit 1
    fi
fi

if test -f S3CE.gen
then
  exit 0
fi
exit 1
