enum TranslationStatus {
  processing,
  completed,
  failed,
}

class TranslationJob {
  final String id;
  final String fileName;
  final String inputPath;
  final String sourceLang;
  final String targetLang;
  final TranslationStatus status;
  final double progress;
  final String? outputPath;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  TranslationJob({
    required this.id,
    required this.fileName,
    required this.inputPath,
    required this.sourceLang,
    required this.targetLang,
    required this.status,
    this.progress = 0.0,
    this.outputPath,
    this.error,
    required this.createdAt,
    this.completedAt,
  });
  
  TranslationJob copyWith({
    String? id,
    String? fileName,
    String? inputPath,
    String? sourceLang,
    String? targetLang,
    TranslationStatus? status,
    double? progress,
    String? outputPath,
    String? error,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TranslationJob(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      inputPath: inputPath ?? this.inputPath,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  
  String get statusText {
    switch (status) {
      case TranslationStatus.processing:
        return 'Đang xử lý...';
      case TranslationStatus.completed:
        return 'Hoàn thành';
      case TranslationStatus.failed:
        return 'Lỗi';
    }
  }
  
  Duration? get processingTime {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }
}