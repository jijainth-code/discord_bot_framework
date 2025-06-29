#!/bin/bash
# Wrapper script for Docker stop operations
# This calls the actual script in the scripts/ directory

exec scripts/docker_stop.sh "$@" 