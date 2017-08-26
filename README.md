Github2Synology
===============
A simple Ash (practically "BusyBox bash") script designed to run on the Synology DS range of file storage servers to backup all repositories (and wikis) for a user from Github.

Running
=======
* Ensure you have `git` installed on the Synology - this can be download from the SynoCommunity. The script also needs cUrl and [jq](https://stedolan.github.io/jq/) but these seem standard on Synologys.

* Now login to Github and go to [https://github.com/settings/tokens]( https://github.com/settings/tokens) and create a personal access token with the following scopes:
    - repo (repo itself including all subs) - Full control of private repositories
    - admin:org read:org - Read org and team membership

* Add this token as the OAUTH_TOKEN in line 7 on the `github2synology.sh` script. (`OAUTH_TOKEN="[PUT YOUR TOKEN HERE BETWEEN THE QUOTES]"`)
* Ensure the backup path is correct on line 9. (`BACKUP_PATH="/volume1/serverBackups/github/backup"`)
* Copy the script over to your Synology and run it (all via SSH)

Problems?
=========
Getting "Access forbidden/Repository not found" issues?
-------------------------------------------------------
This is because the Synology doesn't have access to your Github repositories. The "best (most secure)" way to resolve this is just to enable "SSH Key forwarding" from your Mac/PC to the Synology so it uses your SSH keys for authentication.

On Mac and Linux command line, you should be able to just create/edit `~/.ssh/config` and add:

```
Host [synology]
   ForwardAgent yes
```
   
(replacing synology with the IP/name of your Synology)

In PuTTy on Windows, this is under `Connection`->`SSH`->`Auth`->`Authentication parameters : Allow Agent Forwarding` (ensure Pagaent is running with a Github recognised key).

To test if this is setup correctly, try running from the Synology:
```ssh -T git@github.com```
you should get back:
```Hi xxxxx! You've successfully authenticated, but GitHub does not provide shell access.```

"It's only backing up 100 repositories, I've access to more"
------------------------------------------------------------
Due to the script's simplicity, it does NOT currently read the Github provided `Link:` Http headers which give the `next` page details.

To work around this, run the command `curl -I "https://api.github.com/user/repos?type=all&page=1&per_page=100" -H "Authorization: token [OAUTHTOKEN]"` (replacing `[OAUTHTOKEN]` with your token). You'll then see a line such as:
`Link: <https://api.github.com/user/repos?type=all&per_page=100&page=2>; rel="next", <https://api.github.com/user/repos?type=all&per_page=100&page=3>; rel="last"`

Then just add the Link:...rel="next" entry to the bottom of the script such as:
```
API_URL="https://api.github.com/user/repos?type=all&per_page=100&page=2"

fetch_fromUrl
```
and the `last` and `next` do not match, just repeat these steps changing the `&page=1` increment in the curl command.