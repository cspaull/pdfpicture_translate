import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PdfTranslationService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://192.168.1.16:8000'; //địa chỉ ip của máy chạy backend

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
          responseType: ResponseType.bytes, // Ensure response.data is List<int>
        ),
      );

      // If we reach here, Dio considers it a successful response (status 2xx)
      // and response.data is List<int> due to ResponseType.bytes.
      final file = File(outputPath);
      await file.writeAsBytes(response.data);
      return outputPath;

    } on DioException catch (e) {
      String errorMessage = 'Translation failed.';
      if (e.response != null) {
        // e.response.data is List<int> (bytes of the error response body)
        // due to ResponseType.bytes. Decode it for a readable error message.
        String serverErrorDetails = "Could not decode error response.";
        if (e.response!.data != null && e.response!.data is List<int>) {
          try {
            serverErrorDetails = utf8.decode(e.response!.data as List<int>);
          } catch (decodeError) {
            serverErrorDetails = "Received binary error data that could not be decoded as UTF-8.";
          }
        }
        errorMessage = 'Server error: ${e.response!.statusCode} - ${e.response!.statusMessage}. Details: $serverErrorDetails';
      } else {
        // Network error, timeout, etc. (no response from server)
        errorMessage = 'Network error during translation: ${e.message ?? "Unknown Dio error"}';
      }
      debugPrint('DioException in translatePdf: $errorMessage');
      throw Exception(errorMessage); // Rethrow with a clear string message.

    } catch (e) {
      debugPrint('Unexpected error in translatePdf: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
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
    await inputFile.copy(outputPath);

    return outputPath;
  }
}