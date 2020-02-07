#!/bin/bash
sleep 1
try_count=0
while [ $try_count != 100 ]; do
	julia --project=.ci/ -e 'using Pkg; Pkg.instantiate()'
	if [ $? = 0 ]; then exit 0; fi
	try_count=`expr $try_count + 1`
	sleep 1
done
exit 1
