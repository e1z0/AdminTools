#!/bin/bash
# testas
USER="admin"
PASS="testas"
HOST="serveris.lt"
curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"${PASS}\", \"user\": \"${USER}"}, \"jsonrpc\":\"2.0\", \"method\": \"user.login\", \"id\": 0}" http://${HOST}/api_jsonrpc.php
