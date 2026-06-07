import 'package:flutter/material.dart';
import '../models/notification_settings_model.dart';
import '../services/notification_settings_repository.dart';
import '../services/supabase_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationSettingsRepository _repository =
      NotificationSettingsRepository();
  final SupabaseService _supabaseService = SupabaseService();

  NotificationSettings? settings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final userResponse = await _supabaseService.client
          .from('users')
          .select()
          .eq('authid', userId)
          .single();

      final numericUserId = userResponse['userid'] as int;
      final fetchedSettings = await _repository.getSettings(numericUserId);

      setState(() {
        settings = fetchedSettings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (settings == null) return;

    final updatedSettings = NotificationSettings(
      settingId: settings!.settingId,
      userId: settings!.userId,
      emailSummary: key == 'emailSummary' ? value : settings!.emailSummary,
      smsNotification: key == 'smsNotification'
          ? value
          : settings!.smsNotification,
      appointmentReminder: key == 'appointmentReminder'
          ? value
          : settings!.appointmentReminder,
      medicalRecordUpdate: key == 'medicalRecordUpdate'
          ? value
          : settings!.medicalRecordUpdate,
      healthTips: key == 'healthTips' ? value : settings!.healthTips,
      appUpdates: key == 'appUpdates' ? value : settings!.appUpdates,
      quietMode: key == 'quietMode' ? value : settings!.quietMode,
      quietStartTime: settings!.quietStartTime,
      quietEndTime: settings!.quietEndTime,
    );

    setState(() {
      settings = updatedSettings;
    });

    await _repository.updateSettings(updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông Báo',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading || settings == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNotificationTile(
                    '📧 Báo cáo tóm tắt Email',
                    'Nhận tóm tắt email về hoạt động sức khỏe',
                    settings!.emailSummary ?? false,
                    'emailSummary',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '💬 Thông báo SMS',
                    'Nhận nhắc nhở qua tin nhắn SMS',
                    settings!.smsNotification ?? false,
                    'smsNotification',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '📅 Nhắc nhở lịch khám',
                    'Nhận thông báo trước khi có lịch khám',
                    settings!.appointmentReminder ?? false,
                    'appointmentReminder',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '📋 Cập nhật hồ sơ y tế',
                    'Nhận thông báo khi có hồ sơ y tế mới',
                    settings!.medicalRecordUpdate ?? false,
                    'medicalRecordUpdate',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '💡 Mẹo sức khỏe',
                    'Nhận các mẹo và thông tin sức khỏe hữu ích',
                    settings!.healthTips ?? false,
                    'healthTips',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '🔄 Cập nhật ứng dụng',
                    'Nhận thông báo về các cập nhật ứng dụng mới',
                    settings!.appUpdates ?? false,
                    'appUpdates',
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationTile(
                    '🔇 Chế độ im lặng',
                    'Tắt tất cả thông báo trong khoảng thời gian',
                    settings!.quietMode ?? false,
                    'quietMode',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String description,
    bool isEnabled,
    String settingKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              _updateSetting(settingKey, value);
            },
            activeThumbColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }
}
