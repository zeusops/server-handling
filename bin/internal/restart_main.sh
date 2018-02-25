#!/bin/bash
# 2017-12-15 by Gehock based on a meeting ages ago
# Assumes the server is running in screen window 0 and the log in window 1
# Not very nice implementation, using a PID file would be better

set -e
echo "Restarting arma server at `date`" >> /home/steam/log/cron.log
screen -S byobu -X at 0 stuff $'\003'
screen -S byobu -X at 0 stuff $'start_server.sh main\n'
# sleep 10
# screen -S byobu -X at 1 stuff $'\003'
# screen -S byobu -X at 1 stuff $'log.sh main\n'
echo "Restart done at `date`" >> /home/steam/log/cron.log
ps a | grep arma3server >> /home/steam/log/cron.log
