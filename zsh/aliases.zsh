alias d="docker-compose"
alias dps="docker ps"
alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"
alias grep="grep --color=auto"

alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

alias vpn="~/bin/vpn-up.sh start"
alias ssh-ha="ssh root@homeassistant.local"
alias ssh-homeassistant="ssh root@homeassistant.local"

# vpn status
alias vstatus="launchctl list | grep com.github.iakunin.dotfiles.vpn-up"
# vpn up
alias vup="launchctl kickstart gui/$UID/com.github.iakunin.dotfiles.vpn-up"
# vpn down
alias vdown="launchctl kill SIGTERM gui/$UID/com.github.iakunin.dotfiles.vpn-up"

alias venable="launchctl bootstrap gui/$UID /Users/iakunin/Library/LaunchAgents/com.github.iakunin.dotfiles.vpn.plist"
alias vdisable="launchctl bootout gui/$UID /Users/iakunin/Library/LaunchAgents/com.github.iakunin.dotfiles.vpn.plist"
