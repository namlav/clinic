import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';
import '../models/health_insurance_model.dart';

class ProfileEditScreen extends StatefulWidget {
  final Patient patient;

  const ProfileEditScreen({super.key, required this.patient});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dateOfBirthController;
  late TextEditingController emergencyContactNameController;
  late TextEditingController emergencyContactPhoneController;
  late TextEditingController emergencyContactRelationController;
  late TextEditingController insuranceNumberController;
  late TextEditingController insuranceProviderController;
  late TextEditingController insuranceExpiryController;

  String selectedGender = 'Nam';
  bool isLoading = false;
  Future<HealthInsurance?>? _insuranceFuture;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.patient.fullName);
    emailController = TextEditingController(text: widget.patient.email);
    phoneController = TextEditingController(text: widget.patient.phone);
    addressController = TextEditingController();
    dateOfBirthController = TextEditingController();
    emergencyContactNameController = TextEditingController();
    emergencyContactPhoneController = TextEditingController();
    emergencyContactRelationController = TextEditingController();
    insuranceNumberController = TextEditingController();
    insuranceProviderController = TextEditingController();
    insuranceExpiryController = TextEditingController();
    _insuranceFuture = HealthInsurance.fetch();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dateOfBirthController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactPhoneController.dispose();
    emergencyContactRelationController.dispose();
    insuranceNumberController.dispose();
    insuranceProviderController.dispose();
    insuranceExpiryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateOfBirthController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _selectInsuranceExpiry(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      insuranceExpiryController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (fullNameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw Exception('User not authenticated');

      await supabase
          .from('users')
          .update({
            'fullname': fullNameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
          })
          .eq('userid', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3B4754)),
        title: const Text(
          'Chỉnh Sửa Hồ Sơ',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông Tin Cá Nhân'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: fullNameController,
              label: 'Họ và Tên',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: phoneController,
              label: 'Số Điện Thoại',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: addressController,
              label: 'Địa Chỉ',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildDatePickerField(
              controller: dateOfBirthController,
              label: 'Ngày Sinh',
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 12),
            _buildGenderDropdown(),
            const SizedBox(height: 20),
            _buildSectionTitle('Liên Hệ Khẩn Cấp'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: emergencyContactNameController,
              label: 'Tên Liên Hệ',
              icon: Icons.contacts,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: emergencyContactPhoneController,
              label: 'Số Điện Thoại Liên Hệ',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: emergencyContactRelationController,
              label: 'Mối Quan Hệ',
              icon: Icons.people,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Bảo Hiểm Y Tế'),
            const SizedBox(height: 12),
            FutureBuilder<HealthInsurance?>(
              future: _insuranceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final insurance = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    insuranceNumberController.text = insurance.insuranceNumber;
                    insuranceProviderController.text = insurance.providerName;
                    insuranceExpiryController.text =
                        '${insurance.validUntil.day.toString().padLeft(2, '0')}/${insurance.validUntil.month.toString().padLeft(2, '0')}/${insurance.validUntil.year}';
                  });
                }

                return Column(
                  children: [
                    _buildTextField(
                      controller: insuranceNumberController,
                      label: 'Mã Bảo Hiểm',
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: insuranceProviderController,
                      label: 'Nhà Cung Cấp',
                      icon: Icons.apartment,
                    ),
                    const SizedBox(height: 12),
                    _buildDatePickerField(
                      controller: insuranceExpiryController,
                      label: 'Hạn Sử Dụng',
                      onTap: () => _selectInsuranceExpiry(context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      ),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          enabled: false,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF2563EB),
              size: 20,
            ),
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF9CA3AF),
            ),
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedGender,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
        items: ['Nam', 'Nữ', 'Khác'].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    gender == 'Nam'
                        ? Icons.male
                        : gender == 'Nữ'
                        ? Icons.female
                        : Icons.help,
                    color: const Color(0xFF2563EB),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    gender,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => selectedGender = value);
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Lưu Thay Đổi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
