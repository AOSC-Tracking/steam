#!/bin/sh
# Copyright © 2016-2018 Simon McVittie
# Copyright © 2018 Collabora Ltd.
#
# SPDX-License-Identifier: MIT

set -e
set -u

if [ "${PYCODESTYLE:=pycodestyle}" = false ] || \
        [ -z "$(command -v "$PYCODESTYLE")" ]; then
    echo "1..0 # SKIP pycodestyle not found"
    exit 0
fi

echo "1..1"

if "${PYCODESTYLE}" \
    ./*.py \
    buildutils/*.py \
    steam_launcher/*.py \
    tests/*.py \
    >&2; then
    echo "ok 1 - $PYCODESTYLE reported no issues"
else
    echo "not ok 1 # TODO $PYCODESTYLE issues reported"
fi

# vim:set sw=4 sts=4 et:
