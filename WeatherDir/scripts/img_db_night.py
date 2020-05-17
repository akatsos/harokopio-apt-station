#!/usr/bin/env python3

import sys, psycopg2, datetime
from configparser import ConfigParser

config = ConfigParser()
config.read("/home/pi/WeatherDir/scripts/db_config.ini")

max_elevation = sys.argv[1]
img_name = sys.argv[2]

#Getting the date, time, name of satellite, enhancement from the name of the image. Delimiter is _ 
img_date, img_time, sat_name = img_name.split("_")

#Getting the year, month, day and hour, minutes from img_date, img_time to add to datetime.date and datetime.time
img_year, img_month, img_day = img_date.split("-")
img_hour, img_minute = img_time.split("-")

#Creating the name and path of every image
img_name_thermal = img_name + "_Thermal"
img_name_mcir = img_name + "_MCIR"
img_name_crp = img_name + "_crp"


img_path_thermal = img_date + '_' + img_time + '/' + img_name_thermal + '.png'
img_path_mcir = img_date + '_' + img_time + '/' + img_name_mcir + '.png'
img_path_crp = img_date + '_' + img_time + '/' + img_name_crp + '.png'


#Creating image and pass id
pass_id = str(img_year[-2:]) + str(img_month) + str(img_day) + str(img_hour) + str(img_minute)
img_id_mcir = pass_id + str(1)
img_id_thermal = pass_id + str(2)

#Connect to db
conn = psycopg2.connect('host={} user={} password={} dbname={}'.format(config.get('DATABASE', 'host'), config.get('DATABASE', 'user'), config.get('DATABASE', 'password'), config.get('DATABASE', 'dbname')))
cur = conn.cursor()

#INSERT Pass and Images
cur.execute("INSERT INTO sat_passes (id, date, time, max_elevation, sat_name, path_crp_img) VALUES(%s, %s, %s, %s, %s, %s)", (int(pass_id), datetime.date(int(img_year), int(img_month), int(img_day)), datetime.time(int(img_hour), int(img_minute)), int(max_elevation) ,sat_name, img_path_crp))

#MCIR
cur.execute("INSERT INTO sat_images (id, pass_id, path, img_name, enhancement) VALUES(%s, %s, %s, %s, %s)", (int(img_id_mcir), int(pass_id), img_path_mcir, img_name_mcir, "MCIR"))

#Thermal
cur.execute("INSERT INTO sat_images (id, pass_id, path, img_name, enhancement) VALUES(%s, %s, %s, %s, %s)", (int(img_id_thermal), int(pass_id), img_path_thermal, img_name_thermal, "Thermal"))

#Delete Pass from Future_Passes
cur.execute("DELETE FROM future_passes WHERE date = %s AND time = %s", (datetime.date(int(img_year), int(img_month), int(img_day)), datetime.time(int(img_hour), int(img_minute))))

conn.commit()
cur.close()
conn.close()