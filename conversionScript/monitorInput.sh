#!bin/sh

inputDirectory=./input/;
conversionScriptDirectory=./convert.sh;
#TODO(dooyum) Use inotify instead of fswatch on linux server
fswatch $inputDirectory $conversionScriptDirectory;
