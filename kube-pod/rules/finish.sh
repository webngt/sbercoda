#!/bin/bash

objects=$(/usr/local/bin/kubectl get pods -o json 2>&1)

echo $objects