#!/bin/bash
#
#
export Cluster_mode=${Cluster_mode:-false}
export SSH_PORT=${SSH_PORT:-22}
### rpm packages ###
Packages=(bc net-tools attr libattr unzip)

### BIOS 信息(BIOS Message) ###
Bios_vendor=$(dmidecode -s bios-vendor | uniq)
Bios_version=$(dmidecode -s bios-version | uniq)

#### 服务器硬件信息(Machine Information) ### 
Manufacturer=$(dmidecode -s system-manufacturer | uniq)
Product_Name=$(dmidecode -s system-product-name | uniq)
Serial_Number=$(dmidecode -s system-serial-number | uniq)
Net_device=$(lspci |grep Ethernet)

### 内存硬件信息(Memory) ###
Memory_Num=$(dmidecode -t memory|awk '/Size:/{if($2 != "No") print $2}'|wc -l)
Memory_total=$(dmidecode | grep -A 16 "Memory Device$" |grep Size:|grep -v "No Module Installed"|awk '{print "*" $2,$3}'|uniq -c)
Memory_Info=$(dmidecode -t memory|awk -F ": " '/^[ \t]+(Size:|Type:|Speed:|Manufacturer)/{gsub(/^[ \t]+/,"");if($2 !~ "NO*|Unknow")print $0}')
Mem_size_peer_device=$(dmidecode -t memory|awk -F ": " '/^[ \t]+Size/{gsub(/^[ \t]+/,"");if($2 !~ "NO*|Unknow")print $2}'|uniq)

### CPU硬件信息(cpu Information) ###
Cpu_num=$(dmidecode -t processor|grep "Processor Information"|wc -l)
Cpu_Info=$(dmidecode -t processor|awk -F ": " '/^[ \t]+(Manufacturer|Family|Version|Max Speed|Current Speed|Core Count)|Thread Count/{gsub(/^[ \t]+/,"");print $0}')
Cpu_name=$(lscpu |awk -F ":" '/Model name/{print $2}'|awk '{gsub(/^[ \t]+/,"");print $0}')

### nvme and nvidia gpu info ###
Nvme_num=$(lspci |grep Non-Volatile | wc -l)
Gpu_num=$(lspci |grep NVIDIA|wc -l)

### Network ###
Gateway=$(ip r|awk '{if($1 == "default") print $3}')
if [ -n "$Gateway" ];then
    Net_dev=$(ip r|awk '{if($1 == "default") print $5}')
    DIP=$(ip a ls  $Net_dev|awk '/\<inet\>/{print $2}' |awk -F '/' '{print $1}')
else
    Gty=$(ip r|awk 'NR==1{print $3}')
    Net_dev=$(ip r|awk 'NR==1{print $NF}')
    DIP=$(ip a ls  $Net_dev|awk '/\<inet\>/{print $2}' |awk -F '/' '{print $1}')
fi


### 磁盘 ###
disk_device=$(lsblk -dnp -o NAME,SIZE)
Disk_info=$(df -h --output='source','fstype','ipcent','size','used','avail','pcent','target'|egrep -v "overlay2|kubelet|containers"|awk '{if(NR>1)print $0}')
Partition=$(lsblk -lnp -o NAME,SIZE,FSTYPE,MOUNTPOINT,TYPE|awk '$NF != "disk"{NF-=1;print}')

### Service ###
Service=(firewalld NetworkManager ntpd crond)

### Port Listen ###
Port_listen=$(ss -lntp|awk '{if(NR>1)print $4,$6}')
### users ###
Users=$(awk -F: '$7 !~ /(nologin|sync|shutdown|halt|false)/{print $1,$7}' /etc/passwd)

