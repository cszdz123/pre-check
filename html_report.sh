#!/bin/bash
export LANG=en
#MIP=`ifconfig|grep "inet addr:"|sed -n '1p'|awk -F':' '{print $2}'|awk -F ' ' '{print $1}'`
WEB_DIR=`ip a|egrep "brd.*global" |awk '{print $2}'|awk -F'/' '{print $1}'`_`date '+%Y%m%d%H%M'`
# A little CSS and table layout to make the report look a little nicer
echo "<HTML>
<HEAD>
<style>
.titulo{font-size: 1em; color: white; background:#0863CE; padding: 0.1em 0.2em;}
table
{
border-collapse:collapse;
}
table, td, th
{
border:1px solid black;
}
</style>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
<title>
系统信息报告——BML
</title>
</HEAD>
<BODY align='center'>" > $WEB_DIR.report.html
# View hostname and insert it at the top of the html body
HOST=$(hostname)
echo "日期: <strong>$(date)</strong><br>
Filesystem usage for host <strong>$HOST</strong><br>
Last reboot time: <strong>` who -b`</strong><br><br>
<table border='1'>
<tr>
<th class='titulo'> HOSTNAME</td>
<th class='titulo'>IP</td>
</tr>" >> $WEB_DIR.report.html
#获取IP
ip a|egrep "^[1-9]{1,2}"|grep -v "lo"|awk -F : '{print $2}'|while read Eth; do
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
echo $HOST >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $(ip a ls  $Eth|awk '/\<inet\>/{print $2}' |awk -F '/' '{printf "IP%+30s\nMASK%+19s\n",$1,$2,"\n"}') >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table>
<br>
<br>
<table border='1'>
<tr>
<th class='titulo'>Machine Info</td>
<th class='titulo'>Value</td>
</tr>" >> $WEB_DIR.report.html
dmidecode -t 1|egrep -e "Product|Serial"|while read line; do
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk -F ':' '{print $1}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk -F ':' '{print $2}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
echo "CPU Info" >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
cat /proc/cpuinfo|grep "name"|cut -d: -f2 |awk '{print "*"$1,$2,$3,$4}'|uniq -c>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html

echo "<tr><td align='center'>" >> $WEB_DIR.report.html
echo "Mem Info" >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
dmidecode | grep -A 16 "Memory Device$" |grep Size:|grep -v "No Module Installed"|awk '{print "*" $2,$3}'|uniq -c>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html

#get host info
echo "</table>
<br>
<table border='1'>
<tr>
<th class='titulo'>Release</td>
<th class='titulo'>Infrastructure</td>
<th class='titulo'>Kernel</td>
</tr>" >> $WEB_DIR.report.html
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
rpm -q --qf %{arch} centos-release >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
uname -p >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
uname -r>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
#get host info
echo "</table>
<br>
<br>
<table border='1'>
<tr>
<th class='titulo'>Name</td>
<th class='titulo'>Total</td>
<th class='titulo'>Used</td>
<th class='titulo'>Free</td>
</tr>" >> $WEB_DIR.report.html
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
cat /proc/cpuinfo |grep "cpu MHz" |uniq|awk -F ':' '{print $1}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
cat /proc/cpuinfo |grep "cpu MHz" |uniq|awk -F ':' '{print $2}' >> $WEB_DIR.report.html
echo "<td align='center'>" >> $WEB_DIR.report.html
 echo `cat /proc/cpuinfo |grep "cpu MHz" |uniq|awk -F ':' '{print $2}'`-`cat /proc/cpuinfo |grep "cpu MHz" |uniq|awk -F ':' '{print $2}'`\*`top -n 1|egrep -e "Cpu"|awk -F ':' '{print $2}'|awk -F',' '{print $4}'|awk -F' ' '{print $2}'|awk -F'%' '{print $1}'`*0.01|bc >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo `cat /proc/cpuinfo |grep "cpu MHz" |uniq|awk -F ':' '{print $2}'`\*`top -n 1|egrep -e "Cpu"|awk -F ':' '{print $2}'|awk -F',' '{print $4}'|awk -F' ' '{print $2}'|awk -F'%' '{print $1}'`*0.01|bc>> $WEB_DIR.report.html 
echo "</td></tr>" >> $WEB_DIR.report.html
top -n 1|egrep -e "Mem|Swap" |while read line; do
echo "<tr><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk -F ':' '{print $1}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk -F ':' '{print $2}'|awk -F',' '{print $1}'|awk -F' ' '{print $2}'|awk -F'%' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk -F ':' '{print $2}'|awk -F',' '{print $3}'|awk -F' ' '{print $2}'|awk -F'%' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line |awk -F ':' '{print $2}'|awk -F',' '{print $2}'|awk -F' ' '{print $2}'|awk -F'%' '{print $1}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table>
<br>
<br>
<table border='1'>
<tr><th class='titulo' colspan=6>Disk Info(df -hP)</td>
</tr>" >> $WEB_DIR.report.html
df -hP|while read line; do
echo "<tr><td >" >> $WEB_DIR.report.html
echo $line | awk '{print $1}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $2}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $3}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $4}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $5}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $6}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "<tr><th class='titulo' colspan=6>Disk Info(df -iP)</td>
</tr>" >> $WEB_DIR.report.html
df -iP|while read line; do
echo "<tr><td >" >> $WEB_DIR.report.html
echo $line | awk '{print $1}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $2}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $3}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $4}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $5}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line | awk '{print $6}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo'>System Load</td>
</tr>" >> $WEB_DIR.report.html
echo "<tr><td>" >> $WEB_DIR.report.html
top -b -d 1 -n 1|tail -n +0|head -n 5|while read line; do
echo "<tr><td>" >> $WEB_DIR.report.html
echo $line >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border=0 rules=none>
<tr>
<th class='titulo' colspan = 12>System Load Top 20</td>
</tr>" >> $WEB_DIR.report.html
echo "<tr><td>" >> $WEB_DIR.report.html
top -b -d 1 -n 1|tail -n +7|head -n +21|while read line; do
echo "<tr><td>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $6}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $7}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $8}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $9}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $10}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $11}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $12}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo' colspan = 11>CPU Load</td>
</tr>" >> $WEB_DIR.report.html
echo "<tr><td>" >> $WEB_DIR.report.html
mpstat -P ALL|tail -n5|while read line; do
echo "<tr><td>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $6}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $7}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $8}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $9}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $10}' >> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $11}' >> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done


echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo' colspan = 17>vmstat 1 10</td>
</tr>
<tr>
<td align='center' colspan=2>proc</td>
<td align='center' colspan=4>memory</td>
<td align='center' colspan=2>swap</td>
<td align='center' colspan=2>io</td>
<td align='center' colspan=2>system</td>
<td align='center' colspan=5>cpu</td>
 </tr>">> $WEB_DIR.report.html
vmstat 1 10|tail -n11|while read line; do
echo "<tr><td>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $6}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $7}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $8}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $9}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $10}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $11}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $12}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $13}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $14}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $15}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $16}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $17}'>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo' colspan = 6>iostat</td>
</tr>">> $WEB_DIR.report.html
iostat |sed -n '3p'|while read line; do
echo "<tr style="border=0"><td>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html 
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $6}'>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
iostat |sed -n '4p'|while read line; do
echo "<tr style="border=0"><td>" >> $WEB_DIR.report.html
echo "&nbsp">> $WEB_DIR.report.html 
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}'>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
iostat|sed -n '6,16p'|while read line; do
echo "<tr><td>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $1}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $2}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $3}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $4}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $5}'>> $WEB_DIR.report.html
echo "</td><td align='center'>" >> $WEB_DIR.report.html
echo $line|awk -F' ' '{print $6}'>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo' >Login History</td>
</tr>" >> $WEB_DIR.report.html
export LANG=c
last|sed -n '1,20p'|while read line; do
echo "<tr><td nowrap="nowrap">" >> $WEB_DIR.report.html
echo $line>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>
<table border='1'>
<tr>
<th class='titulo' colspan = 2>Log Messages</td>
</tr>" >> $WEB_DIR.report.html
export LANG=c
 cat /var/log/messages|grep "`date|cut -c 5-11`"|while read line; do
echo "<tr><td nowrap="nowrap">" >> $WEB_DIR.report.html
echo $line |awk -F $HOST '{print $1}'>> $WEB_DIR.report.html
echo "&nbsp</td><td>" >> $WEB_DIR.report.html
echo $line |awk -F $HOST '{print $2}'>> $WEB_DIR.report.html
echo "</td></tr>" >> $WEB_DIR.report.html
done
echo "<th class='titulo' colspan = 2>Log Warnning</td>
</tr>" >> $WEB_DIR.report.html
cat /var/log/messages|grep "`date|cut -c 5-11`"|egrep -e "erro|warning"|while read line; do
echo "<tr><td nowrap="nowrap"><font color = "red">" >> $WEB_DIR.report.html
echo $line |awk -F $HOST '{print $1}'>> $WEB_DIR.report.html
echo "</font>&nbsp</td><td><font color = "red">" >> $WEB_DIR.report.html
echo $line |awk -F $HOST '{print $2}'>> $WEB_DIR.report.html
echo "</font></td></tr>" >> $WEB_DIR.report.html
done
echo "</table><br><br>">> $WEB_DIR.report.html
echo "</table><br><br></BODY></HTML>" >> $WEB_DIR.report.html
echo $WEB_DIR.report.html
