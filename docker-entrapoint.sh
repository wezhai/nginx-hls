#!/bin/bash
function startConvertTool() {
    echo "Starting Convert Tool..."
    nohup sh /scripts/script.sh > /var/log/convert-tool.log 2>&1 &
    echo "Started Convert Tool..."
}

function startNginx() {
    echo "Starting Nginx Server..."
    nginx -g 'daemon off;'
}

if [ "${CONVERT_TOOL}" == "True" ]; then
    startConvertTool
    startNginx
else
    startNginx 
fi
