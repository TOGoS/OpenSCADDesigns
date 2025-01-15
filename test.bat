@echo off

setlocal

set "self_name=%~f0"

if not defined OPENSCAD_COM set "OPENSCAD_COM=C:\Program Files\OpenSCAD\openscad.com"

if not defined UNIX_FIND_EXE (echo In order to use %self_name%, please set UNIX_FIND_EXE 2>&1 & exit /B 1)

rem "%OPENSCAD_COM%" --hardwarnings -o test-output.stl 2023\test\TOGPolyhedronLib1Test.scad
rem if errorlevel 1 goto fail
rem 
rem "%OPENSCAD_COM%" --hardwarnings -o test-output.stl 2023\test\TOGPath1Test.scad
rem if errorlevel 1 goto fail

"%UNIX_FIND_EXE%" 2023/test -name "*.scad" -and -not -path "./2023/lib/*" "(" -exec "%OPENSCAD_COM%" --hardwarnings -o test-output.stl "{}" ";" -o "(" -printf "ERROR EVALUATING %%p" -quit ")" ")"
rem This won't actually exit with nonzero on error because I don't know how to make `find` do that.
if errorlevel 1 goto fail

goto eof


:fail
echo Some tests failed>&2
exit /B 1

:eof
