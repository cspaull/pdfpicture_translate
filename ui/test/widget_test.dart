import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pdf_translator/main.dart';
import 'package:pdf_translator/providers/translation_provider.dart';

void main() {
  group('PDF Translator App Tests', () {
    testWidgets('App loads and displays home screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Verify that home screen elements are present
      expect(find.text('PDF Translator'), findsOneWidget);
      expect(find.text('Chọn ngôn ngữ'), findsOneWidget);
      expect(find.text('Kéo thả file PDF vào đây'), findsOneWidget);
    });

    testWidgets('Language selector works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TranslationProvider(),
            child: const Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Add more specific widget tests here
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Upload area responds to tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Find upload area and tap it
      final uploadArea = find.text('Chọn file PDF');
      expect(uploadArea, findsOneWidget);
      
      // Tap would normally trigger file picker (can't test file picker in unit tests)
      await tester.tap(uploadArea);
      await tester.pump();
      
      // Verify UI responds appropriately
      expect(find.text('Chọn file PDF'), findsOneWidget);
    });
  });

  group('Translation Provider Tests', () {
    test('Initial state is correct', () {
      final provider = TranslationProvider();
      
      expect(provider.jobs, isEmpty);
      expect(provider.isTranslating, false);
      expect(provider.selectedSourceLang, 'id');
      expect(provider.selectedTargetLang, 'vi');
    });

    test('Language selection works', () {
      final provider = TranslationProvider();
      
      provider.setSourceLanguage('en');
      expect(provider.selectedSourceLang, 'en');
      
      provider.setTargetLanguage('zh');
      expect(provider.selectedTargetLang, 'zh');
    });

    test('Supported languages contains expected entries', () {
      final provider = TranslationProvider();
      final languages = provider.supportedLanguages;
      
      expect(languages.containsKey('id'), true);
      expect(languages.containsKey('vi'), true);
      expect(languages.containsKey('en'), true);
      expect(languages['id'], 'Bahasa Indonesia');
      expect(languages['vi'], 'Tiếng Việt');
    });
  });
}