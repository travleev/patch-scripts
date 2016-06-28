Approach
==========

The ``diff`` and ``patch`` commands are used to store and apply
changes to MCNP source. They are wrapped by the ``patch_apply.sh`` and
``patch_get.sh`` scripts. These scripts have been written keeping in mind work
with the MCNP source code, but can be (hopefully) applied to other stuff.

The scripts seem to work with simple changes, i.e. changes, applied to original
MCNP code. However, in cR2S will come necessity to merge differences coming
from different institutions. To what extent the scripts can be useful for this
task -- still unclear. For this reason, structure of this repository, as well
functionality and user interface of ``patch_apply.sh`` and ``patch_get.sh`` scripts
can be changed.


The ``patch_get.sh`` script compares two directories, one with
the original source code, the other with modified, and generates a diff file representing
the differencies. The ``patch_apply.sh`` script applies an existing (previously generated)
diff file to a copy of the folder containing original source code.

Scripts ``patch_get.sh`` and ``patch_apply.sh`` should be copied (or links to these
files should be put to) a place pointed by ``$PATH``, so they can be used from
an arbitrary folder. 


Example usage 
==============


``patch_apply.sh`` 
-----------------

Assume we want to apply patch ``torus.patch`` to MCNP5. The patch file is in
the current folder, original MCNP5 source is in
``$HOME/dist/C810mnycp00/MCNP_CODE/MCNP5`` (this path corresponds to the folder
containing source code for MCNP-5, as distributed with MCNP-6), and scripts
``patch_apply.sh`` and ``patch_get.sh`` can be found in ``$PATH``. ::

    > patch_apply.sh \
      $HOME/dist/C810mnycp00/MCNP_CODE/MCNP5 \      # original files
      torus.patch.5 \                               #  patch
      $HOME/work/MCNP5-mod                          # place for modified files

This command will copy ``$HOME/dist/C810mnycp00/MCNP_CODE/MCNP5`` to
``$HOME/work/MCNP5-mod`` if the latter does not exist, and the patch will be
applied to the copy.  


``patch_get.sh`` 
----------------

Script ``patch_get.sh`` can generate a patch file by comparing two folders in
current directory. It checks whether paths to the original and modified
directoreis contain the folder delimiter ``/`` and exits if it is found. Consider
to use links to put the folders containing original and modified files into the
same place. 

Files mentioned in ``exclude_patterns`` file will be excluded from the generated
patch. This file is created by ``patch_get.sh`` if not exists already, with the
content relevant for MCNP distribution (files ``*.o``, ``*.orig`` and ``*.log`` that
appear after MCNP compilation will not go to patch).


Put information about applied patches into executable
--------------------------------------------------------------

Script ``patch_apply.sh`` adds the name of currently applied patch to file
``patches.log`` inside the directory with modified content. This file is than
read by ``compile.sh`` and its content is copied to the default data path of
compiled MCNP executable. In this way, the user can track the pathes applied to
particular executable. 



Future work
==============

In ``patch_apply.sh``, the source folder not always needed: 
If patch is applied to allready existing folder, the source folder with original 
files is not needed. THus, it should not be specified on the command line.





