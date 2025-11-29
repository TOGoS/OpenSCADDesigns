@echo off

setlocal

if not defined OPENSCAD_202101_CLI_EXE   set "OPENSCAD_202101_CLI_EXE=C:/Program Files/OpenSCAD/openscad.com"
if not defined OPENSCAD_20240727_CLI_EXE set "OPENSCAD_20240727_CLI_EXE=C:/Apps/OpenSCAD-2024.07.27-x86-64/openscad.exe"

deno run --check -A make.ts %*
