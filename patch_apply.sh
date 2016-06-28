#!/bin/bash 

if [[ "3" -ne "$#" ]] ; then
    echo ""
    echo ""
    echo "      Usage:"
    echo ""
    echo "      > patch_get.sh ORIG patch.txt PATCHED"
    echo ""
    echo "      where:"
    echo "          ORIG -- folder with original content,"
    echo "          patch.txt -- name of the patch file,"
    echo "          PATCHED -- name of the folder containing patched files."
    echo ""
    echo "      When PATCHED does not exist, it is created by copying ORIG."
    echo "      Otherwise, patches are applied to files in PATCHED."

    exit 1
fi;

orig=$1  # folder with original files
ptfl=$(readlink -f $2)  # full path to the patch file. It is needed to specify it from another directory (see cd below)
res=$3   # folder with patched files


if [[ ! -d $orig ]]; then
    echo "Original folder does not extst: $orig"
    exit 1
fi;

if [[ ! -f $ptfl ]]; then
    echo "Patch file does not exist: $ptfl"
    exit 1
fi;

echo "original folder:  $orig"
echo "patch full path:  $ptfl"
echo "resulting folder: $res"


if [[ -d $res ]]; then
    # res already exists. Warn user
    echo "$res already exists. "
    echo "Apply patches to files in $res? (y/n)"
    read a
    case $a in
        [^yY]) exit 1;;
    esac
else
    # copy original folder and patch
    echo "Copying $orig to $res"
    cp -r -L $orig $res  # -L to follow links
    chmod -R u+rw $res  # ensure that user has write permission to the copy 
fi    

# apply patch
echo "applying patch to $res"
cd $res
patch -p1 -b < $ptfl

# add patch name to a file:
# patch name is guessed from the patch file name:
echo "patch name is added to $res/patches.log"
ptnm=${ptfl##*/}        # remove pathname
echo $ptnm >> patches.log 

exit 0



