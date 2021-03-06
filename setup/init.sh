#!/bin/bash

# exit script if return code != 0
set -e

# if uid not specified then use default uid for user nobody 
if [[ -z "${UID}" ]]; then
	UID="99"
fi

# if gid not specifed then use default gid for group users
if [[ -z "${GID}" ]]; then
	GID="100"
fi

# set user nobody to specified user id (non unique)
usermod -o -u "${UID}" nobody
echo "[info] Env var UID  defined as ${UID}"

# set group users to specified group id (non unique)
groupmod -o -g "${GID}" users
echo "[info] Env var GID defined as ${GID}"

# check for presence of perms file, if it exists then skip
# setting permissions, otherwise recursively set on /config
if [[ ! -f "/config/perms.txt" ]]; then

	# set permissions for /config volume mapping
	echo "[info] Setting permissions recursively on /config..."
	chown -R "${UID}":"${GID}" /config
	chmod -R 775 /config
	echo "This file prevents permissions from being applied/re-applied to /config, if you want to reset permissions then please delete this file and restart the container." > /config/perms.txt

else

	echo "[info] Permissions already set for /config"

fi

# set permissions inside container
chown -R "${UID}":"${GID}" /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \
chmod -R 775 /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \

echo "[info] Starting Supervisor..."

# run supervisor
"/usr/bin/supervisord" -c "/etc/supervisor.conf" -n