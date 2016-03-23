#!/bin/sh

hostname=$(hostname -s)

if [ $hostname = 'altair01' -o $hostname = 'vega01' ]
then
   cd test/masterfiles
   cf-agent -D test_json,efl_class_hostrange -Kf ./promises.cf
else
   echo 1..1
   echo ok - skipped not correct hostname
fi

