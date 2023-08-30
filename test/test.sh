#!/bin/sh
# $1 = build directory
# $2 = test directory
# $3 = working directory
# $4 = output directory

# load functions
. $1/functions.sh

# test x265
# START_TIME=$(currentTimeInSeconds)
# echoSection "run test x265 encoding"
# $4/bin/ffmpeg -y -i "$2/test.mp4" -c:v "libx265" -pix_fmt yuv420p -an "$3/test-x265-8bit.mp4" > "$3/test-x265_8bit.log" 2>&1
# checkStatus $? "test x265"
# echoDurationInSections $START_TIME

# test x264
START_TIME=$(currentTimeInSeconds)
echoSection "run test x264 encoding"
$4/bin/ffmpeg -y -i "$2/test.mp4" -c:v "libx264" -vf scale=1280:-2 -an "$3/test-x264.mp4" > "$3/test-x264.log" 2>&1
checkStatus $? "test x264"
echoDurationInSections $START_TIME

# test vp8
# START_TIME=$(currentTimeInSeconds)
# echoSection "run test vp8 encoding"
# $4/bin/ffmpeg -y -i "$2/test.mp4" -c:v "libvpx" -an "$3/test-vp8.webm" > "$3/test-vp8.log" 2>&1
# checkStatus $? "test vp8"
# echoDurationInSections $START_TIME

# test vp9
# START_TIME=$(currentTimeInSeconds)
# echoSection "run test vp9 encoding"
# $4/bin/ffmpeg -y -i "$2/test.mp4" -c:v "libvpx-vp9" -an "$3/test-vp9.webm" > "$3/test-vp9.log" 2>&1
# checkStatus $? "test vp9"
# echoDurationInSections $START_TIME

# test lame mp3
# START_TIME=$(currentTimeInSeconds)
# echoSection "run test lame mp3 encoding"
# $4/bin/ffmpeg -y -i "$2/test.mp4" -c:a "libmp3lame" -vn "$3/test-lame.mp3" > "$3/test-lame.log" 2>&1
# checkStatus $? "test lame mp3"
# echoDurationInSections $START_TIME

# test aac
START_TIME=$(currentTimeInSeconds)
echoSection "run test aac encoding"
$4/bin/ffmpeg -y -i "$2/test.mp4" -c:a "aac" -vn "$3/test-aac.m4a" > "$3/test-aac.log" 2>&1
checkStatus $? "test aac"
echoDurationInSections $START_TIME

# test pcm
START_TIME=$(currentTimeInSeconds)
echoSection "run test pcm encoding"
$4/bin/ffmpeg -y -i "$2/test.mp4" -ar 48000 -vn "$3/test-pcm.wav" > "$3/test-pcm.log" 2>&1
checkStatus $? "test pcm"
echoDurationInSections $START_TIME

if [[ "${ENABLE_AVISYNTHPLUS}" == "TRUE" ]]
then
    # test avisynth
    OLD_DIR=$PWD
    START_TIME=$(currentTimeInSeconds)
    echoSection "run test AviSynthPlus script"
    cd $3/tool/lib
    $4/bin/ffmpeg -y -i "$2/test-avisynth.avs"  -c:v "libx264" -an "$3/test-avisynth.mp4" > "$3/test-avisynth.log" 2>&1
    checkStatus $? "test AviSynthPlus"
    echoDurationInSections $START_TIME
    cd $OLD_DIR
fi
