#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
# Base URL to search for Country/City
# http://www.islamicfinder.org/prayer_search.php#2

res=$(curl --silent "http://www.islamicfinder.org/prayer_service.php?country=germany&city=paderborn&state=07&zipcode=&latitude=51.7167&longitude=8.7667&timezone=1&HanfiShafi=2&pmethod=1&fajrTwilight1=10&fajrTwilight2=10&ishaTwilight=10&ishaInterval=30&dhuhrInterval=1&maghribInterval=1&dayLight=1&simpleFormat=xml")
line=$(echo $res | sed ':a;N;$!ba;s/\n//g') 
echo $line | sed -n -e 's/.*<hijri>\(.*\)<\/hijri>.*/\1/p'