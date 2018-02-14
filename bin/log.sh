cd /home/steam/log/

tail -f `ls -1 $1* | tail -n 1`
