# Run Directory (Symlink Placeholder)

This directory should be a symlink to the shared `learn-run` repository.

## Setup Instructions

1. Clone the learn-run repository (if not done):
```bash
cd ..
git clone git@github.com:ontic-in/learn-run.git
```

2. Create symlink from your project:
```bash
cd [YOUR_PROJECT]
rm -rf run  # Remove this placeholder
ln -s ../learn-run/run run
```

3. Verify:
```bash
ls -la run  # Should show symlink to ../learn-run/run
```

## What is run/?

The `run/` directory contains:
- Executable prompts for common tasks
- Automation scripts
- Workflow helpers
- CI/CD utilities

## Usage

Reference run files in your workflows:
```bash
# Example: Use GitHub CLI guide
cat run/USE_GH_CLI.md
```

## Why Symlink?

Symlinking ensures all projects use the same automation tools and stay in sync.
