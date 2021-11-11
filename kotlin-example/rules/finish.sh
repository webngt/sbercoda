#!/bin/sh

msg=$(cd /root/Sprint-2 && mvn test)

jq -M -c -n --arg mvn_out "$msg" '{$mvn_out}'