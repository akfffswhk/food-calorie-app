import 'package:flutter/material.dart';
import 'package:food_calorie_app/utils/app_version.dart';
import 'package:food_calorie_app/theme/app_theme.dart';

class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppVersion.appName,
                  style: AppTheme.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  AppVersion.fullVersion,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Version Information
          _buildSection(
            'Version Information',
            [
              _buildInfoRow('Version', AppVersion.version),
              _buildInfoRow('Build Number', AppVersion.buildNumber.toString()),
              _buildInfoRow('Release Date', '2026-05-11'),
              _buildInfoRow('Type', 'Major Release'),
            ],
          ),
          const SizedBox(height: 24),

          // Build Information
          _buildSection(
            'Build Information',
            [
              _buildInfoRow('Build Type', BuildInfo.buildType),
              _buildInfoRow('Build Timestamp', BuildInfo.buildTimestamp),
              if (BuildInfo.gitCommitHash.isNotEmpty)
                _buildInfoRow('Git Commit', BuildInfo.gitCommitHash.substring(0, 7)),
              if (BuildInfo.gitBranch.isNotEmpty)
                _buildInfoRow('Git Branch', BuildInfo.gitBranch),
            ],
          ),
          const SizedBox(height: 24),

          // Package Information
          _buildSection(
            'Package Information',
            [
              _buildInfoRow('Package Name', AppVersion.packageName),
              _buildInfoRow('Bundle ID', AppVersion.bundleIdentifier),
              _buildInfoRow('Min SDK', AppVersion.minSdkVersion),
              _buildInfoRow('Target SDK', AppVersion.targetSdkVersion),
            ],
          ),
          const SizedBox(height: 24),

          // Version History
          _buildSection(
            'Version History',
            AppVersion.versionHistory.map((info) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    info.version,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${info.releaseDate} • ${info.typeString}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.description,
                            style: AppTheme.bodyMedium,
                          ),
                          if (info.features != null && info.features!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Features:',
                              style: AppTheme.heading3,
                            ),
                            const SizedBox(height: 8),
                            ...info.features!.map((feature) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(feature)),
                                    ],
                                  ),
                                )),
                          ],
                          if (info.bugFixes != null && info.bugFixes!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Bug Fixes:',
                              style: AppTheme.heading3,
                            ),
                            const SizedBox(height: 8),
                            ...info.bugFixes!.map((fix) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(fix)),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Links
          _buildSection(
            'Links',
            [
              _buildLinkRow(
                'GitHub',
                'https://github.com/yourusername/food-calorie-app',
                Icons.code,
              ),
              _buildLinkRow(
                'Privacy Policy',
                'https://yourapp.com/privacy',
                Icons.privacy_tip,
              ),
              _buildLinkRow(
                'Terms of Service',
                'https://yourapp.com/terms',
                Icons.description,
              ),
              _buildLinkRow(
                'Support',
                'https://yourapp.com/support',
                Icons.support_agent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Copyright
          Center(
            child: Text(
              '© 2026 Food Calorie App. All rights reserved.',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.heading3,
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String url, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Open URL
        },
      ),
    );
  }
}
