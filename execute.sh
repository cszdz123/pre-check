#!/bin/bash

############ Define ##################
WORK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd  $WORK_DIR
export LANG=en
source ./tools/config
source ./tools/check-list.sh
source ./tools/libfunc

############ Check ip list ##################
for IPADDR in ${Host[@]};do
    CheckIPADDR $IPADDR
done

############ Initial report dir ##################
[ ! -d "$WORK_DIR/report" ] && mkdir -p report
rm -f $WORK_DIR/report/*

############ main: execute ##################
if [ ${Cluster_mode} == "false" ];then
    echo "Start Collecting Information at localhost..."
    sh $WORK_DIR/gather.sh
    echo "Collection localhost Information Done!"
elif [ ${Cluster_mode} == "true" ];then
    command_exists sshpass || rpm -ivh $WORK_DIR/rpm/sshpass-1.06-2.el7.x86_64.rpm &> /dev/null
    [ $? != 0 ] && echo "install sshpass failure,please install manual" && exit 1
    build_slave_tar    
    for slave in ${Host[@]};do
        sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave pwd &>/dev/null
        if [ $? != 0 ];then
            red_echo "Can't connect $slave"
            echo "${slave}" >> $WORK_DIR/report/unreachable.txt
        else
            reachHost="$slave $reachHost"
            echo "Begin scp to slaves!"
            if [ ! -f $WORK_DIR/slave.tar ]; then
                red_echo "ERROR: No slave.tar, please build slave tar first"
                exit -1
            fi
                sshpass -e scp -P $SSH_PORT $WORK_DIR/slave.tar $slave:/tmp/
                sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave "mkdir -p /tmp/pre-check && cd /tmp/ && tar xf slave.tar -C /tmp/pre-check"
        fi
    done
# execute at slave
   reachableHost=(${reachHost})
       for slave in ${reachableHost[@]};do
           sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave "cd /tmp/pre-check;sh gather.sh"
           sshpass -e scp -P $SSH_PORT  $slave:/tmp/pre-check/report/* $WORK_DIR/report/
       done
   
       # Clean slave test pacakge
       for slave in ${reachableHost[@]};do
           sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave ls /tmp/pre-check &>/dev/null
           [ $? = 0 ] && sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave rm -rf /tmp/pre-check
           sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave ls /tmp/slave.tar &>/dev/null
           [ $? = 0 ] && sshpass -e  ssh   -p $SSH_PORT -o StrictHostKeyChecking=no root@$slave rm -rf /tmp/slave.tar
       done
           host_index=1
           for host in ${reachableHost[@]};do
               if [[ $host_index == ${#reachableHost[@]} ]];then
                   Cluster_html="$Cluster_html
                {
                  name: \"$host\",
                  url: \"$host-report.html\"
                }"
               else
                   Cluster_html="{
                  name: \"$host\",
                  url: \"$host-report.html\"
                },
                $Cluster_html"
               fi
               let host_index+=1
           done
           export CLUSTER=$Cluster_html
           [ ! -f "$WORK_DIR/report/jquery-3.2.1.min.js" ] && cp $WORK_DIR/template/jquery-3.2.1.min.js $WORK_DIR/report/
           envsubst < template/cluster.html.template >report/cluster.html
else
    echo "Variable <cluster_mode> error,please set cluster_mode=true or cluster_mode=false in tools/config "
    exit 1
fi

### lunch an HTTP Server for view result ###
if [[ $(tty) =~ pts ]];then
        start_http_zh
    elif [[ $(tty) =~ tty ]];then
        start_http_en
fi
 

