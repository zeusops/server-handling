#!/bin/sh
if [ -z ${1} ]
then
	echo "Usage: `basename \"$0\"` path"
else
  if [ -z $WINDOWS ]; then
	  find $1 -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
  fi
fi
