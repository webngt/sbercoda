#!/bin/bash
launch.sh

while [ $(kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'| tr ';' "\n"  | grep "Ready=True" | wc -l) != "2" ] ; do sleep 1 ; done
