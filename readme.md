SPEECH HACK

first cd to /hydraTCPClient


INPUT FROM WEB TCP? USE

java TCPServer | ffmpeg -i pipe:0 -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient localhost 10530




INPUT FROM LIVESTREAM? USE

ffserver -d -f /etc/ffserver.conf

ffplay http://localhost:8090/feed1.ffm

ffmpeg -f s16le -i http://localhost:8090/test1.wav -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient 10.0.20.160 10530 6000

ffmpeg -re -f wav -i input.wav http://localhost:8090/feed1.ffm


INPUT FROM LIVESTREAM? USE PART 2 (http://localhost:8090/test1.flv)


ffserver -d -f /etc/ffserver.conf

ffmpeg -i http://localhost:8090/live.flv -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient 10.0.20.160 10530 6000

ffmpeg -re -f mp4 -i ted.mp4 http://localhost:8090/feed1.ffm


working ffserver config for flv
<Stream live.flv>
Format flv
Feed feed1.ffm

VideoCodec libx264 
VideoFrameRate 30
VideoBitRate 512
VideoSize 320x240 
AVOptionVideo crf 23
AVOptionVideo preset medium
AVOptionVideo flags +global_header
AVOptionVideo me_range 16
AVOptionVideo qdiff 4
AVOptionVideo qmin 10
AVOptionVideo qmax 51

AudioCodec aac
Strict -2
AudioBitRate 128
AudioChannels 2
AudioSampleRate 44100
AVOptionAudio flags +global_header
</Stream>