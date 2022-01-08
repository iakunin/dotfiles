# gpg-agent for ssh via YubiKey
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# aliases
alias d='docker-compose'
alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"