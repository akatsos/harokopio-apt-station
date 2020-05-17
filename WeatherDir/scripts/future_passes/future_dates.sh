#!/bin/bash

Pass_Start_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | head -1 | cut -d " " -f 1`
Pass_End_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | tail -1 | cut -d " " -f 1`

Max_Elevation=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" | awk -v maxEl=0 '{if($5>maxEl){maxEl=$5}}END{print maxEl}'`

#Get the passes of the next 5 days
for ((i=0;i<5;i++))
do
	date=$(date -u --date="$i day" +%Y%m%d)

	while [[ `date -ud @${Pass_Start_UT} +%Y%m%d` -eq $date ]] 
	do
		
		Pass_Duration=`expr $Pass_End_UT - $Pass_Start_UT`
	
		Date_For_Name=`date -ud @${Pass_Start_UT} +%Y-%m-%d_%H-%M`
	
		if [ $Max_Elevation -gt 29 ]
		then
			Sat_Name=$1
			Sat_Name_File="${Sat_Name// /-}"
			Day_Passes+="$Sat_Name_File.$Max_Elevation.$Date_For_Name,"
		fi	
	
		Next_Pass=`expr $Pass_End_UT + 60`
		
		Pass_Start_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | head -1 | cut -d " " -f 1`
		Pass_End_UT=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | tail -1 | cut -d " " -f 1`
		
		Max_Elevation=`/usr/bin/predict -t /home/pi/WeatherDir/scripts/weather.tle -p "${1}" $Next_Pass | awk -v maxEl=0 '{if($5>maxEl){maxEl=$5}}END{print maxEl}'`

	done
done 

python3 /home/pi/WeatherDir/scripts/future_passes/future_db.py $Day_Passes
