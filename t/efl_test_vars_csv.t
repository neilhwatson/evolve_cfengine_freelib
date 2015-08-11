#!/bin/sh

cd test/masterfiles
cf-agent -D test_csv,efl_test_vars -Kf ./promises.cf
