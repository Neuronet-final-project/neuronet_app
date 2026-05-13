import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';

import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';
import '../widgets/journal_composer_widgets.dart';

class NewJournalEntryScreen extends ConsumerStatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  ConsumerState<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends ConsumerState<NewJournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  List<String> get _sparks => [
    context.localizations.sparkSmile,
    context.localizations.sparkGrateful,
    context.localizations.sparkVictory,
    context.localizations.sparkChallenge,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final content = _contentController.text.trim();
    final title = _titleController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.localizations.pleaseWriteSomething, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: NeuroColors.adolescentPrimaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_isSaving) return;

    setState(() => _isSaving = true);

    ref.read(journalControllerProvider.notifier).beginSaveEntry(
      content,
      title: title.isEmpty ? null : title,
      mood: MoodType.neutral,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.localizations.journalSaved,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: NeuroColors.adolescentPrimaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.go(AdolescentRoutes.journal);
  }

  void _closeJournal() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AdolescentRoutes.journal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: JournalComposerBottomBar(
        isSaving: _isSaving,
        onSave: _isSaving ? null : _handleSave,
      ),
      body: Stack(
        children: [
          // 1. Premium Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A1FDB),
                    Color(0xFF7C4DFF),
                    Color(0xFF9E8CD8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            right: -40,
            child: Icon(Icons.circle, size: 180, color: Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: -50,
            child: Icon(Icons.circle, size: 140, color: const Color(0xFFB388FF).withValues(alpha: 0.12)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.white,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _closeJournal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          context.localizations.newEntryTag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: NeuroColors.adolescentPrimary.withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, -8),
                      ),
                      const BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 24,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE4DAF5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Color(0xFF6A1FDB), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.localizations.safeSpaceNote,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                        color: Color(0xFF5A4A8A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            JournalComposerSparkStrip(
                              sparks: _sparks,
                              onSelect: (spark) {
                                if (_contentController.text.isEmpty) {
                                  setState(() => _contentController.text = '$spark\n\n');
                                } else {
                                  setState(() => _contentController.text = '${_contentController.text}\n\n$spark\n\n');
                                }
                              },
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2C1C5F),
                                letterSpacing: -0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: context.localizations.journalTitleHint,
                                hintStyle: const TextStyle(color: Color(0xFFB4A8D3)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F8FD),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFF0EDF5), width: 1.5),
                              ),
                              child: TextField(
                                controller: _contentController,
                                minLines: 4,
                                maxLines: 8,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF53477D),
                                ),
                                decoration: InputDecoration(
                                  hintText: context.localizations.journalContentHint,
                                  hintStyle: const TextStyle(color: Color(0xFFB4A8D3)),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
