import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_new_password_screen.dart';

enum OtpTypeVerify { email, recovery }

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
      OtpType supabaseOtpType = widget.type == OtpTypeVerify.recovery
          ? OtpType.recovery
          : OtpType.email;

      final res = await supabase.auth.verifyOTP(
        type: supabaseOtpType,
        token: _otpController.text.trim(),
        email: widget.target,
      );

      if (res.user != null) {
        if (widget.type == OtpTypeVerify.recovery) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNewPasswordScreen(),
            ),
          );
        } else {
          await supabase.auth.updateUser(
            UserAttributes(password: widget.userData!['password']),
          );

          await supabase.from('users').upsert({
            'userid': res.user!.id,
            'authid': res.user!.id,
            'fullname': widget.userData!['fullname'],
            'email': widget.userData!['email'],
            'phone': widget.userData!['phone'],
            'role': widget.userData!['role'],
            'isactive': true,
            'joineddate': DateTime.now().toIso8601String(),
            'membershiptier': 'Standard',
          }, onConflict: 'userid');

          await supabase.auth.signOut();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mã xác thực không đúng hoặc đã hết hạn"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực Email"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.email_outlined,
              size: 80,
              color: Color(0xFF0056A7),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mã OTP đã được gửi đến Email",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.target, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(
                  color: Colors.grey.shade300,
                  letterSpacing: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "XÁC NHẬN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
