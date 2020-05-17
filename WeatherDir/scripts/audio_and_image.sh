#!/bin/bash

# $1 = Satellite Name
# $2 = Satellite Frequency
# $3 = Date_For_Name 
# $4 = weather.tle Path
# $5 = Pass_Start_UT			Time Satellite reaches 0 degrees Elevation
# $6 = Pass_Duration			In seconds
# $7 = Max_Elevation

#Removing the space from the satellite's  name and adding it to the file name
Sat_Name=$1
Sat_Name_File="${Sat_Name// /-}"
FileName="$3_$Sat_Name_File"

Pass_Start=`expr $5 + 90`

#Check if an instance of rtl_fm is already running. (Recording another pass)
#If not, start recording the pass
if (( $(pgrep -x rtl_fm) ))
then
	exit 1
else
	sudo timeout $6 rtl_fm -f ${2}M -s 70k -g 20 -p 55 -E wav -E deemp -F 9 - | /usr/bin/sox -t raw -e signed -c 1 -b 16 -r 70000 - /home/pi/WeatherDir/audio/"$FileName".wav rate 11025
fi

#Check the size of the created wav file.
#If the size is 44 bytes it means that something went wrong with rtl_fm and the wav file created from sox only contains
#the RIFF header and the fmt/data subchunks with no data passed from rtl_fm.
#In this case no images are created.
file_size=$(stat -c%s /home/pi/WeatherDir/audio/"$FileName".wav)

if [[ -e /home/pi/WeatherDir/audio/"$FileName".wav && $file_size -gt 45 ]]
then

	#Create a directory for every pass
	mkdir -p /home/pi/WeatherDir/passes/$3
	
	#Create maps/images and save the images in the directory of the pass
	/usr/local/bin/wxmap -T "${1}" -H ${4} -p 0 -l 0 -o $Pass_Start /home/pi/WeatherDir/maps/${3}-map.png
	
	/usr/local/bin/wxtoimg -m /home/pi/WeatherDir/maps/${3}-map.png -e therm -c /home/pi/WeatherDir/audio/$FileName.wav /home/pi/WeatherDir/passes/$3/${FileName}_Thermal.png
	
	/usr/local/bin/wxtoimg -m /home/pi/WeatherDir/maps/${3}-map.png -e mcir-precip -c /home/pi/WeatherDir/audio/$FileName.wav /home/pi/WeatherDir/passes/$3/${FileName}_MCIR.png
	
	#HVC enhancement requires a solar elevation angle of more than 15 degrees
	Sun_Elevation=$(python3 /home/pi/WeatherDir/scripts/sun_elev.py)
	
	#If it is day an HVC image gets created along the Thermal and MCIR ones.
	#img_db_day		inserts the info of 3 images (Thermal, MCIR, HVC) to the database whereas
	#img_db_night 	inserts the info of 2 images (Thermal, MCIR)
	if (( $(echo "${Sun_Elevation} > 15" | bc -l) ))
	then
		/usr/local/bin/wxtoimg -m /home/pi/WeatherDir/maps/${3}-map.png -e hvc-precip -c /home/pi/WeatherDir/audio/$FileName.wav /home/pi/WeatherDir/passes/$3/${FileName}_HVC.png
	
		python3 /home/pi/WeatherDir/scripts/img_db_day.py $7 $FileName
	else
		python3 /home/pi/WeatherDir/scripts/img_db_night.py $7 $FileName
	fi	
	
	#Create a thumbnail for website usage
	convert /home/pi/WeatherDir/passes/$3/${FileName}_MCIR.png -resize 200 /home/pi/WeatherDir/passes/$3/${FileName}_crp.png

	#SCP transfer of images to server
	scp -r /home/pi/WeatherDir/passes/$3 user@IP:/home/user/sat_app/public/sat_images

fi
