#!/bin/bash
# Test Reverse Proxy + Load Balancer

PROXY_IP="10.41.100.101"

echo "[*] Testing load balancing..."
for i in {1..6}; do
  curl -s http://$PROXY_IP | grep Hello
done

