alias updt='sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && cargo install-update -a'
alias ausMaus='shutdown -h now'
alias lg='lazygit'

# spyker & next
alias runhorst='sudo chmod 666 /var/run/docker.sock && cd ~/projects/spryker/ && docker/sdk up'
alias phpFixDiff='cd ~/projects/spryker/ && git diff --diff-filter=ACM --name-only development $(git rev-parse --abbrev-ref HEAD) -- src | xargs docker/sdk cli vendor/bin/phpcbf'

# Seg VPN
alias vpn-connect='~/.config/vpn/connect.sh'
alias vpn-disconnect='~/.config/vpn/disconnect.sh'
alias vpn-status='nmcli connection show --active | grep vpn || echo "VPN not connected"'
