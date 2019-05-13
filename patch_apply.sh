#!/bin/bash 

if [[ "0" -eq "$#" ]] ; then
    echo ""
    echo ""
    echo "      Usage:"
    echo ""
    echo "      > patch_apply.sh [ORIG] MOD [PATCH]"
    echo ""
    echo "      where:"
    echo "          ORIG -- folder with original content,"
    echo "          MOD -- folder with files to be patched,"
    echo "          PATCH -- the patch file."
    echo ""
    echo "      See comments in script for details."
    echo ""

    exit 1
fi;

# This script applies patches from PATCH to files in MOD, which are obtained by
# copying from ORIG.
# 
# Folder ORIG and file PATCH are optional.  When ORIG is not given, MOD must be
# an existing folder. In this case PATCH is applied to MOD. When ORIG is given,
# the script copies ORIG to MOD recursively and following links (cp -rL).  File
# permissions are changed to permit the current user to edit files. When PATCH is
# given, it is applied to files in MOD.
# 
# Command line arguments are parsed by thier filetype and position. When
# a non-existing file name is given, its value defines MOD. The 1-st existing
# folder is understood as ORIG.  If however, MOD is not specified (as the 2-nd
# existing folder or a non-existing filename), the 1-st folder defines MOD. The
# 1-st existing ordinary file (not a folder) defines PATCH.
# 
# The order of folders, ORIG followed by MOD is chosen deliberately to be
# consistent with the ``cp`` command.
# 
# 
# 
# EXAMPLES:
#     Assume that `orig` is an existing folder containing some source code,
#     `mod` does not exists, and `patch.1` is a patch file. The following
#     commands are equal:
# 
#     > patch_apply.sh orig   mod   patch.1
#     > patch_apply.sh patch.1   orig   mod
#     > patch_apply.sh patch.1   mod   orig
# 
#     In all these cases, the folder `orig` will be copied to `mod` and than files in
#     `mod` will be changed according to `patch.1`. 
# 
# 
#     Another example -- apply patch to exisiting files. Assume that folder
#     `mod` already exists (for example, was created with the above commands),
#     and file `patch.2` also exists.  The following commands are equal:
# 
#     > patch_apply.sh mod patch.2
#     > patch_apply.sh patch.2 mod
#
#     and change already existing files in `mod` according to `patch.2`. 
#     This invocation is useful when several patches must be applied
#     consequently, and the folder with modified source code already exists.
# 
# 
# 
#     One more example -- the patch file is not given. In this case the order is
#     important if both arguments are existing folders.
# 
#     > patch_apply.sh orig mod      # copy orig to mod
#     > patch_apply.sh mod orig      # equal to the above only when mod does not exist
# 
#     This invocation is useful when preparing a new working environment. 
# 
# 


# Command line arguments go here:
d1='' # 1-st directory
d2='' # 2-nd directory
f=''  # not-a-folder file

for a in "$@"; do

    # define fletype of a. Only file and dir are of interest
    [ -d "$a" ] && t="dir"
    [ -f "$a" ] && t="fil"
    [ ! -e "$a" ] && t="new"  # non-existing filename.

    echo $a $t

    # Set f only once:
    [ "$t" == "fil" ] && [ -z "$f" ]  && f=$a 

    # Set d1 and d2 only once 
    if [ "$t" == "dir" ]; then
        if [ -z "$d1" ]; then
            d1="$a"
        elif [ -z "$d2" ]; then
            d2="$a"
        fi
    fi
    # A non-existing filename defines d2, when not set already
    [ "$t" == "new" ] && [ -z "$d2" ] && d2="$a"

    # When all parameters are set, do not parse the rest of the command line
    [ -n "$d1" ] && [ -n "$d2" ] && [ -n "$f" ] && break
done

ORI=''    # Folder containing original code
MOD=''    # Folder containing modified code
pat=$(readlink -f "$f")  # full path to the patch file

# When 2 folders are given, they are ORIG and MOD. When only one -- it is MOD
if [ -n "$d1" ]; then 
   if [ -n "$d2" ]; then 
      ORI="$d1"
      MOD="$d2"
   else 
       MOD="$d1"
   fi
fi   

# Print summary
[ -n "$ORI" ] && echo "Original files from $ORI will be copied to $MOD" 
[ -n "$pat" ] && echo "Files in $MOD will patched with $pat"
read -p "Continue? (yY): " aaa
case $aaa in 
    [^yY]) exit 1;;
esac    

if [ -n "$ORI" -a -n "$MOD" ]; then
    # both folders are given. Copy ORI to MOD

    # Ask if MOD already exists
    if [ -d "$MOD" ]; then 
        read -p "Folder $MOD already exists. Rewrite it? (yY): " aaa
        case "$aaa" in
            [^yY]) exit 1;;
        esac 
        rm $MOD -rf
    fi

    cp -r -L $ORI $MOD  # -L to follow links
    chmod -R u+rw $MOD  # ensure that user has write permission to the copy 
fi    

if [ -n "$pat" ]; then
    echo "applying $pat to files in $MOD"
    cd $MOD
    patch -p1 -b < $pat

    # add patch name to a file:
    # patch name is guessed from the patch file name:
    echo "patch name is added to $MOD/patches.log"
    ptnm=${pat##*/}        # remove pathname
    echo $ptnm >> patches.log 
else
    echo "Patch name was not given or points to non-existing file."
    echo "No patch is applied."
fi


exit 0
