#!/bin/sh
# A script to backup Github repositories to a Synology.
# By Richard Bairwell. http://www.bairwell.com
# MIT Licenced. https://github.com/bairwell/github2synology

# token from https://github.com/settings/tokens
OAUTH_TOKEN="[PUT YOUR TOKEN HERE BETWEEN THE QUOTES]"
# where should the files be saved
BACKUP_PATH="/volume1/serverBackups/github/backup"


# you shouldn't need to change anything below here - unless you have over 100 repos: in which case, see the bottom.

API_URL="https://api.github.com/user/repos?type=all&per_page=100"
GIT="/volume1/@appstore/git/bin/git"

fetch_fromUrl() {
    echo "Fetching from ${API_URL}"
    REPOS=`curl -H "Authorization: token ${OAUTH_TOKEN}" -s "${API_URL}" | jq -r 'values[] | "\(.full_name),\(.private),\(.git_url),\(.has_wiki)"'`
    for REPO in $REPOS
    do
        REPONAME=`echo ${REPO} | cut -d ',' -f1`
        PRIVATEFLAG=`echo ${REPO} | cut -d ',' -f2`
        ORIGINALGITURL=`echo ${REPO} | cut -d ',' -f3`
        HASWIKI=`echo ${REPO} | cut -d ',' -f4`
        GITURL="${ORIGINALGITURL/git:\/\/github.com\//git@github.com:}"
        mkdir "${BACKUP_PATH}/${REPONAME}" -p
        REPOPATH="${BACKUP_PATH}/${REPONAME}/code"


        if [ -d "$REPOPATH" ]; then
            echo "PULLING Repo URL: ${REPONAME} from url ${GITURL} to ${REPOPATH}"
            cd ${REPOPATH}
            ${GIT} pull
        else
            echo "CLONING Repo URL: ${REPONAME} from url ${GITURL} to ${REPOPATH}"
            ${GIT} clone ${GITURL} ${REPOPATH}
            if [ "true"===${PRIVATEFLAG} ]; then
                `touch ${BACKUP_PATH}/${REPONAME}/private`
            fi
        fi
        if [ "true"===${HASWIKI} ]; then
            WIKIPATH="${BACKUP_PATH}/${REPONAME}/wiki"
            WIKIURL="${ORIGINALGITURL/git:\/\/github.com\//git@github.com:}"
            WIKIURL=`echo ${WIKIURL} | sed -e "s/.git$/.wiki.git/"`
            if [ -d "$WIKIPATH" ]; then
                echo "PULLING Repo Wiki: ${REPONAME} from url ${WIKIURL}: to ${WIKIPATH}"
                cd ${WIKIPATH}
                ${GIT} pull
            else
                echo "CLONING Repo Wiki: ${REPONAME} from url ${WIKIURL}:to ${WIKIPATH}"
                ${GIT} clone ${WIKIURL} ${WIKIPATH}
            fi
        fi
    done

}
fetch_fromUrl
# If you need additional urls adding, put them here.
#API_URL="https://api.github.com/user/repos?type=all&per_page=100&page=2"
#fetch_fromUrl