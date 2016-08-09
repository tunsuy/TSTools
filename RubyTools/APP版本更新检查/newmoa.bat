@echo off

echo "正在安装新包并获取安装文件，请稍等..."
::set path=%~dp0
adb connect 192.16.1.106
adb install -r %~dp0\MOA.apk
adb shell < %~dp0\cmd.txt
adb pull data/data/com.sangfor.pocket/ %~dp0\moafile\new

echo "获取文件完成！"
exit

