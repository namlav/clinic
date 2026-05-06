import 'package:flutter/material.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

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
        description: 'Bạn sẽ nhận được email về lịch tờ lịch khám hàng ngày',
        isEnabled: true,
        icon: 'email',
      ),
      NotificationSettings(
        id: '2',
        title: 'Thông báo qua tin nhắn SMS',
        description: 'Bạn sẽ nhận được lời nhắc nhở qua tin nhắn SMS',
        isEnabled: true,
        icon: 'sms',
      ),
      NotificationSettings(
        id: '3',
        title: 'Cập nhật về sự kiện y tế',
        description: 'Bạn sẽ nhận được thông báo về tế độ kiểm tra y tế',
        isEnabled: true,
        icon: 'medical',
      ),
      NotificationSettings(
        id: '4',
        title: 'Nhập nhắc lịch khám bệnh',
        description: 'Bạn sẽ nhận được thông báo nhập khám bệnh trước cuộc hẹn',
        isEnabled: true,
        icon: 'appointment',
      ),
      NotificationSettings(
        id: '5',
        title: 'Bản cập nhật bảo hiểm',
        description: 'Bạn sẽ nhận được thông báo về bảo hiểm y tế',
        isEnabled: false,
        icon: 'insurance',
      ),
      NotificationSettings(
        id: '6',
        title: 'Nhập nhắc tiêm vắc xin',
        description: 'Bạn sẽ nhận được thông báo nhập về vắc xin sắp tới',
        isEnabled: true,
        icon: 'vaccine',
      ),
      NotificationSettings(
        id: '7',
        title: 'Thông báo áp suất máu cao',
        description: 'Bạn sẽ được thông báo khi huyết áp cao',
        isEnabled: false,
        icon: 'alert',
      ),
      NotificationSettings(
        id: '8',
        title: 'Thông báo quản lý trang',
        description: 'Bạn sẽ nhận được thông báo liên quan đến hệ thống',
        isEnabled: true,
        icon: 'admin',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông Báo',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            notifications.length,
            (index) => _buildNotificationTile(index),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(int index) {
    final notification = notifications[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildNotificationIcon(notification.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
            activeThumbColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String iconType) {
    final iconData = {
      'email': Icons.email,
      'sms': Icons.mail,
      'medical': Icons.local_hospital,
      'appointment': Icons.calendar_today,
      'insurance': Icons.health_and_safety,
      'vaccine': Icons.vaccines,
      'alert': Icons.warning,
      'admin': Icons.admin_panel_settings,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[100],
      ),
      child: Icon(
        iconData[iconType] ?? Icons.notifications,
        color: Colors.blue[600],
      ),
    );
  }
}
