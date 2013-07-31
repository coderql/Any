#!/bin/bash

# -------------
# author qlr
# date 08.10.12
# -------------

################################################################################
#                     DECLARATION                                              #
################################################################################

declare -r NUM='4'
declare -r CORRECT_RESULT='24'
declare -r MAX_DIFF='0.001'
declare -r SCALE='5'
WELCOME_HERE="Welcome to qlr's 24 point game."
WELCOME_BACK="Good Bye! Wish to see you again."

# poker color array to hold 4 pokes
declare -a colors
# poker values array to hold 4 pokes(Ace-1,Jack-10,Queen-10,King-10)
declare -a values
# real integer value for each poker
declare -a pokes
# possible correct expressoin(value)
declare -a correct_answer
# temp help array(expression)
declare -a help_values

# 24 data file
declare -r DATAFILE='.db24' # ~/.db24 suggest

################################################################################
#                     FUNCTION                                                 #
################################################################################

######################################
# printPoke
#     print random 4 pokes
######################################
function printPoke {
    local i
    for (( i = 0; i < $NUM; i++ ))
    do
        echo -n "[${colors[$i]} ${values[$i]}]    "
    done
    echo
}

######################################
# generatePokeSeq
#     pick out 4 pokes randomly.
#     color & number can't be the
#     same in one selection.
######################################
function generatePokeSeq {
    local i
    local j
    for (( i = 0; i < $NUM; i++ ))
    do
        color=${suite[$((RANDOM%num_suites))]}
        value=${denomination[$((RANDOM%num_denomination))]}
        for j in $(seq $((i-1)))
        do
            if [[ "${colors[$j]}" = "$color" && "${values[$j]}" = "$value" ]]
            then
                (( i-- ))
                continue 2
            fi
        done
        colors[$i]=$color
        values[$i]=$value
        if [[ -z "$(echo "$value" | sed -e 's/[0-9]//g')" ]]
        then
            pokes[$i]=${values[$i]}
        else
            if [[ $value = "Ace" ]]
            then
                pokes[$i]=1
            else
                pokes[$i]=10
            fi
        fi
    done
    bubbleSort
    printPoke
}

######################################
# bubbleSort
#     sort pokes in descending
#     order, since if a1 > a2, will
#     try a1 - a2 first, more possible
#     to find solution.
######################################
function bubbleSort {
    local i
    local j
    local swap=-1
    for (( i = 0; i < NUM - 1; i++ ))
    do
        for (( j = 0; j < NUM - i - 1; j++ ))
        do
            if [[ ${pokes[$j]} -lt ${pokes[$((j + 1))]} ]]
            then
                swap=${pokes[$j]}
                pokes[$j]=${pokes[$((j + 1))]}
                pokes[$((j + 1))]=$swap
            fi
        done
    done
}

######################################
# abs
#     calculate a number's abosulte
#     value.
# parameter
#     number string
# output value
#     absolute value of this number
######################################
function abs {
    echo ${1#-}
}

######################################
# PositiveOrNegative
#     determine if a number is a
#     positive number of negative
#     number.
# parameter
#     number string
# return value
#     0 - positive number
#     1 - negative number
######################################
function PositiveOrNegative {
    [ "${1#-}" = "$1" ]
}

######################################
# EqualsTo24
#     determine if the value of an
#     expression is 24.
# parameter
#     arithmetic expression
# return value
#     0 - = 24
#     1 - != 24
# notes:
#     Not exact equals,
#     with an accuracy of $MAX_DIFF
######################################
function equalsTo24 {
    local expression=$1
    local result=$(echo "scale=$SCALE; $expression" | bc)
    if [[ "$(echo "$result" | sed -e 's/error//gi')" != "$result" ]]
    then
        return 1
    fi
    local diff=$(abs "$(echo "scale=$SCALE; $CORRECT_RESULT-($result)" | bc)")
    if [[ "$(echo "$result" | sed -e 's/error//gi')" != "$result" ]]
    then
        return 1
    fi
    PositiveOrNegative $(echo "scale=$SCALE; $MAX_DIFF-($diff)" | bc)
}

######################################
# isLegalExpression
#     determine if the expression is
#     a valid arithmetic expression.
# parameter
#     arithmetic expression
# return value
#     0 - legal expression
#     1 - illegal expression
######################################
function isLegalExpression {
    local expression=$1
    # each character in expression must be a digit, +,-,*,/ ,(,)
    local left=$(echo "$expression" | sed -e 's#[*+-/()0-9]##g')
    [ ! -z $left ] && return 1

    # 4 numbers in expression are same with 4 numbers provided
    local temp1=$(echo "$expression" | sed -e 's#[*+-/()]#\n#g' | \
                  sed -e '/^$/d' | sort -n)
    local temp2=$(echo -e "${pokes[0]}\n${pokes[1]}\n${pokes[2]}\n${pokes[3]}" | sort -n)
    [ "$temp1" != "$temp2" ] && return 1

    # no two sequential like '**' '++' to avoid '**' is also a op.
    local tmp=$(echo "$expression" | sed -e 's#[*+-/]# #g' | \
                sed -e 's/[0-9()]//g');
    [ ${#tmp} -ne 3 ] && return 1
    return 0
}

######################################
# solution
#     make sure whether this case has
#     at least one correct answer.
#     and if has, store one.
#
# return value
#     0 - Has answer
#     1 - No answer
######################################
function solution {
    for (( i = 0; i < $NUM; i++ ))
    do
        correct_answer[$i]=${pokes[$i]}
        help_values[$i]=${pokes[$i]}
    done
    findHelper $NUM
    if [[ $? -eq 0 ]]
    then
        addToDB ${help_values[0]}
        #local pattern="${help_values[0]}"
        #if ! isInDB
        #then
            ## Ok
            #echo "${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}:${help_values[0]};" >> $DATAFILE
        #fi
        return 0
    else
        # ok
        #echo "${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}:" >> $DATAFILE
        echo "${pokes[@]}:" >> $DATAFILE
        return 1
    fi
}

function findHelper {
    echo $1
    local n=$1
    if [[ $n -eq 1 ]]
    then
        if equalsTo24 "${correct_answer[0]}"
        then
            return 0
        else
            return 1
        fi
    fi

    local i
    local j
    for (( i = 0; i < $n; i++ ))
    do
        for (( j = i + 1; j < $n; j++ ))
        do
            local n1
            local n2
            local exp1
            local exp2

            n1=${correct_answer[$i]}
            n2=${correct_answer[$j]}
            echo "n1:$n1 n2:$n2"
            correct_answer[$j]=${correct_answer[$((n-1))]}

            exp1=${help_values[$i]}
            exp2=${help_values[$j]}
            echo "exp1:$exp1 exp2:$exp2"
            help_values[$j]=${help_values[$((n-1))]}

            help_values[$i]="($exp1+$exp2)"
            echo ${help_values[$i]}
            correct_answer[$i]=$(echo "scale=$SCALE; ($n1)+($n2)" | bc)
            findHelper "$((n-1))" && return 0

            help_values[$i]="($exp1-$exp2)"
            echo ${help_values[$i]}
            correct_answer[$i]=$(echo "scale=$SCALE; ($n1)-($n2)" | bc)
            findHelper "$((n-1))" && return 0

            help_values[$i]="($exp2-$exp1)"
            echo ${help_values[$i]}
            correct_answer[$i]=$(echo "scale=$SCALE; ($n2)-($n1)" | bc)
            findHelper "$((n-1))" && return 0

            help_values[$i]="($exp1*$exp2)"
            echo ${help_values[$i]}
            correct_answer[$i]=$(echo "scale=$SCALE; ($n1)*($n2)" | bc)
            findHelper "$((n-1))" && return 0

            if [[ "$n2" != '0' ]]
            then
                help_values[$i]="($exp1/$exp2)"
            echo ${help_values[$i]}
                correct_answer[$i]=$(echo "scale=$SCALE; ($n1)/($n2)" | bc)
                findHelper "$((n-1))" && return 0
            fi
            if [[ "$n1" != '0' ]]
            then
                help_values[$i]="($exp2/$exp1)"
            echo ${help_values[$i]}
                correct_answer[$i]=$(echo "scale=$SCALE; ($n2)/($n1)" | bc)
                findHelper "$((n-1))" && return 0
            fi

            help_values[$i]=$exp1
            help_values[$j]=$exp2
            correct_answer[$i]=$n1
            correct_answer[$j]=$n2
        done
    done
    return 1
}

function addToDB {
    local expression=$1
    local temp=
    local nums="${pokes[@]}"
    #local nums="${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}"
    if ! isInDB
    then
        echo "$nums:$expression;" >> $DATAFILE
    else
        temp=$(grep -h "$nums" $DATAFILE)
        echo "temp1:$temp"
        #if ! echo "$temp" | grep -q "$expression"
        if [[ "$temp" = "${temp/$expression/}" ]]
        then
            temp="$temp$expression;"
        echo "temp2:$temp"
            sed -i -e "/$nums/d" $DATAFILE
            echo "$temp" >> $DATAFILE
        fi
    fi
}

function isInDB {
    local nums="${pokes[@]}"
    #local nums="${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}"
    grep -q "$nums" $DATAFILE
}

function hasAnswer {
    local nums="${pokes[@]}"
    #local nums="${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}"
    local line=$(grep -h "$nums" $DATAFILE)
    [ ! -z $(echo $line | cut -d: -f2) ]
}
function getAnswer {
    local nums="${pokes[@]}"
    #local nums="${pokes[0]} ${pokes[1]} ${pokes[2]} ${pokes[3]}"
    local line=$(grep -h "$nums" $DATAFILE)
    echo $line | cut -d: -f2 | cut -d';' -f1
}

################################################################################
Suites="
Clubs
Diamonds
Hearts
Spades"

Denominations="
2
3
4
5
6
7
8
9
10
Jack
Queen
King
Ace
"
: <<COMMENT_BLOCK
Operators="
+
-
*
/
"
COMMENT_BLOCK

suite=($Suites)
denomination=($Denominations)
#ops=($Operators)

num_suites=${#suite[*]}
num_denomination=${#denomination[*]}
num_ops=${#ops[*]}

#echo $num_suites $num_denomination
################################################################################


################################################################################
#                     MAIN                                                     #
################################################################################
echo "$WELCOME_HERE"; echo

options="training help quit"
PS3="Choose: "
select selection in $options
do
    if [[ $selection = 'training' ]]
    then
        choice='Y'
        expression=
        while [[ "$choice" = 'Y' || "$choice" = 'y' ]]
        do
            generatePokeSeq
            if ! hasAnswer && ! solution
            then
                echo "No answer!"
                continue
            fi

            read -p 'Your answer: ' expression
            if isLegalExpression "$expression" && equalsTo24 "$expression"
            then
                addToDB "$expression"
                echo 'Cong Ming!'
            else
                echo 'Ben Si le!!' >&2
                echo -n "Qiao Zhe:"
                if hasAnswer
                then
                    echo "$(getAnswer)"
                else
                    echo "${help_values[0]}"
                fi
            fi
            expression=
            read -p "'Y' to continue, 'N' to quit(Y/N) " choice
        done
    elif [[ $selection = 'help' ]]
    then
        :
    elif [[ $selection = 'quit' ]]
    then
        echo "$WELCOME_BACK";
        break
    fi
done
