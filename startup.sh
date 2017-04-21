#!/usr/bin/env sh

# Use 'run' instead of start to keep Presto running and sending logs to Stdout:
/etc/init.d/presto run

# If using the service start then finish this script with a 'tail -f' to keep it
# running and see the logs:
# /etc/init.d/presto start
# tail -f /var/log/presto/server.log

# Also, if required, use this to keep the container running:
# while true; do
#   :
# done
