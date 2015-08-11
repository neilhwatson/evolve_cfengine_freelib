#!/bin/sh

cd test/masterfiles
cf-agent -D test_json,efl_class_classmatch -Kf ./promises.cf
