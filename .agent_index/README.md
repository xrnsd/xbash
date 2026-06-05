# .agent_index

This directory is the repository knowledge base for `xbash`.

## What is indexed
- `project_manifest.json`: project overview and entry points
- `file_index.json`: important file metadata, hashes, and timestamps
- `symbol_index.json`: function, class, and constant lookup by file
- `dependency_graph.json`: module and package relationships
- `call_graph.json`: major startup and feature flows
- `feature_map.json`: features mapped to files, symbols, dependencies, and tests
- `config_map.json`: config files, manifests, permissions, env vars, and package managers
- `test_map.json`: current smoke-test coverage and gaps
- `change_log_index.json`: index generation provenance

## Refresh rules
- Keep updates incremental when possible.
- Recompute entries only for files that changed.
- Recheck file hashes and timestamps when investigating staleness.
- Exclude `.git`, `.gradle`, `build`, `dist`, `target`, `node_modules`, `vendor`, `DerivedData`, `.idea`, and `.vscode`.

## Current snapshot
- Indexed commit: `cd49c44785ef070caa3b33191584c4b0024f285f`
- Generated: `2026-06-05T15:32:03Z`
