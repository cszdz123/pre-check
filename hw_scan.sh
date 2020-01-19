#!/bin/bash
Cpu_type=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -d)
Cup_num=$(grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l)
Cpu_core_num=$(cat /proc/cpuinfo |grep 'processor'|wc -l)
Cpu_Mhz=$(cat /proc/cpuinfo |grep MHz|head -1|cut -d: -f2|cut -d. -f1)