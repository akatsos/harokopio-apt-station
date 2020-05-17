#!/bin/bash

# $1 = Satellite Name
# $2 = Satellite Frequency

#Pass_Start/End in Unix Time only
Pass_Start_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | head -1 | cut -d " " -f 1`
Pass_End_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | tail -1 | cut -d " " -f 1`

Max_Elevation=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | awk -v maxEl=0 '{if($5>maxEl){maxEl=$5}}END{print maxEl}'`

#Comparing the date of the pass to the current date (in UTC) to calculate the passes that happen today
#Out of all the passes, only the ones with an Elevation above 30 will get scheduled
while [[ `date -ud @${Pass_Start_UT} +%Y%m%d` -eq `date -u +%Y%m%d` ]] 
do
	Pass_Duration=`expr $Pass_End_UT - $Pass_Start_UT`
	Date_For_Name=`date -ud @${Pass_Start_UT} +%Y-%m-%d_%H-%M`

	if [ $Max_Elevation -gt 29 ]
	then
		echo "${1} Pass"
		#Create AT job
		echo "/home/pi/WeatherDir/scripts/audio_and_image.sh \"${1}\" $2 $Date_For_Name /home/pi/WeatherDir/scripts/weather.tle $Pass_Start_UT $Pass_Duration $Max_Elevation" | at `date -d @${Pass_Start_UT} +"%H:%M %D"`
	fi

	Next_Pass=`expr $Pass_End_UT + 60`
	
	Pass_Start_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | head -1 | cut -d " " -f 1`
	Pass_End_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | tail -1 | cut -d " " -f 1`
	
	Max_Elevation=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | awk -v maxEl=0 '{if($5>maxEl){maxEl=$5}}END{print maxEl}'`
done