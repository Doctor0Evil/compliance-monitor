from enforcement_core import IsolationManager, ResourceAllocator, InteractionMonitor, EmergencyHandler, AuditLogger
from zml_loader import load_constitution, load_resources, load_safety, load_legal

# Load ZML frameworks
constitution = load_constitution("/zml/Core_Constitution.zml")
resources = load_resources("/zml/Resource_Allocation_Ethics.zml")
safety = load_safety("/zml/Cross_Environment_Safety.zml")
legal = load_legal("/zml/Legal_Framework_and_Integration.zml")

# Initialize session
session = IsolationManager.create_session(entity_id="did:bit:hub:user_01", environment="gaming-virtual")

# Allocate resources safely
ResourceAllocator.allocate(session, resources)

# Monitor interactions
InteractionMonitor.start(session, safety)

# Attach emergency handler
EmergencyHandler.attach(session, safety)

# Start audit logging
AuditLogger.start(session)

# Runtime enforcement loop
while session.active:
    InteractionMonitor.check(session)
    ResourceAllocator.update(session)
    EmergencyHandler.evaluate(session)
    AuditLogger.record(session)
