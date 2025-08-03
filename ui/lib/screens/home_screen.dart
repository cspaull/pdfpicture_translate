import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_job_card.dart';
import '../widgets/enhanced_upload_area.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Translator'),
        centerTitle: true,
        actions: [
          Consumer<TranslationProvider>(
            builder: (context, provider, child) {
              if (provider.jobs.isNotEmpty) {
                return PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => provider.clearAllJobs(),
                      child: const Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Xóa tất cả'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<TranslationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Language Selection Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn ngôn ngữ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: LanguageSelector(
                              label: 'Từ',
                              selectedLang: provider.selectedSourceLang,
                              languages: provider.supportedLanguages,
                              onChanged: provider.setSourceLanguage,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: LanguageSelector(
                              label: 'Sang',
                              selectedLang: provider.selectedTargetLang,
                              languages: provider.supportedLanguages,
                              onChanged: provider.setTargetLanguage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Upload Area
              EnhancedUploadArea(
                onFilePicked: (filePath, fileName) {
                  provider.translatePdf(filePath, fileName);
                },
                isUploading: provider.isTranslating,
              ),
              
              // Jobs List
              Expanded(
                child: provider.jobs.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        itemCount: provider.jobs.length,
                        itemBuilder: (context, index) {
                          final job = provider.jobs[index];
                          return TranslationJobCard(
                            job: job,
                            onDelete: () => provider.removeJob(job.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView( // Wrap Column with SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có file PDF nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn file PDF để bắt đầu dịch',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
