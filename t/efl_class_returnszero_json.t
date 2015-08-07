#!/bin/sh

cd test/masterfiles
cf-agent -D efl_class_returnszero_json -Kf ./promises.cf
