#!/usr/bin/env bash
# pigpen.sh: Runs a command with limits

PIGPEN_VERSION="0.1"

if [ -z "$PIGPEN_BASE_DIR" ]; then
  PIGPEN_BASE_DIR=/var/pigpen # The base directory for all pigpen mounts
fi

if [ -z "$PIGPEN_DEFAULT_MEMORY_LIMIT" ]; then
  PIGPEN_DEFAULT_MEMORY_LIMIT=256000 # The memory limit in kbytes (256MB)
fi

function show_version () {
  echo "github.com/timchurchard/pigpen.sh $PIGPEN_VERSION"
}

function show_usage () {
  echo "Usage: pigpen.sh [options] command"
  echo ""
  echo "Options:"
  echo "  --version            Show version"
  echo "  -h, --help           Show this message"
  echo "  -v, --verbose        Enable verbose output"
  echo "  -m, --memory         Set memory limit kbytes e.g. 256000 = 256MB"
  echo "  --                   End of options"
  echo ""
  echo "Examples:"
  echo "  pigpen.sh --verbose -- /bin/bash"
}


# Set up bash options
set -o errexit -o nounset -o pipefail; shopt -s nullglob

# random_id returns a random 16-character hex string
function random_id () {
  head -c8 </dev/urandom | xxd -p
}

# setup_simple creates a simple pigpen with a user home (no chroot, no unshare)
# takes (pig_id "deadbeef") and returns the created uid
function setup_simple () {
  local pig_id=$1

  local random_gid=$(shuf -i 30003-39993 -n 1)

  addgroup \
    --allow-bad-names \
    --gid "$random_gid" "$pig_id" >/dev/null 2>&1
  adduser \
    --allow-bad-names \
    --gecos "" \
    --disabled-password \
    --home "/nonexistent" \
    --no-create-home \
    --shell "/sbin/nologin" \
    --gid "$random_gid" \
    --uid "$random_gid" \
    "$pig_id" >/dev/null 2>&1

   echo "$random_gid"
}

# cleanup_simple removes a simple pigpen
# takes (pig_id "deadbeef") and uid, returns nothing
function cleanup_simple () {
  local pig_id=$1
  local uid=$2

  killall -u "$pig_id" || true

  userdel "$pig_id"
}


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

verbose=""
memory="$PIGPEN_DEFAULT_MEMORY_LIMIT"

# Parse command line arguments
for i in "$@"; do
  case $i in
    -h|--help)
      show_usage
      exit 0
      ;;
    --version)
      show_version
      exit 0
      ;;
    -v|--verbose)
      verbose="true"
      shift # past argument
      ;;
    -m|--memory)
      memory="$2"
      shift # past argument
      shift # past value
      ;;
    --)
      shift # past argument
      break
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

pig_cmd="$@"
if [ ! -z "$verbose" ]; then
  echo "Running \"$pig_cmd\" "
fi

pig_id=$(random_id)
if [ ! -z "$verbose" ]; then
  echo "Creating pigpen $pig_id"
fi

pig_uid=$(setup_simple "$pig_id")
if [ ! -z "$verbose" ]; then
  echo "Created user with uid $pig_uid"
fi

sudo -u "$pig_id" -- /bin/bash -c "ulimit -v $memory && $pig_cmd || echo \"Command failed with exit code $?\""

cleanup_simple "$pig_id" "$pig_uid"
if [ ! -z "$verbose" ]; then
  echo "Removed pigpen $pig_id / $pig_uid"
fi