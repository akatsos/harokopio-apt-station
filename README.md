# harokopio-apt-station

An [Automatic Picture Transmission](https://en.wikipedia.org/wiki/Automatic_picture_transmission) station created for my Bachelor's Thesis.

Said thesis can be found [here](http://estia.hua.gr/browse/23032). (Greek)

All the equipment (antenna, Raspberry Pi etc) is located at the Harokopio University of Athens.

The website of the application is: http://83.212.242.246/

----

The scripts in the WeatherDir as well as the cronjobs in the crontab file are being run on a Raspberry Pi 3 Model B.

The Raspberry transfers data to a host machine located in the premisses of the Harokopio University.

Said host machine contains the PostgreSQL DB and the NodeJS application.

For SSH connection between the Raspi and the host machine, SSH keys are being used.

----
The logic of the automation is based in various old examples found online but with a lot of changes to accomodate for deprecated dependencies and database / application server support.
