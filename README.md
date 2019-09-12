# git-resetter

The purpose of this repo is to maintain a script that will automatically reset our develop and staging environments 

## Usage
This script reads from a file that should house a git repo in each line.  

Below is an example of the contents of what the file should look like.  It is important that this node has access to the git repos otherwise the script cannot clone the repos. 
```
git@github.com:erictsai6/super-web-app.git
git@github.com:erictsai6/something-service.git

```

The script will pull down the repo in the list, force 'develop' and 'staging' to match master and push it back. 

Lastly if you pass a 3rd argument it will curl that endpoint to notify the slack room or whatever service you want to update. 

## Important note
You file MUST end with a new line otherwise it will not read the last repo correctly