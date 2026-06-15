# SereneHealth 🏥

[![Nam Lav](https://img.shields.io/badge/Author-Nam_Lav-0D9488?style=for-the-badge&logo=github&logoColor=white)](https://github.com/namlav)

## 🎯 Mục tiêu

**SereneHealth** là một ứng dụng di động hỗ trợ đặt lịch khám bệnh và quản lý hồ sơ sức khỏe cá nhân, được xây dựng bằng **Flutter** và **Supabase**. Dự án này được phát triển như một Đồ án môn Mobile App.

## 🌟 Tính Năng Nổi Bật

### Dành cho Bệnh nhân (Patient)
- **Xác thực an toàn:** Đăng nhập, đăng ký bằng Email/Mật khẩu với quy trình xác thực OTP 6 số bảo mật. Hỗ trợ khôi phục mật khẩu.
- **Trang chủ & Tìm kiếm:** Giao diện trực quan giúp tìm kiếm bác sĩ, dịch vụ y tế và chuyên khoa dễ dàng.
- **Đặt lịch khám:** Chọn bác sĩ, chọn dịch vụ, chọn thời gian linh hoạt và tiến hành đặt lịch.
- **Quản lý cuộc hẹn:** Xem danh sách các lịch khám sắp tới, lịch sử khám bệnh và luồng hủy lịch khám.
- **Hồ sơ sức khỏe:** Lưu trữ và xem lại hồ sơ bệnh án, lịch sử tiêm chủng, thông tin thẻ bảo hiểm y tế.
- **Thanh toán:** Tích hợp quy trình thanh toán dịch vụ.
- **Cài đặt thông báo:** Tùy chỉnh nhận thông báo cho các sự kiện của ứng dụng.

### Dành cho Bác sĩ (Doctor Portal)
- **Quản lý công việc:** Xem danh sách bệnh nhân đã đặt lịch khám với mình.
- **Theo dõi lịch sử khám:** Cập nhật thông tin và điền phiếu khám bệnh (Medical Exam Form).

## 🛠️ Công Nghệ Sử Dụng

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL, Authentication)
- **Thư viện chính:**
  - `supabase_flutter`: Kết nối Backend (BaaS).
  - `dio` / `http`: Xử lý HTTP requests.
  - `provider`: Quản lý trạng thái (State Management).
  - `flutter_dotenv`: Quản lý biến môi trường bảo mật.
  - `shared_preferences`: Lưu trữ dữ liệu cục bộ.
  - Phụ trợ: `intl`, `cached_network_image`, `file_picker`, `url_launcher`.

## 📁 Cấu Trúc Thư Mục (Feature-First Architecture)

Dự án áp dụng kiến trúc Feature-First, phân chia thư mục theo từng nhóm chức năng (features) độc lập giúp dễ dàng bảo trì và mở rộng:

```text
lib/
├── features/
│   ├── appointment/    # Quản lý luồng đặt lịch, lịch sử khám, hủy lịch
│   ├── auth/           # Đăng nhập, đăng ký, xác thực OTP, khôi phục mật khẩu
│   ├── booking/        # Luồng đặt lịch khám, chọn bác sĩ, chọn dịch vụ
│   ├── doctor_portal/  # Giao diện và luồng nghiệp vụ dành riêng cho Bác sĩ
│   ├── home/           # Trang chủ, màn hình tìm kiếm
│   ├── notification/   # Cấu hình và quản lý thông báo
│   ├── payment/        # Giao diện thanh toán
│   └── profile/        # Quản lý hồ sơ người dùng, bệnh án, bảo hiểm, tiêm chủng
├── widgets/            # Các UI Component dùng chung (BottomNav, Transitions...)
└── main.dart           # Điểm khởi chạy ứng dụng & Auth Gate
```

## 🚀 Hướng Dẫn Cài Đặt và Chạy Dự Án

### 1. Yêu cầu hệ thống
- Flutter SDK (`>=3.11.0`)
- Môi trường phát triển Android / iOS đã được cấu hình.

### 2. Các bước cài đặt
Clone repository về máy và di chuyển vào thư mục dự án:
```bash
git clone <repository_url>
cd clinic
```

Cài đặt các package phụ thuộc:
```bash
flutter pub get
```

### 3. Cấu hình môi trường (Supabase)
Tạo một file `.env` ở thư mục gốc của dự án (cùng cấp với `pubspec.yaml`) và điền các khóa API của Supabase:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Lưu ý Cấu hình Supabase Dashboard:**
- Tính năng **Confirm Email** phải được BẬT (`ON`).
- Trong mục **Email Templates > Confirm signup**, cấu hình nội dung gửi mã OTP 6 số bằng biến `{{ .Token }}` (Không dùng `{{ .ConfirmationURL }}`).

### 4. Chạy ứng dụng
```bash
flutter run
```

## 🔐 Bảo mật và Phân Quyền (RLS)
Dự án ứng dụng mạnh mẽ tính năng Row Level Security (RLS) của Supabase để đảm bảo an toàn và bảo mật dữ liệu:
- Bệnh nhân chỉ được phép xem thông tin lịch khám của bản thân.
- Bác sĩ chỉ được phép truy xuất danh sách bệnh nhân và lịch hẹn đã được đặt riêng cho mình.
- Tự động điều hướng giao diện linh hoạt dựa trên Role của tài khoản (Doctor / Patient).

## 🚀 Happy Coding!