#!/bin/bash

#Truncate future_passes table
python3 /home/pi/WeatherDir/scripts/future_passes/truncate_table.py

#Calculate the future passes for each satellite
/home/pi/WeatherDir/scripts/future_passes/future_dates.sh "NOAA 15" 
/home/pi/WeatherDir/scripts/future_passes/future_dates.sh "NOAA 18" 
/home/pi/WeatherDir/scripts/future_passes/future_dates.sh "NOAA 19"
