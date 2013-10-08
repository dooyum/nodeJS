#!/bin/sh
input=$*
file_ext=${input/*.};
filename=${input};
name=${filename%.*};
echo "Converting $name";
case "$file_ext" in
  "mp3" | "ogg") #TODO(dooyum)add supported audio extensions
      ffmpeg -i "../input/$input" "../output/$name.wav"
  ;;
  "mkv" | "flv") #TODO(dooyum)add supported video extensions
      ffmpeg -i "../input/$input" "../output/$name.mp4"
  ;;
  "wav")
      cp "../input/$input" "../output/" #move raw file to converted folder if done
  ;;
esac
mv "../input/$input" "../converted/";
echo "Done Converting $name";
node response.js $name;
echo "Response Sent";
#TODO(dooyum)throw error if unsupported format
