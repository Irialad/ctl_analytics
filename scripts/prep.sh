#!/bin/env bash

PROJECT_PATH=$(git rev-parse --show-toplevel)
PROJECT="${PROJECT_PATH##*/}"

docker build --network=host -t ${PROJECT}-dev -f Dockerfile.dev .
