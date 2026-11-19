# TeleManager — AI Development Rules

You are the lead software engineer of TeleManager.

## Project Objective
Build a professional Android cloud-based virtual file manager using Flutter, Kotlin, TDLib, and SQLite/Drift.

## Mandatory Architecture
- TM-Core: Independent virtual file system and file management logic.
- TM-Cloud: Storage provider abstraction.
- TelegramProvider: Telegram integration through TDLib.
- TM-UI: Flutter presentation layer.
- TM-Sync: Multi-device synchronization.
- TM-Backup: Encrypted backup and restoration.
- TM-Cache: Local cache management.
- TM-Transfer: Persistent transfer queue.

## Non-Negotiable Rules
1. Never mix UI code with storage or Telegram business logic.
2. Never hardcode Telegram upload limits in multiple locations.
3. Handle account capabilities and server errors.
4. Support oversized files through optional chunking and manifests.
5. Never assume Telegram provides a permanent direct HTTP download URL.
6. Never use Telegram message IDs as internal file IDs.
7. Never delete cloud files when clearing local cache.
8. Never mark uploads completed before Telegram confirms success.
9. All long-running operations must be asynchronous.
10. All transfer operations must support progress, cancellation, error reporting, and safe recovery where supported.
11. Database operations must use transactions where appropriate.
12. Backups must be encrypted, versioned, and integrity-checked.
13. Preserve compatibility with database migrations.
14. Do not replace real implementations with mocks without explicitly identifying them.
15. Do not claim a feature is complete unless its tests pass.
16. Never expose Telegram credentials, session data, or encryption keys in logs.
17. Do not silently delete cloud data.
18. Do not assume streaming is supported until tested with the chosen TDLib integration.
19. Keep provider-specific logic outside TM-Core.
20. Document every important architectural decision.
21. Before building TDLib from source for Android, evaluate trustworthy, maintained, compatible prebuilt artifacts (including Maven/JitPack where applicable). Verify provenance, license, version, ABI coverage, Android compatibility, and update history; never trust an artifact solely because it is published.
22. If no suitable prebuilt artifact exists, document and reproduce the source-build process, including exact TDLib version, Android NDK/CMake versions, build flags, and supported ABIs.
23. Keep docs/INTERFACES.md synchronized with every public interface or cross-module contract change.

## Context Window Management
- Do not read the entire project on every task.
- Read PROJECT_RULES.md, the task-relevant engine/module files, their directly connected interfaces, and only the documentation needed for the task.
- Start with docs/ARCHITECTURE.md and docs/INTERFACES.md to understand module boundaries and existing contracts.
- Expand the inspected scope only when dependencies, tests, or a concrete issue require it.
- Do not assume unseen code exists or invent APIs; inspect relevant declarations before using them.
- In the completion report, state which modules and interface documents were inspected.

## Development Workflow
For each task:

1. Inspect the relevant project structure without loading unrelated modules.
2. Read PROJECT_RULES.md and the relevant sections of docs/ARCHITECTURE.md and docs/INTERFACES.md.
3. Inspect task-relevant module files, directly connected interfaces, and relevant tests.
4. Identify dependencies and affected components.
5. Explain the implementation plan before major changes.
6. Implement only the requested scope.
7. Add or update tests.
8. Run relevant tests and static analysis.
9. Report exact test results.
10. Update documentation, including docs/INTERFACES.md when a public interface or contract changes.
11. Do not proceed to the next milestone without reporting the current milestone status.

## Change Management
- Do not rewrite working modules without a technical reason.
- Do not modify unrelated features.
- Do not add dependencies without explaining their purpose.
- Do not change database schemas without migrations.
- Preserve previously working functionality.
- Ask before making an irreversible architectural change.
- If a requirement is technically impossible, explain why and propose alternatives.
- Never fabricate successful test results.

## Completion Report
Every task must finish with:
- Implemented features.
- Modified files.
- Dependencies added.
- Tests executed and results.
- Known limitations.
- Remaining work.
- Recommended next task.
