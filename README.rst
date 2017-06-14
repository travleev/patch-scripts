Intro
=========
cR2S assumes changes to the MCNP source code. These changes can be stored and distributed only as patches, without
storing and/or distributing the original or modified MCNP code. Scripts in this folder simplify working with patches.

Approach
==========

The standard linux utilities ``diff`` and ``patch`` are used to store and apply
changes to the MCNP source. They are wrapped by the ``patch_apply.sh`` and
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
the differencies. The ``patch_apply.sh`` script applies changes from an existing (previously generated)
diff file to a copy of the folder containing the original source code.

Scripts ``patch_get.sh`` and ``patch_apply.sh`` should be copied (or links to these
files should be put to) a place pointed by ``$PATH``, so they can be used from
an arbitrary folder. 


Example usage 
==============


``patch_apply.sh`` 
-----------------

Assume we want to apply the ``torus.patch`` patch to MCNP5. The patch file is in
the current folder, original MCNP5 source is in
``$HOME/dist/C810mnycp00/MCNP_CODE/MCNP5`` (this path corresponds to the folder
containing source code for MCNP-5, as distributed with MCNP-6), and scripts
``patch_apply.sh`` and ``patch_get.sh`` can be found in ``$PATH``. The command ::

    > patch_apply.sh \
      $HOME/dist/C810mnycp00/MCNP_CODE/MCNP5 \      # original files
      $HOME/work/MCNP5-mod                          # place for modified files
      torus.patch.5 \                               #  patch

will copy ``$HOME/dist/C810mnycp00/MCNP_CODE/MCNP5`` to
``$HOME/work/MCNP5-mod`` if the latter does not exist, and the patch will be
applied to files in ``$HOME/work/MCNP5-mod``. For details see the comments in the `script file`_.

.. _`script file`: patch_apply.sh



``patch_get.sh`` 
----------------

Script ``patch_get.sh`` can generate a patch file by comparing two folders in
the current directory (to protect from comparing folders from different places, 
the script checks whether paths to the original and modified directoreis contain 
the folder delimiter character ``/`` and exits if it is found. Consider
to use links to put the folders containing original and modified files into the
same place). 

Files mentioned in the file ``exclude_patterns`` will be excluded from the generated
patch. This file is created by ``patch_get.sh`` if not exists already, with the
content relevant for MCNP distribution (files ``*.o``, ``*.orig`` and ``*.log`` that
appear after MCNP compilation will not go to patch). Once created, it can be modified
to exclude other files.


MCNP compilation generates many auxiliary files and even removes some from the
original distribution (the ``make build`` command to compile MCNP-6 calls under
some consitions the target ``realclean``, which deletes utilities from the
``bin`` folder). Therefore, it is better to clean both folders, with the
original distribution and with modified code before generating the patch file.
Assuming that the original files are in ``mcnp-orig`` and modified in
``mcnp-mod``, the following commands should be called to generate the patch::

    > cd mcnp-orig/Source
    > make realclean
    > cd ../../mcnp-mod/Source
    > make realclean
    > cd ../..
    > patch_get mcnp-orig mcnp-mod


Note for MCNP-6
-----------------



Put information about applied patches into MCNP executable
--------------------------------------------------------------

Script ``patch_apply.sh`` adds the name of currently applied patch to the file
``patches.log``, located in the directory with modified content. This file is then
read by ``compile.sh`` and its content is copied to the default data path of
compiled MCNP executable. In this way, the user can track the patches applied to
particular executable. 


