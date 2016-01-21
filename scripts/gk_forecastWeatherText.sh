#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
#curl --silent "http://weather.yahooapis.com/forecastrss?w=684090&u=c" | grep -E -A2 '(Forecast:)' | sed -e 's/Forecast://' -e 's/<br \/>/°C/' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/<BR \/>//' -e '/^$/d' -e 's/\(.*\) Low/\1°C Low/' -e 's/<description>//' -e 's/<\/description>//'
curl --silent "http://weather.yahooapis.com/forecastrss?w=12797587&u=c" | grep -E -A2 '(Forecast:)' | sed -e 's/Forecast://' -e 's/<br \/>/°C/' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/<BR \/>//' -e '/^$/d' -e 's/\(.*\) Low/\1°C Low/' -e 's/<description>//' -e 's/<\/description>//'