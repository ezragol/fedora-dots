function get_windows {
    swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .focus | length - 1 | if (. > 0) then "+" + (. | tostring) + " more" else "show all windows" end'
}

LAST=$(get_windows)
echo $LAST

swaymsg -mt subscribe '["window", "workspace"]' | while IFS= read -r line
do
    NEXT=$(get_windows)
    if [ "$LAST" != "$NEXT" ]; then
        echo $NEXT
        LAST=$NEXT
    fi
done