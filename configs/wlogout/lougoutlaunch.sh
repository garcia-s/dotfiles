#!/usr/bin/env sh


#// Check if wlogout is already running

if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi

wLayout="$HOME/.config/wlogout/layout_main"
wlTmplt="$HOME/.config/wlogout/style_main.css"

#// detect monitor res
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

wlColms=6 
export mgn=$(( y_mon * 28 / hypr_scale ))
export hvr=$(( y_mon * 23 / hypr_scale )) ;

#// scale font size
export fntSize=$(( y_mon * 2 / 100 ))

#// detect wallpaper brightness
[ -f "${cacheDir}/wall.dcol" ] && source "${cacheDir}/wall.dcol"
[ "${dcol_mode}" == "dark" ] && export BtnCol="white" || export BtnCol="black"

#// eval hypr border radius
export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 8 ))

#// eval config files
wlStyle="$(envsubst < $wlTmplt)"


#// launch wlogout

wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell
