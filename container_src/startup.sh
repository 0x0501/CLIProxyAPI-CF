#!/bin/sh
set -eu

R2_MOUNT_PATH="${R2_MOUNT_PATH:-/mnt/r2}"
AUTH_DIR="${AUTH_DIR:-/CLIProxyAPI/.cli-proxy-api}"

mkdir -p "${R2_MOUNT_PATH}" "${AUTH_DIR}"

if [ -n "${R2_ACCOUNT_ID:-}" ] && [ -n "${R2_BUCKET_NAME:-}" ]; then
    R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
    echo "Mounting bucket ${R2_BUCKET_NAME} to ${R2_MOUNT_PATH}..."

    /usr/local/bin/tigrisfs --endpoint "${R2_ENDPOINT}" -f "${R2_BUCKET_NAME}" "${R2_MOUNT_PATH}" &
    mount_pid=$!

    i=0
    while [ "${i}" -lt 15 ]; do
        if ! kill -0 "${mount_pid}" 2>/dev/null; then
            echo "tigrisfs exited before the R2 mount became ready."
            wait "${mount_pid}"
            exit 1
        fi

        if grep -qs " ${R2_MOUNT_PATH} " /proc/mounts; then
            break
        fi

        sleep 1
        i=$((i + 1))
    done

    if ! grep -qs " ${R2_MOUNT_PATH} " /proc/mounts; then
        echo "Timed out waiting for the R2 mount at ${R2_MOUNT_PATH}."
        exit 1
    fi

    echo "Mount /mnt/r2 success."
else
    echo "R2_ACCOUNT_ID or R2_BUCKET_NAME is not set, skipping R2 mount."
fi

cd /CLIProxyAPI
exec "$@"
