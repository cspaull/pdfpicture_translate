import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_translation_service.dart';
import '../models/translation_job.dart';

class TranslationProvider extends ChangeNotifier {
  final PdfTranslationService _translationService = PdfTranslationService();
  
  final List<TranslationJob> _jobs = [];
  bool _isTranslating = false;
  String _selectedSourceLang = 'id';
  String _selectedTargetLang = 'vi';
  
  List<TranslationJob> get jobs => _jobs;
  bool get isTranslating => _isTranslating;
  String get selectedSourceLang => _selectedSourceLang;
  String get selectedTargetLang => _selectedTargetLang;
  
  final Map<String, String> _supportedLanguages = {
    'id': 'Bahasa Indonesia',
    'vi': 'Tiếng Việt',
    'en': 'English',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'th': 'Thai',
  };
  
  Map<String, String> get supportedLanguages => _supportedLanguages;
  
  void setSourceLanguage(String langCode) {
    _selectedSourceLang = langCode;
    notifyListeners();
  }
  
  void setTargetLanguage(String langCode) {
    _selectedTargetLang = langCode;
    notifyListeners();
  }
  
  Future<void> pickAndTranslatePdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        await translatePdf(filePath, fileName);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      rethrow;
    }
  }
  
  Future<void> translatePdf(String inputPath, String fileName) async {
    final job = TranslationJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      inputPath: inputPath,
      sourceLang: _selectedSourceLang,
      targetLang: _selectedTargetLang,
      status: TranslationStatus.processing,
      createdAt: DateTime.now(),
    );
    
    _jobs.insert(0, job);
    _isTranslating = true;
    notifyListeners();
    
    try {
      final outputPath = await _translationService.translatePdf(
        inputPath: inputPath,
        sourceLang: _selectedSourceLang,
        targetLang: _selectedTargetLang,
        onProgress: (progress) {
          _updateJobProgress(job.id, progress);
        },
      );
      
      _updateJobStatus(job.id, TranslationStatus.completed, outputPath: outputPath);
    } catch (e) {
      _updateJobStatus(job.id, TranslationStatus.failed, error: e.toString());
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }
  
  void _updateJobProgress(String jobId, double progress) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(progress: progress);
      notifyListeners();
    }
  }
  
  void _updateJobStatus(String jobId, TranslationStatus status, {String? outputPath, String? error}) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(
        status: status,
        outputPath: outputPath,
        error: error,
        completedAt: status == TranslationStatus.completed ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }
  
  void removeJob(String jobId) {
    _jobs.removeWhere((job) => job.id == jobId);
    notifyListeners();
  }
  
  void clearAllJobs() {
    _jobs.clear();
    notifyListeners();
  }
}