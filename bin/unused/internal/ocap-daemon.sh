#!/bin/bash

shopt -s nullglob

for f in /ocap-output/*.done.json;
do
        echo "Processing $f ..."
        missionfilename=$(basename "$f" ".done.json")
        echo "mission filename is $missionfilename"

        echo "copying json"
        cp "/ocap-output/${missionfilename}" /var/www/ocap/data/
        finishline=$(<"$f")
        finishline=${finishline#\{}
        finishline=${finishline%\}}
        IFS=';' read -a missionarray <<< "$finishline"
        echo curl -v -d "option=dbInsert" -d "worldName=${missionarray[2]}" -d "missionName=${missionarray[3]}" -d "missionDuration=${missionarray[4]}" -d "filename=${missionarray[1]}" http://localhost:8082/ocap/data/receive.php
        curl -v -d "option=dbInsert" -d "worldName=${missionarray[2]}" -d "missionName=${missionarray[3]}" -d "missionDuration=${missionarray[4]}" -d "filename=${missionarray[1]}" http://localhost:8082/ocap/data/receive.php
        echo "moving files"
        mv "/ocap-output/${missionfilename}" /ocap-output/imported/
        mv "${f}" /ocap-output/imported/
done

