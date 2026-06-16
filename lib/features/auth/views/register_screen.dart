import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isObscured = true;
  bool _isLoading = false;
  bool _isAgreed = false;

  void _handleRegister() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng đồng ý với Điều khoản & Chính sách để tiếp tục",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String phone = _phoneController.text.trim();
      if (phone.startsWith('0')) phone = '0${phone.substring(1)}';
      String email = _emailController.text.trim().toLowerCase();

      try {
        // Sử dụng hàm RPC check_email_exists để kiểm tra mà không bị chặn bởi RLS
        final bool isEmailExists = await supabase
            .rpc('check_email_exists', params: {'lookup_email': email});

        if (isEmailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email này đã được đăng ký, vui lòng đăng nhập!"),
            ),
          );
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        // Sử dụng signUp chuẩn của Supabase
        await supabase.auth.signUp(
          email: email,
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              target: email,
              type: OtpTypeVerify.email,
              userData: {
                'fullname': _nameController.text.trim(),
                'email': email,
                'phone': phone,
                'password': _passwordController.text.trim(),
                'role': 'patient',
              },
            ),
          ),
        );
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi hệ thống: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF0056D2),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'SereneHealth',
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const Text(
              "Tạo Tài Khoản",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bắt đầu hành trình chữa lành của bạn",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Card Đăng ký
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Họ và Tên"),
                    _buildField(
                      controller: _nameController,
                      hint: "Nguyễn Văn Khỏe",
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Vui lòng nhập họ tên";
                        }
                        if (RegExp(
                          r'[0-9!@#<>?":_`~;[\]\\|=+)(*&^%$-]',
                        ).hasMatch(val)) {
                          return "Tên không chứa số hoặc ký tự đặc biệt";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel("Email"),
                    _buildField(
                      controller: _emailController,
                      hint: "khoe@gmail.com",
                      icon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Vui lòng nhập Email";
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(val)) {
                          return "Định dạng email không hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel("Số điện thoại"),
                    _buildField(
                      controller: _phoneController,
                      hint: "+84 *** *** ***",
                      icon: Icons.phone_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Vui lòng nhập số điện thoại";
                        }
                        if (!RegExp(
                          r'^(0|84)[3|5|7|8|9][0-9]{8}$',
                        ).hasMatch(val)) {
                          return "Số điện thoại 10 số không hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildLabel("Mật khẩu"),
                    _buildField(
                      controller: _passwordController,
                      hint: "********",
                      icon: Icons.lock_outline,
                      isPass: true,
                      validator: (val) => (val != null && val.length >= 6)
                          ? null
                          : "Mật khẩu tối thiểu 6 ký tự",
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isAgreed,
                            activeColor: const Color(0xFF0056D2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (bool? value) {
                              setState(() => _isAgreed = value ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isAgreed = !_isAgreed),
                            child: const Text.rich(
                              TextSpan(
                                text: "Tôi đồng ý với ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Điều Khoản Dịch Vụ",
                                    style: TextStyle(
                                      color: Color(0xFF0056D2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " và "),
                                  TextSpan(
                                    text: "Chính Sách Bảo Mật",
                                    style: TextStyle(
                                      color: Color(0xFF0056D2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _handleRegister,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            else ...[
                              const Text(
                                "Đăng Ký",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Đã có tài khoản? ",
                  style: TextStyle(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Đăng Nhập",
                    style: TextStyle(
                      color: Color(0xFF0056D2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPass = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPass ? _isObscured : false,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Màu nền ô nhập nhạt theo thiết kế
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0056D2), width: 1),
        ),
        errorStyle: const TextStyle(fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
