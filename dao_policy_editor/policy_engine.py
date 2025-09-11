# dao_policy_editor/policy_engine.py
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum
import json
from datetime import time, datetime
from web3 import Web3

class PolicyScope(Enum):
    PERSONAL = "personal"          # Applies only to the user
    HOUSEHOLD = "household"        # Applies to all devices in household
    NEIGHBORHOOD = "neighborhood"  # Applies to local mesh network
    COMMUNITY = "community"        # Applies to wider community

class TimeConstraint(Enum):
    ANYTIME = "anytime"
    WORK_HOURS = "work_hours"
    EVENING = "evening"
    WEEKEND = "weekend"
    QUIET_HOURS = "quiet_hours"

class BandwidthAction(Enum):
    LIMIT = "limit"            # Set absolute bandwidth limit
    REDUCE = "reduce"          # Reduce by percentage
    PRIORITIZE = "prioritize"  # Give priority to certain traffic
    THROTTLE = "throttle"
