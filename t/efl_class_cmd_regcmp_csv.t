#!/bin/sh

cd test/masterfiles
cf-agent -D test_csv,efl_class_cmd_regcmp -Kf ./promises.cf

