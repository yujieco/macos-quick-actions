#!/bin/sh
# 把 workflows/*.workflow 安装到 ~/Library/Services，并让系统重新扫描服务。
# 同名动作会被覆盖，其它动作不受影响。
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)/workflows"
DEST="$HOME/Library/Services"

if [ ! -d "$SRC" ]; then
	echo "找不到 $SRC" >&2
	exit 1
fi

mkdir -p "$DEST"

for wf in "$SRC"/*.workflow; do
	[ -d "$wf" ] || continue
	name="$(basename "$wf")"
	rm -rf "$DEST/$name"
	cp -R "$wf" "$DEST/$name"
	echo "已安装 $name"
done

/System/Library/CoreServices/pbs -flush

echo
echo "完成。在访达里右键选中项 → 快速操作，即可看到新动作。"
echo "没出现就执行：killall Finder"
