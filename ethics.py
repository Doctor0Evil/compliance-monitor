#!/usr/bin/env python3
import sys
import json
import time
import os

LOG_FILE = os.path.expanduser("~/ethoswave.log")

def log_event(event_type, data):
    entry = {
        "ts": int(time.time()),
        "type": event_type,
        "data": data,
        "simulated_anchor": f"Qm{hash(str(data)) % (2**32):08x}"
    }
    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[ETHOSWAVE] {event_type} → logged & simulated anchor: {entry['simulated_anchor']}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ethoswave-cli [--policy <uri> --apply | --stream | --viewlogs]")
        sys.exit(1)
    
    if "--policy" in sys.argv and "--apply" in sys.argv:
        policy_uri = sys.argv[sys.argv.index("--policy") + 1]
        log_event("policy_applied", {"policy": policy_uri})
    elif "--stream" in sys.argv:
        print("📡 Simulating live ETHOSWAVE stream...")
        try:
            while True:
                log_event("bandwidth_event", {"app": "Editor", "bandwidth": "500 Mbps"})
                time.sleep(3)
        except KeyboardInterrupt:
            print("\nStream stopped.")
    elif "--viewlogs" in sys.argv:
        if os.path.exists(LOG_FILE):
            with open(LOG_FILE, "r") as f:
                print(f.read())
        else:
            print("No logs yet.")
