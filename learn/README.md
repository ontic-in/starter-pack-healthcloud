# Learn Directory (Symlink Placeholder)

This directory should be a symlink to the shared `learn-run` repository.

## Setup Instructions

1. Clone the learn-run repository:
```bash
cd ..
git clone git@github.com:ontic-in/learn-run.git
```

2. Create symlink from your project:
```bash
cd [YOUR_PROJECT]
rm -rf learn  # Remove this placeholder
ln -s ../learn-run/learn learn
```

3. Verify:
```bash
ls -la learn  # Should show symlink to ../learn-run/learn
```

## What is learn/?

The `learn/` directory contains:
- Shared learning prompts and methodologies
- MCP (Model Context Protocol) setup guides
- Best practices and patterns
- Reusable prompt templates

## Why Symlink?

Symlinking allows multiple projects to share the same learn-run repository, ensuring:
- Consistency across projects
- Single source of truth for methodologies
- Easy updates across all projects

## Troubleshooting

**Symlink broken?**
- Ensure learn-run is cloned at the same directory level as your project
- Check relative path: `../learn-run/learn`

**Permission denied?**
- Ensure you have read access to ontic-in/learn-run repository
