#!/bin/bash

set -eu -o pipefail

test_num=0
failed=0

# Output in TAP format on fd 3, which is our original stdout.
# Direct commands' stdout to our original stderr.
exec 3>&1
exec >&2

for external in \
    bootstraplinux_ubuntu12_32.tar.xz \
    client-versions.json \
; do
    test_num=$(( test_num + 1 ))
    if [ -e "$external" ]; then
        printf '# ' >&3
        ls -dl "$external" >&3
        case "$external" in
            (*.json)
                sed -e 's/^/#   /' "$external" >&3
                # JSON files don't always end with a newline
                echo '#'
                ;;

            (*.tar.*)
                tar -tvf "./$external" | sed -e 's/^/#   /' >&3
                ;;
        esac
        echo "ok $test_num - $external is present" >&3
    else
        echo "# $external not found" >&3
        echo "# Try running buildutils/add-client-files.py" >&3
        echo "not ok $test_num - $external is missing" >&3
        failed=1
    fi
done

echo "1..$test_num" >&3
exit "$failed"
