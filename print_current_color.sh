#!/bin/bash

# defines a set of colors, interpolates between them to create a smooth gradient
# and then changes the keyboard backlight color to match the current time
# uses https://github.com/wroberts/rogauracore

red="232,20,22"
orange="255,165,0"
yellow="250,235,54"
green="121,195,20"
blue="72,125,231"
indigo="75,54,157"
violet="112,54,157"

# Function to interpolate between two colors
interpolate_color() {
    local start_color="$1"
    local end_color="$2"
    local steps="$3"

    start_r=$(echo "$start_color" | cut -d',' -f1)
    start_g=$(echo "$start_color" | cut -d',' -f2)
    start_b=$(echo "$start_color" | cut -d',' -f3)

    end_r=$(echo "$end_color" | cut -d',' -f1)
    end_g=$(echo "$end_color" | cut -d',' -f2)
    end_b=$(echo "$end_color" | cut -d',' -f3)

    for ((i = 0; i <= steps; i++)); do
        curr_r=$(echo "scale=0; $start_r + ($end_r - $start_r) * $i / $steps" | bc)
        curr_g=$(echo "scale=0; $start_g + ($end_g - $start_g) * $i / $steps" | bc)
        curr_b=$(echo "scale=0; $start_b + ($end_b - $start_b) * $i / $steps" | bc)
        printf "%02X%02X%02X\n" "$curr_r" "$curr_g" "$curr_b"
    done
}

# Interpolate colors
steps=10
interpolated_colors=()
interpolated_colors+=($(interpolate_color "$red" "$orange" "$steps"))
interpolated_colors+=($(interpolate_color "$orange" "$yellow" "$steps"))
interpolated_colors+=($(interpolate_color "$yellow" "$green" "$steps"))
interpolated_colors+=($(interpolate_color "$green" "$blue" "$steps"))
interpolated_colors+=($(interpolate_color "$blue" "$indigo" "$steps"))
interpolated_colors+=($(interpolate_color "$indigo" "$violet" "$steps"))

current_hour=$(date +"%H")
current_minute=$(date +"%M")
factor=2.72   # adjusted to fit into 24 hours

for ((i=0; i<${#interpolated_colors[@]}; i++)); do
    color=${interpolated_colors[$i]}
    hour_decimal=$(echo "scale=2; $i / $factor" | bc) 
    hour=$(echo "$hour_decimal" | cut -d'.' -f1 )
    if [ "$hour" = "" ]; then
        hour="00"
    elif [ "$hour" -lt 10 ]; then
        hour="0$hour"
    fi
    
    minute_decimal=$(echo "$hour_decimal" | cut -d'.' -f2)
    minute=$(echo "scale=0; $minute_decimal * 60 / 100" | bc)
    if [ "$minute" = "" ]; then
        minute="00"
    elif [ "$minute" -lt 10 ]; then
        minute="0$minute"
    fi

    # if the current time is before $hour:$minute, fire and exit!
    if [ "$current_hour" -lt "$hour" ] || ([ "$current_hour" -eq "$hour" ] && [ "$current_minute" -lt "$minute" ]); then
        echo "Color: #$color, Time: $hour:$minute"
        sudo rogauracore single_static $color
        break
    fi
done
