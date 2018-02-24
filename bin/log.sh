cd /home/steam/test/log/

tail -f `ls -1 $1*.rpt | tail -n 1`
