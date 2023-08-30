#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = output directory
# $5 = CPUs
# $6 = FFmpeg version

# load functions
. $1/functions.sh
set -x
SOFTWARE=ffmpeg

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source


  if [[ "${BUILD_FROM_MAIN}" == "TRUE" ]]
  then
    git clone  https://git.ffmpeg.org/ffmpeg.git
    cd ffmpeg
    checkStatus $? "change directory failed"
    export FFMPEG_DIR="ffmpeg"

  else
    curl -O https://ffmpeg.org/releases/ffmpeg-$6.tar.bz2
    checkStatus $? "download of ${SOFTWARE} failed"

    # unpack ffmpeg
    bunzip2 ffmpeg-$6.tar.bz2
    tar -xf ffmpeg-$6.tar
    cd "ffmpeg-$6/"
    checkStatus $? "change directory failed"
    export FFMPEG_DIR="ffmpeg-$6"
  fi

}

configure_build () {

  cd "$2/${SOFTWARE}/${FFMPEG_DIR}/"
  checkStatus $? "change directory failed"

  # prepare build
  FF_FLAGS="-L${3}/lib -I${3}/include"
  export LDFLAGS="$FF_FLAGS"
  export CFLAGS="$FF_FLAGS"
  export MACOSX_DEPLOYMENT_TARGET=11.7

  FFMPEG_EXTRAS=''
  
  if [[ "${ENABLE_FFPLAY}" == "TRUE" ]]
  then
       FFMPEG_EXTRAS="${FFMPEG_EXTRAS} --enable-sdl2"
  fi

  if [[ "${ENABLE_AVISYNTHPLUS}" == "TRUE" ]]
  then
       FFMPEG_EXTRAS="${FFMPEG_EXTRAS} --enable-avisynth"
  fi


  # --pkg-config-flags="--static" is required to respect the Libs.private flags of the *.pc files
  ./configure --prefix="$4" --enable-gpl --pkg-config-flags="--static" --pkg-config=$3/bin/pkg-config \
      --disable-encoders --enable-libx264 --enable-encoder=libx264 --enable-encoder=aac --enable-encoder=pcm_s16le \
      --enable-libaom --enable-libx265 --enable-libvpx --enable-libmp3lame \
      --enable-runtime-cpudetect \
      --enable-audiotoolbox --enable-videotoolbox \
      --disable-filters --enable-filter=scale --enable-filter=aresample \
      --disable-devices --disable-doc \
      --enable-lto --enable-nonfree --enable-opencl --enable-small ${FFMPEG_EXTRAS}

  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/${FFMPEG_DIR}/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"


}

make_compile () {

  cd "$2/${SOFTWARE}/${FFMPEG_DIR}/"
  checkStatus $? "change directory failed"

  # build
  make -j $5
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

}

build_main () {


  # ffmpeg we always want to rebuild

  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@
