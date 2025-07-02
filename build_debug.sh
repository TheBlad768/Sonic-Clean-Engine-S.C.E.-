#!/bin/sh
AS_MSGPATH="Tools/AS/Linux"
USEANSI=n

# Delete some intermediate assembler output just in case
rm -f S3CE.Debug.gen
rm -f Main.p
rm -f Main.h

# Run the assembler:
# -xx       shows the most detailed error output
# -q        shuts up AS
# -c        outputs a shared file (*.h)
# -A        gives us a small speedup
# -L        listing to file
# -U        forces case-sensitivity
# -E        output errors to a file (*.log)
# -i "."    allows (b)include paths to be absolute
${AS_MSGPATH}/asl -xx -n -q -c -D __DEBUG__ -olist Main.Debug.lst -A -L -U -E -i . Main.asm


test -f Main.log && cat Main.log
if [ ! -f "Main.p" ]; then
    echo "Assembler did not produce Main.p"
    exit 1
fi

# Convert the assembled file to binary
${AS_MSGPATH}/p2bin -p=FF -z=0,kosinskiplus,Size_of_DAC_driver_guess,after Main.p S3CE.Debug.gen Main.h

# Delete temporary files with error checking
rm -f Main.p
rm -f Main.h

# Generate debug information
${AS_MSGPATH}/convsym Main.lst S3CE.Debug.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a
${AS_MSGPATH}/convsym Main.lst "Engine/_RAM.Debug.asm" -in as_lst -out asm -range FF0000 FFFFFF

# Make ROM padding (commented out as in the original)
#${AS_MSGPATH}/rompad S3CE.Debug.gen 255 0

# Fix the ROM header
${AS_MSGPATH}/fixheader S3CE.Debug.gen

if test -f S3CE.Debug.gen
then
  exit 0
fi
exit 1
