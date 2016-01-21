#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
# Get current weather image
curl --silent "https://weather.yahoo.com/united-states/california/san-jose-12797613/" | grep "current-weather" | sed "s/.*background:url(\('.*'\)) no-repeat scroll.*/\1/" | xargs curl --silent -o /tmp/weather.png
# Get current weather condition
curl --silent "http://weather.yahooapis.com/forecastrss?w=12797613&u=c" | grep -E '(Current Conditions:|C<BR)' | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' -e 's/<\/b>//' -e 's/<BR \/>//' -e 's/\(.*\) C/\1°C/' -e '/^$/d' -e 's/<description>//' -e 's/<\/description>//'