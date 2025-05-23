#!/bin/bash

## include this in the Hetzner cloud machine init script to create nopassword sudo user with SSH login

# Configurable variables
USERNAME="developer"
GROUPNAME="wheel"
PUBKEY="your-public-key-here"

# Create group if it doesn't exist
if ! getent group "$GROUPNAME" >/dev/null; then
    groupadd "$GROUPNAME"
    echo "Group '$GROUPNAME' created."
fi

# Create user if it doesn't exist
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash -g "$GROUPNAME" "$USERNAME"
    usermod -aG sudo "$USERNAME"
    echo "User '$USERNAME' created and added to '$GROUPNAME' and 'sudo'."
fi

# Set up SSH key access
USER_HOME="/home/$USERNAME"
mkdir -p "$USER_HOME/.ssh"
echo "$PUBKEY" > "$USER_HOME/.ssh/authorized_keys"
chmod 700 "$USER_HOME/.ssh"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown -R "$USERNAME:$GROUPNAME" "$USER_HOME/.ssh"
echo "SSH key added for user '$USERNAME'."

# Configure sudoers for wheel group NOPASSWD
if ! grep -q "^%$GROUPNAME ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    sed -i.bak "/^%$GROUPNAME/s/^# *//; /^%$GROUPNAME/s/ALL$/NOPASSWD: ALL/" /etc/sudoers
    echo "Updated sudoers: %$GROUPNAME NOPASSWD enabled."
fi

