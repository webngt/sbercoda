#!/bin/sh

msg=$(cat /tmp/test.log)

jq -M -c -n --arg mvn_out "$msg" '{$mvn_out}'