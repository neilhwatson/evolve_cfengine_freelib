#!/bin/sh

cd test/masterfiles
cf-agent -D efl_class_cmd_regcmp_json -Kf ./promises.cf
