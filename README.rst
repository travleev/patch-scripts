Intro
=========
A set of scritps that wrapper the ``patch`` and ``diff`` utilities for the use
with sets of files in folder hierarchy. 

Consider you have two folders, ``orig`` -- with the original code, and ``mod``
that is basically a copy of ``orig`` with some minor modifications. The
``patch_get.sh`` script compares the two folders and generates a diff file
describing the differences. The ``patch_apply.sh`` script applies the diff file
to ``orig`` and restores ``mod``.

Although the work can be done directly with ``diff`` and ``patch`` utilities,
the scripts in this repository simplyfy their use exactly to the case of
comparing folders. 

For details see comment lines in the scripts.

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


Exclude files
===============


Keep track of applied patches
===================================
The ``patch_apply.sh`` script adds the name of currently applied patch file to
``patches.log`` in the modified folder. Thus, one can keep track of the applied
patches.

