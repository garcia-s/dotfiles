alias resource="source $HOME/.bashrc"
alias fman="compgen -c | fzf --preview 'man {}' | xargs man"
alias fcd="ls ~/git | fzf | xargs echo"
alias opentheme="cd /var/www/html/wp-content/themes/hispanos-theme"
alias openhispanos="cd /var/www/html"
alias runemu="emulator -list-avds | sed \"s#INFO .*##g\" | fzf | xargs -i emulator -avd \"{}\" "

