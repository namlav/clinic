import 'package:supabase_flutter/supabase_flutter.dart';

String getUserId() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw Exception('Người dùng chưa đăng nhập');
  }
  return user.id;
}

Future<int> getUserIdFromDatabase() async {
  try {
    final authUuid = getUserId();
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('users')
        .select('userid')
        .eq('id', authUuid)
        .single();

    return response['userid'] as int;
  } catch (e) {
    throw Exception('Lỗi lấy userid từ database: $e');
  }
}
