#!/usr/bin/env bash

function drawGoal(){
clear
echo "Goal:
* Win the game by turning off all the lights.
* When toggling the state of a tile the
neighbouring tiles (above, below, left and
right) will also change state."
    read -s -n 1
    drawField
}

function drawHelp(){
echo "lightsoff [-h] [-c columns] [-r rows] [-l levels] [-s seed]

  -h,--help    display this help text

  -c,--colors  integer representing the number of columns
  -r,--rows    integer representing the number of rows
  -l,--level   integer representing the level
  -s,--seed    integer seed for the pseudo-random number generator"
}

function keyBindings(){
    clear
echo "Key bindings:
 | Key             | Action                     |
 |:---------------:|:--------------------------:|
 | h,left          | move cursor left           |
 | l,right         | move cursor right          |
 | j,down          | move cursor down           |
 | k,up            | move cursor up             |
 | H               | move cursor to left edge   |
 | L               | move cursor to right edge  |
 | J               | move cursor to bottom edge |
 | K               | move cursor to top edge    |
 | enter,space,tab | toggle light               |
 | r               | replay game                |
 | n               | new game                   |
 | q               | quit game                  |
 | x               | change nr of columns       |
 | y               | change nr of rows          |
 | s               | change seed                |
 | v               | change level               |
 | z               | show move                  |
 | w               | redraw screen              |
 | i               | display goal               |
 | ?               | display key bindings       |"
    read -s -n 1
    drawField
}

ncolumns=5
nrows=5
level=7

tiles=(· o)

while [ $# -gt 0 ]; do
    case "$1" in
        '-h'|'--help') drawHelp; exit;;
        '-r'|'--rows')
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                nrows=$2
            else
                echo "invalid input for number of rows: $2"
                exit 1
            fi
            shift 2;;
        '-c'|'--columns')
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                ncolumns=$2
            else
                echo "invalid input for number of columns: $2"
                exit 1
            fi
            shift 2;;
        '-l'|'--level')
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                level=$2
            else
                echo "invalid input for level: $2"
                exit 1
            fi
            shift 2;;
        '-s'|'--seed') seed="$2"; shift 2;;
        *) echo "unknown input: $1"; exit 1;;
    esac
done

function newGame(){
    size=$((ncolumns*nrows))
    ((`tput lines`<nrows+3)) && clear && printf "max nr rows: %d" $((`tput lines`-3)) && nrows=-2 && exit 1
    ((`tput cols`<2*ncolumns+1)) && clear && printf "max nr cols: %d" $(((`tput cols`-1)/2)) && nrows=-2 && exit 1
    ((level>size)) && clear && printf "max level: $size" && nrows=-2 && exit 1
    irow=$(((nrows-1)/2))
    icolumn=$(((ncolumns-1)/2))
    [ $# -gt 0 ] && seed="$1" || seed=$((RANDOM))
    RANDOM=$seed
    board=()
    moves=()
    local i=0
    while [ $i -lt $size ]; do
        board[$i]=0
        ((i++))
    done
    local new=$((RANDOM%size))
    while [ ${#moves[@]} -lt $level ]; do
        while [[ " ${moves[@]} " =~ " $new " ]]; do
            new=$((RANDOM%size))
        done
        toggle $new
    done
    nmoves=0
    status=1
    drawField
}

function toggle(){
    board[$1]=$((board[$1]?0:1))
    (($1%ncolumns>0)) && board[$1-1]=$((board[$1-1]?0:1))
    (($1%ncolumns<ncolumns-1)) && board[$1+1]=$((board[$1+1]?0:1))
    (($1/ncolumns>0)) && board[$1-ncolumns]=$((board[$1-ncolumns]?0:1))
    (($1/ncolumns<nrows-1)) && board[$1+ncolumns]=$((board[$1+ncolumns]?0:1))
    ((nmoves++))
    [[ "${board[@]}" =~ 1 ]] || status=0
    [[ ! " ${moves[@]} " =~ " $1 " ]] && moves+=($1) || {
        moves=" ${moves[@]} "
        moves=(${moves/ $1 / })
    }
}

function drawField(){
    indent=""
    row=
    local i=0
    while [ $i -lt $nrows ]; do
        row+="indent${board[@]:i*ncolumns:ncolumns} \e[0m\n"
        ((i++))
    done
    row=${row//0 /\\e[2m${tiles[0]} \\e[0m}
    row=${row//1 /\\e[1;33m${tiles[1]} \\e[0m}
    stty -echo; tput civis
    clear
    printf "${row//indent/ } moves:%d\n seed:%d\n\e[2m ?:key bindings\e[0m" $nmoves $seed
    if [ $status -eq 0 ]; then
        local col=$(((2*ncolumns-14)/2))
        tput 'cup' $((nrows/2)) $((col<0?0:col)); printf "\e[5;33mCONGRATULATIONS\e[0m"
    fi
}

function changeSetting(){
    unset input
    stty echo; tput cnorm
    while [[ ! "$input" =~ ^\ *([1-9][0-9]*|[qQ])\ *$ ]]; do
        clear
        printf "\e[2mq:cancel\e[0m\n"
        read -p "$1: " input
    done
    if [[ "$input" =~ [qQ] ]]; then
        drawField
    else
        case $1 in
            rows) 
                if ((input>`tput lines`-3)); then
                    printf "max nr rows: %d" $((`tput lines`-3))
                    stty -echo; tput civis
                    read -s -n 1
                    drawField
                else
                    nrows=$input
                    newGame
                fi;;
            columns)
                if ((2*input+1>`tput cols`)); then
                    printf "max nr cols: %d" $(((`tput cols`-1)/2))
                    stty -echo; tput civis
                    read -s -n 1
                    drawField
                else
                    ncolumns=$input
                    newGame
                fi;;
            level)
                if ((level>size)); then
                    printf "max level: $size"
                    stty -echo; tput civis
                    read -s -n 1
                    drawField
                else
                    level=$input
                    newGame
                fi;;
            seed) seed=$input; newGame $seed;;
        esac
    fi
}

trap 'tput "cup" $((nrows+2)) 0; echo -e "\e[0m"; stty echo; tput cnorm; exit' EXIT INT

[ "$seed" ] && newGame "$seed" || newGame
while :; do

    if [ $status -eq 1 ]; then
        tput 'cup' $irow $((2*icolumn)); printf "["
        tput 'cup' $irow $((2*icolumn+2)); printf "]"
    fi
    read -s -n 1 action
    if [ $status -eq 1 ]; then
        tput 'cup' $irow $((2*icolumn)); printf " "
        tput 'cup' $irow $((2*icolumn+2)); printf " "
    fi

    case "$action" in
        h|D) [ $status -eq 1 ] && icolumn=$((icolumn==0?ncolumns-1:icolumn-1));;
        H) [ $status -eq 1 ] && icolumn=0;;
        l|C) [ $status -eq 1 ] && icolumn=$((icolumn<ncolumns-1?icolumn+1:0));;
        L) [ $status -eq 1 ] && icolumn=$((ncolumns-1));;
        k|A) [ $status -eq 1 ] && irow=$((irow==0?nrows-1:irow-1));;
        K) [ $status -eq 1 ] && irow=0;;
        j|B) [ $status -eq 1 ] && irow=$((irow<nrows-1?irow+1:0));;
        J) [ $status -eq 1 ] && irow=$((nrows-1));;
        q|Q) break;;
        n|N) newGame;;
        r|R) newGame $seed;;
        s|S) changeSetting seed;;
        x|X) changeSetting columns;;
        y|Y) changeSetting rows;;
        v|V) changeSetting level;;
        w|W) drawField;;
        i|I) drawGoal;;
        z|Z) [ $status -eq 1 ] && {
                tput 'cup' $((moves[-1]/ncolumns)) $((2*(moves[-1]%ncolumns)+1))
                printf "\e[1;5;34m${tiles[board[moves[-1]]]}\e[0m"
            };;
        '?'|'/') keyBindings;;
        '') [ $status -eq 1 ] && toggle $((irow*ncolumns+icolumn)); drawField;;
    esac

done

