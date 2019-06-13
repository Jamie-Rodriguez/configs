# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Ignore *consecutive* duplicate commands in bash history
export HISTCONTROL=ignoredups

# Customise shell prompt
BOLD="\[$(tput bold)\]"
RESETALL="\[$(tput sgr0)\]"
RESETCOLOUR=$RESETALL${BOLD}

DEEPSKYBLUE="\[\e[38;5;39m\]"
DEEPPINK="\[\e[38;5;197m\]"

export PS1="${RESETCOLOUR}${DEEPSKYBLUE}\u${RESETCOLOUR}@${DEEPSKYBLUE}\h${RESETCOLOUR}: ${DEEPPINK}\w${RESETCOLOUR} \\$ ${RESETALL}"

