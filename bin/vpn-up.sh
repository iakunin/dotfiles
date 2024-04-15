#!/bin/bash

# Author: Sorin-Doru Ipate
# Edited by: Mohammad Amin Dadgar
# Copyright (c) Sorin-Doru Ipate
# Source: https://github.com/sorinipate/vpn-up-for-openconnect

# prepend a timestamp to all output (https://unix.stackexchange.com/a/622928/409236)
exec &> >( /opt/homebrew/bin/gawk '{ print strftime("[%Y-%m-%d %H:%M:%S] "), $0 }' )

PROGRAM_NAME=$(basename $0)
DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
PID_FILE_PATH="${DIR}/${PROGRAM_NAME}.pid"
LOG_FILE_PATH="${DIR}/${PROGRAM_NAME}.log"

# OPTIONS
BACKGROUND=FALSE
    # TRUE          Runs in background after startup
    # FALSE         Runs in foreground after startup

QUIET=FALSE
    # TRUE          Less output
    # FALSE         Detailed output

PRIMARY="\x1b[36;1m"
SUCCESS="\x1b[32;1m"
WARNING="\x1b[35;1m"
DANGER="\x1b[31;1m"
RESET="\x1b[0m"


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


export VPN_NAME="PaloAlto GlobalProtect"
export PROTOCOL="gp"
    # anyconnect       Compatible with Cisco AnyConnect SSL VPN, as well as ocserv (default)
    # nc               Compatible with Juniper Network Connect
    # gp               Compatible with Palo Alto Networks (PAN) GlobalProtect SSL VPN
    # pulse            Compatible with Pulse Connect Secure SSL VPN
export VPN_HOST=$(/opt/homebrew/bin/op read "op://Private/mkolgjopnanhi7i7oolvjbtug4/PaloAlto_GlobalProtect_VPN_Host")
#export VPN_GROUP=<group>
export VPN_USER=$(/opt/homebrew/bin/op read "op://Private/mkolgjopnanhi7i7oolvjbtug4/email")
export VPN_PASSWD=$(/opt/homebrew/bin/op read "op://Private/mkolgjopnanhi7i7oolvjbtug4/password")

function start(){

    if ! is_network_available
        then
            printf "$DANGER"
            printf "Please check your internet connection or try again later!\n"
            printf "$RESET"
            exit 1
    fi

    if is_vpn_running
        then
            printf "$WARNING"
            printf "Already connected to a VPN!\n"
            printf "$RESET"
            exit 1
    fi

    printf "$PRIMARY"
    printf "Starting $PROGRAM_NAME ...\n"
    printf "$RESET"

    printf "$WARNING"
    printf "Process ID (PID) stored in $PID_FILE_PATH ...\n"
    printf "$RESET"

    printf "$WARNING"
    printf "Logs file (LOG) stored in $LOG_FILE_PATH ...\n"
    printf "$RESET"

    connect

    if [ "$BACKGROUND" = TRUE ]
    then
        if is_vpn_running
        then
            printf "$SUCCESS"
            printf "Connected to $VPN_NAME\n"
            print_current_ip_address
            printf "$RESET"
        else
            printf "$DANGER"
            printf "Failed to connect!\n"
            printf "$RESET"
        fi
    fi
}

function connect(){
    if [[ -z $VPN_HOST ]]
        then
            printf "$DANGER"
            printf "Variable 'VPN_HOST' is not declared! Update the variable 'VPN_HOST' declaration in VPN PROFILES ...\n"
            printf "$RESET"
            return
    fi
    if [[ -z $PROTOCOL ]]
        then
            printf "$DANGER"
            printf "Variable 'PROTOCOL' is not declared! Update the variable 'PROTOCOL' declaration in VPN PROFILES ..."
            printf "$RESET"
            return
    fi

    case $PROTOCOL in
        "anyconnect")
            export PROTOCOL_DESCRIPTION="Cisco AnyConnect SSL VPN"
            ;;
        "nc")
            export PROTOCOL_DESCRIPTION="Juniper Network Connect"
            ;;
        "gp")
            export PROTOCOL_DESCRIPTION="Palo Alto Networks (PAN) GlobalProtect SSL VPN"
            ;;
        "pulse")
            export PROTOCOL_DESCRIPTION="Pulse Connect Secure SSL VPN"
            ;;
        *)
            printf "$DANGER"
            printf "Unsupported protocol! Update the variable 'PROTOCOL' declaration in VPN PROFILES ..."
            printf "$RESET"
            return
            ;;
    esac

    printf "$PRIMARY"
    printf "Starting the '$VPN_NAME' on '$VPN_HOST' using '$PROTOCOL_DESCRIPTION' ...\n"
    printf "$RESET"

    if [ "$BACKGROUND" = TRUE ]
    then
        printf "$PRIMARY"
        printf "Running the '$VPN_NAME' in background ...\n"
        printf "$RESET"
        if [ "$QUIET" = TRUE ]
        then
            printf "$PRIMARY"
            printf "Running the '$VPN_NAME' with less output (quiet) ...\n"
            printf "$RESET"
            echo $VPN_PASSWD | sudo /opt/homebrew/bin/openconnect --protocol=$PROTOCOL --background --quiet $VPN_HOST --user=$VPN_USER --authgroup=$VPN_GROUP --passwd-on-stdin --pid-file $PID_FILE_PATH 2>&1 > $LOG_FILE_PATH
        else
            printf "$PRIMARY"
            printf "Running the '$VPN_NAME' with detailed output ...\n"
            printf "$RESET"
            echo $VPN_PASSWD | sudo /opt/homebrew/bin/openconnect --protocol=$PROTOCOL --background $VPN_HOST --user=$VPN_USER --authgroup=$VPN_GROUP --passwd-on-stdin --pid-file $PID_FILE_PATH 2>&1 > $LOG_FILE_PATH
        fi
    else
        printf "$PRIMARY"
        printf "Running the '$VPN_NAME' ...\n"
        printf "$RESET"
        if [ "$QUIET" = TRUE ]
        then
            printf "$PRIMARY"
            printf "Running the '$VPN_NAME' with less output (quiet) ...\n"
            printf "$RESET"
            echo $VPN_PASSWD | sudo /opt/homebrew/bin/openconnect --protocol=$PROTOCOL --quiet $VPN_HOST --user=$VPN_USER --authgroup=$VPN_GROUP --passwd-on-stdin --pid-file $PID_FILE_PATH 2>&1
        else
            printf "$PRIMARY"
            printf "Running the '$VPN_NAME' with detailed output ...\n"
            printf "$RESET"
            echo $VPN_PASSWD | sudo /opt/homebrew/bin/openconnect --protocol=$PROTOCOL $VPN_HOST --user=$VPN_USER --authgroup=$VPN_GROUP --passwd-on-stdin --pid-file $PID_FILE_PATH 2>&1
        fi
    fi

}

function status() {
    if is_vpn_running
        then
            printf "$SUCCESS"
            printf "Connected ...\n"
        else
            printf "$PRIMARY"
            printf "Not connected ...\n"
    fi
    print_current_ip_address
    printf "$RESET"
}

function stop() {

    if is_vpn_running
    then
        printf "$WARNING"
        printf "Connected ...\nRemoving $PID_FILE_PATH ...\n"
        printf "$RESET"
        local pid=$(cat $PID_FILE_PATH)
        sudo kill -9 $pid
        rm -f $PID_FILE_PATH
        printf "$SUCCESS"
        printf "Disconnected ...\n"
    else
        printf "$PRIMARY"
        printf "Disconnected ...\n"
    fi

    print_current_ip_address
    printf "$RESET"
}

function print_info() {
    printf "$WARNING"
    printf "Usage: $(basename "$0") (start|stop|status|restart)\n"
    printf "$RESET"
}

function is_network_available() {
    ping -q -c 1 -W 1 8.8.8.8 > /dev/null 2>&1;
}

function is_vpn_running() {
    test -f $PID_FILE_PATH && return 0
}

function print_current_ip_address() {
    local ip=$(curl --silent https://ifconfig.me/)
    printf "Your IP address (ifconfig.me) is $ip ...\n"
}

case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "status")
        status
        ;;
    "restart")
        $0 stop
        $0 start
        ;;
    *)
        print_info
        exit 0
        ;;
esac
