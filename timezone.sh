timedatectl status|awk '/Time zone/{print $3}'