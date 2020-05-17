#!/usr/bin/env python3

from pysolar.solar import *
import datetime

date = datetime.datetime.now(pytz.utc)

sun_altitude = get_altitude(37.96, 23.7, date)

print(sun_altitude)