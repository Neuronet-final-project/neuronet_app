import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translation_service.dart';
import '../l10n/l10n_extensions.dart';

/// A button that handles translation of text using the backend translation service.
/// 
/// Automatically detects Amharic (Ethiopic script) and provides a toggle
/// between original and translated text.
class NeuroTranslateButton extends ConsumerStatefulWidget {
  const NeuroTranslateButton({
    super.key,
    required this.text,
    required this.onTranslationDone,
    this.translatedContent,
    this.color,
  });

  /// The original text to translate.
  final String text;

  /// Optional pre-translated content from backend.
  final String? translatedContent;

  /// Callback when translation is completed or toggled.
  /// 
  /// [translatedText] is the text to display.
  /// [isShowingOriginal] is true if we just switched back to the original.
  final Function(String translatedText, bool isShowingOriginal) onTranslationDone;

  /// Optional color for the button. Defaults to theme primary color.
  final Color? color;

  @override
  ConsumerState<NeuroTranslateButton> createState() => _NeuroTranslateButtonState();
}

class _NeuroTranslateButtonState extends ConsumerState<NeuroTranslateButton> {
  bool _isTranslating = false;
  bool _isTranslated = false;
  String? _originalText;

  /// Simple heuristic for Ethiopian scripts or specific languages.
  String _detectLanguage(String text, BuildContext context) {
    // Ethiopic/Geez script range: U+1200 to U+137F
    final ethiopicRegex = RegExp(r'[\u1200-\u137F]');
    if (ethiopicRegex.hasMatch(text)) return 'am';
    
    // For Afaan Oromo, it's harder as it uses Latin script.
    // We check the current app locale as a hint.
    final currentLocale = Localizations.localeOf(context);
    if (currentLocale.languageCode == 'om') return 'om';

    // Default to Amharic if it's Ethiopic, otherwise might be English or other.
    return 'am'; 
  }

  Future<void> _handleTranslate() async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
      });
      widget.onTranslationDone(_originalText!, true);
      return;
    }

    _originalText = widget.text;

    // Use pre-translated content if available from backend (optimization)
    if (widget.translatedContent != null && widget.translatedContent!.isNotEmpty) {
      setState(() {
        _isTranslated = true;
      });
      widget.onTranslationDone(widget.translatedContent!, false);
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    final sourceLang = _detectLanguage(widget.text, context);

    final result = await ref.read(translationServiceProvider).translate(
      text: widget.text,
      sourceLang: sourceLang,
    );

    if (mounted) {
      setState(() {
        _isTranslating = false;
      });

      result.when(
        success: (response) {
          setState(() {
            _isTranslated = true;
          });
          widget.onTranslationDone(response.translatedText, false);
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.localizations.translationError)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final theme = Theme.of(context);
    final activeColor = widget.color ?? theme.primaryColor;

    if (_isTranslating) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      );
    }

    // Only show if it looks like it might need translation (non-English or forced)
    // For this prototype, we'll show it if it has Ethiopic characters or if it's long
    final ethiopicRegex = RegExp(r'[\u1200-\u137F]');
    final hasEthiopic = ethiopicRegex.hasMatch(widget.text);
    
    if (!hasEthiopic && !_isTranslated) {
      // If no ethiopic and not already translated, we only show for non-Latin-ish?
      // Actually, let's just show it if it has Ethiopic or if the user is in a non-English locale
      final currentLocale = Localizations.localeOf(context);
      if (currentLocale.languageCode == 'en' && !hasEthiopic) {
        return const SizedBox.shrink();
      }
    }

    return TextButton.icon(
      onPressed: _handleTranslate,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: activeColor,
      ),
      icon: Icon(
        _isTranslated ? Icons.restore_rounded : Icons.translate_rounded,
        size: 16,
      ),
      label: Text(
        _isTranslated ? l10n.showOriginal : l10n.translate,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
