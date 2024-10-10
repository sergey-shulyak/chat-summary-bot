#!/bin/bash

# Start the bot
echo 'Restarting bot...'
kill -9 $(cat ./bot.pid)
nohup ruby main.rb > log/bot.log 2>&1 &
echo $! > ./bot.pid
echo 'Bot restarted!'
