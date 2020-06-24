#!/bin/bash
set -e

if [ -z $1 ]; then
    echo "The file with all of the repositories that you wish to reset at the end of the sprint.  Each git repo should be on a separate line"
    exit 1
fi

if [ -z $2 ]; then
    echo "A base timestamp (epoch) must be passed in to calculate the 2 week sprint cycle"
    exit 1
fi

currdir="$(cd "$(dirname "$0")"; pwd)"

echo "Current directory: $currdir"

one_day_in_seconds=86400
two_weeks_in_seconds=$(($one_day_in_seconds * 14))
timestamp=$(date +%s)
modulo=$((($timestamp - $2) % $two_weeks_in_seconds))
abs_modulo=$(($modulo > 0 ? $modulo : ($modulo * -1)))

if [ "$abs_modulo" -gt "$one_day_in_seconds" ]; then
    echo "Detected that we aren't within a day of the end of the sprint, exiting.."
    exit 1
fi

git_repos=$currdir/git-repos

[ -d $git_repos ] && rm -rf $git_repos

echo
echo "Creating temporary directory: $git_repos"
mkdir $git_repos
echo

index=0
repos=""
while IFS= read -r line; do
    repos="$repos\n$line"
    echo "Cloning: $line"
    git clone $line $git_repos/repo-$index
    cd $git_repos/repo-$index    

    echo " -- Resetting 'develop' branch to latest master --"
    git checkout develop
    git reset --hard origin/master
    git push origin develop --no-verify --force

    echo " -- Resetting 'staging' branch to latest master --"
    git checkout staging
    git reset --hard origin/master
    git push origin staging --no-verify --force

    cd $currdir
    index=$((index+1))
done < $1

echo
echo "Cleaning directory: $git_repos"
rm -rf $git_repos

if [  ! -z $3 ]; then
    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Successfully reset develop and staging branches to latest master: $repos\"}" $3
fi

echo
echo "Done"
echo
