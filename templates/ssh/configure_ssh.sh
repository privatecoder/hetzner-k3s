supports_ipv6() {
  [ -f /proc/net/if_inet6 ] || return 1
  [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)" != "1" ]
}

if systemctl is-active ssh.socket > /dev/null 2>&1
then
  # OpenSSH is using socket activation
  mkdir -p /etc/systemd/system/ssh.socket.d
  cat > /etc/systemd/system/ssh.socket.d/listen.conf <<'EOF'
[Socket]
ListenStream=
ListenStream=0.0.0.0:{{ ssh_port}}
EOF
  if supports_ipv6 && [ "{{ ipv6_enabled }}" = "true" ]
  then
    echo "ListenStream=[::]:{{ ssh_port}}" >> /etc/systemd/system/ssh.socket.d/listen.conf
  fi
  echo "BindIPv6Only=default" >> /etc/systemd/system/ssh.socket.d/listen.conf

  systemctl disable ssh
  systemctl daemon-reload
  systemctl restart ssh.socket
  systemctl stop ssh
else
  # OpenSSH is not using socket activation
  sed -i 's/^#*Port .*/Port {{ ssh_port }}/' /etc/ssh/sshd_config
fi
systemctl restart ssh
