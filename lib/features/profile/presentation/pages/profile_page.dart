import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../subscription/presentation/pages/paywall_page.dart';
import '../controllers/export_controller.dart';
import '../controllers/profile_controller.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    final exportController = Get.find<ExportController>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          // ... existing code ...
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),

              // User Profile Card (Reactive)
              Obx(() {
                final user = authController.currentUser.value;
                if (user == null) {
                  return _buildLoginCard();
                }
                return _buildUserCard(user, authController);
              }),

              SizedBox(height: 24.h),

              // Settings Section
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              Obx(
                () => _buildSettingsTile(
                  icon: Icons.monetization_on_outlined,
                  title: 'Currency',
                  subtitle: profileController.selectedCurrency.value,
                  onTap: () => _showCurrencyDialog(context, profileController),
                ),
              ),
              Obx(
                () => _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: _getNotificationSubtitle(profileController),
                  onTap: () =>
                      _showNotificationsDialog(context, profileController),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'System default',
                onTap: () => _showThemeDialog(context),
              ),

              SizedBox(height: 24.h),

              // Data Section
              Text(
                'Data',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              _buildSettingsTile(
                icon: Icons.download_outlined,
                title: 'Data Export',
                subtitle: 'CSV, PDF',
                onTap: () => _showExportDialog(context, exportController),
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Data',
                subtitle: 'Remove all transactions',
                onTap: () => _showClearDataDialog(context),
                textColor: AppColors.errorRed,
              ),

              SizedBox(height: 24.h),

              // About Section
              Text(
                'About',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About MindSpend',
                subtitle: 'Version info & credits',
                onTap: () => _showAboutDialog(context),
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we protect your data',
                onTap: () => _showPrivacyDialog(context),
              ),

              SizedBox(height: 32.h),

              // Version Info
              Center(
                child: FutureBuilder<String>(
                  future: _getVersion(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData
                          ? 'Version ${snapshot.data}'
                          : 'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(user, AuthController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: user.photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 30.sp,
                        color: AppColors.primaryBlue,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'MindSpend User',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (!user.isPremium)
            GestureDetector(
              onTap: () => Get.to(() => const PaywallPage()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (user.isPremium)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Premium Member',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => controller.logout(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.errorRed),
                foregroundColor: AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 48.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          Text(
            'Sign in to sync your data',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Keep your streaks safe and access premium features',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const LoginPage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                'Login / Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: textColor ?? AppColors.primaryBlue,
                  size: 24.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.currencies.keys.length,
            itemBuilder: (context, index) {
              final code = controller.currencies.keys.elementAt(index);
              final symbol = controller.currencies[code];
              return Obx(
                () => RadioListTile<String>(
                  title: Text('$code ($symbol)'),
                  value: code,
                  groupValue: controller.selectedCurrency.value,
                  onChanged: (val) {
                    if (val != null) {
                      controller.updateCurrency(val);
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppColors.primaryOrange,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getNotificationSubtitle(ProfileController controller) {
    List<String> active = [];
    if (controller.morningReminderEnabled.value) {
      active.add('Morning (${_formatTime(controller.morningTime)})');
    }
    if (controller.eveningReminderEnabled.value) {
      active.add('Evening (${_formatTime(controller.eveningTime)})');
    }
    return active.isEmpty ? 'Off' : active.join(', ');
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  void _showNotificationsDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Obx(
        () => AlertDialog(
          title: Text('Daily Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Morning Reminder
              SwitchListTile(
                title: Text('Morning Reminder'),
                subtitle: Text('Time: ${_formatTime(controller.morningTime)}'),
                value: controller.morningReminderEnabled.value,
                onChanged: (val) => controller.toggleMorningReminder(val),
                activeColor: AppColors.primaryOrange,
              ),
              if (controller.morningReminderEnabled.value)
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: controller.morningTime,
                    );
                    if (picked != null) controller.updateMorningTime(picked);
                  },
                  child: Text('Change Morning Time'),
                ),
              Divider(),
              // Evening Reminder
              SwitchListTile(
                title: Text('Evening Reminder'),
                subtitle: Text('Time: ${_formatTime(controller.eveningTime)}'),
                value: controller.eveningReminderEnabled.value,
                onChanged: (val) => controller.toggleEveningReminder(val),
                activeColor: AppColors.primaryOrange,
              ),
              if (controller.eveningReminderEnabled.value)
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: controller.eveningTime,
                    );
                    if (picked != null) controller.updateEveningTime(picked);
                  },
                  child: Text('Change Evening Time'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Light'),
              leading: Radio(value: 0, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text('Dark'),
              leading: Radio(value: 1, groupValue: 1, onChanged: null),
            ),
            ListTile(
              title: Text('System Default'),
              leading: Radio(value: 2, groupValue: 2, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data?'),
        content: Text(
          'This will permanently delete all your transactions and streak data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clear data functionality coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) async {
    final version = await _getVersion();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About MindSpend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MindSpend',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text('Version $version'),
            SizedBox(height: 16.h),
            Text(
              'A mindful expense tracking app that helps you build better spending habits through daily logging and emotional awareness.',
            ),
            SizedBox(height: 16.h),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('• Quick expense logging'),
            Text('• Streak tracking'),
            Text('• Emotion tagging'),
            Text('• Spending insights'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              Text('MindSpend stores all your data locally on your device.'),
              SizedBox(height: 8.h),
              Text('• No data is sent to external servers'),
              Text('• No tracking or analytics'),
              Text('• No ads or third-party services'),
              Text('• Your financial data stays private'),
              SizedBox(height: 12.h),
              Text(
                'All transaction data is stored in a local SQLite database on your device.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<String> _getVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0';
    }
  }

  void _showExportDialog(BuildContext context, ExportController controller) {
    showDialog(
      context: context,
      builder: (context) => Obx(
        () => AlertDialog(
          title: Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date Range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              _buildDateRangeTile(context, controller),
              SizedBox(height: 16.h),
              Text(
                'Choose Format',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: controller.isExporting.value
                  ? null
                  : () => controller.exportCSV(),
              child: Text('Export CSV'),
            ),
            TextButton(
              onPressed: controller.isExporting.value
                  ? null
                  : () => controller.exportPDF(),
              child: Text('Export PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeTile(
    BuildContext context,
    ExportController controller,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: controller.startDate.value,
            end: controller.endDate.value,
          ),
        );
        if (picked != null) {
          controller.startDate.value = picked.start;
          controller.endDate.value = picked.end;
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.bgTertiary),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, size: 20.sp, color: AppColors.primaryOrange),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${dateFormat.format(controller.startDate.value)} - ${dateFormat.format(controller.endDate.value)}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            Icon(Icons.edit, size: 16.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
