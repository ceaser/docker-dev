#!/usr/bin/env bash

# Exit immediately on non-zero return codes.
set -ex

if [ "${1:0:1}" = '-' ]; then
  set -- /usr/sbin/sshd "$@"
fi

# Run boot scripts before starting the server.
if [ "$1" = "/usr/sbin/sshd" ]; then

  HOME_DIR="/home/clarry"
  if [ -z "$(id -u clarry 2>/dev/null)" ]; then
    useradd -U -d "$HOME_DIR" -s /bin/bash clarry
    usermod -G wheel clarry
  fi

  if [ -d "$HOME_DIR" ]; then
    chown clarry:clarry "$HOME_DIR"
  fi

  if [ ! -d "$HOME_DIR/.ssh" ]; then
    mkdir "$HOME_DIR/.ssh"
    chown clarry:clarry "$HOME_DIR/.ssh"
  fi

  if [ ! -f "$HOME_DIR/.ssh/authorized_keys" ]; then
    curl -s https://github.com/ceaser.keys | tee -a "$HOME_DIR/.ssh/authorized_keys"
    chown clarry:clarry "$HOME_DIR/.ssh/authorized_keys"
  fi

  # Setup user/group ids
  if [ ! -z "${DEV_UID}" ]; then
    if [ ! "$(id -u clarry)" -eq "${DEV_UID}" ]; then

      # usermod likes to chown the home directory, so create a new one and use that
      # However, if the new UID is 0, we can't set the home dir back because the
      # UID of 0 is already in use (executing this script).
      if [ ! "${DEV_UID}" -eq 0 ]; then
        mkdir /tmp/temphome
        usermod -d /tmp/temphome clarry
      fi

      # Change the UID
      usermod -o -u "${DEV_UID}" clarry

      # Cleanup the temp home dir
      if [ ! "${DEV_UID}" -eq 0 ]; then
        usermod -d $HOME_DIR clarry
        rm -Rf /tmp/temphome
      fi
    fi
  fi

  if [ ! -z "${DEV_GID}" ]; then
    if [ ! "$(id -g clarry)" -eq "${DEV_UID}" ]; then
      groupmod -o -g "${DEV_UID}" clarry
    fi
  fi
  if [ ! "$CHANGE_HOME_DIR_OWNERSHIP" == "false" ]; then
    chown -R clarry:clarry $HOME_DIR
  fi

  if [ ! -f "/etc/machine-id" ]; then
    dbus-uuidgen --ensure=/etc/machine-id
  fi

  P=`head -c 31 /dev/urandom | base64`
  echo "User password set to: $P"
  echo "clarry:$P" | chpasswd
  unset P
fi

# Execute the command.
#bash -x /init.sh /usr/sbin/sshd -D
exec "$@"
