#!/bin/bash

objects=$(kubectl -n myapp get pods -o json 2>&1)

echo $objects