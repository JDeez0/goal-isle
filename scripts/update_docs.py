#!/usr/bin/env python3
"""Update CURRENT_STATUS.md with recent commits and fresh timestamp."""
import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
STATUS = REPO / 'CURRENT_STATUS.md'
KNOWLEDGE = REPO / 'PROJECT_KNOWLEDGE.md'

# 1. Update "Last updated" timestamp
today = __import__('datetime').date.today().strftime('%B %d, %Y')
for path in [STATUS, KNOWLEDGE]:
    if path.exists():
        text = path.read_text()
        text = re.sub(r'^\*\*Last updated:\*\*.*', f'**Last updated:** {today}', text, flags=re.MULTILINE)
        path.write_text(text)

# 2. Append recent commits as changelog
status = STATUS.read_text()
# Get commits since last doc update
result = subprocess.run(
    ['git', 'log', '--oneline', '--no-decorate', '--follow', '-1', '--', str(STATUS)],
    capture_output=True, text=True, cwd=REPO
)
last_doc = result.stdout.split()[0] if result.stdout.strip() else None
if not last_doc:
    result = subprocess.run(['git', 'rev-list', '--max-parents=0', 'HEAD'], capture_output=True, text=True, cwd=REPO)
    last_doc = result.stdout.strip()

result = subprocess.run(
    ['git', 'log', f'{last_doc}..HEAD', '--oneline', '--no-decorate'],
    capture_output=True, text=True, cwd=REPO
)
changes = '\n'.join(
    line for line in result.stdout.split('\n')
    if line.strip() and 'skip ci' not in line and 'Auto-update' not in line
)

if changes:
    block = f'## Recent Changes\n\n{changes}\n'
    if '## Recent Changes' in status:
        status = re.sub(r'## Recent Changes\n.*?(?=\n## )', block, status, flags=re.DOTALL)
    else:
        status = status.replace('## 🚀 What to Do Next', f'{block}\n## 🚀 What to Do Next')
    STATUS.write_text(status)
    count = len(changes.split('\n'))
else:
    count = 0

print(f'Docs updated: timestamp refreshed, {count} new commits')