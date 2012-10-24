#!/bin/bash
#
# Author: Mohammad Rashid Ali Ahmad
# Author email: rash.dev@hotmail.com
#
# URL to search for Country/City
# http://www.islamicfinder.org/prayer_search.php#2

###############################################################################
###                        CONFIGURATION SECTION BEGIN                      ###
###############################################################################

# The URL of the search query from islamic finder
webURL="http://www.islamicfinder.org/prayer_service.php?country=germany&city=paderborn&state=07&zipcode=&latitude=51.7167&longitude=8.7667&timezone=1&HanfiShafi=2&pmethod=1&fajrTwilight1=10&fajrTwilight2=10&ishaTwilight=10&ishaInterval=30&dhuhrInterval=1&maghribInterval=1&dayLight=1&simpleFormat=xml"

# Select the color in which you want the current Salah to be highlighted
# Black, Red, Green, Yellow, Blue, Magenta, Cyan, White
currColor="Yellow"
currColorWarning="Red"

# When to use the warning color for the Salah in seconds (1800 Sec = 30 mins)
warningTime=1800

# If using a file to store info -> complete path of file and name
# Note: If you leave this empty then a web fetch is performed every time
#       Giving a file name will perform a webfetch only on date change
#SalahTimesFile="/tmp/SalahTimes.xml"
SalahTimesFile=""

# Proxy information - leave empty if on direct internet connection
proxyUsername=""
proxyPassword=""
proxyServer=""
proxyPort=""

###############################################################################
###                        CONFIGURATION SECTION END                        ###
###############################################################################

# Variables to hold the calculated time in seconds
fTime=0
sTime=0
dTime=0
aTime=0
mTime=0
iTime=0
currTime=0

###
# Print the time in color
#
# @param:   $1 -> The color in which the string is to be echoed
#           $2 -> The string to be echoed
###
printInColor()
{
    # echo -e
    #       enables escape sequence
    #
    # \033[
    #       starts the escape sequence
    #
    # 32m
    #       prints in green color
    #       echo -e "\033[32m Hello World"          => prints Hello World in green color
    #       Note: All text after this will still be in green
    #
    #       30m => Black
    #       31m => Red
    #       32m => Green
    #       33m => Yellow
    #       34m => Blue
    #       35m => Magenta
    #       36m => Cyan
    #       37m => White
    #
    # 0m
    #       returns to plain normal mode
    #       echo -e "\033[0m"                       => returns to normal mode
    #       echo -e "\033[32m Hello World\033[0m"   => will print Hello World in green and
    #                                               all after that in normal


#    echo -e "\033[31;5;148m$1\033[39m"
#    echo -e "\033[1;32m$1\033[0m"

    case "$1" in
        Black)
            colorCode="30m"
            ;;
        Red)
            colorCode="31m"
            ;;
        Green)
            colorCode="32m"
            ;;
        Yellow)
            colorCode="33m"
            ;;
        Blue)
            colorCode="34m"
            ;;
        Magenta)
            colorCode="35m"
            ;;
        Cyan)
            colorCode="36m"
            ;;
        White)
            colorCode="37m"
            ;;
        *)
            colorCode="30m"
            ;;
    esac

    echo -e "\033[$colorCode$2\033[0m"
}

###
# Calculates the time in 24H format to its equivalent in seconds
#
# @param:   $1 -> The time to be Calculated to seconds
# @return:  $sec -> Calculated time in seconds
###
getSeconds()
{
    # Split the HH:MM:SS string with the delimiter :
    IFS=: read h m s <<<"${1%.*}"

    # Convert the h m s to base 10 - else 08 would be treated as base 8
    h=$((10#$h))
    m=$((10#$m))
    s=$((10#$s))

    # Calculate the time in seconds as h*3600 + m*60 + s
    sec="$(($s+$m*60+$h*3600))"
}

###
# Convert time to seconds. This is actual calculation
# Input time should be of HH:MM:SS or hh:mm:ss with : as separator
#
# Will take the IN time from fTimeHMS and sets the converted time in seconds to fTime
###
time2Seconds()
{
    getSeconds $fTimeHMS
    fTime=$sec
    getSeconds $sTimeHMS
    sTime=$sec
    getSeconds $dTimeHMS
    dTime=$sec
    getSeconds $aTimeHMS
    aTime=$sec
    getSeconds $mTimeHMS
    mTime=$sec
    getSeconds $iTimeHMS
    iTime=$sec
}

###
# Converts the seconds for the time to the seconds for the time as 24 hrs
#
# Expects that atleast the Fajr and Sunrise times are before 12:00 noon
# The logic is
#   Time1 (7:30) is compared with Time2 (5:00)
#   if Time1 < Time2
#   Time1 = Time1 + 43200 (Time1 has crossed 12:00, so should add 12:00 as seconds to it)
#
# Example:
#   Actual times in 12h     Seconds For 12h     Calculated seconds for 24h
#   FajrTime    = 5:07      18420               18420
#   SunriseTime = 7:10      25800               25800
#                       < CROSSES 12:00 >
#   DuhrTime    = 1:30      5400                48600
#   AsrTime     = 4:45      17100               60300
#   MagribTime  = 7:25      26700               69900
#   IshaTime    = 9:00      32400               75600
###
convertTo24()
{
    # Check if Sunrise time is less than Fajr time
    if [ $sTime -lt $fTime ]
    then
        # Sunrise time IS less than Fajr time so add 12:00 as seconds to all the following times
        sTime=$((sTime+43200))
        dTime=$((dTime+43200))
        aTime=$((aTime+43200))
        mTime=$((mTime+43200))
        iTime=$((iTime+43200))
    else
        # Check if Duhur time is less than Sunrise time
        if [ $dTime -lt $sTime ]
        then
            # Duhr time IS less than Sunrise time so add 12:00 as seconds to all the following times
            dTime=$((dTime+43200))
            aTime=$((aTime+43200))
            mTime=$((mTime+43200))
            iTime=$((iTime+43200))
        else
            # Check if Asr time is less than Duhur time
            if [ $aTime -lt $dTime ]
            then
                # Asr time IS less than Duhr time so add 12:00 as seconds to all the following times
                aTime=$((aTime+43200))
                mTime=$((mTime+43200))
                iTime=$((iTime+43200))
            else
                # Check if Magrib time is less than Asr time
                if [ $mTime -lt $aTime ]
                then
                    # Magrib time IS less than Asr time so add 12:00 as seconds to all the following times
                    mTime=$((mTime+43200))
                    iTime=$((iTime+43200))
                else
                    # Check if Isha time is less than Magrib time
                    if [ $iTime -lt $mTime ]
                    then
                        # Isha time IS less than Magrib time so add 12:00 as seconds to all the following times
                        iTime=$((iTime+43200))
                    fi
                fi
            fi
        fi
    fi
}

###
# Checks the color type to use to echoing the colored string.
#
# Needs to variables to be set $currColor and $currColorWarning indicating
# the color for the current Salah and the warning color for the current Salah
# Also needs the $warningTime to be set
#
# @param:   $1 -> The time for which the color is to be decided in seconds
#           $2 -> The string which has to be echoed
###
decideColor()
{
    currTime="$(($1-$currTime))"
    if [ $currTime -gt $warningTime ]
    then
        printInColor $currColor $2
    else
        printInColor $currColorWarning $2
    fi
}

###
# Checks if the current time (HH:MM) in seconds is less than the individual times
#
# Example:
#   Current time  10:30
#   Actual times in 12h
#   FajrTime    = 5:07
#   SunriseTime = 7:10    => will be marked in a different color
#   DuhrTime    = 1:30
#   AsrTime     = 4:45
#   MagribTime  = 7:25
#   IshaTime    = 9:00
###
setColorForTime()
{
    # Get the current time and convert to seconds
    currTime=$(date +%H:%M)

    # Convert current time to seconds
    getSeconds $currTime
    currTime=$sec

    # Decide on the color based on the current time
    if [ $currTime -lt $fTime ]
    then
        decideColor $fTime "Fajr\t\t\t$fTimeHMS"
        echo -e "Sunrise\t$sTimeHMS"
        echo -e "Duhur\t$dTimeHMS"
        echo -e "Asr\t\t\t$aTimeHMS"
        echo -e "Magrib\t$mTimeHMS"
        echo -e "Isha\t\t\t$iTimeHMS"
    else
        if [ $currTime -lt $sTime ]
        then
            echo -e "Fajr\t\t\t$fTimeHMS"
            decideColor $sTime "Sunrise\t$sTimeHMS"
            echo -e "Duhur\t$dTimeHMS"
            echo -e "Asr\t\t\t$aTimeHMS"
            echo -e "Magrib\t$mTimeHMS"
            echo -e "Isha\t\t\t$iTimeHMS"
        else
            if [ $currTime -lt $dTime ]
            then
                echo -e "Fajr\t\t\t$fTimeHMS"
                echo -e "Sunrise\t$sTimeHMS"
                decideColor $dTime "Duhur\t$dTimeHMS"
                echo -e "Asr\t\t\t$aTimeHMS"
                echo -e "Magrib\t$mTimeHMS"
                echo -e "Isha\t\t\t$iTimeHMS"
            else
                if [ $currTime -lt $aTime ]
                then
                    echo -e "Fajr\t\t\t$fTimeHMS"
                    echo -e "Sunrise\t$sTimeHMS"
                    echo -e "Duhur\t$dTimeHMS"
                    decideColor $aTime "Asr\t\t\t$aTimeHMS"
                    echo -e "Magrib\t$mTimeHMS"
                    echo -e "Isha\t\t\t$iTimeHMS"
                else
                    if [ $currTime -lt $mTime ]
                    then
                        echo -e "Fajr\t\t\t$fTimeHMS"
                        echo -e "Sunrise\t$sTimeHMS"
                        echo -e "Duhur\t$dTimeHMS"
                        echo -e "Asr\t\t\t$aTimeHMS"
                        decideColor $mTime "Magrib\t$mTimeHMS"
                        echo -e "Isha\t\t\t$iTimeHMS"
                    else
                        if [ $currTime -lt $iTime ]
                        then
                            echo -e "Fajr\t\t\t$fTimeHMS"
                            echo -e "Sunrise\t$sTimeHMS"
                            echo -e "Duhur\t$dTimeHMS"
                            echo -e "Asr\t\t\t$aTimeHMS"
                            echo -e "Magrib\t$mTimeHMS"
                            decideColor $iTime "Isha\t\t\t$iTimeHMS"
                        else
                            echo -e "Fajr\t\t\t$fTimeHMS"
                            echo -e "Sunrise\t$sTimeHMS"
                            echo -e "Duhur\t$dTimeHMS"
                            echo -e "Asr\t\t\t$aTimeHMS"
                            echo -e "Magrib\t$mTimeHMS"
                            echo -e "Isha\t\t\t$iTimeHMS"
                        fi
                    fi
                fi
            fi
        fi
    fi
}

###
# Get the Salah times from the internet, and prepare the got result in the variable xmlResult
#
# If behind a proxy use one of the following syntax for curl
#   curl --silent -x http://username:passwprd@proxy_server:proxy_port http://www.google.com
#   curl --silent -x http://username@proxy_server:proxy_port http://www.google.com
#   curl --silent -x http://username@proxy_server http://www.google.com
#   curl --silent -x http://proxy_server:proxy_port http://www.google.com
#
# Direct connection - no proxy
#   curl --silent http://www.google.com
###
getSalahTimesFromWeb()
{
    CURL=`which curl`" --silent"
    proxyString=""

    # Prepare the proxy string with username
    if [ "$proxyUsername" != "" ]
    then
        proxyString="-x http://"$proxyUsername
    fi

    # Prepare the proxy string with Password
    if [ "$proxyPassword" != "" ]
    then
        proxyString=$proxyString":"$proxyPassword
    fi

    # Further prepare the proxy string with proxy server
    if [ "$proxyServer" != "" ]
    then
        if [ "$proxyString" = "" ]
        then
            proxyString="-x http://"$proxyServer
        else
            proxyString=$proxyString"@"$proxyServer
        fi
    fi

    # Further prepare the proxy string with proxy port
    if [ "$proxyPort" != "" ]
    then
        proxyString=$proxyString":"$proxyPort
    fi

    # Save the web result in a file if the user wants by giving a file name, else use variable
    if [ "$SalahTimesFile" = "" ]
    then
        # Get the xml result of the web query direct connection without proxy
        xmlResult=$($CURL $proxyString $webURL)
    else
        # Insert into the file the datestamp
        # This is needed to check if we need to get the Salah times again for today
        echo $(date +%F) > $SalahTimesFile

        # Save the xml to a file
        $CURL $proxyString $webURL >> $SalahTimesFile

        # Read the file into the variable
        xmlResult=`cat $SalahTimesFile`
    fi
}

###############################################################################
###                               MAIN PORTION                              ###
###############################################################################

# Check if we need to get the new results from the web or we already have it
if [ "$SalahTimesFile" != "" ]
then
    if [ -e $SalahTimesFile ]
    then
        # Get the date the Salah times file was created (first line in the file)
        fileDate=$(head -n 1 $SalahTimesFile)
        # Get the current date
        currDate=$(date +%F)
        
        # Compare that the file date and today are same
        if [ "$currDate" != "$fileDate" ]
        then
            # Not same get the file again
            getSalahTimesFromWeb
        fi
    else
        # File dosent exists get from internet
        getSalahTimesFromWeb
    fi
else
    # We have full time internet - 
    # So we dont need file and we will get Salah time from internet every time
    getSalahTimesFromWeb
fi

# Remove all new line characters
xmlResult=$(echo $xmlResult | sed ':a;N;$!ba;s/\n//g')

# Remove spaces from result and put back in line
xmlResult=$(echo $xmlResult | sed 's/ //g')

# Extract the different times from the resulting XML
fTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<fajr>\(.*\)<\/fajr>.*/\1/p')
sTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<sunrise>\(.*\)<\/sunrise>.*/\1/p')
dTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<dhuhr>\(.*\)<\/dhuhr>.*/\1/p')
aTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<asr>\(.*\)<\/asr>.*/\1/p')
mTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<maghrib>\(.*\)<\/maghrib>.*/\1/p')
iTimeHMS=$(echo $xmlResult | sed -n -e 's/.*<isha>\(.*\)<\/isha>.*/\1/p')

# Convert the found times for Salah to seconds
time2Seconds

# Convert the Salah times in seconds to its 24 hrs equivalent in seconds
convertTo24

# Decide the Salah time color based on current time
setColorForTime

# Success return code
exit 0