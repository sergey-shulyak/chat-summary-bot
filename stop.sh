#!/bin/bash

# Start the bot
echo 'Stopping bot...'
kill -9 $(cat ./bot.pid)
rm ./bot.pid
echo 'Bot stopped!'
