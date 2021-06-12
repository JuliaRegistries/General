#!/bin/bash

# This script runs `Pkg.instantiate()` inside a bounded retry loop.

try_count=0
while [ $try_count != 9 ]; do
    julia --color=yes --project=.ci/ -e 'import Pkg; Pkg.instantiate()'
    if [ $? = 0 ]; then exit 0; fi
    try_count=`expr $try_count + 1`
    sleep 20
done
exit 1
