# Versioning Guide

This document explains how to manage versions for the Food Calorie App.

## Overview

We follow [Semantic Versioning](https://semver.org/) with the format `MAJOR.MINOR.PATCH+BUILD`.

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Bug fixes in a backwards compatible manner
- **BUILD**: Incremental build number

## Current Version

**Version**: 1.0.0+3

## Version Management Tools

### Using the Version Script

#### Windows (version.bat)
```batch
cd scripts
version.bat show              # Show current version
version.bat bump minor        # Bump minor version
version.bat release           # Create a release
```

#### Linux/Mac (version.sh)
```bash
cd scripts
chmod +x version.sh
./version.sh show              # Show current version
./version.sh bump minor        # Bump minor version
./version.sh release           # Create a release
```

### Manual Version Update

If you prefer to update versions manually:

1. **Update `frontend/pubspec.yaml`**:
   ```yaml
   version: 1.0.0+1
   ```

2. **Update `frontend/lib/utils/app_version.dart`**:
   ```dart
   static const String version = '1.0.0';
   static const int buildNumber = 1;
   ```

3. **Update `CHANGELOG.md`** with the changes

## Release Process

### 1. Prepare for Release

- Ensure all features are complete and tested
- Update CHANGELOG.md with all changes
- Run tests: `flutter test`

### 2. Bump Version

```batch
cd scripts
version.bat bump minor        # or major, patch, build
```

### 3. Create Release

```batch
version.bat release
```

This will:
- Update version numbers in all files
- Commit changes with message "chore: release v1.0.0"
- Create a git tag "v1.0.0"

### 4. Push Release

```bash
git push origin main
git push origin v1.0.0
```

### 5. Create GitHub Release

1. Go to GitHub Releases
2. Click "Draft a new release"
3. Select the tag you just pushed
4. Add release notes from CHANGELOG.md
5. Publish the release

## Version Bump Guidelines

### When to Bump MAJOR
- Breaking changes to API
- Removing existing features
- Major UI/UX changes that affect user workflow
- Database schema changes requiring migration

### When to Bump MINOR
- Adding new features
- Enhancements to existing features
- New screens or components
- New API endpoints

### When to Bump PATCH
- Bug fixes
- Performance improvements
- Small UI tweaks
- Documentation updates
- Security fixes

### When to Bump BUILD
- Hotfixes that don't require version bump
- Test builds
- Beta releases

## Pre-release Versions

For development and testing, use pre-release versions:

- `1.1.0-alpha.1` - Alpha release (early testing)
- `1.1.0-beta.1` - Beta release (public testing)
- `1.1.0-rc.1` - Release candidate (final testing before release)

### Creating Pre-release

```batch
# Update version manually to include pre-release suffix
# Example: 1.1.0-alpha.1+1
```

## Git Branch Strategy

```
main          → Production releases
develop       → Development branch
feature/*     → Feature branches
hotfix/*      → Hotfix branches
release/*     → Release preparation branches
```

### Feature Branch Workflow

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and commit
3. Push and create PR
4. Merge to develop after review
5. When ready for release, merge develop to main

### Hotfix Workflow

1. Create hotfix branch from main: `git checkout -b hotfix/critical-bug`
2. Fix the issue
3. Bump PATCH version
4. Merge to main and develop
5. Create release immediately

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

### Examples

```
feat: add recipe detail screen
fix: resolve token refresh issue
docs: update API documentation
style: format code with dart format
refactor: simplify auth provider logic
test: add unit tests for API service
chore: update dependencies
perf: optimize image loading
```

## CHANGELOG.md Format

```markdown
## [1.0.0] - 2026-05-13

### Added
- New feature 1
- New feature 2

### Changed
- Updated existing feature

### Fixed
- Fixed bug 1
- Fixed bug 2

### Deprecated
- Old feature (will be removed in 2.0.0)

### Removed
- Removed old feature

### Security
- Security fix 1
```

## Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.

## Automated Versioning with CI/CD

The project includes GitHub Actions workflows for automated versioning:

- `.github/workflows/version.yml` - Version bump automation
- `.github/workflows/release.yml` - Release automation

These workflows can automatically:
- Bump version on merge
- Create git tags
- Generate release notes
- Publish to app stores

## Troubleshooting

### Version Mismatch

If version numbers don't match between files:
1. Check `frontend/pubspec.yaml`
2. Check `frontend/lib/utils/app_version.dart`
3. Ensure both have the same version

### Git Tag Issues

If you need to delete a tag:
```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

### Build Number Conflicts

If build number conflicts occur:
1. Check current build number
2. Manually increment if needed
3. Ensure no concurrent builds are running

## Resources

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Flutter Versioning](https://docs.flutter.dev/deployment/android#versioning)
