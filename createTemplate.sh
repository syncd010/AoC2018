#!/bin/sh

if [ -z "$1" ]
then
    echo "Please provide a day number"
    exit
fi

DAY="day$1"

if [ -d $DAY ]
then
    echo "Day $1 already exists"
else
    mkdir $DAY
    cp day.dart $DAY/
    echo "Day $1 created"
fi

if [ -f ~/Downloads/input ]
then
    mv ~/Downloads/input $DAY/
    echo "Input moved"
fi



