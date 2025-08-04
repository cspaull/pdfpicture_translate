# PDF Translator App

Ứng dụng Flutter cho phép dịch văn bản trong file PDF sử dụng OCR và Google Translate API.

## ✨ Tính năng

- 📄 Chọn và upload file PDF
- 🔍 Nhận dạng văn bản tự động (OCR) với EasyOCR
- 🌐 Dịch nhiều ngôn ngữ: Indonesia, Việt Nam, Tiếng Anh, Trung, Nhật, Hàn, Thái
- 📱 Giao diện thân thiện, hiện đại
- 📊 Theo dõi tiến trình dịch thuật real-time
- 💾 Lưu và chia sẻ file PDF đã dịch
- 🎨 Hỗ trợ Dark/Light theme
- 📋 Quản lý lịch sử công việc dịch thuật

## 🏗️ Kiến trúc

```
📱 Flutter App (UI)
    ↕️ HTTP API
🐍 Python Flask Backend (OCR + Translation)
    ↕️ Google Translate API
🤖 EasyOCR + PyMuPDF
```

## 🚀 Cài đặt và chạy

### Backend (Python Flask)

1. **Cài đặt Python dependencies:**
```bash
cd backend
pip install -r requirements.txt
```

2. **Chạy Flask server:**
```bash
python app.py
```
Server sẽ chạy tại `http://localhost:8000`

### Frontend (Flutter)

1. **Cài đặt Flutter dependencies:**
```bash
flutter pub get
```

2. **Chạy ứng dụng:**
```bash
flutter run
```

## 📁 Cấu trúc project

```
pdf_translator/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/
│   │   └── translation_job.dart  # Data models
│   ├── providers/
│   │   └── translation_provider.dart # State management
│   ├── screens/
│   │   └── home_screen.dart      # Main UI screen
│   ├── services/
│   │   └── pdf_translation_service.dart # API service
│   ├── utils/
│   │   ├── app_theme.dart        # App theming
│   │   └── file_utils.dart       # File utilities
│   └── widgets/
│       ├── language_selector.dart # Language picker
│       ├── translation_job_card.dart # Job status card
│       └── upload_area.dart      # File upload widget
├── backend/
│   ├── app.py                    # Flask API server
│   ├── requirements.txt          # Python dependencies
│   ├── uploads/                  # Temp upload folder
│   └── outputs/                  # Translated files
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml   # Android permissions
│       └── res/xml/file_paths.xml # File provider config
└── pubspec.yaml                  # Flutter dependencies
```

## 🔧 Cấu hình

### Android Permissions
App yêu cầu các quyền sau:
- `INTERNET` - Gọi API
- `READ_EXTERNAL_STORAGE` - Đọc file PDF
- `WRITE_EXTERNAL_STORAGE` - Lưu file đã dịch
- `MANAGE_EXTERNAL_STORAGE` - Quản lý file (Android 11+)

### Ngôn ngữ hỗ trợ
- 🇮🇩 Bahasa Indonesia (id)
- 🇻🇳 Tiếng Việt (vi)
- 🇺🇸 English (en)
- 🇨🇳 Chinese (zh)
- 🇯🇵 Japanese (ja)
- 🇰🇷 Korean (ko)
- 🇹🇭 Thai (th)

## 🎯 Sử dụng

1. **Chọn ngôn ngữ nguồn và đích**
2. **Nhấn vùng upload để chọn file PDF**
3. **Theo dõi tiến trình dịch thuật**
4. **Mở hoặc chia sẻ file đã dịch**

## 🛠️ Phát triển

### Thêm ngôn ngữ mới
1. Cập nhật `supportedLanguages` trong `TranslationProvider`
2. Thêm flag emoji trong `LanguageSelector`
3. Cập nhật EasyOCR languages trong backend

### Tùy chỉnh giao diện
- Chỉnh sửa `AppTheme` trong `lib/utils/app_theme.dart`
- Màu sắc, fonts, và spacing được định nghĩa tập trung

### API Endpoints
- `POST /translate-pdf` - Dịch file PDF
- `GET /health` - Health check
- `GET /supported-languages` - Danh sách ngôn ngữ

## 🐛 Xử lý lỗi

- **File không hỗ trợ**: Chỉ chấp nhận file .pdf
- **Kết nối mạng**: Kiểm tra backend server đang chạy
- **Quyền truy cập**: Cấp quyền đọc/ghi file cho app
- **OCR thất bại**: Đảm bảo file PDF có chất lượng tốt

## 📦 Build Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Đóng góp

1. Fork project
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request



## 🙏 Acknowledgments

- [EasyOCR](https://github.com/JaidedAI/EasyOCR) - OCR engine
- [PyMuPDF](https://github.com/pymupdf/PyMuPDF) - PDF processing
- [Google Translate](https://translate.google.com/) - Translation service
- [Flutter](https://flutter.dev/) - UI framework
