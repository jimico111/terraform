cat << EOF > ~/.ssh/config

Host ${hostname}
  HostName ${hostname}
  IdentityFile ${identifyfile}
  User ${username}
  ForwardAgent yes

EOF


chmod 600 ~/.ssh/config