sourcing_tool
-------------
Scan and separate blockchain files (.sol, web3 hints) from metalayer files (.zml, .bitshell, nexus/windows hints).

Examples:
# dry-run scan
python3 tools/sourcing_tool/sourcing_tool.py --root . --dry-run

# copy classified files into separated/
python3 tools/sourcing_tool/sourcing_tool.py --copy --no-dry-run
