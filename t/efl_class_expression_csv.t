#!/bin/sh

cd test/masterfiles
cf-agent -D efl_class_expression_csv -Kf ./promises.cf
