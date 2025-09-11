# BitHubEnforcementEngine/main.py
import json
import os
import time
import hashlib
from dataclasses import dataclass, asdict
from datetime import datetime
from enum import Enum
from typing import Dict, List, Optional, Set
import yaml  # For ZML loading

class EnvironmentType(Enum):
    GAMING_VIRTUAL = "gaming-virtual"
    PROFESSIONAL = "professional"
    SOCIAL = "social"
    EDUCATIONAL = "educational"
    RESEARCH = "research"
    CREATIVE = "creative"
    GOVERNANCE = "governance"
    EMERGENCY = "emergency"

class EntityType(Enum):
    HUMAN = "human"
    AI = "ai"
    HYBRID = "hybrid"
    CORPORATE = "corporate"
    GOVERNMENT = "government"
    UNKNOWN = "unknown"

class ResourceType(Enum):
    COMPUTATIONAL = "computational"
    STORAGE = "storage"
    NETWORK = "network"
    DATA = "data"
    SPECIALIZED = "specialized"

@dataclass
class SessionState:
    entity_id: str
    environment: EnvironmentType
    start_time: float
    active: bool = True
    allocated_resources: Dict[ResourceType, float] = None
    compliance_score: float = 1.0
    warnings: List[str] = None
    emergency_status: bool = False

    def __post_init__(self):
        if self.allocated_resources is None:
            self.allocated_resources = {}
        if self.warnings is None:
            self.warnings = []

@dataclass
class ComplianceProfile:
    entity_id: str
    entity_type: EntityType
    granted_rights: Set[str]
    environment_access: Dict[EnvironmentType, bool]
    reputation_score: float
    ethical_constraints: List[str]
    safety_parameters: Dict[str, float]

class IsolationManager:
    def __init__(self, instances_dir: str = "instances"):
        self.instances_dir = instances_dir
        self.active_sessions: Dict[str, SessionState] = {}
        os.makedirs(instances_dir, exist_ok=True)
    
    def create_session(self, entity_id: str, environment: EnvironmentType) -> SessionState:
        """Create a new isolated session for an entity in a specific environment"""
        # Check if entity has access to this environment
        profile = self._load_compliance_profile(entity_id)
        if not profile.environment_access.get(environment, False):
            raise ValueError(f"Entity {entity_id} not authorized for {environment.value}")
        
        # Create session directory
        session_id = f"session_{entity_id}_{int(time.time())}"
        session_dir = os.path.join(self.instances_dir, session_id)
        os.makedirs(session_dir, exist_ok=True)
        os.makedirs(os.path.join(session_dir, "assets"), exist_ok=True)
        os.makedirs(os.path.join(session_dir, "logs"), exist_ok=True)
        
        # Initialize session state
        session = SessionState(
            entity_id=entity_id,
            environment=environment,
            start_time=time.time()
        )
        
        # Save initial state
        self._save_session_state(session_dir, session)
        
        # Create initial compliance profile
        self._save_compliance_profile(session_dir, profile)
        
        self.active_sessions[session_id] = session
        return session
    
    def terminate_session(self, session_id: str):
        """Terminate a session and clean up resources"""
        if session_id in self.active_sessions:
            session = self.active_sessions[session_id]
            session.active = False
            
            # Save final state
            session_dir = os.path.join(self.instances_dir, session_id)
            self._save_session_state(session_dir, session)
            
            # Release allocated resources
            # (Implementation would interface with ResourceAllocator)
            
            del self.active_sessions[session_id]
    
    def _load_compliance_profile(self, entity_id: str) -> ComplianceProfile:
        """Load compliance profile for an entity"""
        # In a real implementation, this would load from a secure registry
        # For demo purposes, we create a mock profile
        return ComplianceProfile(
            entity_id=entity_id,
            entity_type=EntityType.HUMAN,  # Default
            granted_rights={"RightToExist", "RightToPrivacy", "RightToFairTreatment"},
            environment_access={
                EnvironmentType.GAMING_VIRTUAL: True,
                EnvironmentType.PROFESSIONAL: True,
                EnvironmentType.SOCIAL: True,
                EnvironmentType.EDUCATIONAL: True,
                EnvironmentType.RESEARCH: False,  # No research access by default
                EnvironmentType.CREATIVE: True,
                EnvironmentType.GOVERNANCE: False,  # No governance access by default
                EnvironmentType.EMERGENCY: False,   # No emergency access by default
            },
            reputation_score=75.0,  # Default score
            ethical_constraints=["non-discrimination", "privacy", "sustainability"],
            safety_parameters={"max_interaction_depth": 5, "reality_separation": 0.8}
        )
    
    def _save_session_state(self, session_dir: str, session: SessionState):
        """Save session state to JSON file"""
        state_path = os.path.join(session_dir, "state.json")
        with open(state_path, 'w') as f:
            json.dump(asdict(session), f, indent=2, default=str)
    
    def _save_compliance_profile(self, session_dir: str, profile: ComplianceProfile):
        """Save compliance profile to JSON file"""
        profile_path = os.path.join(session_dir, "compliance_profile.json")
        with open(profile_path, 'w') as f:
            json.dump(asdict(profile), f, indent=2, default=str)

class ResourceAllocator:
    def __init__(self, resource_policies: Dict):
        self.resource_policies = resource_policies
        self.allocated_resources: Dict[str, Dict[ResourceType, float]] = {}
    
    def allocate(self, session: SessionState, resource_policies: Dict):
        """Allocate resources to a session based on policies"""
        entity_id = session.entity_id
        environment = session.environment
        
        # Get allocation rules for this environment
        env_rules = resource_policies.get(environment.value, {})
        
        # Calculate resource allocation based on entity type, reputation, etc.
        allocation = {}
        for res_type, rules in env_rules.items():
            base_allocation = rules.get("base", 0)
            # Apply scaling factors based on entity properties
            scaling_factor = self._calculate_scaling_factor(session, rules)
            allocation[ResourceType(res_type)] = base_allocation * scaling_factor
        
        # Apply ethical constraints
        allocation = self._apply_ethical_constraints(allocation, session)
        
        # Update session state
        session.allocated_resources = allocation
        
        # Track global allocation
        self.allocated_resources[session.entity_id] = allocation
        
        return allocation
    
    def update(self, session: SessionState):
        """Update resource allocation based on current session state"""
        # Check if resources need adjustment based on compliance score
        if session.compliance_score < 0.7:
            # Reduce resources for non-compliant sessions
            for res_type in session.allocated_resources:
                session.allocated_resources[res_type] *= 0.8  # Reduce by 20%
        
        # Re-apply ethical constraints
        session.allocated_resources = self._apply_ethical_constraints(
            session.allocated_resources, session
        )
    
    def _calculate_scaling_factor(self, session: SessionState, rules: Dict) -> float:
        """Calculate resource scaling factor based on entity properties"""
        # Load compliance profile
        profile = self._load_compliance_profile(session.entity_id)
        
        # Base factor is 1.0
        factor = 1.0
        
        # Apply reputation scaling
        if "reputation_scaling" in rules:
            rep_range = rules["reputation_scaling"]
            factor *= (profile.reputation_score / 100) * (
                rep_range.get("max", 2.0) - rep_range.get("min", 0.5)
            ) + rep_range.get("min", 0.5)
        
        # Apply entity type scaling
        if "entity_type_scaling" in rules:
            type_factors = rules["entity_type_scaling"]
            factor *= type_factors.get(profile.entity_type.value, 1.0)
        
        return max(factor, 0.1)  # Ensure minimum allocation
    
    def _apply_ethical_constraints(self, allocation: Dict[ResourceType, float], 
                                 session: SessionState) -> Dict[ResourceType, float]:
        """Apply ethical constraints to resource allocation"""
        # Load compliance profile
        profile = self._load_compliance_profile(session.entity_id)
        
        # Check sustainability constraints
        if "sustainability" in profile.ethical_constraints:
            for res_type, amount in allocation.items():
                # Apply sustainability limits
                max_sustainable = self._get_sustainable_limit(res_type)
                allocation[res_type] = min(amount, max_sustainable)
        
        return allocation
    
    def _load_compliance_profile(self, entity_id: str) -> ComplianceProfile:
        """Load compliance profile for an entity"""
        # Simplified implementation - would interface with IsolationManager
        # In a real system, this would query a central registry
        return ComplianceProfile(
            entity_id=entity_id,
            entity_type=EntityType.HUMAN,
            granted_rights=set(),
            environment_access={},
            reputation_score=75.0,
            ethical_constraints=[],
            safety_parameters={}
        )
    
    def _get_sustainable_limit(self, resource_type: ResourceType) -> float:
        """Get sustainable limit for a resource type"""
        # These would be configured in policy files
        limits = {
            ResourceType.COMPUTATIONAL: 100.0,
            ResourceType.STORAGE: 500.0,
            ResourceType.NETWORK: 200.0,
            ResourceType.DATA: 1000.0,
            ResourceType.SPECIALIZED: 50.0
        }
        return limits.get(resource_type, 10.0)

class InteractionMonitor:
    def __init__(self, safety_policies: Dict):
        self.safety_policies = safety_policies
        self.interaction_logs: Dict[str, List[Dict]] = {}
    
    def start(self, session: SessionState, safety_policies: Dict):
        """Start monitoring interactions for a session"""
        session_id = f"{session.entity_id}_{session.environment.value}"
        self.interaction_logs[session_id] = []
        
        # Log monitoring start
        self._log_interaction(
            session_id,
            "monitoring_start",
            "Interaction monitoring started",
            {"environment": session.environment.value}
        )
    
    def check(self, session: SessionState):
        """Check current interactions for compliance issues"""
        session_id = f"{session.entity_id}_{session.environment.value}"
        
        # Get safety rules for this environment
        env_rules = self.safety_policies.get(session.environment.value, {})
        
        # Simulate interaction checking
        # In a real system, this would analyze actual interactions
        issues = self._simulate_interaction_analysis(session, env_rules)
        
        # Update session compliance score
        if issues:
            session.compliance_score *= 0.9  # Reduce compliance score
            session.warnings.extend(issues)
            
            for issue in issues:
                self._log_interaction(
                    session_id,
                    "compliance_issue",
                    issue,
                    {"compliance_score": session.compliance_score}
                )
    
    def _simulate_interaction_analysis(self, session: SessionState, rules: Dict) -> List[str]:
        """Simulate interaction analysis (would be replaced with real analysis)"""
        issues = []
        
        # Randomly generate some issues for demonstration
        import random
        if random.random() < 0.2:  # 20% chance of issue
            issues.append("Potential boundary violation detected")
        
        if random.random() < 0.1:  # 10% chance of more serious issue
            issues.append("Ethical constraint nearing violation threshold")
        
        return issues
    
    def _log_interaction(self, session_id: str, event_type: str, 
                        description: str, metadata: Dict):
        """Log an interaction event"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "event_type": event_type,
            "description": description,
            "metadata": metadata
        }
        
        if session_id in self.interaction_logs:
            self.interaction_logs[session_id].append(log_entry)
        
        # Also save to session log file
        session_dir = os.path.join("instances", f"session_{session_id}")
        log_path = os.path.join(session_dir, "logs", "interactions.jsonl")
        
        with open(log_path, 'a') as f:
            f.write(json.dumps(log_entry) + "\n")

class EmergencyHandler:
    def __init__(self, safety_policies: Dict):
        self.safety_policies = safety_policies
        self.emergency_protocols = safety_policies.get("emergency_protocols", {})
    
    def attach(self, session: SessionState, safety_policies: Dict):
        """Attach emergency handler to a session"""
        # Load environment-specific emergency protocols
        env_protocols = safety_policies.get(session.environment.value, {}).get(
            "emergency_protocols", []
        )
        
        # Initialize emergency status
        session.emergency_status = False
    
    def evaluate(self, session: SessionState):
        """Evaluate if emergency protocols should be activated"""
        # Check compliance score threshold
        if session.compliance_score < 0.3:
            self._activate_emergency(session, "Low compliance score")
        
        # Check for specific emergency conditions
        if session.warnings and any("violation" in w for w in session.warnings):
            self._activate_emergency(session, "Boundary violation detected")
    
    def _activate_emergency(self, session: SessionState, reason: str):
        """Activate emergency protocols for a session"""
        session.emergency_status = True
        
        # Get environment-specific emergency protocols
        env_protocols = self.safety_policies.get(
            session.environment.value, {}
        ).get("emergency_protocols", [])
        
        # Execute emergency protocols
        for protocol in env_protocols:
            self._execute_protocol(session, protocol)
        
        # Log emergency activation
        self._log_emergency(session, reason, env_protocols)
    
    def _execute_protocol(self, session: SessionState, protocol: str):
        """Execute a specific emergency protocol"""
        if protocol == "immediate_disconnect":
            # Would actually disconnect the session
            print(f"Emergency disconnect for {session.entity_id}")
        
        elif protocol == "environment_freeze":
            # Would freeze the environment state
            print(f"Environment freeze for {session.entity_id}")
        
        elif protocol == "admin_alert":
            # Would alert administrators
            print(f"Admin alert for {session.entity_id}")
        
        elif protocol == "resource_restriction":
            # Restrict resources
            if session.allocated_resources:
                for res_type in session.allocated_resources:
                    session.allocated_resources[res_type] *= 0.2  Reduce to 20%
    
    def _log_emergency(self, session: SessionState, reason: str, protocols: List[str]):
        """Log emergency activation"""
        session_id = f"{session.entity_id}_{session.environment.value}"
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "event_type": "emergency_activation",
            "reason": reason,
            "protocols_activated": protocols,
            "compliance_score": session.compliance_score
        }
        
        # Save to session log file
        session_dir = os.path.join("instances", f"session_{session_id}")
        log_path = os.path.join(session_dir, "logs", "emergency.jsonl")
        
        with open(log_path, 'a') as f:
            f.write(json.dumps(log_entry) + "\n")

class AuditLogger:
    def __init__(self, ledger_path: str = "ledger/keyless_ledger.jsonl"):
        self.ledger_path = ledger_path
        os.makedirs(os.path.dirname(ledger_path), exist_ok=True)
    
    def start(self, session: SessionState):
        """Start audit logging for a session"""
        # Log session creation
        self._log_to_ledger({
            "timestamp": datetime.now().isoformat(),
            "entity_id": session.entity_id,
            "environment": session.environment.value,
            "event_type": "session_start",
            "start_time": session.start_time
        })
    
    def record(self, session: SessionState):
        """Record current session state to audit log"""
        # Log session state at interval
        self._log_to_ledger({
            "timestamp": datetime.now().isoformat(),
            "entity_id": session.entity_id,
            "environment": session.environment.value,
            "event_type": "session_update",
            "compliance_score": session.compliance_score,
            "allocated_resources": session.allocated_resources,
            "warnings": session.warnings,
            "emergency_status": session.emergency_status
        })
    
    def _log_to_ledger(self, record: Dict):
        """Add a record to the keyless ledger"""
        # Generate hash for record integrity
        record_str = json.dumps(record, sort_keys=True, default=str)
        record_hash = hashlib.sha256(record_str.encode()).hexdigest()
        
        # Add hash to record
        record["_hash"] = record_hash
        
        # Append to ledger file
        with open(self.ledger_path, 'a') as f:
            f.write(json.dumps(record) + "\n")

# ZML Loader functions
def load_constitution(zml_path: str) -> Dict:
    """Load and parse constitution ZML file"""
    return _load_zml_file(zml_path)

def load_resources(zml_path: str) -> Dict:
    """Load and parse resource allocation ZML file"""
    return _load_zml_file(zml_path)

def load_safety(zml_path: str) -> Dict:
    """Load and parse safety ZML file"""
    return _load_zml_file(zml_path)

def load_legal(zml_path: str) -> Dict:
    """Load and parse legal framework ZML file"""
    return _load_zml_file(zml_path)

def _load_zml_file(zml_path: str) -> Dict:
    """Load a ZML file (using YAML parser for demonstration)"""
    try:
        with open(zml_path, 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Warning: ZML file not found: {zml_path}")
        return {}
    except yaml.YAMLError as e:
        print(f"Error parsing ZML file {zml_path}: {e}")
        return {}

# Main enforcement loop
def main():
    # Load ZML frameworks
    constitution = load_constitution("/zml/Core_Constitution.zml")
    resources = load_resources("/zml/Resource_Allocation_Ethics.zml")
    safety = load_safety("/zml/Cross_Environment_Safety.zml")
    legal = load_legal("/zml/Legal_Framework_and_Integration.zml")
    
    # Initialize enforcement components
    isolation_mgr = IsolationManager()
    resource_allocator = ResourceAllocator(resources)
    interaction_monitor = InteractionMonitor(safety)
    emergency_handler = EmergencyHandler(safety)
    audit_logger = AuditLogger()
    
    # Initialize session
    session = isolation_mgr.create_session(
        entity_id="did:bit:hub:user_01", 
        environment=EnvironmentType.GAMING_VIRTUAL
    )
    
    # Allocate resources safely
    resource_allocator.allocate(session, resources)
    
    # Monitor interactions
    interaction_monitor.start(session, safety)
    
    # Attach emergency handler
    emergency_handler.attach(session, safety)
    
    # Start audit logging
    audit_logger.start(session)
    
    # Runtime enforcement loop
    try:
        while session.active:
            interaction_monitor.check(session)
            resource_allocator.update(session)
            emergency_handler.evaluate(session)
            audit_logger.record(session)
            
            # Check for termination conditions
            if session.compliance_score < 0.2 or session.emergency_status:
                print(f"Terminating session for {session.entity_id} due to compliance issues")
                isolation_mgr.terminate_session(session)
                break
            
            # Simulate some processing time
            time.sleep(5)  # Check every 5 seconds in real implementation
            
    except KeyboardInterrupt:
        print("Enforcement loop interrupted")
    finally:
        # Ensure session is properly terminated
        isolation_mgr.terminate_session(session)

if __name__ == "__main__":
    main()
