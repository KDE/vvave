#!/bin/bash

# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


$XGETTEXT $(find src/ -name \*.cpp -o -name \*.h -o -name \*.qml) -o $podir/vvave.pot
