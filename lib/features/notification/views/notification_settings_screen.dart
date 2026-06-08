import 'package:flutter/material.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late List<NotificationSettings> notifications;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    notifications = [
      NotificationSettings(
        id: '1',
        title: 'Nhận báo cáo lịch biểu Email',
        description: 'Bạn sẽ nhận được email về lịch khám hàng ngày',
        isEnabled: true,
        icon: 'email',
        time: '07:00',
      ),
      NotificationSettings(
        id: '2',
        title: 'Thông báo qua tin nhắn SMS',
        description: 'Bạn sẽ nhận được lời nhắc nhở qua SMS',
        isEnabled: true,
        icon: 'sms',
        time: '08:00',
      ),
      NotificationSettings(
        id: '3',
        title: 'Cập nhật về sự kiện y tế',
        description: 'Nhận thông tin về khám sàng lọc và chương trình sức khỏe',
        isEnabled: true,
        icon: 'medical',
        time: null,
      ),
      NotificationSettings(
        id: '4',
        title: 'Nhắc nhở lịch khám',
        description: 'Bạn sẽ nhận lời nhắc trước cuộc hẹn 1 ngày',
        isEnabled: true,
        icon: 'appointment',
        time: '18:00',
      ),
      NotificationSettings(
        id: '5',
        title: 'Bản cập nhật bảo hiểm',
        description: 'Thông báo khi thay đổi quyền lợi bảo hiểm',
        isEnabled: false,
        icon: 'insurance',
        time: null,
      ),
      NotificationSettings(
        id: '6',
        title: 'Nhắc nhở tiêm vắc xin',
        description: 'Nhận lời nhắc khi lịch tiêm sắp tới',
        isEnabled: true,
        icon: 'vaccine',
        time: '09:00',
      ),
      NotificationSettings(
        id: '7',
        title: 'Thông báo huyết áp cao',
        description: 'Nhận cảnh báo khi áp suất tăng cao',
        isEnabled: false,
        icon: 'alert',
        time: null,
      ),
      NotificationSettings(
        id: '8',
        title: 'Thông báo hệ thống',
        description: 'Nhận cập nhật từ hệ thống SereneHealth',
        isEnabled: true,
        icon: 'admin',
        time: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông Báo',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationHeader(),
            const SizedBox(height: 20),
            _buildSectionLabel('Ưu tiên thông báo'),
            const SizedBox(height: 12),
            _buildNotificationTile(0),
            const SizedBox(height: 12),
            _buildNotificationTile(1),
            const SizedBox(height: 20),
            _buildSectionLabel('Danh mục'),
            const SizedBox(height: 12),
            ...List.generate(
              notifications.length - 2,
              (index) => Column(
                children: [
                  _buildNotificationTile(index + 2),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            _buildQuietModeCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Luôn bật thông báo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tùy chỉnh thông báo để cập nhật nhắc nhở về lịch khám và dịch vụ sức khỏe của bạn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(int index) {
    final notification = notifications[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationIcon(notification.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                if (notification.time != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notification.time!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: notification.isEnabled,
            onChanged: (value) {
              setState(() {
                notifications[index] = NotificationSettings(
                  id: notification.id,
                  title: notification.title,
                  description: notification.description,
                  isEnabled: value,
                  icon: notification.icon,
                  time: notification.time,
                );
              });
            },
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildQuietModeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yên Tĩnh',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tạm ngưng những thông báo không quan trọng trong thời gian bạn nghỉ ngơi.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '22:00',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              Text(
                '07:00',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String iconType) {
    final iconData = {
      'email': Icons.email,
      'sms': Icons.sms,
      'medical': Icons.local_hospital,
      'appointment': Icons.calendar_today,
      'insurance': Icons.health_and_safety,
      'vaccine': Icons.vaccines,
      'alert': Icons.warning,
      'admin': Icons.admin_panel_settings,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData[iconType] ?? Icons.notifications,
        color: const Color(0xFF2563EB),
        size: 22,
      ),
    );
  }
}
