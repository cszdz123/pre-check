### Shell Tools
RED='\e[1;31m'
GREEN='\e[1;32m'
NC='\e[0m'
function red_echo() {
      echo -e "${RED}$1 ${NC}"
}
function green_echo() {
      echo -e "${GREEN}$1 ${NC}"
}
function reg_grep() {
   echo "$1" | grep -E "$2" > /dev/null
   echo $?
}
function name_check() {
   echo "$1" | grep -E "^[0-9]" > /dev/null
   echo $?
}
function count_down() {
    for count in `seq $1 -1 1`
    do
        echo "Waiting for $count second!"
        sleep 1
    done
}
Shell_lock() {
  touch /tmp/$0.lock
}

Shell_unlock() {
  rm -f /tmp/$0.lock
}

Fmt="%-20s"
alias iprint='printf "$Fmt $Fmt $Fmt $Fmt\n"'
Time=$(date +%m%d%H%M)