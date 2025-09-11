#!/usr/bin/env python3
"""
sourcing_tool.py
Scan a repository and classify files as 'blockchain' vs 'metalayer' using simple heuristics.
Safe by default (dry-run). Can --copy or --move results into a separated/ directory tree.

Usage:
  ./sourcing_tool.py --root /workspaces/Bit.Hub --dry-run
  ./sourcing_tool.py --copy
"""
import argparse, sys, re, shutil
from pathlib import Path

BLOCK_EXT = {'.sol'}
BLOCK_HINTS = re.compile(r'\b(web3|ethers|solc|geth|truffle|hardhat|chaincode|fabric|eth)\b', re.I)
METAL_EXT = {'.zml', '.bitshell'}
METAL_HINTS = re.compile(r'\b(meta|nexus|xbox|windows10|windows11|metalayer)\b', re.I)

def classify(path):
    if path.suffix.lower() in METAL_EXT:
        return 'metalayer'
    if path.suffix.lower() in BLOCK_EXT:
        return 'blockchain'
    try:
        text = path.read_text(encoding='utf-8', errors='ignore')
    except Exception:
        return 'other'
    if BLOCK_HINTS.search(text):
        return 'blockchain'
    if METAL_HINTS.search(text):
        return 'metalayer'
    return 'other'

def run(root, dry_run=True, do_copy=False, do_move=False, outdir='separated'):
    root = Path(root).resolve()
    files = [p for p in root.rglob('*') if p.is_file() and not any(part.startswith('.') for part in p.parts)]
    groups = {'blockchain':[], 'metalayer':[], 'other':[]}
    for f in files:
        # skip the tool output dir to avoid loops
        if outdir in f.parts:
            continue
        cls = classify(f)
        groups.setdefault(cls, []).append(f.relative_to(root))
    print("Scan summary:")
    for k in groups:
        print(f"  {k}: {len(groups[k])} file(s)")
    if dry_run:
        print("\nDry-run mode; no files will be moved/copied.")
    if do_copy or do_move:
        dst_root = root / outdir
        for k in ('blockchain','metalayer'):
            dest = dst_root / k
            for rel in groups[k]:
                src = root / rel
                dst = dest / rel.parent
                dst.mkdir(parents=True, exist_ok=True)
                target = dst / rel.name
                action = "move" if do_move else "copy"
                print(f"{action}: {src} -> {target}")
                if not dry_run:
                    if do_move:
                        shutil.move(str(src), str(target))
                    else:
                        shutil.copy2(str(src), str(target))
    return groups

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--root', default='.', help='repo root')
    p.add_argument('--dry-run', action='store_true', default=True, help='default dry run')
    p.add_argument('--no-dry-run', dest='dry_run', action='store_false')
    p.add_argument('--copy', action='store_true')
    p.add_argument('--move', action='store_true')
    p.add_argument('--outdir', default='separated')
    args = p.parse_args()
    if args.copy and args.move:
        print("Choose only one of --copy or --move", file=sys.stderr); sys.exit(2)
    run(args.root, dry_run=args.dry_run, do_copy=args.copy, do_move=args.move, outdir=args.outdir)

if __name__ == '__main__':
    main()
