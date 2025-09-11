# /etc/systemd/system/ethics-guard.service
[Unit]
Description=Bit.Hub Ethics Guard
After=network-online.target

[Service]
Type=oneshot
WorkingDirectory=/srv/runner-repo
ExecStart=/srv/runner-repo/tools/ethics-guard.sh .bit/environment.ethics.yml
User=runner
Group=runner

[Install]
WantedBy=multi-user.target


---

### `.github/workflows/bitbot_recover_failed.yml`
```yaml
name: BitBot Recover Failed Workflows
on:
  schedule:
    - cron: "*/10 * * * *"
  workflow_dispatch:

jobs:
  recover_failed:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Detect Failed Jobs
        run: |
          echo "Scanning for failed jobs in bit.hub..."
          python bithub/scripts/get_failed_jobs.py > failed_jobs.json

      - name: Replace Runner with BitBot Agent
        run: |
          python bithub/scripts/deploy_bitbot_agent.py --input failed_jobs.json --pattern ml.patterns.learn.bitbot.bit

      - name: Retry Failed Jobs with BitBot
        run: |
          python bithub/scripts/retry_with_bitbot.py --input failed_jobs.json

      - name: Mark Legacy Jobs as Superseded
        run: |
          python bithub/scripts/mark_jobs_superseded.py --input failed_jobs.json
```

---

### `.github/workflows/bitbot_queue_pending.yml`
```yaml
name: BitBot Queue Pending Workflows
on:
  schedule:
    - cron: "*/15 * * * *"
  workflow_dispatch:

jobs:
  queue_pending:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get Pending Workflows
        run: |
          python bithub/scripts/get_pending_workflows.py > pending_wfs.json

      - name: Deploy BitBot Agents for Pending
        run: |
          python bithub/scripts/deploy_bitbot_agent.py --input pending_wfs.json --pattern ml.patterns.learn.bitbot.bit

      - name: Run Pending Workflows on BitBot
        run: |
          python bithub/scripts/run_pending_with_bitbot.py --input pending_wfs.json
```

---

### `.github/workflows/bitbot_site_build.yml`
```yaml
name: BitBot Site Build Check
on:
  schedule:
    - cron: "0 * * * *"
  workflow_dispatch:

jobs:
  site_build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check Production Site Status
        run: |
          python bithub/scripts/check_site_status.py --target production > site_status.json

      - name: Trigger Site Build if Needed
        if: ${{ hashFiles('site_status.json') != '' && contains(fromJSON(file('site_status.json')).status, 'stale') }}
        run: |
          python bithub/scripts/deploy_bitbot_agent.py --pattern ml.patterns.learn.bitbot.bit --output agent_id.txt
          python bithub/scripts/run_workflow.py --agent $(cat agent_id.txt) --workflow "site:build" --args "publish:latest"
```

---

### `.github/workflows/bitbot_learning_feedback.yml`
```yaml
name: BitBot Learning Feedback Loop
on:
  workflow_run:
    workflows:
      - BitBot Recover Failed Workflows
      - BitBot Queue Pending Workflows
      - BitBot Site Build Check
    types:
      - completed
  workflow_dispatch:

jobs:
  learn_from_runs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Aggregate Run Results
        run: |
          python bithub/scripts/aggregate_run_results.py > run_results.json

      - name: Update ML Patterns
        run: |
          python bithub/scripts/update_ml_patterns.py --input run_results.json --pattern-store .bithub/ml_patterns.json

      - name: Store Updated Patterns
        run: |
          git config user.name "bitbot"
          git config user.email "bitbot@users.noreply.github.com"
          git add .bithub/ml_patterns.json
          git commit -m "Update ML patterns from latest runs" || echo "No changes"
          git push
```

---

### How they map to your ALN script

| ALN Step | YAML Workflow |
|----------|---------------|
| 1–5: Enumerate failed jobs, replace runner, retry, mark superseded | `bitbot_recover_failed.yml` |
| 6: Queue pending/hanging workflows on BitBot | `bitbot_queue_pending.yml` |
| 7: Verify site build, trigger if needed | `bitbot_site_build.yml` |
| Continuous learning from outcomes | `bitbot_learning_feedback.yml` |

---

If you want, I can also scaffold the **Python stubs** for `get_failed_jobs.py`, `deploy_bitbot_agent.py`, etc., so these workflows will run without errors even before you wire in the real BitBot API calls. That way you can commit them to `Doctor0Evil/ALN_Programming_Language` immediately and iterate. Would you like me to prepare those stubs next?
