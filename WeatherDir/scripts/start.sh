#!/bin/bash

#Remove all AT jobs. 
#An AT job will be added for every satellite pass in the next 24 hours
for i in `atq | awk '{print $1}'`; do atrm $i; done

#Update weather.txt from the Celestrak site
wget -qr https://www.celestrak.com/NORAD/elements/weather.txt -O /home/pi/WeatherDir/scripts/weather.txt

#Get info from weather.txt for NOAA 15/18/19 and save in weather.tle
grep "NOAA 15" /home/pi/WeatherDir/scripts/weather.txt -A 2 > /home/pi/WeatherDir/scripts/weather.tle
grep "NOAA 18" /home/pi/WeatherDir/scripts/weather.txt -A 2 >> /home/pi/WeatherDir/scripts/weather.tle
grep "NOAA 19" /home/pi/WeatherDir/scripts/weather.txt -A 2 >> /home/pi/WeatherDir/scripts/weather.tle

#Start satellite.sh script with Satellite Name and Satellite Frequency as inputs

/home/pi/WeatherDir/scripts/satellite.sh "NOAA 15" 137.6200
/home/pi/WeatherDir/scripts/satellite.sh "NOAA 18" 137.9125
/home/pi/WeatherDir/scripts/satellite.sh "NOAA 19" 137.1000

#Start the future_passes scripts
/home/pi/WeatherDir/scripts/future_passes/start_FD.sh