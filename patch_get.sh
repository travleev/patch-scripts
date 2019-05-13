#!/bin/bash 

if [[ "3" -ne "$#" ]] ; then
    echo ""
    echo "      Specify original folder, modified folder "
    echo "      and diff file name as command line parameters"
    echo ""
    echo "      > patch_get.sh ORIG MODIF patch.txt"
    echo ""
    echo "      ORIG and MODIF must be subfolders of the current folder "
    echo "      (see general recomendations for avoiding common "
    echo "      mistakes in GNU diff)."
    echo ""
    echo "      If file `exclude_patterns` exists, it will be used to exclude files" 
    echo "      from comparison. If this file does not exist, it will be generated"
    echo "      to show example content."
    exit 1
fi;

orig=$1  # original folder
modi=$2  # modified folder
ptch=$3  # diff file 

echo "Original folder: $orig"
echo "Modified folder: $modi"
echo "Diff file:       $ptch"

for f in "$orig" "$modi" ; do
    if [[ ! -d $f ]]; then
        echo "Folder does not exist: $f"
        exit 1
    fi;

    if [[ "$f" == *"/"* ]]; then
        echo "$f: folder name contains slashes. Consider to work only with folders in current dir."
        exit 1
    fi;
done;


if [[ -f $ptch ]]; then
    dat=$(date +%Y_%m_%d__%H_%M_%S)
    bak=$ptch.$dat
    echo "Patch file $ptch already exists. It will be moved to $bak"
    mv $ptch $bak
fi;

if [[ ! -a exclude_patterns ]]; then
    echo ""
    echo "Example exclude_patterns will be generated. Adjust it"
    echo "to control inclusion of files into patch, and restart the script."
    echo '*.o'     > exclude_patterns
    echo '*.orig' >> exclude_patterns
    echo '*.log'  >> exclude_patterns
fi;    
diff -Naur  -X exclude_patterns  $orig $modi > $ptch 
exit 0

