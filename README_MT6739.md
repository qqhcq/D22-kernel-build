# MT6739 内核一键克隆、编译与回包

本方案让你无需WSL，直接在Windows上通过Docker完成MT6739内核的克隆与编译，并把新内核与现有`ramdisk`、`boot.img.cfg`一起回包生成`boot_new.img`（最终回包需要AIK或mkbootimg执行）。

## 前置条件
- Windows 已安装 Docker Desktop，并启用WSL2后端（推荐）或Hyper-V。
- 本项目根目录存在：
  - `boot.img.dump/ramdisk.dump/` 原始ramdisk解包目录
  - `boot.img.cfg`（包含`cmdline`等参数）

## 一键脚本

在项目根目录执行：

```
pwsh -File scripts/clone_build_repack.ps1 -KernelRepo "https://github.com/cateajansmedya/android_kernel_mediatek_mt6739" -Defconfig "mt6739_64_defconfig" -MakeTarget "Image.gz-dtb" -BootCfg "boot.img.cfg" -RamdiskDir "boot.img.dump/ramdisk.dump" -OutBoot "boot_new.img"
```

脚本流程：
- 克隆仓库到`kernel_src/`
- 在Docker中安装交叉编译依赖并编译`Image.gz-dtb`
- 将`Image.gz-dtb`与现有ramdisk、`boot.img.cfg`进行打包准备
- 最终生成`out_tmp/`中的素材，使用AIK或`mkbootimg`生成`boot_new.img`

## GitHub Actions（可选）

你也可以在GitHub仓库中手动触发`MT6739 Kernel Build`工作流，设置输入：
- `defconfig`: `mt6739_64_defconfig`
- `make_target`: `Image.gz-dtb`
- `kernel_repo_url`: `https://github.com/cateajansmedya/android_kernel_mediatek_mt6739`

Artifact将包含`Image.gz-dtb`。

## ACM 功能提示

我们已在`scripts/acm_defconfig_fragment.config`提供ACM相关Kconfig片段，工作流和Docker脚本会合并到`.config`并`olddefconfig`。若上游仓库缺少`f_acm.c`或未启用`CONFIG_USB_CONFIGFS`，请告知我以便调整。

## 回包与刷写

生成`boot_new.img`后，仅刷写`boot`分区。使用SP Flash Tool，选择`boot`并`Download`。首次启动用ADB检查：
- `ls -l /dev/ttyACM*` 是否存在
- `dmesg | grep -i acm` 是否有ACM枚举日志

## 常见问题
- Docker未安装：请安装Docker Desktop。
- 交叉编译失败：检查网络、重复执行脚本或使用Actions。
- 无法枚举ACM：请发送`zcat /proc/config.gz | grep -i acm`与`init.usb.*.rc`给我进一步定位。