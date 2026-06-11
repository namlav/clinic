import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_new_password_screen.dart';

enum OtpTypeVerify { email, sms, recovery }

class OTPVerificationScreen extends StatefulWidget {
  final String target;
  final OtpTypeVerify type;
  final Map<String, String>? userData;

  const OTPVerificationScreen({
    super.key,
    required this.target,
    required this.type,
    this.userData,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isVerifying = false;

  void _verify() async {
    if (_otpController.text.length < 6) return;
    setState(() => _isVerifying = true);

    try {
      final res = await supabase.auth.verifyOTP(
        type: widget.type == OtpTypeVerify.sms
            ? OtpType.sms
            : (widget.type == OtpTypeVerify.email
                  ? OtpType.signup
                  : OtpType.recovery),
        token: _otpController.text.trim(),
        email: widget.type != OtpTypeVerify.sms ? widget.target : null,
        phone: widget.type == OtpTypeVerify.sms ? widget.target : null,
      );

      if (res.user != null) {
        if (widget.type == OtpTypeVerify.recovery) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNewPasswordScreen(),
            ),
          );
        } else {
          // Ép cập nhật Password & Email để Login được bằng Pass
          await supabase.auth.updateUser(
            UserAttributes(
              email: widget.userData!['email'],
              password: widget.userData!['password'],
            ),
          );

          // Lưu DB public
          await supabase.from('users').upsert({
            'userid': res.user!.id,
            'authid': res.user!.id,
            'fullname': widget.userData!['fullname'],
            'email': widget.userData!['email'],
            'phone': widget.userData!['phone'],
            'isactive': true,
            'joineddate': DateTime.now().toIso8601String(),
            'membershiptier': 'Standard',
          }, onConflict: 'userid');

          await supabase.auth.signOut();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xác thực: Mã sai hoặc hết hạn")),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực mã OTP")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text("Nhập mã 6 số gửi đến ${widget.target}"),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A7),
                ),
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const CircularProgressIndicator()
                    : const Text(
                        "XÁC NHẬN",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
