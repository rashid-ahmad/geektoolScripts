#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#

# Use files to collect and handle information or just variables
USEFILES=TRUE

YAHOO_URL="http://weather.yahooapis.com/forecastrss?w=12797613&u=c"
GKTL_FILE_WEATHER=$TMPDIR/GeekTool_WeatherTxt.txt

GKTL_CITY=""
GKTL_CURRENT=""
GKTL_FORECAST=""
GKTL_WEATHERIMAGE=""

if [ $USEFILES=TRUE ] ;
	then
		GKTL_FILE_CITY=$TMPDIR/GeekTool_WeatherCityName.txt
		GKTL_FILE_CURRENT=$TMPDIR/GeekTool_WeatherCurrentCondition.txt
		GKTL_FILE_FORECAST=$TMPDIR/GeekTool_WeatherForecast.txt
		GKTL_FILE_WEATHER_IMAGE=./WeatherImages/GeekTool_WeatherImage.gif
fi

# Check if file exists
#if [ ! -f $GKTL_FILE_WEATHER ]
#	then
#		curl --silent $YAHOO_URL > $GKTL_FILE_WEATHER
#fi

# Get the weather report now
curl --silent $YAHOO_URL > $GKTL_FILE_WEATHER

# <yweather:location city="San Jose" region="CA"   country="United States"/>
GKTL_CITY=$(grep -E '(<yweather:location city=")' $GKTL_FILE_WEATHER | sed -n -e 's/.*<yweather:location city="\(.*\)" region.*/\1/p')

# <b>Current Conditions:</b><br />
# Mostly Cloudy, 14 C<BR />
GKTL_CURRENT=$(grep -E '(Current Conditions:|C<BR)' $GKTL_FILE_WEATHER | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/\(.*\) C/\1°C/' -e '/^$/d' -e 's/<description>//' -e 's/<\/description>//')

# <BR /><b>Forecast:</b><BR />
# Thu - AM Clouds/PM Sun. High: 19 Low: 13<br />
# Fri - Rain. High: 16 Low: 10<br />
# Sat - Showers. High: 14 Low: 7<br />
# Sun - Partly Cloudy. High: 15 Low: 6<br />
# Mon - Partly Cloudy. High: 17 Low: 7<br />
# <br />
GKTL_FORECAST=$(grep -E -A2 '(Forecast:)' $GKTL_FILE_WEATHER | sed -e 's/Forecast://' -e 's/<br \/>/°C/' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/<BR \/>//' -e '/^$/d' -e 's/\(.*\) Low/\1°C Low/' -e 's/<description>//' -e 's/<\/description>//' -e 's/Mon/\\nMon/' -e 's/Tue/\\nTue/' -e 's/Wed/\\nWed/' -e 's/Thu/\\nThu/' -e 's/Fri/\\nFri/' -e 's/Sat/\\nSat/' -e 's/Sun/\\nSun/' )

# Get the weather icon
# <img src="http://l.yimg.com/a/i/us/we/52/28.gif"/><br />
GKTL_WEATHERIMAGE=$(grep -E '(<img src=")' $GKTL_FILE_WEATHER | sed 's/[^"]*"\([^"]*\)".*/\1/')
curl --silent $GKTL_WEATHERIMAGE > $GKTL_FILE_WEATHER_IMAGE

# Start echoing to files
echo $GKTL_CITY > $GKTL_FILE_CITY
echo $GKTL_CURRENT > $GKTL_FILE_CURRENT
echo -e $GKTL_FORECAST > $GKTL_FILE_FORECAST

# for debug echo findings
#echo $GKTL_CITY
#echo $GKTL_CURRENT
#echo -e $GKTL_FORECAST