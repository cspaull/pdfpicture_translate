import 'dart:io'; // Keep for other FileUtils methods if they exist
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart'; // Kept for Clipboard in shareFile

class FileUtils {
  static Future<void> openFile(BuildContext context, String filePath) async { // Added BuildContext
    try {
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        // Show SnackBar if context is available and mounted
        // Ensure context is valid for ScaffoldMessenger
        if (ScaffoldMessenger.maybeOf(context) != null) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở file: ${result.message} (Code: ${result.type})'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Also print to console for debugging
        print("OpenFilex error: ${result.type} - ${result.message}");
      }
    } catch (e) {
      // Catch any other unexpected errors during the openFile call
      if (ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error opening file with OpenFilex: $e');
    }
  }

  static Future<void> shareFile(String filePath) async {
    // Current implementation uses MethodChannel.
    // Consider replacing with a plugin like 'share_plus' for a pure Dart approach.
    try {
      const platform = MethodChannel('pdf_translator/file_utils');
      await platform.invokeMethod('shareFile', {'filePath': filePath});
    } catch (e) {
      debugPrint('Error sharing file: $e');
      // Fallback: copy path to clipboard
      await Clipboard.setData(ClipboardData(text: filePath));
    }
  }
  
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
  
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }
  
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}