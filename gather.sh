#!/bin/bash

############ Define ##################
WORK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd  $WORK_DIR
export LANG=en
source ./tools/config
source ./tools/libfunc
source ./tools/check-list.sh
command_exists sshpass || rpm -ivh $WORK_DIR/rpm/sshpass-1.06-2.el7.x86_64.rpm &> /dev/null
[ $? != 0 ] && echo "install sshpass failure,please install manual" && exit 1

############ Report ######################
func_html_header
### 主机名/网卡名/IP,MASK/网关 ###
html_echo "<h2>主机名及网卡信息</h2>"
func_tr_start "hostname" "Eth name" "IP/MASK" "DEFAULT GATEWAY"
ip a|egrep "^[1-9]{1,2}"|egrep -v "lo|flannel|cni|docker"|awk -F : '{print $2}'|while read Eth; do
func_tr
func_td "$HOST"
func_td "$Eth"
func_td $(ip a ls  $Eth|awk '/\<inet\>/{print $2}' |awk -F '/' '{print $1"/"$2}')
func_td "${Gateway}"
done
func_tb_end

### SSH 连通性测试 ###
html_echo "<h2>SSH连通性</h2>"
html_echo "<p>测试从${DIP}到其他节点的ssh连通性</p>"
func_tr_start "HOST" "Info"
func_tr
for Slave_IP in ${Host[@]};do
    if [[ $Slave_IP = "${DIP}" ]];then
        continue
    fi
    sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$Slave_IP pwd &>/dev/null
    if [ $? != 0 ];then
        func_td "$Slave_IP"
        func_td "Failed"
        func_tr
        continue
    else
        func_td "$Slave_IP"
        func_td "Succeed"
        func_tr
    fi
done
func_tb_end


### 主机信息：架构、系统版本等 ###
#func_tab
html_echo "<h2>操作系统信息</h2>"
func_tr_start "System Release" "System Architecture" "Kernel Version"
func_tr
func_td "$(cat /etc/redhat-release)"
func_td "$(uname -p)"
func_td $(uname -r)
func_tr_end
func_tb_end

### BIOS ###
html_echo "<h2>BIOS主板信息</h2>"
func_tr_start "BIOS" "Info"
func_tr
func_td "BIOS Vendor"
func_td "$Bios_vendor"
func_tr
func_td "Bios Version"
func_td "$Bios_version"
func_tb_end

### 服务器信息 ###
html_echo "<h2>服务器硬件信息</h2>"
func_tr_start "Machine" "Info"
func_tr
func_td "Manufacturer"
func_td "$Manufacturer"
func_tr
func_td "Product_Name"
func_td "$Product_Name"
func_tr
func_td "Serial_Number"
func_td "$Serial_Number"
func_tr
func_td "RAM"
func_td "${Mem_size_peer_device} *${Memory_Num}"
func_tr
func_td "CPU"
func_td "${Cpu_name} *${Cpu_num}"
func_tb_end

### 内存硬件信息 ###
html_echo "<h2>内存卡信息</h2>"
func_tr_start "Memory Device" "MetaData" "Value"
#func_tr
#func_th_col "Total Size ${Memory_total}" 3
echo "$Memory_Info" | while read line; do
    if [[ "${line%: *}" == Size* ]];then
    i=${i:-0}
    let i+=1
        func_tr
        func_th Device$i 4
        func_td "${line%: *}"
        func_td "${line#*:}"
        func_tr_end 
    else
	func_tr
	func_td "${line%: *}"
        func_td "${line#*:}"
        func_tr_end
    fi
done    
func_tb_end

### cpu硬件信息 ###
html_echo "<h2>CPU卡信息</h2>"
func_tr_start "CPU Device" "MetaData" "Value"
func_tr
echo "$Cpu_Info" | while read line;do
    if [[ "${line%: *}" == Family ]];then
    cpu_num=${cpu_num:-0}
    let cpu_num+=1
	func_tr
        func_th CPU$cpu_num 7
        func_td "${line%: *}"
        func_td "${line#*:}"
        func_tr_end
    else
        func_tr
        func_td "${line%: *}"
        func_td "${line#*:}"
        func_tr_end
    fi
done
func_tb_end

#######################
### 硬盘,分区，挂载 ###
#######################
## 硬盘
html_echo "<h2>硬盘信息</h2>"
func_tr_start "DISK NAME" "SIZE"
echo "${disk_device}" | while read line;do
    func_tr
#    func_td "$(echo $line|awk '{print $1}')"
#    func_td "$(echo $line|awk '{print $2}')"
    func_td "${line%% *}"
    func_td "${line##* }"
done
func_tb_end
## 分区 
html_echo "<h2>分区信息</h2>"
func_tr_start "Partition NAME" "SIZE" "FSTYPE" "MOUNT POINT"
echo "${Partition}" |while read line;do
    func_tr
    func_td "$(echo $line|awk '{print $1}')"
    func_td "$(echo $line|awk '{print $2}')"
    func_td "$(echo $line|awk '{print $3}')"
    func_td "$(echo $line|awk '{print $4}')"
done
func_tb_end

## 挂载及使用率
html_echo "<h2>磁盘使用率及挂载信息</h2>"
func_tr_start "Disk Name" "TYPE" "Inode Use%" "Disk Size" "Used" "Avail" "Use%" "Mounted on"
echo "${Disk_info}" | while read line;do
    func_tr
    func_td "$(echo $line|awk '{print $1}')"
    func_td "$(echo $line|awk '{print $2}')"
    func_td "$(echo $line|awk '{print $3}')"
    func_td "$(echo $line|awk '{print $4}')"
    func_td "$(echo $line|awk '{print $5}')"
    func_td "$(echo $line|awk '{print $6}')"
    func_td "$(echo $line|awk '{print $7}')"
    func_td "$(echo $line|awk '{print $8}')"
done
func_tb_end

### nvme device ###
html_echo "<h2>nvme磁盘信息</h2>"
func_tr_start "DEVICE" "NUMBER"
func_tr
func_td "NVME"
func_td "$Nvme_num"
func_tr
func_td "NVIDIA GPU"
func_td "$Gpu_num"
func_tr_end
func_tb_end

### rpm packages ###
html_echo "<h2>通用软件包安装信息</h2>"
func_tr_start "RPM NAME" "STATUS"
for pkg in ${Packages[@]};do
  if [ $(rpm -qa $pkg) ];then
    func_tr
    func_td "$pkg"
    func_td "exists"
  else
    func_tr
    func_td "$pkg"
    func_td "Not found"
  fi
done
func_tr_end
func_tb_end

### 服务启动信息 ###
html_echo "<h2>服务启动情况</h2>"
func_tr_start "Service name" "Status"
for svc in ${Service[@]};do
    func_tr
    func_td "${svc}"
    func_td "$(systemctl is-active ${svc})"
done
func_tr
func_td "Selinux"
func_td "$(getenforce)"
func_tb_end

### 用户信息 ###
html_echo "<h2>可登录用户信息</h2>"
func_tr_start "User Name" "Login Shell"
echo "${Users}" |while read line;do
    func_tr
    func_td "$(echo $line|awk '{print $1}')"
    func_td "$(echo $line|awk '{print $2}')"
done
func_tb_end

### DNS ###
html_echo "<h2>主机DNS信息</h2>"
func_tr_start "DNS Information"
while read line;do
    func_tr
    func_td "$line"
done <  /etc/resolv.conf
func_tr_end
func_tb_end

### PORT Listening ###
html_echo "<h2>端口监听信息</h2>"
func_tr_start "Listen IP:Port" "Info"
echo "${Port_listen}" | while read line;do
    func_tr
    func_td "$(echo $line|awk '{print $1}')"
    func_td "$(echo $line|awk '{print $2}')"
done
func_tb_end

##################################
######### 日志 ###################
##################################

## /var/log/message
html_echo "<h2>messages日志最近输出信息</h2>"
func_tr_start "Log: Message"
tail -20 /var/log/messages > ./tmp_message
while read line;do
    func_tr
    func_td "$line"
done < ./tmp_message
rm -f ./tmp_message
func_tb_end

## /var/log/dmesg
html_echo "<h2>内核报错信息(dmesg)</h2>"
func_tr_start "Log: dmesg/Error"
dmesg | grep Error > ./tmp_dmesg
while read line;do
    func_tr
    func_td "$line"
done < ./tmp_dmesg
rm -f ./tmp_dmesg
func_tb_end




