#!/bin/bash

function getPlatform {
    case $(uname -s) in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
   if [ ${machine} = Linux ]; then
       if [ $(cat /proc/cpuinfo | grep -c  Raspberry) -gt 0 ]; then
           if [ $(getconf LONG_BIT) -eq 32 ]; then
               machine=Raspberry32
            elif [ $(getconf LONG_BIT) -eq 64 ]; then
               machine=Raspberry64
           fi
       fi
   fi
    echo ${machine}
}


platform=$(getPlatform)
if [ ${platform} = Linux -o ${platform} = Raspberry32 -o ${platform} = Raspberry64 ]; then
    CLI_DIR=/opt/arduino-cli
    export PATH=$CLI_DIR/bin:$PATH
    LIBDIR=$HOME/Arduino/libraries
elif [ ${platform} = Mac ]; then
    LIBDIR=$HOME/Documents/Arduino/libraries
else
  echo "Unsupported Platform: ${platform}"
  exit 1;
fi

# Set up cli on Linux - on OSX just use "brew install arduino-cli"
if [ ${platform} = Linux -o ${platform} = Raspberry32 -o ${platform} = Raspberry64 ]; then
    if [ ! -f  $CLI_DIR/bin/arduino-cli ]
    then
        echo "Running setup"
        mkdir $CLI_DIR
        pushd $CLI_DIR
        if [ ${platform} = Raspberry32 ]; then
            mkdir -p $CLI_DIR/bin
            cd $CLI_DIR/bin
            url=https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv6.tar.gz
            fname=$(basename $url)
            curl -OL ${url}
            tar -xf ${fname}
        else
            curl -SL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
        fi
        popd
        arduino-cli config init
        arduino-cli core update-index
        arduino-cli core install  arduino:avr
    fi
fi

# arduino-cli board list
# arduino-cli lib search debouncer

# For SEN0137 Temperature and Humidity sensor
arduino-cli lib install "DHT sensor library for ESPx"

# For DFR0198: Waterproof DS18B20 Sensor Kit
arduino-cli lib install OneWire

# JSON
arduino-cli lib install ArduinoJson

# Wifi for Wifi Uni
# arduino-cli lib install WiFiNINA

# DEFOBOT EC
#wget https://github.com/DFRobot/DFRobot_EC/archive/master.zip
#unzip master.zip
#rm master.zip
#mv DFRobot_EC-master $LIBDIR
git clone https://github.com/linucks/DFRobot_EC.git $LIBDIR/DFRobot_EC

# DEFOBOT pH
git clone https://github.com/linucks/DFRobot_PH.git $LIBDIR/DFRobot_PH
