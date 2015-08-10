#!/bin/sh

cd test/masterfiles
cf-agent -D test_csv,efl_class_returnszero -Kf ./promises.cf
