import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../payment/views/payment_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final int appointmentId;
  final int doctorId;
  final int? specialtyId;
  final String bookingDate;
  final String bookingTime;
  final double consultationFee;

  const ServiceSelectionScreen({
    super.key,
    required this.appointmentId,
    required this.doctorId,
    this.specialtyId,
    required this.bookingDate,
    required this.bookingTime,
    required this.consultationFee,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  int? _selectedServiceId;
  String? _selectedServiceName;
  double _selectedServicePrice = 0;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      var q = Supabase.instance.client
          .from('services')
          .select('*')
          .eq('isactive', true);

      // Lọc theo chuyên khoa của bác sĩ nếu có
      if (widget.specialtyId != null) {
        q = q.eq('specialtyid', widget.specialtyId!);
      }

      final response = await q;
      if (mounted) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi fetch services: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _proceedToPayment() async {
    // Nếu có chọn dịch vụ thì cập nhật serviceid cho appointment
    if (_selectedServiceId != null) {
      setState(() => _isConfirming = true);
      try {
        await Supabase.instance.client
            .from('appointments')
            .update({'serviceid': _selectedServiceId})
            .eq('appointmentid', widget.appointmentId);
      } catch (e) {
        debugPrint('Lỗi cập nhật serviceid: $e');
      }
      if (mounted) setState(() => _isConfirming = false);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          appointmentId: widget.appointmentId,
          doctorId: widget.doctorId,
          bookingDate: widget.bookingDate,
          bookingTime: widget.bookingTime,
          serviceName: _selectedServiceName,
          servicePrice: _selectedServicePrice > 0
              ? _selectedServicePrice
              : null,
        ),
      ),
    );
  }

  // Hủy appointment nếu người dùng bấm back
  Future<void> _cancelAndPop() async {
    try {
      await Supabase.instance.client
          .from('appointments')
          .update({'status': 'Cancelled'})
          .eq('appointmentid', widget.appointmentId);
    } catch (e) {
      debugPrint('Lỗi hủy appointment: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0đ';
    final double p = double.tryParse(price.toString()) ?? 0;
    if (p == 0) return 'Miễn phí';
    return '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _cancelAndPop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _cancelAndPop,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Color(0xFF0057C2),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Chọn dịch vụ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0057C2),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // SUB TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF0057C2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Vui lòng chọn ít nhất một dịch vụ y tế để tiếp tục đặt lịch!.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0057C2),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CONTENT
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0057C2),
                        ),
                      )
                    : _services.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 56,
                              color: Color(0xFFB5BDCA),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Không có dịch vụ nào\ncho chuyên khoa này',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6E7688),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _services.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final serv = _services[index];
                          final bool isSelected =
                              _selectedServiceId == serv['serviceid'];
                          final double price =
                              double.tryParse(
                                serv['price']?.toString() ?? '0',
                              ) ??
                              0;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  // Bỏ chọn nếu tap lại
                                  _selectedServiceId = null;
                                  _selectedServiceName = null;
                                  _selectedServicePrice = 0;
                                } else {
                                  _selectedServiceId = serv['serviceid'];
                                  _selectedServiceName = serv['servicename'];
                                  _selectedServicePrice = price;
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0057C2)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(0x220057C2)
                                        : Colors.black.withOpacity(0.04),
                                    blurRadius: isSelected ? 16 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // ICON
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF0057C2)
                                          : const Color(0xFFEAF2FF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.medical_services_outlined,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF0057C2),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serv['servicename'] ?? 'Dịch vụ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? const Color(0xFF0057C2)
                                                : const Color(0xFF1A1F36),
                                          ),
                                        ),
                                        if (serv['description'] != null &&
                                            serv['description']
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            serv['description'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6E7688),
                                              height: 1.4,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatPrice(serv['price']),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0057C2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // CHECKBOX
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF0057C2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0057C2)
                                            : const Color(0xFFB5BDCA),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // BOTTOM SUMMARY + BUTTON
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phí khám
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Phí khám',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6E7688),
                          ),
                        ),
                        Text(
                          _formatPrice(widget.consultationFee),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedServiceId != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedServiceName ?? 'Dịch vụ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6E7688),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '+${_formatPrice(_selectedServicePrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0057C2),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        Text(
                          _formatPrice(
                            widget.consultationFee + _selectedServicePrice,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0057C2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isConfirming || _selectedServiceId == null)
                            ? null
                            : _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0057C2),
                          elevation: 8,
                          shadowColor: const Color(0x330057C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isConfirming
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _selectedServiceId != null
                                    ? 'Tiếp tục thanh toán'
                                    : 'Vui lòng chọn dịch vụ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
