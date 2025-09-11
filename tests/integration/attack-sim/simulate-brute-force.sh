#!/bin/bash
echo "🧨 Simulating brute force against canary endpoint..."
for i in {1..50}; do
  curl -s http://localhost:8081/admin.php?cmd=id > /dev/null &
done
wait
echo "✅ Simulation complete. Check Falco alerts and SIEM."
