#!/bin/bash
#==========================================================
# Author        : caoshibo
# Email         : shibo.cao@foxmail.com
# Last modified : 2019-12-03 14:17
# Filename      : all.sh
# Description   : You know what i mean,hehe
#==========================================================
### Env Set
WORK_DIR=$(dirname $(readlink -f $0))

### Shell Tools
RED='\e[1;31m'
GREEN='\e[1;32m'
NC='\e[0m'
Fmt="%-20s"
log_fmt="-$(date +%m%d%H%M).txt"
log_dir=$WORK_DIR/report
alias iprint='printf "$Fmt $Fmt $Fmt $Fmt\n"'
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
# Shell Usage
Shell_usage() {
  echo -e "\e[1;32mUsage: $0 <OPTIONS>\e[0m
OPTIONS:
all\t\tprint all informations.
sys,system\tprint OS type and Kernel version.
rpm\t\tprint base rpm packages info.
gpu\t\tprint gpu information.
cpu\t\tprint cpu information.
net\t\tprint network infomation.
"
}

Shell_log () {
  cd $WORK_DIR
  echo "$(date "+%F %T") $0 : $1 " >> ${WORK_DIR}/${0}.log
}
Shell_lock() {
  touch /tmp/$0.lock
}

Shell_unlock() {
  rm -f /tmp/$0.lock
}
system() {
green_echo "Kernel Version: $(uname -r)"
green_echo "System Version: $(cat /etc/redhat-release)"
iprint "Kernel Version:" "$(uname -r)" > $log_dir/kernel_info$log_fmt
iprint "System Version:" "$(cat /etc/redhat-release)" > $log_dir/system_version$log_fmt
}
# test if the rpm packages is exists
Rpm() {
  Package=(bc net-tools attr libattr unzip)
  iprint "PACKAGE" "INFO" > $log_dir/rpm_info$log_fmt
  for pkg in ${Package[@]};do
    if [ $(rpm -qa $pkg) ];then
      green_echo "$pkg is exists"
      iprint "$pkg" "exists" >> $log_dir/rpm_info$log_fmt
    else
      red_echo "Err: Package '$pkg' not found,type'yum install $pkg' to install it."
      iprint "$pkg" "Not exists" >> $log_dir/rpm_info$log_fmt
    fi
  done
}
GPU(){
  iprint "GPU" "INFO" > $log_dir/gpu_info$log_fmt
  GPU_NUM=$(lspci |grep NVIDIA|wc -l)
  if [[ $GPU_NUM = 0 ]];then
    red_echo "No GPU Device found"
    iprint "GPU number" "0" >> $log_dir/gpu_info$log_fmt
  else
    green_echo "GPU number is: $GPU_NUM"
    print "GPU number" "#GPU_NUM" >> $log_dir/gpu_info$log_fmt
  fi
}

CPU(){
  Cpu_type=$(lscpu |awk  -F : '/Model name/{ gsub(" *","");print $2}')
  Cpu_num=$(lscpu |awk  -F : '/^CPU\(s\)/{ gsub(" *","");print $2}')
  [ -z $log_dir/cpu_info.txt ] && $(rm -f $log_dir/cpu_info.txt)
  green_echo "cpu number is: $Cpu_num"
  green_echo "cpu type is: $Cpu_type"
  iprint "GPU" "INFO" > $log_dir/cpu_info$log_fmt
  iprint "cpu number" "$Cpu_num" >> $log_dir/cpu_info$log_fmt
  iprint "cpu type" "$Cpu_type" >> $log_dir/cpu_info$log_fmt
}

## NetWork
network() {
DNS=$(awk '/nameserver/{print $2}' /etc/resolv.conf)
iprint "NETWORK" "INFO" > $log_dir/network_info$log_fmt
if [ -n "$DNS" ];then
  green_echo "DNS:\t\t     $DNS"
  iprint "DNS" "$DNS" >> $log_dir/network_info$log_fmt
else
  red_echo "DNS: none"
  iprint "DNS" "none" >> $log_dir/network_info$log_fmt
fi

Gateway=$(ip r|awk '{if($1 == "default") print $3}')
if [ -n $Gateway ];then
  green_echo "Gateway:\t     $Gateway"
  iprint "Gateway" "$Gateway" >> $log_dir/network_info$log_fmt
else
  red_echo "Gateway: none"
  iprint "Gateway" "none" >> $log_dir/network_info$log_fmt
fi

Eth_name="$(ip a|egrep "^[1-9]{1,2}"|grep -v "lo"|awk -F : '{print $2}')"
for Eth in $Eth_name;do
  green_echo "Device name:\t     ${Eth}"
  iprint "Device" "${Eth}" >> $log_dir/network_info$log_fmt
  IP=$(ip a ls  $Eth|awk '/\<inet\>/{print $2}' |awk -F '/' '{printf "IP%+30s\nMASK%+19s\n",$1,$2,"\n"}')
  if [[ ${IP} != 0 ]];then
    green_echo "$IP"
    echo "$IP" >> $log_dir/network_info$log_fmt
  else
    red_echo "Device ${Eth} No IPv4 address found"
  iprint "${Eth}" "none" >> $log_dir/network_info$log_fmt
  fi
done
}


### Output information file
Output() {
  cd $log_dir
  [ -f "all_information$log_fmt" ] && rm -f all_information$log_fmt
  for txt in `ls -1 *.txt`;do
    cat $txt >> $log_dir/all_information$log_fmt
    echo "========================================================" >> $log_dir/all_information$log_fmt
 done
}

### Main Function
main () {
  if [ -f "/tmp/${0}.lock" ];then
    red_echo "${0} is run" && exit 2
  fi
  case $1 in
    system|sys)
      Shell_lock && system &&Shell_unlock
      ;;
    rpm)
      Shell_lock && Rpm && Shell_unlock
      ;;
    network|net)
      Shell_lock && network && Shell_unlock
      ;;
    [Cc][Pp][Uu])
      Shell_lock && CPU && Shell_unlock
      ;;
    [Gg][Pp][Uu])
      Shell_lock && GPU && Shell_unlock
      ;;
    all)
      Shell_lock
      system
      Rpm
      CPU
      GPU
      network
      Shell_unlock
      Output
      ;;
    *)
      Shell_usage
      ;;
    esac
}

# Exec
main $1
