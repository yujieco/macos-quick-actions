# macos-quick-actions

给 macOS 访达的右键菜单补上几个常用动作：选中文件或文件夹，一键把完整路径拷进剪贴板。

就是一个 `.workflow` 文件夹加一个安装脚本。没有常驻进程、不申请辅助功能权限、启动项里不会多出东西，删掉目录就完全还原。

[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square)](#要求)

## 要求

- macOS，已在 27.2.1 上验证。
- 只用系统自带的 Automator 与服务机制，不需要 Xcode，也不需要签名。
- 动作装在 `~/Library/Services`，只对当前用户生效。

## 安装

```bash
git clone https://github.com/yujieco/macos-quick-actions.git
cd macos-quick-actions
./install.sh
```

`install.sh` 把 `workflows/` 下每个 `.workflow` 复制进 `~/Library/Services`，再调用 `pbs -flush` 让系统重新扫描服务。**同名动作会被覆盖**，其它动作不受影响。

```text
已安装 CopyPath.workflow

完成。在访达里右键选中项 → 快速操作，即可看到新动作。
没出现就执行：killall Finder
```

## 第一次使用

1. 在访达里选中一个文件或文件夹。
2. 右键 →「快速操作」→「拷贝路径」。
3. 检查剪贴板：

```bash
pbpaste
```

```text
/Users/you/Documents/report.pdf
```

多选时一行一个路径：

```text
/Users/you/Documents/a.txt
/Users/you/Documents/b.txt
```

## 动作

- **拷贝路径**（`workflows/CopyPath.workflow`）：把选中的每个文件或文件夹的绝对路径写入剪贴板，每行一个。

## 改脚本

每个动作就是一个目录，脚本在 `Contents/Resources/document.wflow` 里，那是纯文本 plist，真正执行的 shell 在 `COMMAND_STRING`：

```xml
<key>COMMAND_STRING</key>
<string>for f in "$@"; do
	/usr/bin/printf '%s\n' "$f"
done | /usr/bin/pbcopy</string>
```

改完重新执行 `./install.sh` 才生效。几个常用变体，替换上面那段即可：

```sh
# 带转义，可直接粘进终端：/Users/you/My\ Files
printf '%q\n' "$@" | pbcopy

# 家目录缩写成 ~
printf '%s\n' "${@/#$HOME/~}" | pbcopy

# 直接 cd 过去
printf 'cd %q\n' "$@" | pbcopy
```

## 加自己的动作

最省事的方式是复制一份现成的：

```bash
cp -R workflows/CopyPath.workflow workflows/OpenInTerminal.workflow
```

然后改两个地方：`Contents/Info.plist` 里 `NSMenuItem` 的 `default`（菜单上显示的名字）和 `document.wflow` 里的 `COMMAND_STRING`。目录名用动词加宾语，`CopyPath` 好过 `Copy`。

想可视化编辑也可以：Automator → 新建「快速操作」→ 接收「文件或文件夹」于「访达」→ 拖入「运行 Shell 脚本」，把「传递输入」改成 **作为参数** → 保存；再把生成在 `~/Library/Services` 的目录挪进 `workflows/`。

## 卸载

```bash
rm -rf ~/Library/Services/CopyPath.workflow
/System/Library/CoreServices/pbs -flush
```

## 限制

- 动作落在右键的「快速操作」子菜单里，不是顶层。要顶层的独立项只能写 Finder Sync 扩展，那需要 Xcode、签名，还要用户去系统设置里手动启用，成本完全不是一个量级。
- 只对访达里选中的文件或文件夹生效，不会出现在文本选择、浏览器等其他上下文里。
- 没有安装器 App、没有更新机制、没有多语言菜单：就是几个文本文件，改哪看哪。
- 如果只是想临时拷一次路径，访达自带**拷贝为路径名称**：按住 Option 打开「编辑」菜单可见，快捷键通常是 `⌥⌘C`。这个仓库补的是"右键顺手就能点"。

## 贡献

一个动作只做一件事；目录名 PascalCase；提交前先跑一遍 `./install.sh`，确认菜单里点一下拿得到预期结果。

## License

MIT，见 [LICENSE](LICENSE)。
