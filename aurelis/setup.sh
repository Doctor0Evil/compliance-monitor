# aurelis/setup.sh
#!/bin/bash

echo "Setting up AURELIS Ethical Creation Engine..."

# Create virtual environment
python -m venv aurelis-env
source aurelis-env/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create data directories
mkdir -p data/ledgers
mkdir -p data/logs

# Initialize Web5 identities
python -c "
from web5 import Web5
import asyncio

async def init_web5():
    web5 = await Web5.connect()
    print(f'Initialized Web5 with DID: {web5.did}')
    
asyncio.run(init_web5())
"

echo "AURELIS setup complete!"
echo "Start the system with: python -m aurelis.server.main"
