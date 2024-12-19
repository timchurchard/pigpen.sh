# pigpen.sh example in docker

An example simple unprivileged Dockerfile to demo starting another process with limits.

```bash
cd example
docker build -t pigpen-example -f Dockerfile .

docker run -it --rm pigpen-example

$ sudo /opt/pigpen/pigpen.sh --version
github.com/timchurchard/pigpen.sh 0.1

$  sudo /opt/pigpen/pigpen.sh -v -- /bin/ls -l
Running "/bin/ls -l" 
Creating pigpen 2a7ed9a61cc10ae2
Created user with uid 38165
total 56
lrwxrwxrwx   1 root root    7 Dec  2 00:00 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Oct 31 11:04 boot
drwxr-xr-x  17 root root 4760 Dec 19 20:42 dev
drwxr-xr-x   1 root root 4096 Dec 19 20:42 etc
...
Removed pigpen 2a7ed9a61cc10ae2 / 38165
```

## So what is happening here?

1. The Dockerfile installs `pigpen.sh` into `/opt/pigpen/` and sets the permissions so that a normal user can run it with sudo.
2. `pigpen.sh` Creates a new user and runs the specified process as that user, with a ulimit for memory.
3. The specified process has limits:
    - The process is started as a new user, it cannot read the /proc of other processes e.g. to get environment variables
    - The process is started with a memory limit (ulimit -v)
    - The process has nowhere to write in the filesystem
    - Once the process is finished the script kills all processes running as that user and removes the user 