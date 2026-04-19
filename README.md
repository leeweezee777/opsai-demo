# opsai-test-repo

Exists purely to generate CI failures for opsai evaluation.
Do not use this for anything real.

## Failure types

Generate failures using the `break_things.sh` script from your opsai directory:

```bash
# From inside this repo
bash ../opsai/scripts/break_things.sh import     # ModuleNotFoundError
bash ../opsai/scripts/break_things.sh assertion  # AssertionError
bash ../opsai/scripts/break_things.sh syntax     # SyntaxError
bash ../opsai/scripts/break_things.sh lint       # ruff lint errors
bash ../opsai/scripts/break_things.sh all        # all of the above
```

Each command pushes a branch, triggering a CI run that fails in a different way.
Watch your opsai terminal for findings.
