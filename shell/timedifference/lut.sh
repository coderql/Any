#!/bin/bash

# ------------------------------------------------------------------------------
# usage - shell help
# ------------------------------------------------------------------------------
usage () {
    echo "Usage: lut [-s timedifference] [-l] [name]                       "
    echo "       -s set person's time zone. +n means n hours before current"
    echo "          time zone, -n means n hours after current time zone. if"
    echo "          this option is set, name is mandatory.                 "
    echo "       -l look up a person's timezone that has been stored, if   "
    echo "          name is set, then it displays this person's timezone,  "
    echo "          if name isn't set, then it displays all persons'       "
    echo "          timezone.                                              "
}

# ------------------------------------------------------------------------------
# getMonth - get previous month or get next month
# Parameter:
#    1. month - get its previous or next month
#    2. flag  - indicate 'previous' or 'next',
#               -1 means previous while 1 means next
# Notes:
#     January's previous month is December;
#     December's next month is January.
# ------------------------------------------------------------------------------
getMonth () {
    local i
    case $(echo $1 | tr '[:upper:]' '[:lower:]') in
        jan* ) i=0 ;; feb* ) i=1 ;;
        mar* ) i=2 ;; apr* ) i=3 ;;
        may* ) i=4 ;; jun* ) i=5 ;;
        jul* ) i=6 ;; aug* ) i=7 ;;
        sep* ) i=8 ;; oct* ) i=9 ;;
        nov* ) i=10 ;; dec* ) i=11 ;;
        * ) echo "$0: Unknow month name $1" >&2; exit 1
    esac
    local pi
    if [ $2 -eq -1 ]; then
        pi=$((i - 1))
        [ $pi -lt 0 ] && pi=11
    fi
    if [ $2 -eq 1 ]; then
        pi=$((i + 1))
        [ $pi -gt 11 ] && pi=0
    fi
    echo ${months[$pi]}
}

# ------------------------------------------------------------------------------
# getDay - get previous day or get next day (day - from Mon to Fri)
# Parameter:
#    1. day - get its previous or next day
#    2. flag  - indicate 'previous' or 'next',
#               -1 means previous while 1 means next
# Notes:
#     Monday's previous day is Sunday;
#     Sunday's next day is Monday.
# ------------------------------------------------------------------------------
getDay () {
    local i
    case $(echo $1 | tr '[:upper:]' '[:lower:]') in
        mon* ) i=0 ;; tue* ) i=1 ;;
        wed* ) i=2 ;; thu* ) i=3 ;;
        fri* ) i=4 ;; sat* ) i=5 ;;
        sun* ) i=6 ;;
        * ) echo "$0: Unkown day $1" >&2; exit 1
    esac
    local pi
    if [ $2 -eq -1 ]; then
        pi=$((i - 1))
        [ $pi -lt 0 ] && pi=6
    fi
    if [ $2 -eq 1 ]; then
        pi=$((i + 1))
        [ $pi -gt 6 ] && pi=0
     fi
     echo ${days[$pi]}
}

# ------------------------------------------------------------------------------
# daysInMonth - get number of days in a specified month
# Parameter:
#    1. month - current month
#    2. year  - current year, help to decide days in Feb.
# Notes:
#     if leap year, number of days in Feb is 28, else is 29.
# ------------------------------------------------------------------------------
daysInMonth () {
    if isLeapYear $2; then
        febdays=29
    fi
    febdays=${febdays:-28}
    local maxdays
    case $(echo $1 | tr '[:upper:]' '[:lower:]') in
        jan* ) maxdays=31 ;; feb* ) maxdays=$febdays ;;
        mar* ) maxdays=31 ;; apr* ) maxdays=30 ;;
        may* ) maxdays=31 ;; jun* ) maxdays=30 ;;
        jul* ) maxdays=31 ;; aug* ) maxdays=31 ;;
        sep* ) maxdays=30 ;; oct* ) maxdays=31 ;;
        nov* ) maxdays=30 ;; dec* ) maxdays=31 ;;
        * ) echo "$0: Unknow month name $1" >&2; exit 1
    esac
    echo $maxdays
}

# ------------------------------------------------------------------------------
# isLeapYear - check if a year is a leap year.
# Parameter:
#    1. year - current year
# ------------------------------------------------------------------------------
isLeapYear () {
    year=$1
    if [ "$((year % 4))" -ne 0 ]; then
        return 1
    elif [ "$((year % 400))" -eq 0 ]; then
        return 0
    elif [ "$((year % 100))" -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

formatHour() {
    if [ ${#1} -eq 2 ] && [ ${1:0:1} -eq 0 ]; then
        echo ${1:1:1}
    else
        echo $1
    fi
}

# ------------------------------------------------------------------------------
# calTime - calculate the exact time
# Parameter:
#    1. year - current time on your system
#    2. operator - later or earlier
#    3. diff - time difference(per hour)
# Notes:
#    Leap year
#    Febuary
#    End of Month, Start of Month
#    End of Year, Start of Year
# ------------------------------------------------------------------------------
calTime () {
    local year=$(echo $1 | awk '{print $NF}')
    local month=$(echo $1 | awk '{print $2}')
    local dayOfMonth=$(echo $1 | awk '{print $3}')
    local day=$(echo $1 | awk '{print $1}')
    local hour=$(formatHour $(echo $(echo $1 | awk '{print $4}') | cut -d: -f1))
    local minute=$(echo $(echo $1 | awk '{print $4}') | cut -d: -f2)
    local second=$(echo $(echo $1 | awk '{print $4}') | cut -d: -f3)

    local operator=$2
    local diff=$3
    if [ "$operator" = "+" ]; then
        hour=$((hour + diff))
        if [ $hour -le 23 ]; then
            echo "$day $month $dayOfMonth $hour:$minute:$second $year"
            return 0
        else
            hour=$((hour - 24))
            day=$(getDay $day 1)
            if [ $dayOfMonth -eq $(daysInMonth $month $year) ]; then
                dayOfMonth=1
                month=$(getMonth $month 1)
                if [ 'jan' = $(echo $month | tr '[:upper:]' '[:lower:]') ]; then
                    year=$((year + 1))
                fi
                echo "$day $month $dayOfMonth $hour:$minute:$second $year"
                return 0
            else
                dayOfMonth=$((dayOfMonth + 1))
                echo "$day $month $dayOfMonth $hour:$minute:$second $year"
                return 0
            fi
        fi
    elif [ "$operator" = "-" ]; then
        hour=$((hour - diff))
        if [ $hour -ge 0 ]; then
            echo "$day $month $dayOfMonth $hour:$minute:$second $year"
            return 0
        else
            hour=$((hour + 24))
            day=$(getDay $day -1)
            if [ $dayOfMonth -eq 1 ]; then
                month=$(getMonth $month -1)
                if [ 'dec' = $(echo $month | tr '[:upper:]' '[:lower:]') ]; then
                    year=$((year - 1))
                    dayOfMonth=$(daysInMonth $month $year)
                    echo "$day $month $dayOfMonth $hour:$minute:$second $year"
                    return 0
                fi
                dayOfMonth=$(daysInMonth $newMonth $year)
                echo "$day $month $dayOfMonth $hour:$minute:$second $year"
                return 0
            else
                dayOfMonth=$((dayOfMonth - 1))
                echo "$day $month $dayOfMonth $hour:$minute:$second $year"
                return 0
            fi
        fi
    fi
    return 1
}

option=0
while getopts "ls:" opt; do
    case $opt in
        l ) option=$((option + 1)) ;;
        s ) option=$((option + 2)); timeDiff="$OPTARG" ;;
        * ) usage; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

name=${@:-".*"}
lutdbpath='/home/qlr/workspace/shell/timedifference/dblut'

months=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
days=(Mon Tue Wed Thu Fri Sat Sun)

if [ $option -eq 3 ]; then
    echo "only one of -l and -s can be specified." >&2
    usage
    exit 1
fi
if [ $option -eq 2 ] || [ $option -eq 0 ]; then
    if [ ! -n "$timeDiff" ] || [ -z "$timeDiff" ] \
    || [ ! -n "$name" ] || [ -z "$name" ]; then
        echo "argument should be like '+n' or '-n'" >&2
        usage
        exit 1
    fi
    len=${#timeDiff}
    operator=${timeDiff:0:1}
    diff=${timeDiff:1:$((len - 1))}

    if [ ! -z $(echo $diff | sed 's/[[:digit:]]//g') ]; then
        echo "Invalid time difference! Only digits." >&2
        exit 1
    fi
    if [ "$diff" -lt 0 ] || [ "$diff" -gt 24 ]; then
        echo "Invalid time difference! Between 0 and 24." >&2
        exit 1
    fi
    if [ "$operator" != '+' ] && [ "$operator" != '-' ]; then
        echo "Invalid operator! '+' or '-'." >&2
        exit 1
    fi

    awk -F: '$1!=name {print}' name=$name $lutdbpath > ${lutdbpath}_$$
    mv -f ${lutdbpath}_$$ $lutdbpath

    echo "$name:$operator$diff" >> $lutdbpath
    exit 0
elif [ $option -eq 1 ]; then
    ifs=$IFS
    IFS=$'\n'
    for item in $(grep "$name" $lutdbpath)
    do
        nameitem=$(echo $item | cut -f1 -d:)
        timeDiff=$(echo $item | cut -f2 -d:)
        operator=${timeDiff:0:1}
        len=${#timeDiff}
        diff=${timeDiff:1:$((len - 1))}
        newTime=$(calTime "$(date)" $operator $diff)
        echo "${nameitem}:${newTime}"
    done
    IFS=$ifs
    exit 0
fi
