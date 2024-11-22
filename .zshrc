PROMPT="%B%F{039}%n%f@%F{039}%m%f: %F{197}%~%f %# %b"
RPROMPT="%B%*%b"

export CLICOLOR=1

# Make C-z toggle between `bg` and `fg`
# (Normally C-z only executes `bg` and you have to type/enter `fg` to return
# back to the original process)
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

