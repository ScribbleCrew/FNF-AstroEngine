@echo off
color 0a
cd ../../../../
echo BUILDING GAME
haxelib run lime build Project.hxp linux -release
echo.
echo done.
pause
pwd
explorer.exe export\release\linux\bin