#!bin/sh

inputDirectory=~/Desktop/speech_hack/input/;
conversionScriptDirectory=~/Desktop/speech_hack/convert.sh;
#TODO(dooyum) Use inotify instead of fswatch on linux server
fswatch $inputDirectory $conversionScriptDirectory;
