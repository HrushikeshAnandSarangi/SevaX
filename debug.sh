#!/usr/bin/env bash

file=''
flavor=''

if [[ $# -eq 0 ]]
    then
        echo "No parameters received. Launching default flavor"
        file="main_app.dart"
        flavor="app"
elif [[ $1 == 'tulsi' ]]
    then
        file="main_tulsi.dart"
        flavor="tulsi"
elif [[ $1 == 'app' ]]
    then
        file="main_app.dart"
        flavor="app"
elif [[ $1 == 'humanityfirst' ]]
    then
        file="main_humanity_first.dart"
        flavor="humanityfirst"
else
    echo "Invalid Params"
    exit
fi

echo "DEBUG: Launching flavor $flavor from lib/$file."
flutter run --flavor ${flavor} --target lib/${file} -d all