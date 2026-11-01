@echo off

setlocal

set "self_name=store.bat"

if not defined UNIX_FIND_EXE (echo %self_name%: Error: UNIX_FIND_EXE not defined>&2 & goto fail)

set "stl_pats="
set "png_pats="
set "tef_pats="

:parse_args
if "%1" == "" goto parse_args_done

set "pattern=%1"
set stl_pats=%stl_pats% -o -name "%pattern%.stl"
set png_pats=%png_pats% -o -name "%pattern%.png"
set tef_pats=%tef_pats% -o -name "%pattern%.tef"

shift
goto parse_args
:parse_args_done

if "%stl_pats%" == "" (echo %self_name%: No patterns indicated; quitting without running anything. & goto:eof)

set find_common_cmd="%UNIX_FIND_EXE%" print-archive -name ".*" -a -type d -a -prune -a -false

%find_common_cmd% %tef_pats% | xargs cat
%find_common_cmd% %stl_pats% | xargs -n 5 ccouch-store-and-upload.bat -link -sector 3dp-stl
%find_common_cmd% %png_pats% | xargs -n 5 ccouch-store-and-upload.bat -link -sector pictures

goto:eof

:fail
exit /B 1

:eof
