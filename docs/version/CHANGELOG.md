# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Food analysis flow testing documentation
- Comprehensive API integration testing plan

### Fixed
- Auth refresh endpoint now accepts refresh token in request body
- History stats endpoint route ordering fixed
- MongoDB query typos corrected ("<lt" to "$lt")

## [1.0.0+3] - 2026-05-13

### Changed
- Bumped build number to 3
- Updated implementation status with API fixes

## [1.0.0+2] - 2026-05-11

### Changed
- Bumped build number to 2
- Updated implementation status with food analysis testing completion

## [1.0.0+1] - 2026-05-13

### Added
- Initial release of Food Calorie App
- User authentication (login, register, logout)
- JWT token management with secure storage
- Automatic token refresh
- Food image analysis with AI
- History tracking with pagination
- Daily/weekly/monthly history views
- Meal suggestions based on remaining calories
- Recipe details view
- Favorites system for suggestions
- Profile management
- Daily calorie goal setting
- Dietary preferences management
- Allergies tracking
- Statistics dashboard
- Bottom navigation bar
- Dark theme support
- Offline error handling
- Loading states throughout the app

### Changed
- Replaced mock data with real API calls
- Improved error handling and user feedback
- Optimized image loading

### Fixed
- Fixed navigation between screens
- Fixed token persistence across app restarts
- Fixed profile updates not saving to backend

---

## Versioning Guidelines

### Version Format
We follow Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Bug fixes in a backwards compatible manner

### Pre-release Versions
For development versions, use:
- `1.0.0-alpha.1` - Alpha release
- `1.0.0-beta.1` - Beta release
- `1.0.0-rc.1` - Release candidate

### Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with changes
3. Commit changes with message: `chore: release v1.0.0`
4. Create git tag: `git tag -a v1.0.0 -m "Release version 1.0.0"`
5. Push tag: `git push origin v1.0.0`

### Development Versions

For feature development, use:
- `1.1.0-dev` - Development version for next minor release
- `1.0.1-dev` - Development version for next patch release

### Version Bump Rules

**When to bump MAJOR:**
- Breaking changes to API
- Removing existing features
- Major UI/UX changes that affect user workflow

**When to bump MINOR:**
- Adding new features
- Enhancements to existing features
- New screens or components

**When to bump PATCH:**
- Bug fixes
- Performance improvements
- Small UI tweaks
- Documentation updates

### Git Branch Strategy

- `main` - Production releases
- `develop` - Development branch
- `feature/*` - Feature branches
- `hotfix/*` - Hotfix branches
- `release/*` - Release preparation branches

### Commit Message Format

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

Examples:
- `feat: add recipe detail screen`
- `fix: resolve token refresh issue`
- `docs: update API documentation`
- `chore: release v1.0.0`
