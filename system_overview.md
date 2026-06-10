# Tổng quan Hệ thống Ứng dụng Phòng Khám (SereneHealth)

Tài liệu này trình bày từ tổng quan đến chi tiết các công nghệ, kỹ thuật được áp dụng trong hệ thống phòng khám SereneHealth. Tài liệu chú trọng vào việc giải thích công nghệ được dùng ở đâu và mô tả luồng hoạt động (workflow) của từng chức năng nghiệp vụ cụ thể.

---

## 1. Các Công nghệ và Kỹ thuật Cốt lõi

### 1.1. Nền tảng và Giao diện (Frontend)
- **Flutter & Dart:** Hệ thống sử dụng Flutter để xây dựng ứng dụng di động đa nền tảng (iOS & Android). Dart là ngôn ngữ lập trình chính.
- **Kỹ thuật UI/UX:** 
  - Sử dụng `Material 3` design system.
  - Sử dụng `AnimatedSwitcher` và `FadeTransition` (trong `MainApp`) để tạo hiệu ứng chuyển trang mượt mà giữa các tab dưới (Bottom Navigation).
  - Sử dụng `TabController` (có `SingleTickerProviderStateMixin`) để quản lý các tab trạng thái tĩnh/động (ví dụ: chuyển đổi tab Lịch hẹn Sắp tới và Hoàn thành).
- **Cached Network Image:** Kỹ thuật bộ nhớ đệm (cache) hình ảnh (avatar bác sĩ, banner) giúp tăng tốc độ tải và giảm băng thông.

### 1.2. Backend as a Service (BaaS) & Database
- **Supabase:** Nền tảng Backend thay thế Firebase, cung cấp các dịch vụ cốt lõi:
  - **Supabase Auth:** Xử lý xác thực người dùng (Đăng nhập, Đăng ký).
  - **Supabase PostgreSQL:** Cơ sở dữ liệu quan hệ lưu trữ thông tin người dùng (`users`), bác sĩ (`doctors`), chuyên khoa (`specialties`) và lịch hẹn (`appointments`).
  - Được khởi tạo duy nhất tại `main.dart` thông qua `Supabase.initialize` và dùng chung (`Supabase.instance.client`) trên toàn app.

### 1.3. Quản lý Trạng thái & Môi trường
- **Provider / State Management:** Xử lý trạng thái nội bộ của widget (`setState`) và chia sẻ dữ liệu giữa các luồng.
- **Flutter Dotenv (`flutter_dotenv`):** Kỹ thuật quản lý biến môi trường. Các thông tin nhạy cảm như `SUPABASE_URL` và `SUPABASE_ANON_KEY` được bảo mật trong file `.env` để không bị lộ mã nguồn.
- **Intl:** Kỹ thuật định dạng ngày/tháng/năm và tiền tệ, được sử dụng rất nhiều trong phần hiển thị thời gian khám bệnh.

---

## 2. Quy trình Nghiệp vụ Cốt lõi (Core Business Logic)

Trước khi đi sâu vào kỹ thuật, dưới đây là các quy tắc và luồng nghiệp vụ kinh doanh chính mà hệ thống đang giải quyết:

### 2.1. Hành trình Người dùng (Patient Journey)
Toàn bộ hệ thống xoay quanh một quy trình khép kín dành cho bệnh nhân:
**Khám phá** (Tìm kiếm bác sĩ/chuyên khoa) ➔ **Ra quyết định** (Xem hồ sơ, chọn ngày/khung giờ) ➔ **Cam kết** (Xác nhận đặt lịch & Thanh toán) ➔ **Thực hiện** (Theo dõi lịch sắp tới, đến phòng khám) ➔ **Kết thúc** (Hoàn thành lịch hẹn).

### 2.2. Các Quy tắc Nghiệp vụ Chặt chẽ (Business Rules)
- **Ràng buộc thời gian đặt lịch:** Người dùng tuyệt đối không được phép đặt lịch vào các ngày trong quá khứ. 
- **Ràng buộc trạng thái "Hoàn thành":** Để đảm bảo tính thực tế, nút "Hoàn thành" (đánh dấu buổi khám đã xong) chỉ được phép bấm (bật sáng) **sau khi** thời gian hiện tại đã vượt qua thời gian bắt đầu của ca khám đó. Nếu chưa đến giờ, nút này sẽ bị vô hiệu hóa (disable).
- **Tự động hóa trạng thái:** Để tránh tình trạng rác dữ liệu khi bệnh nhân quên bấm hoàn thành, hệ thống có nghiệp vụ **tự động rà soát**. Nếu một lịch hẹn đã qua ngày hôm nay (tức là lịch của ngày hôm qua trở về trước), hệ thống sẽ ngầm chuyển trạng thái lịch đó sang "Completed" và đưa thẳng vào tab "Hoàn thành".
- **Loại bỏ lịch đã Hủy:** Các lịch hẹn đã bị hủy (Cancelled) sẽ không được hiển thị trong danh sách "Sắp tới" hay "Hoàn thành" để tránh gây nhiễu cho luồng theo dõi của bệnh nhân.

---

## 3. Chi tiết Áp dụng Công nghệ vào Chức năng và Luồng hoạt động

Dưới đây là cách các công nghệ trên được áp dụng trực tiếp vào từng chức năng (Module) và luồng hoạt động chi tiết.

### 3.1. Chức năng Xác thực (Authentication)
**Kỹ thuật áp dụng:** Supabase Auth, SharedPreferences.
**Nghiệp vụ:** Đăng nhập, Đăng ký, Quản lý phiên đăng nhập.

**Luồng hoạt động:**
1. Người dùng nhập Email/Mật khẩu vào màn hình đăng nhập.
2. Ứng dụng gọi hàm `supabase.auth.signInWithPassword()`.
3. Supabase kiểm tra thông tin. Nếu hợp lệ, hệ thống trả về `Auth Token`.
4. Ứng dụng tự động lưu trữ Token và định tuyến (Navigate) người dùng vào màn hình chính (`MainApp`).
5. App gọi DB lấy bảng `users` với `authid` tương ứng để hiển thị thông tin hồ sơ.

### 3.2. Chức năng Trang chủ và Tìm kiếm (Home & Search)
**Kỹ thuật áp dụng:** Supabase Database (Truy vấn Select, Filter), Cached Network Image.
**Nghiệp vụ:** Hiển thị danh sách bác sĩ nổi bật, chuyên khoa, và tìm kiếm bác sĩ.

**Luồng hoạt động:**
1. Khi màn hình `HomeScreen` được khởi tạo, ứng dụng thực hiện truy vấn bất đồng bộ (`Future`) lên bảng `doctors` và `specialties`.
2. Dữ liệu trả về được ánh xạ (map) vào danh sách UI. Hình ảnh avatar bác sĩ được tải qua kỹ thuật Cache (không cần tải lại mỗi lần mở app).
3. Khi người dùng nhập từ khóa vào ô tìm kiếm hoặc bấm qua `SearchScreen`, ứng dụng sử dụng câu truy vấn `ilike` trên Supabase (hoặc filter cục bộ) để tìm tên bác sĩ phù hợp và trả về kết quả ngay lập tức.

### 3.3. Chức năng Đặt lịch khám (Booking)
**Kỹ thuật áp dụng:** Lịch (Date Picker), `Intl` (Format thời gian), Xử lý ngoại lệ CSDL (PostgrestException).
**Nghiệp vụ:** Chọn ngày giờ, chống đặt trùng lịch (Double Booking) và ràng buộc bảo mật (RLS).

**Luồng xử lý thực tế:**
1. Khi xem `DoctorProfileScreen`, danh sách khung giờ được render. Nếu là ngày hôm nay, hệ thống tự động tính toán và vô hiệu hóa (disabled) các khung giờ đã trôi qua.
2. Khi người dùng bấm "Xác nhận cuộc hẹn":
   - Ứng dụng lấy `authId` của phiên đăng nhập hiện tại, truy vấn bảng `users` để lấy `userid` số nguyên.
   - Insert một bản ghi vào bảng `appointments` với trạng thái ban đầu là `Pending` (chờ thanh toán).
3. **Xử lý tranh chấp (Double Booking):** Hệ thống được thiết kế để bắt lỗi CSDL (Mã lỗi 23505 - Unique constraint). Nếu cùng một lúc có 2 người đặt cùng 1 bác sĩ và 1 khung giờ, người chậm hơn 1 giây sẽ nhận được cảnh báo "Khung giờ đã đầy" và không tạo được lịch hẹn.
4. Nếu thành công, ứng dụng điều hướng sang màn hình Thanh toán.

### 3.4. Chức năng Xác nhận & Thanh toán (Payment)
**Kỹ thuật áp dụng:** `Timer` đếm ngược, Update trạng thái DB liên tục.
**Nghiệp vụ:** Giữ chỗ trong thời gian giới hạn, giải phóng chỗ nếu hủy ngang.

**Luồng xử lý thực tế:**
1. Khi vào `PaymentScreen`, một bộ đếm thời gian (Timer) bắt đầu chạy lùi **5 phút (300 giây)** để "giữ chỗ" khung giờ đó cho bệnh nhân.
2. **Luồng Hủy/Giải phóng (Timeout & Pop):** 
   - Nếu bệnh nhân ấn nút Back (thoát ngang màn hình) HOẶC hết 5 phút mà chưa thanh toán, hệ thống tự động gọi API cập nhật lịch hẹn đang `Pending` thành `Cancelled`. Khung giờ sẽ lập tức trống trở lại để người khác có thể đặt.
3. **Luồng Thành công:**
   - Khi bấm thanh toán, hệ thống đổi trạng thái lịch hẹn thành `Confirmed`.
   - Sinh một mã giao dịch ngẫu nhiên (VD: SH-82312), chèn (insert) vào bảng `payments` với trạng thái `Success`.
   - Hủy (cancel) bộ đếm thời gian và chuyển sang màn hình thành công.

### 3.5. Chức năng Quản lý Lịch trình (Appointment / Schedule)
**Kỹ thuật áp dụng:** Bóc tách ngày tháng (`DateTime.parse`), Batch Update Database, `TabController`.
**Nghiệp vụ:** Phân loại lịch tự động, tự động quét dọn dữ liệu, thay đổi trạng thái UI mượt mà.

**Luồng xử lý thực tế:**
1. `ScheduleListScreen` truy vấn toàn bộ lịch hẹn (bỏ qua trạng thái `Cancelled`).
2. **Tự động hóa dọn dẹp lịch cũ (Auto-complete):**
   - Ứng dụng lọc các lịch đang `Pending` hoặc `Confirmed`. 
   - Nếu phát hiện ngày khám của lịch hẹn thuộc về các ngày trước đó (quá khứ so với thời điểm mở app), hệ thống sẽ gộp ID các lịch này lại và chạy tác vụ chạy ngầm (Batch update) ép trạng thái trên DB thành `Completed`.
3. **Phân loại hiển thị:**
   - Đưa các lịch ở quá khứ và các lịch có trạng thái `Completed` vào tab **Hoàn thành**.
   - Các lịch từ hôm nay trở đi được đưa vào tab **Sắp tới**.
4. **Logic thao tác nút "Hoàn thành":**
   - Ở tab "Sắp tới", ứng dụng liên tục so sánh thời gian hiện tại với giờ bắt đầu khám. Nút "Hoàn thành" bị vô hiệu hóa (xám) cho đến khi thời gian thực tế chạm mốc giờ khám.
   - Khi bấm "Hoàn thành" -> Gọi update API trạng thái `Completed` -> Mở popup xác nhận.
   - Bấm "Đóng" popup -> Lệnh `_tabController.animateTo(1)` được kích hoạt, vuốt màn hình sang tab Hoàn thành một cách mượt mà để phản ánh sự thay đổi lập tức.

### 3.6. Chức năng Hồ sơ (Profile)
**Kỹ thuật áp dụng:** Supabase Database, Supabase Auth.
**Nghiệp vụ:** Hiển thị thông tin cá nhân và Đăng xuất.

**Luồng hoạt động:**
1. Màn hình Profile đọc dữ liệu người dùng đã được lưu trong state hoặc gọi lại DB để lấy thông tin chi tiết.
2. Cung cấp chức năng "Đăng xuất": Ứng dụng gọi `supabase.auth.signOut()`, xóa cache nội bộ và đẩy người dùng về lại màn hình `WelcomeScreen`/Login.
