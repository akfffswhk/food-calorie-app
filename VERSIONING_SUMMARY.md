# Versioning System Summary

## Overview

The Food Calorie App now has a comprehensive versioning system that tracks all improvements and releases.

## Files Created

### 1. Version Tracking
- **`CHANGELOG.md`** - Complete changelog following Keep a Changelog format
- **`VERSIONING.md`** - Detailed versioning guide and documentation
- **`frontend/lib/utils/app_version.dart`** - Version information and tracking in code

### 2. Version Management Scripts
- **`scripts/version.bat`** - Windows batch script for version management
- **`scripts/version.sh`** - Linux/Mac shell script for version management

### 3. GitHub Actions Workflows
- **`.github/workflows/version-bump.yml`** - Automated version bumping
- **`.github/workflows/create-release.yml`** - Automated release creation

### 4. UI Components
- **`frontend/lib/screens/about/version_screen.dart`** - Version information screen

## Current Version

**Version**: 1.0.0+1

## Usage

### Show Current Version
```batch
cd scripts
version.bat show
```

### Bump Version
```batch
version.bat bump minor    # major, minor, patch, or build
```

### Create Release
```batch
version.bat release
```

### View Version in App
1. Open the app
2. Go to Profile
3. Tap "About"
4. View version information and history

## Version Bump Types

| Type | When to Use | Example |
|------|-------------|---------|
| **major** | Breaking changes, API changes | 1.0.0 → 2.0.0 |
| **minor** | New features, enhancements | 1.0.0 → 1.1.0 |
| **patch** | Bug fixes, small improvements | 1.0.0 → 1.0.1 |
| **build** | Hotfixes, test builds | 1.0.0+1 → 1.0.0+2 |

## Commit Message Format

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style
- `refactor:` - Refactoring
- `test:` - Tests
- `chore:` - Maintenance
- `perf:` - Performance

## Release Process

1. **Prepare**: Complete features, update CHANGELOG.md
2. **Bump**: Run `version.bat bump minor`
3. **Release**: Run `version.bat release`
4. **Push**: `git push origin main && git push origin v1.0.0`
5. **Publish**: Create GitHub release with notes

## Automated Versioning

The GitHub Actions workflows automatically:
- Detect version type from commit messages
- Bump version on merge to main/develop
- Create git tags
- Generate release notes
- Build and upload APKs

## Next Steps

1. Test the version scripts locally
2. Set up GitHub Actions in your repository
3. Configure automated version bumping
4. Create your first release

## Documentation

- See [VERSIONING.md](../VERSIONING.md) for detailed guide
- See [CHANGELOG.md](../CHANGELOG.md) for version history
- See [app_version.dart](../frontend/lib/utils/app_version.dart) for code reference
