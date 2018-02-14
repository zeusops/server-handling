cd /home/steam/log/

tail -f `ls -1 arma3server_$1* | tail -n 1`
