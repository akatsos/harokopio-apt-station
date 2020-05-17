#!/bin/bash

#Deletes older than 1 day audio files(wav) ,maps(png) and passes
#Is scheduled to run every Monday and Thursday with a cronjob
#This happens so the RaspPi never runs out of storage space

find /home/pi/WeatherDir/maps -type f -mtime +1 -name '*.png' -delete

find /home/pi/WeatherDir/audio -type f -mtime +1 -name '*.wav' -delete

find /home/pi/WeatherDir/passes -mindepth 1 -maxdepth 1 -type d -mtime +1 -exec rm -rf {} \;
