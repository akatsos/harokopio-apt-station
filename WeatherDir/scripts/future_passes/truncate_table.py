#!/usr/bin/env python3

import sys, psycopg2
from configparser import ConfigParser

config = ConfigParser()
config.read("/home/pi/WeatherDir/scripts/db_config.ini")

#Connect to db
conn = psycopg2.connect('host={} user={} password={} dbname={}'.format(config.get('DATABASE', 'host'), config.get('DATABASE', 'user'), config.get('DATABASE', 'password'), config.get('DATABASE', 'dbname')))
cur = conn.cursor()

cur.execute("TRUNCATE future_passes")

conn.commit()
cur.close()
conn.close()