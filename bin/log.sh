if [ ! -z $2 ];
then
	BASEPATH=$2
else
	BASEPATH=/home/steam
fi

cd $BASEPATH/log/

tail -f `ls -1 $1*.rpt | tail -n 1`
