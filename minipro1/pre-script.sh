#!/bin/bash

echo -n "Enter your key filename(ex: bsckey):"
read SSHKEYFILE

ssh-keygen -t rsa -f ~/.ssh/$SSHKEYFILE -N ''

