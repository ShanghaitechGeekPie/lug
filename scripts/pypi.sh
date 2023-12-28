#!/bin/bash
set -e
BANDERSNATCH=${BANDERSNATCH:-"~/.local/bin/bandersnatch"}
TUNASYNC_UPSTREAM=${TUNASYNC_UPSTREAM_URL:-"https://pypi.org"}
TUNASYNC_WORKING_DIR="/mirrors/pypi"
CONF="/tmp/bandersnatch.conf"
INIT=${INIT:-"0"}

if [ ! -d "$TUNASYNC_WORKING_DIR" ]; then
	mkdir -p $TUNASYNC_WORKING_DIR
	INIT="1"
fi

echo "Syncing to $TUNASYNC_WORKING_DIR"

if [[ $INIT == "0" ]]; then
(
	cat << EOF
[mirror]
directory = /mirrors/pypi
master = https://pypi.org
#download-mirror = https://mirrors.tuna.tsinghua.edu.cn/pypi
storage-backend = filesystem
json = true
timeout = 300
workers = 10
hash-index = false
stop-on-error = false
delete-packages = true
compare-method = stat
#proxy="http://10.15.89.182:8080"

[plugins]
enabled =
    regex_project
    blocklist_project
    prerelease_release

[filter_regex]
packages =
    .+-nightly(-|$)

[filter_prerelease]
packages =
    duckdb
    graphscope-client
    lalsuite
    gs-apps
    gs-engine
    gs-include
    bigdl-dllib
    bigdl-dllib-spark2
    bigdl-dllib-spark3
    ovito

[blocklist]
packages =
    uselesscapitalquiz
    mpf
EOF
	for i in $PYPI_EXCLUDE; do
		echo "    $i"
	done
) > $CONF
	exec $BANDERSNATCH -c $CONF mirror
else
	cat > $CONF << EOF
[mirror]
directory = ${TUNASYNC_WORKING_DIR}
master = ${TUNASYNC_UPSTREAM}
json = true
timeout = 15
workers = 10
hash-index = false
stop-on-error = false
delete-packages = false
#proxy="http://10.15.89.182:8080"
EOF

	exec $BANDERSNATCH -c $CONF mirror
fi
