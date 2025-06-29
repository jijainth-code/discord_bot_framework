#!/bin/bash
# Wrapper script for Docker operations
# This calls the actual script in the scripts/ directory

exec scripts/docker-run.sh "$@" 