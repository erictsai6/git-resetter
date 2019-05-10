#!/bin/bash

if [ -z $1 ]; then
    echo "The absolute directory path must be passed in for the git repo you wish to reset"
    exit 1
fi

if [ -z $2 ]; then
    echo "A base timestamp (epoch) must be passed in to calculate the 2 week sprint cycle"
    exit 1
fi

one_day_in_seconds=86400
two_weeks_in_seconds=$(($one_day_in_seconds * 14))
timestamp=$(date +%s)
modulo=$((($timestamp - $2) % $two_weeks_in_seconds))
abs_modulo=$(($modulo > 0 ? $modulo : ($modulo * -1)))

if [ "$abs_modulo" -gt "$one_day_in_seconds" ]; then
    echo "Detected that we aren't within a day of the end of the sprint, exiting.."
    exit 1
fi

echo " -- Navigating to " $1 " --"
cd $1

git fetch origin

echo " -- Resetting 'develop' branch to latest master --"
git checkout develop
git reset --hard origin/master
git push origin develop --no-verify --force

echo " -- Resetting 'staging' branch to latest master --"
git checkout staging
git reset --hard origin/master
git push origin staging --no-verify --force

echo " -- Resetting 'master' branch to latest master --"
git checkout master
git reset --hard origin/master

if [  ! -z $3 ]; then
    curl -X POST -H 'Content-type: application/json' --data '{"text": "Successfully reset develop and staging branches to latest master"}' $2  
fi
