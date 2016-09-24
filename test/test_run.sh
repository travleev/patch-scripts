#!/bin/bash

rm -rf mod1 mod2
rm patch*
rm exclude_patterns

# Create a new directry as a copy of orig
../patch_apply.sh orig mod1 << EOF
y
y
EOF

# Arbitrary order of arguments
../patch_apply.sh mod2 orig << EOF
y
y
EOF

# Modify mod1 and mod2
cat >> mod1/f1.txt << EOF
Modified from mod1
EOF
cat >> mod2/f1.txt << EOF
Modified from mod2
EOF


# Create patches
../patch_get.sh orig mod1 p1.patch
../patch_get.sh orig mod2 p2.patch

# Apply patches to new copy of orig:
../patch_apply.sh orig mod3 p1.patch << EOF
y
y
EOF
../patch_apply.sh mod3 p2.patch << EOF
y
y
EOF


