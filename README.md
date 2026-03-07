# NEURONET Monorepo

AI-Driven Early Detection and Support System for Adolescent Mental Health.

## Structure

```
neuronet/
├── apps/
│   ├── adolescent_app/    # Adolescent mobile app (Flutter)
│   └── guardian_app/      # Guardian mobile app (Flutter)
├── packages/
│   └── neuronet_core/     # Shared models, services, theme, widgets
├── melos.yaml             # Monorepo orchestrator
└── prd.md                 # Product Requirements
```

## Getting Started

```bash
# Install Melos
dart pub global activate melos

# Bootstrap workspace
melos bootstrap

# Run code generation
melos run build_runner

# Run all tests
melos run test

# Analyze all packages
melos run analyze
```

## Apps

| App | User | Description |
|-----|------|-------------|
| `adolescent_app` | Teens 13-17 | Journaling, mood tracking, AI chat, personal dashboard |
| `guardian_app` | Parents/Guardians | Registration, consent management, alerts, aggregated insights |

## Architecture

- **Pattern:** MVVM with Riverpod
- **Models:** Freezed with JSON serialization
- **Routing:** GoRouter
- **Networking:** Dio with JWT auth
- **State:** Riverpod + code generation
