Param(
  [string]$KernelImage = "kernel_src/out/Image.gz-dtb",
  [string]$RamdiskDir = "boot.img.dump/ramdisk.dump",
  [string]$BootCfg = "boot.img.cfg",
  [string]$OutBoot = "boot_new.img"
)

Write-Host "Preparing ramdisk..."
New-Item -ItemType Directory -Force -Path out_tmp | Out-Null

# Create ramdisk cpio.gz from ramdisk.dump
tar -C $RamdiskDir -cf out_tmp/ramdisk.tar .
"`nCreating cpio archive" | Out-File -Append out_tmp/log.txt
& powershell -Command "Get-Content out_tmp/ramdisk.tar | Write-Output" > out_tmp/ramdisk.tar.copy
Remove-Item out_tmp/ramdisk.tar -Force
Move-Item out_tmp/ramdisk.tar.copy out_tmp/ramdisk.tar

Write-Host "[Note] Use AIK or existing tools for mkbootimg. This script stages files only."
Copy-Item $KernelImage -Destination out_tmp/Image.gz-dtb -Force
Copy-Item $BootCfg -Destination out_tmp/boot.img.cfg -Force
Write-Host "Staged kernel and ramdisk. Use AIK repackimg.bat or mkbootimg with boot.img.cfg to produce $OutBoot."