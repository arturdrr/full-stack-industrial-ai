# 🤝 Contributing to Full-Stack Industrial AI

## Quick Start for Contributors

1. Fork & Clone
```bash
git clone https://github.com/YOUR-USERNAME/full-stack-industrial-ai.git
```

2. Development Environment
```bash
./scripts/setup-dev.sh
```

3. Run Tests
```bash
./scripts/test-all.sh
```

4. Start Development Stack
```bash
docker-compose -f docker-compose.dev.yml up -d
```

## Development Workflow

### 🔄 Feature Development
1. Create feature branch: `git checkout -b feature/ai-routing-improvement`
2. Write tests first (TDD approach)
3. Implement feature
4. Run full test suite: `./scripts/test-all.sh`
5. Submit PR with clear description

### ✅ Code Quality Standards
- **Python**: Black formatter, flake8 linting, 90%+ test coverage
- **JavaScript**: Prettier + ESLint, Jest testing
- **Documentation**: Update relevant .md files
- **Commit Messages**: Use conventional commits format

### 🧪 Testing Requirements
All PRs must include:
- ✅ Unit tests for new functions
- ✅ Integration tests for API changes  
- ✅ Performance impact assessment
- ✅ Security review for sensitive changes

## Local Development

### 🚀 Dev Environment Features
- Hot reloading for all services
- Debug logging enabled
- Test data pre-loaded
- Mock API responses for development

### 🔧 Debugging
View all logs
```bash
docker-compose logs -f
```
Debug specific service
```bash
docker-compose logs -f litellm-proxy
```
Connect to running container
```bash
docker-compose exec litellm-proxy bash
```

## Architecture Decisions

When proposing architectural changes, include:
- 📋 **Problem Statement**: What issue does this solve?
- 🎯 **Proposed Solution**: High-level approach
- ⚖️ **Trade-offs**: Performance, security, maintenance implications
- 🧪 **Testing Strategy**: How will this be validated?

## Recognition

Contributors will be:
- 🏆 Listed in README contributors section
- 🎖️ Featured in release notes for major contributions
- 💌 Invited to maintainer team after consistent quality contributions