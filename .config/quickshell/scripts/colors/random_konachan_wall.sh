#!/usr/bin/env bash

mkdir -p ~/Pictures/Wallpapers
page=$((1 + RANDOM % 10));
item=$((1 + RANDOM % 22));
response=$(curl "https://wallhaven.cc/api/v1/search?apikey=sl0kFZexOeamzYy8HppuAoqr6RkAsfdS&atleast=2560x1440&sorting=toplist&topRange=3M&purity=100&categories=100&ratios=16x9,16x10&page=$page")
link=$(echo "$response" | jq ".data[$item].path" -r);
ext=$(echo "$link" | awk -F. '{print $NF}')
downloadPath="$HOME/Pictures/Wallpapers/wallhaven_random_image.$ext"
curl "$link" -o "$downloadPath"
~/.config/quickshell/scripts/colors/switchwall.sh --image "$downloadPath"
