/// App version information and tracking
///
/// This file contains version information for the Food Calorie App.
/// Update this file when releasing new versions.
class AppVersion {
  /// Current app version
  static const String version = '1.0.0';

  /// Build number (increment with each build)
  static const int buildNumber = 3;

  /// Full version string with build number
  static String get fullVersion => '$version+$buildNumber';

  /// App name
  static const String appName = 'Food Calorie';

  /// Package name (Android)
  static const String packageName = 'com.example.food_calorie_app';

  /// Bundle identifier (iOS)
  static const String bundleIdentifier = 'com.example.foodCalorieApp';

  /// Minimum supported SDK version
  static const String minSdkVersion = '21';

  /// Target SDK version
  static const String targetSdkVersion = '34';

  /// Compile SDK version
  static const String compileSdkVersion = '34';

  /// Version history
  static const List<VersionInfo> versionHistory = [
    VersionInfo(
      version: '1.0.0',
      buildNumber: 1,
      releaseDate: '2026-05-11',
      type: ReleaseType.major,
      description: 'Initial release with core features',
    ),
  ];

  /// Check if current version is newer than the given version
  static bool isNewerThan(String otherVersion) {
    final currentParts = version.split('.').map(int.parse).toList();
    final otherParts = otherVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final current = i < currentParts.length ? currentParts[i] : 0;
      final other = i < otherParts.length ? otherParts[i] : 0;

      if (current > other) return true;
      if (current < other) return false;
    }

    return false;
  }

  /// Get version info for a specific version
  static VersionInfo? getVersionInfo(String version) {
    for (final info in versionHistory) {
      if (info.version == version) {
        return info;
      }
    }
    return null;
  }

  /// Get all release notes
  static String getReleaseNotes() {
    final buffer = StringBuffer();
    for (final info in versionHistory) {
      buffer.writeln('## ${info.version} (${info.releaseDate})');
      buffer.writeln(info.description);
      buffer.writeln();
    }
    return buffer.toString();
  }
}

/// Version information for a specific release
class VersionInfo {
  final String version;
  final int buildNumber;
  final String releaseDate;
  final ReleaseType type;
  final String description;
  final List<String>? features;
  final List<String>? bugFixes;
  final List<String>? knownIssues;

  const VersionInfo({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.type,
    required this.description,
    this.features,
    this.bugFixes,
    this.knownIssues,
  });

  /// Get version type as string
  String get typeString {
    switch (type) {
      case ReleaseType.major:
        return 'Major';
      case ReleaseType.minor:
        return 'Minor';
      case ReleaseType.patch:
        return 'Patch';
      case ReleaseType.alpha:
        return 'Alpha';
      case ReleaseType.beta:
        return 'Beta';
      case ReleaseType.rc:
        return 'Release Candidate';
    }
  }
}

/// Release type enum
enum ReleaseType {
  major,
  minor,
  patch,
  alpha,
  beta,
  rc,
}

/// Development build information
class BuildInfo {
  /// Build timestamp
  static final String buildTimestamp = DateTime.now().toIso8601String();

  /// Git commit hash (if available)
  static const String gitCommitHash = String.fromEnvironment('GIT_COMMIT_HASH');

  /// Git branch (if available)
  static const String gitBranch = String.fromEnvironment('GIT_BRANCH');

  /// Is this a debug build?
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);

  /// Is this a profile build?
  static const bool isProfile = bool.fromEnvironment('PROFILE', defaultValue: false);

  /// Is this a release build?
  static const bool isRelease = bool.fromEnvironment('RELEASE', defaultValue: false);

  /// Get build type string
  static String get buildType {
    if (isRelease) return 'Release';
    if (isProfile) return 'Profile';
    return 'Debug';
  }

  /// Get full build info string
  static String get fullBuildInfo {
    return '${AppVersion.fullVersion} ($buildType) - $buildTimestamp';
  }
}
