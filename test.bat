ufind . -name "*.scad" -and -not -path "./2023/lib/*" "(" -exec "C:\Program Files\OpenSCAD\openscad.com" --hardwarnings -o test-output.stl "{}" ";" -o "(" -printf "ERROR EVALUATING %%p" -quit ")" ")"
rem This won't actually exit with nonzero on error because I don't know how to make `find` do that.
