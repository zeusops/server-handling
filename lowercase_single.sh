if [ -z ${1} ]
then
	echo "Usage: `basename \"$0\"` path"
else
	find $1 -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
fi
