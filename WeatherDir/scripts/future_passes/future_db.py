#!/usr/bin/env python3

import sys, psycopg2, datetime
from configparser import ConfigParser

config = ConfigParser()
config.read("/home/pi/WeatherDir/scripts/db_config.ini")

#Connect to db
conn = psycopg2.connect('host={} user={} password={} dbname={}'.format(config.get('DATABASE', 'host'), config.get('DATABASE', 'user'), config.get('DATABASE', 'password'), config.get('DATABASE', 'dbname')))
cur = conn.cursor()

Day_Passes = sys.argv[1]
Single_Pass = Day_Passes.split(",")

x = len(Single_Pass) - 1

for i in range(0, x):
	sat_name, max_elevation, date_time_string = Single_Pass[i].split(".")

	pass_date, pass_time = date_time_string.split("_")
	pass_year, pass_month, pass_day = pass_date.split("-")
	pass_hour, pass_minute = pass_time.split("-")

	#print(pass_year, pass_month, pass_day, pass_hour, pass_minute)
	cur.execute("INSERT INTO future_passes (date, time, max_elevation, sat_name) VALUES(%s, %s, %s, %s)", (datetime.date(int(pass_year), int(pass_month), int(pass_day)), datetime.time(int(pass_hour), int(pass_minute)), int(max_elevation) ,sat_name))

conn.commit()
cur.close()
conn.close()