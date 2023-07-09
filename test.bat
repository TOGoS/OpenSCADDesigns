@echo off

set "self_name=%~f0"

if not defined UNIX_FIND_EXE (echo In order to use %self_name%, please set UNIX_FIND_EXE 2>&1 & exit /B 1)

"%UNIX_FIND_EXE%" . -name "*.scad" -and -not -path "./2023/lib/*" "(" -exec "C:\Program Files\OpenSCAD\openscad.com" --hardwarnings -o test-output.stl "{}" ";" -o "(" -printf "ERROR EVALUATING %%p" -quit ")" ")"
rem This won't actually exit with nonzero on error because I don't know how to make `find` do that.
