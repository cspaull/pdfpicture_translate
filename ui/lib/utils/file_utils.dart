import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FileUtils {
  static Future<void> openFile(String filePath) async {
    try {
      if (Platform.isAndroid) {
        // Use intent to open PDF file on Android
        const platform = MethodChannel('pdf_translator/file_utils');
        await platform.invokeMethod('openFile', {'filePath': filePath});
      } else if (Platform.isIOS) {
        // Use document interaction controller on iOS
        const platform = MethodChannel('pdf_translator/file_utils');
        await platform.invokeMethod('openFile', {'filePath': filePath});
      } else {
        // For other platforms, try to open with system default
        await Process.start('open', [filePath]);
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      // Fallback: copy path to clipboard
      await Clipboard.setData(ClipboardData(text: filePath));
    }
  }
  
  static Future<void> shareFile(String filePath) async {
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