#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
# Base URL to search for Country/City
# http://www.islamicfinder.org/prayer_search.php#2

# UNUSED FILE - CHECK gk_prayerTime for getting both prayer time and hijri date

BASEURL="http://www.islamicfinder.org/prayer_service.php?lang=english&simpleFormat=xml"

CITY="San_Jose"
COUNTRY="US"
STATE="CA"
STATE_NAME="California"
COUNTRY_CODE_GEOIP="US"
LATITUDE="37.3422"
LONGITUDE="-121.9052"
TIMEZONE="-8"
DAYLIGHT="1"
PMETHOD="5"
HANFISHAFI="1"

#sanjose="http://www.islamicfinder.org/prayer_service.php?latitude=37.3422&longitude=-121.9052&timezone=-8&pmethod=5&daylight=1&city=San_Jose&state=CA&state_name=California&country_code_geoip=US&country=usa&lang=english&simpleFormat=xml"
#url=$sanjose

URL=$BASEURL"&hanfishafi="$HANFISHAFI"&country="$COUNTRY"&state="$STATE"&state_name"$STATE_NAME"&latitude="$LATITUDE"&longitude="$LONGITUDE"&timezone="$TIMEZONE"&daylight="$DAYLIGHT"&pmethod="$PMETHOD
echo $URL

# Get the prayer time and Hijri date  from the URL
res=$(curl --silent $URL)
line=$(echo $res | sed ':a;N;$!ba;s/\n//g') 

# Hijri date is all between <hijri> and </hijri>
echo $line | sed -n -e 's/.*<hijri>\(.*\)<\/hijri>.*/\1/p'