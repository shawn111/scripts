#!/bin/bash
#
# step:  
#  1. create a compress file (tar zc), test.tgz
#  2. cat extractor.sh test.tgz > x.bin
# x.bin is the result

SKIP=`awk '/^__ARCHIVE_BELOW__/ { print NR + 1; exit 0; }' $0`
tail -n +$SKIP $0 | tar -xz
exit 0

# NOTE: Don't place any newline characters after the last line below.
__ARCHIVE_BELOW__
