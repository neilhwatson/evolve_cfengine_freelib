#!/bin/sh

cd test/masterfiles
cf-agent -D test_csv,efl_class_hostname2 -Kf ./promises.cf
