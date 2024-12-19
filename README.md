# pigpen.sh

Script to start another process with limits

## Why

I want to start processes in a Docker container with limits. My container cannot be privileged, so I cannot use cgroups or unshare.

## Proof of concept

`pigpen.sh` requires root to run. It starts another process as a specified user, with specified memory limit.   
