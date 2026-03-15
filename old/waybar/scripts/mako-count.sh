#!/bin/bash
count=$(makoctl list | grep -c "app-name")
if [ "$count" -gt 0 ]; then
    echo "{\"text\":\"$count\",\"alt\":\"notification\",\"tooltip\":\"$count notification(s)\"}"
else
    echo "{\"text\":\"\",\"alt\":\"none\",\"tooltip\":\"No notifications\"}"
fi
