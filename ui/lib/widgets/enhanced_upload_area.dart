import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EnhancedUploadArea extends StatefulWidget {
  final Function(String filePath, String fileName) onFilePicked;
  final bool isUploading;
  
  const EnhancedUploadArea({
    super.key,
    required this.onFilePicked,
    required this.isUploading,
  });

  @override
  State<EnhancedUploadArea> createState() => _EnhancedUploadAreaState();
}

class _EnhancedUploadAreaState extends State<EnhancedUploadArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (widget.isUploading) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false, // Don't load file data into memory
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        // Validate file size (50MB limit)
        final file = File(filePath);
        final fileSize = await file.length();
        const maxSize = 50 * 1024 * 1024; // 50MB in bytes
        
        if (fileSize > maxSize) {
          _showErrorDialog('File quá lớn', 
              'Vui lòng chọn file PDF nhỏ hơn 50MB.\nFile hiện tại: ${_formatFileSize(fileSize)}');
          return;
        }

        widget.onFilePicked(filePath, fileName);
      }
    } catch (e) {
      _showErrorDialog('Lỗi chọn file', 
          'Không thể chọn file. Vui lòng thử lại.\nLỗi: ${e.toString()}');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _isHovering ? 8 : 4,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          onTap: _pickFile,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isUploading 
                        ? Theme.of(context).primaryColor
                        : (_isHovering 
                            ? Theme.of(context).primaryColor.withOpacity(0.5)
                            : Colors.grey[300]!),
                    width: 2,
                    style: widget.isUploading ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  color: _isHovering 
                      ? Theme.of(context).primaryColor.withOpacity(0.02)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isUploading) ...[
                      // Loading state
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.upload_file,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang xử lý file...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng đợi trong giây lát',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ] else ...[
                      // Default state
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(_isHovering ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(
                            _isHovering ? 0.15 : 0.1
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: _isHovering ? 52 : 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Kéo thả file PDF vào đây',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isHovering 
                              ? Theme.of(context).primaryColor 
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'hoặc nhấn để chọn file từ thiết bị',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: const Text('Chọn file PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32, 
                            vertical: 16
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // File info section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 18,
                                  color: Colors.red[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hỗ trợ file PDF • Tối đa 50MB',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFeatureItem(
                                  Icons.security,
                                  'Bảo mật',
                                  Colors.green,
                                ),
                                _buildFeatureItem(
                                  Icons.speed,
                                  'Nhanh chóng',
                                  Colors.blue,
                                ),
                                _buildFeatureItem(
                                  Icons.high_quality,
                                  'Chất lượng cao',
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 10
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'File được xử lý an toàn và tự động xóa sau 24h',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}