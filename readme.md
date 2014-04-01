SPEECH HACK

first cd to /hydraTCPClient

INPUT FROM FILE USE

ffmpeg -i media/input.wav -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient localhost 10530 6000 localhost 11530 7000
                     <hydraddress1> <port1> <callbackPort1> (repeat this pattern for more hydra connections)


INPUT FROM WEB TCP? USE

java TCPServer | ffmpeg -i pipe:0 -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient localhost 10530 0

INPUT FROM LIVESTREAM (http://localhost:8090/live.flv)

ffserver -d -f /etc/ffserver.conf

ffmpeg -i http://localhost:8090/audio.wav -f s16le -acodec pcm_s16le - | java -cp target/hydraTCPClient-1.0-SNAPSHOT.jar edu.cmu.sv.hydraTCPClient.HydraTCPClient 10.0.20.160 10530 6000

PLAY ONE FILE
ffmpeg -re -f mp4 -i media/CES.mp4 http://localhost:8090/feed1.ffm

PLAYLIST (use libfdk_aac if the audio encoder gives problems)
for f in *.mp4; do echo "Playing $f"; ffmpeg -re -f mp4 -i $f http://localhost:8090/feed1.ffm; done

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
# for more info on crf/preset options, type: x264 --help
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

<Stream audio.wav>
Feed feed1.ffm
Format wav
AudioChannels 1
AudioSampleRate 16000
AudioCodec pcm_s16le
NoVideo
</Stream>