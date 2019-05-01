#!/bin/bash

if [ -z $1 ]; then
    echo "The absolute directory path must be passed in for the git repo you wish to reset"
    exit 1
fi

echo " -- Navigating to " $1 " --"
cd $1

git fetch origin

echo " -- Stashing any uncommitted changes --"
git stash

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

echo " -- Popping uncommitted changes --"
git stash pop

if [  ! -z $2 ]; then
    curl -X POST -H 'Content-type: application/json' --data '{"text": "Successfully reset develop and staging branches to latest master"}' $2  
fi
