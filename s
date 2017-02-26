#!/bin/bash

cmd=$1

shift

docker-compose $cmd web $*
