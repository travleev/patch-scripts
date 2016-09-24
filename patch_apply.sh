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
# consistent with the cp command.
# 
# 
# 
# EXAMPLES:
#     Assume that mcnp5 is an existing folder containing mcnp source code,
#     mcnp5-mod does not exists, and torus.patch is a patch file. The following
#     commands are equal:
# 
#     > patch_apply.sh mcnp5   mcnp5-mod   torus.patch
#     > patch_apply.sh torus.patch   mcnp5   mcnp5-mod
#     > patch_apply.sh torus.patch   mcnp5-mod   mcnp5
# 
#     Folder mcnp5 will be copied to mcnp5-mod and files in mcnp5-mod will be
#     changed according to torus.patch.
# 
# 
# 
#     Another example -- apply patch to exisiting files. Assume that folder
#     mcnp5-mod already exists, and file material.patch also exists.  The
#     following commands are equal:
# 
#     > patch_apply.sh mcnp5-mod materials.patch
#     > patch_apply.sh materials.patch mcnp5-mod
# 
#     This invocation is useful when several patches must be applied
#     consequently, and the folder with modified source code already exists.
# 
# 
# 
#     Another example -- the patch file is not given. In this case the order is
#     important if both arguments are existing folders.
# 
#     > patch_apply.sh mcnp5 mcnp5-mod    # copy mcnp5 to mcnp5-mod
#     > patch_apply.sh mcnp5-mod mcnp5    # equal to above only when mcnp5-mod does not exist
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
    
##########################################################################################################
# OLD IMPLEMENTATION

# # There are 3 scenarios of using this script:
# #
# #   1. Apply PATCH to ORIG and put result to MOD. All three arguments must be specified.
# #   2. Apply PATCH to allready existing MOD. In this case, argument ORIG not needed. Issue warning before modifying MOD!
# #   3. Prepare workplace by copying ORIG to MOD. Links should be followed (i.e. ensure that a link in ORIG becomes usual file in MOD) and 
# #      permissions are modified to grant user modification rights. In this case PATCH argument is not needed.
# #
# # In all scenarios, MOD must be always specified, therefor it is always the first argument. If this argument points to existing folder, the
# # next argument is understood as PATCH file, otherwise, as ORIG folder. In the latter case, the last (third) argument, if given, defines PATCH.
# 
# 
# 
# mod="$1"
# 
# if [[ -d "$mod" ]]; then
#     # MOD exists. Next argument -- patch file.
#     pfl="$2"
# 
#     read -p "Apply patch $pfl to existing folder $mod. Continue? (y)" a
#     case $a in
#         [^yY]) exit 1;;
#     esac
# 
# elif [[ ! -e "$mod" ]]; then
#     # MOD does not exist. Next argument -- ORIG folder.
#     org="$2"
#     pfl="$3"
#     if [[ 3 -eq $# ]]; then
#         message=" and apply patch $pfl"
#     else
#         message=""
#     fi
# 
#     read -p "Copy folder $org to $mod $message. Continue? (y)" a
#     case $a in
#         [^yY]) exit 1;;
#     esac
# else
#     # MOD exists, but not a folder. This is error.
#     echo "$mod is not a directory."
#     exit 1
# fi
# 
# exit
# 
# orig=$1  # folder with original files
# ptfl=$(readlink -f $2)  # full path to the patch file. It is needed to specify it from another directory (see cd below)
# res=$3   # folder with patched files
# 
# 
# if [[ ! -d $orig ]]; then
#     echo "Original folder does not extst: $orig"
#     exit 1
# fi;
# 
# if [[ ! -f $ptfl ]]; then
#     echo "Patch file does not exist: $ptfl"
#     exit 1
# fi;
# 
# echo "original folder:  $orig"
# echo "patch full path:  $ptfl"
# echo "resulting folder: $res"
# 
# 
# if [[ -d $res ]]; then
#     # res already exists. Warn user
#     echo "$res already exists. "
#     echo "Apply patches to files in $res? (y/n)"
#     read a
#     case $a in
#         [^yY]) exit 1;;
#     esac
# else
#     # copy original folder and patch
#     echo "Copying $orig to $res"
#     cp -r -L $orig $res  # -L to follow links
#     chmod -R u+rw $res  # ensure that user has write permission to the copy 
# fi    
# 
# # apply patch
# echo "applying patch to $res"
# cd $res
# patch -p1 -b < $ptfl
# 
# # add patch name to a file:
# # patch name is guessed from the patch file name:
# echo "patch name is added to $res/patches.log"
# ptnm=${ptfl##*/}        # remove pathname
# echo $ptnm >> patches.log 
# 
# exit 0
# 
# 

