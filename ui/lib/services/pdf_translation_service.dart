import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PdfTranslationService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:8000'; // Python Flask server
  
  Future<String> translatePdf({
    required String inputPath,
    required String sourceLang,
    required String targetLang,
    Function(double)? onProgress,
  }) async {
    try {
      // Get output directory
      final directory = await getApplicationDocumentsDirectory();
      final outputDir = Directory('${directory.path}/translated_pdfs');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      
      final fileName = inputPath.split('/').last.replaceAll('.pdf', '');
      final outputPath = '${outputDir.path}/${fileName}_translated_$targetLang.pdf';
      
      // Prepare form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(inputPath),
        'source_lang': sourceLang,
        'target_lang': targetLang,
      });
      
      // Send request to Python backend
      final response = await _dio.post(
        '$_baseUrl/translate-pdf',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onProgress != null && total != -1) {
            onProgress(sent / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
          sendTimeout: const Duration(minutes: 5),
        ),
      );
      
      if (response.statusCode == 200) {
        // Save the translated PDF
        final file = File(outputPath);
        await file.writeAsBytes(response.data);
        return outputPath;
      } else {
        throw Exception('Translation failed: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      rethrow;
    }
  }
  
  // For demonstration - mock translation when backend is not available
  Future<String> mockTranslatePdf({
    required String inputPath,
    required String sourceLang,
    required String targetLang,
    Function(double)? onProgress,
  }) async {
    // Simulate processing time
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(i / 100);
    }
    
    // Copy original file to output location (mock translation)
    final directory = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${directory.path}/translated_pdfs');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    
    final fileName = inputPath.split('/').last.replaceAll('.pdf', '');
    final outputPath = '${outputDir.path}/${fileName}_translated_$targetLang.pdf';
    
    final inputFile = File(inputPath);
    final outputFile = File(outputPath);
    await inputFile.copy(outputPath);
    
    return outputPath;
  }
}