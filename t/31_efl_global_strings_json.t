#!/bin/sh

cd test/masterfiles
cf-agent -D test_json,efl_global_strings -Kf ./promises.cf
