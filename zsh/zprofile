if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; 
then
  startx
fi

if [[ -r ~/.zshrc ]]; then
	. ~/.zshrc
fi

source /etc/profile.d/vte.sh
