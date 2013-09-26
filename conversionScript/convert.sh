#!/bin/sh

for input in ./input/*;
  do
  file_ext=${input##*/*.};
  filename=${input##*/};
  name=${filename%.*};
  echo $name;
  case "$file_ext" in
    "mp3" | "ogg") #TODO(dooyum)add supported audio extensions
        ffmpeg -i "$input" "./output/$name.wav"
    ;;
    "mkv" | "flv") #TODO(dooyum)add supported video extensions
        ffmpeg -i "$input" "./output/$name.mp4"
    ;;
    "wav")
        cp "$input" "./output/" #move raw file to converted folder if done
    ;;
  esac

    mv "$input" "./converted/";
    #TODO(dooyum)throw error if unsupported format
done
