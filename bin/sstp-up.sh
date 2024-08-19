#!/bin/bash

# prepend a timestamp to all output (https://unix.stackexchange.com/a/622928/409236)
exec &> >( /opt/homebrew/bin/gawk '{ print strftime("[%Y-%m-%d %H:%M:%S] "), $0 }' )

function wait_for_op_available() {
    version="0"
    while : ; do
      printf "Checking if 'op' is available\n"
      version=$(/opt/homebrew/bin/op --version)
      if [ "$version" != "0" ]; then
          printf "'op' is available! Continuing...\n"
          break
      fi
      printf "'op' is not available! Sleeping...\n"
      sleep 1
    done
}

wait_for_op_available


export SSTP_USER=$(/opt/homebrew/bin/op read "op://Private/qn27akp5pzhhktv442vscrxm3a/sstp_user")
export SSTP_PASS=$(/opt/homebrew/bin/op read "op://Private/qn27akp5pzhhktv442vscrxm3a/sstp_password")
export SSTP_DOMAIN=$(/opt/homebrew/bin/op read "op://Private/qn27akp5pzhhktv442vscrxm3a/sstp_domain")

sudo /opt/homebrew/sbin/sstpc \
  --cert-warn \
  --tls-ext \
  --log-stdout \
  --log-stderr \
  --log-level 4 \
  --user "$SSTP_USER" \
  --password "$SSTP_PASS" \
  "$SSTP_DOMAIN" \
  usepeerdns require-mschap-v2 noauth noipdefault noccp refuse-eap refuse-pap refuse-mschap defaultroute
