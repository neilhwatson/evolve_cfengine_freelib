#!/bin/sh

cd test/masterfiles
cf-agent -D test_csv,efl_global_strings -Kf ./promises.cf
