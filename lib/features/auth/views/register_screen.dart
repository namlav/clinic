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
  bool _isLoading = false;

  void _showOptions() {
    if (_formKey.currentState!.validate()) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chọn phương thức xác thực",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("Xác thực qua SMS"),
                onTap: () {
                  Navigator.pop(context);
                  _sendOTP(isSMS: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: const Text("Xác thực qua Email"),
                onTap: () {
                  Navigator.pop(context);
                  _sendOTP(isSMS: false);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _sendOTP({required bool isSMS}) async {
    setState(() => _isLoading = true);
    String phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = '84${phone.substring(1)}';
    String email = _emailController.text.trim().toLowerCase();

    try {
      if (isSMS)
        await supabase.auth.signInWithOtp(phone: phone);
      else
        await supabase.auth.signInWithOtp(email: email);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            target: isSMS ? phone : email,
            type: isSMS ? OtpTypeVerify.sms : OtpTypeVerify.email,
            userData: {
              'fullname': _nameController.text.trim(),
              'email': email,
              'phone': phone,
              'password': _passwordController.text.trim(),
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                _nameController,
                "Họ và tên",
                Icons.person,
                isName: true,
              ),
              const SizedBox(height: 15),
              _buildField(
                _emailController,
                "Email",
                Icons.email,
                isEmail: true,
              ),
              const SizedBox(height: 15),
              _buildField(
                _phoneController,
                "Số điện thoại",
                Icons.phone,
                isPhone: true,
              ),
              const SizedBox(height: 15),
              _buildField(
                _passwordController,
                "Mật khẩu",
                Icons.lock,
                isPass: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056A7),
                  ),
                  onPressed: _isLoading ? null : _showOptions,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "ĐĂNG KÝ",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
    bool isPass = false,
    bool isName = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Không được để trống";
        if (isName &&
            !RegExp(
              r"^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵýỷỹ\s]+$",
            ).hasMatch(val))
          return "Tên không chứa số/ký tự lạ";
        if (isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val))
          return "Email sai định dạng";
        if (isPhone && !RegExp(r'^(0|84)[3|5|7|8|9][0-9]{8}$').hasMatch(val))
          return "SĐT 10 số không hợp lệ";
        if (isPass && val.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
        return null;
      },
    );
  }
}
