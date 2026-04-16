[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace

shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"



BOLD="\[\033[1m\]"
FG1="\[\033[38;2;22;29;29m\]"
BG1="\[\033[48;2;126;156;216m\]"
BG2="\[\033[48;2;68;71;90m\]"   
BG3="\[\033[48;2;149;127;184m\]"  
RESET="\[\033[0m\]"

SEP1="\[\033[38;2;126;156;216m\033[48;2;68;71;90m\]"
SEP2="\[\033[38;2;68;71;90m\033[48;2;149;127;184m\]"
END1="\[\033[38;2;68;71;90m\]"
END2="\[\033[38;2;149;127;184m\]"

ERR="\[\e[38;2;255;0;0m\]"


build_promt() {

    local EXIT="$?"
    local BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    PS1="\n${BG1}${FG1}${BOLD} \u@\h ${RESET}${SEP1}${BG2}${FG_W} \w "


    if [ -n "$BRANCH" ]; then
        PS1+="${SEP2}${BG3}${FG1}${BOLD}  $BRANCH ${RESET}${END2}${RESET}"
    else
        PS1+="${RESET}${END1}${RESET}"
    fi

    PS1+="\n"
    if [ "$EXIT" -eq 0 ]; then
        PS1+="${RESET}❯${RESET} "
    else
        PS1+="${ERR}❯${RESET} "
    fi
}


PROMPT_COMMAND=build_promt

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export COLORTERM=truecolor
export TERM=xterm-256color
export CLICOLOR=1

#FLUTTER STUFF
export FLUTTER_PATH=$HOME/dev/flutter/bin
export CHROME_EXECUTABLE=/var/lib/flatpak/app/com.google.Chrome/x86_64/stable/active/export/bin/com.google.Chrome
export PATH=$PATH:$FLUTTER_PATH

# ANDROID STUDIO STUFF
export ANDROID_HOME=$HOME/Android/Sdk #ANDROID HOME
export PATH=$PATH:$ANDROID_HOME/emulator #EMULATOR 
export PATH=$PATH:$ANDROID_HOME/platform-tools 
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin 

#PERSONAL SCRIPTS PATH
export PATH=$PATH:$HOME/scripts
export PATH=$PATH:/usr/local/lib64:$HOME/.pub-cache/bin

#GOLANG
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/golib
export PATH=$PATH:$GOPATH/bin

GOPRIVATE=github.com/garcia-s
GONOPROXY=true

#JAVA
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$PATH:$JAVA_HOME/bin

#SPRING
export SPRING_PATH=$HOME/dev/spring/bin
export PATH=$PATH:$SPRING_PATH


#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

export FLEX_HOME=$HOME/dev/apache-flex
export PATH=$PATH:$FLEX_HOME/bin

### Claudio
export PATH=$HOME/.local/bin:$PATH

### Weird askpass for ssh
export SSH_ASKPASS_REQUIRE=never

### MONADO


export XRT_COMPOSITOR_FORCE_XCB=1
#export MONADO_FAKE_HMD=1
export QWERTY_ENABLE=1
export XRT_DEBUG_GUI=1

export XR_RUNTIME_JSON="/home/symmetry/.local/share/envision/prefixes/simulated_default/share/openxr/1/openxr_monado.json"
export PATH=$PATH:"$HOME/.local/share/envision/prefixes/simulated_default/bin"

## GODOT
export PATH=$PATH:"$HOME/dev/godot"

