@echo off

echo "正在获取当前MOA版本安装文件，请稍等..."
::set path=%~dp0
adb connect 192.16.1.106
adb shell < %~dp0\cmd.txt
adb pull data/data/com.sangfor.pocket/ %~dp0\moafile\old

echo "获取文件完成！"
exit


