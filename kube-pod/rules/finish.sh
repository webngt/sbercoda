#!/bin/bash

objects=$(kubectl get pods -o json 2>&1)

echo $objects