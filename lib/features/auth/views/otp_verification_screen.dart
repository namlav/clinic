import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final Map<String, String> userData;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.userData,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  void _verifyAndRegister() async {
    setState(() => _isVerifying = true);
    try {
      // 1. Xác thực OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Kiểm tra OTP bằng cách thử đăng nhập tạm thời (hoặc xác thực)
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 2. Nếu OTP đúng, tiến hành tạo tài khoản Email/Pass
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.userData['email']!,
            password: widget.userData['password']!,
          );

      // 3. Lưu thông tin vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'uid': userCred.user!.uid,
            'name': widget.userData['name'],
            'email': widget.userData['email'],
            'phone': widget.userData['phone'],
            'createdAt': DateTime.now(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      // Về màn hình chính
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi xác thực: Mã OTP sai hoặc Email đã tồn tại"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực OTP")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: Color(0xFF0056A7),
            ),
            const SizedBox(height: 20),
            Text(
              "Nhập mã OTP đã được gửi đến số\n${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 15,
              ),
              decoration: InputDecoration(
                hintText: "000000",
                hintStyle: const TextStyle(letterSpacing: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
                onPressed: _isVerifying ? null : _verifyAndRegister,
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "HOÀN TẤT ĐĂNG KÝ",
                        style: TextStyle(
                          color: Colors.white,
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
