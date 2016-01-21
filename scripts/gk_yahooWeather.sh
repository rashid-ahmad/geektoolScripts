#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
# Get the weather icon
#curl --silent "http://weather.yahoo.com/germany/north-rhine-westphalia/paderborn-684090/" | grep "current-weather" | sed "s/.*background:url(\('.*'\)) no-repeat scroll.*/\1/" | xargs curl --silent -o /tmp/weather.png

# Current conditions Without °C
curl --silent "http://weather.yahooapis.com/forecastrss?w=684090&u=c" | grep -E '(Current Conditions:|C<BR)' | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/<description>//' -e 's/<\/description>//'

# Current conditions With °C
curl --silent "http://weather.yahooapis.com/forecastrss?w=684090&u=c" | grep -E '(Current Conditions:|C<BR)' | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/\(.*\) C/\1°C/' -e '/^$/d' -e 's/<description>//' -e 's/<\/description>//'

# Forecast with °C
curl --silent "http://weather.yahooapis.com/forecastrss?w=684090&u=c" | grep -E -A2 '(Forecast:)' | sed -e 's/Forecast://' -e 's/<br \/>/°C/' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/<BR \/>//' -e '/^$/d' -e 's/\(.*\) Low/\1°C Low/' -e 's/<description>//' -e 's/<\/description>//'