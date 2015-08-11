#!/bin/sh

cd test/masterfiles
cf-agent -D test_json,efl_test_classes -Kf ./promises.cf
