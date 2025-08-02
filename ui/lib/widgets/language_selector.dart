import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String label;
  final String selectedLang;
  final Map<String, String> languages;
  final Function(String) onChanged;
  
  const LanguageSelector({
    super.key,
    required this.label,
    required this.selectedLang,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLang,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: languages.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      _buildFlagIcon(entry.key),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFlagIcon(String langCode) {
    // Map language codes to flag emojis
    const flagMap = {
      'id': '🇮🇩',
      'vi': '🇻🇳',
      'en': '🇺🇸',
      'zh': '🇨🇳',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'th': '🇹🇭',
    };
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          flagMap[langCode] ?? '🌐',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}