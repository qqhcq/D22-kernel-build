Param(
  [string]$KernelRepo = "https://github.com/cateajansmedya/android_kernel_mediatek_mt6739",
  [string]$Defconfig = "mt6739_64_defconfig",
  [string]$MakeTarget = "Image.gz-dtb",
  [string]$BootCfg = "boot.img.cfg",
  [string]$RamdiskDir = "boot.img.dump/ramdisk.dump",
  [string]$OutBoot = "boot_new.img"
)

Write-Host "Cloning kernel repo: $KernelRepo"
if (Test-Path "kernel_src") { Remove-Item -Recurse -Force "kernel_src" }
git clone $KernelRepo "kernel_src"
Set-Location "kernel_src"
git submodule update --init --recursive 2>$null
Set-Location ..

Write-Host "Building kernel in Docker..."
& "$PWD/scripts/build_kernel_docker.ps1" -Defconfig $Defconfig -MakeTarget $MakeTarget

Write-Host "Staging and repacking boot image..."
& "$PWD/scripts/repack_boot_with_kernel.ps1" -KernelImage "kernel_src/out/Image.gz-dtb" -RamdiskDir $RamdiskDir -BootCfg $BootCfg -OutBoot $OutBoot

Write-Host "Done. Generated staged files for $OutBoot. Use AIK或mkbootimg完成最终回包。"