import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:neuronet_core/neuronet_core.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';

/// Safely formats a date with locale fallback.
String _safeFormatDate(DateTime date, String pattern, String locale) {
  try {
    return intl.DateFormat(pattern, locale).format(date);
  } on ArgumentError {
    return intl.DateFormat(pattern, 'en').format(date);
  }
}

class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: journalAsync.when(
        data: (state) {
          JournalEntry? entry;
          for (final e in state.entries) {
            if (e.id == entryId) {
              entry = e;
              break;
            }
          }
          if (entry == null) {
            return _EntryMissingBody(onBack: () => _popOrGoJournal(context));
          }
          return _DetailContent(entry: entry);
        },
        loading: () => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8E0F5)),
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: Color(0xFF6A1FDB),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.localizations.openingYourEntry,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF6A5C9A),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => _ErrorBody(
          message: '$error',
          onRetry: () => ref.read(journalControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeuroErrorWidget(
          message: '${context.localizations.failedToLoadJournals}: $message',
          onRetry: onRetry,
        ),
      ),
    );
  }
}

void _popOrGoJournal(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AdolescentRoutes.journal);
  }
}

String _formatEntryForShare(JournalEntry entry) {
  final buf = StringBuffer();
  // Use English for sharing to ensure consistent formatting
  final date = intl.DateFormat('yMMMMd', 'en').format(entry.createdAt);
  final time = intl.DateFormat('jm', 'en').format(entry.createdAt);
  buf.writeln('$date · $time');
  if (entry.title != null && entry.title!.trim().isNotEmpty) {
    buf.writeln();
    buf.writeln(entry.title!.trim());
  }
  buf.writeln();
  buf.write(entry.content.trim());
  return buf.toString();
}

Future<void> _journalDetailShareFromAnchor(
  BuildContext scaffoldContext,
  BuildContext anchorContext,
  JournalEntry entry,
) async {
  final text = _formatEntryForShare(entry);
  if (text.trim().isEmpty) return;

  Rect origin;
  final ro = anchorContext.findRenderObject();
  if (ro is RenderBox && ro.hasSize && ro.attached) {
    origin = ro.localToGlobal(Offset.zero) & ro.size;
    if (origin.width < 1 || origin.height < 1) {
      final sz = MediaQuery.sizeOf(scaffoldContext);
      origin = Rect.fromCenter(center: Offset(sz.width / 2, sz.height / 2), width: 2, height: 2);
    }
  } else {
    final sz = MediaQuery.sizeOf(scaffoldContext);
    origin = Rect.fromCenter(center: Offset(sz.width / 2, sz.height / 2), width: 2, height: 2);
  }

  final subject = (entry.title?.trim().isNotEmpty ?? false) ? entry.title!.trim() : scaffoldContext.localizations.journalSubject;

  try {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      ),
    );
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (scaffoldContext.mounted) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(scaffoldContext.localizations.couldNotOpenShare),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF2C1C5F),
        ),
      );
    }
  }
}

class _EntryMissingBody extends StatelessWidget {
  const _EntryMissingBody({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              alignment: Alignment.centerLeft,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                foregroundColor: NeuroColors.adolescentPrimaryDark,
                backgroundColor: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(Icons.menu_book_outlined, size: 64, color: NeuroColors.adolescentPrimary.withValues(alpha: 0.45)),
            const SizedBox(height: 20),
            Text(
              context.localizations.journalNotFound,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C1C5F),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              context.localizations.entryRemovedNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: NeuroColors.adolescentPrimaryDark.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: Text(context.localizations.backToJournal),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A1FDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  const _DetailContent({required this.entry});
  final JournalEntry entry;

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  late String _displayContent;

  @override
  void initState() {
    super.initState();
    _displayContent = widget.entry.content;
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final wordCount = entry.content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    final readTime = wordCount == 0 ? 1 : (wordCount / 200).ceil();
    
    // Emotion and Sentiment logic
    final emotion = entry.emotion ?? 'Analysis pending...';
    final sentimentScore = entry.sentimentScore;
    final sentimentLabel = sentimentScore == null
        ? '---'
        : (sentimentScore >= 0.5 ? 'Positive' : 'Negative');
    final sentimentIcon = sentimentScore == null
        ? Icons.analytics_outlined
        : (sentimentScore >= 0.5 ? Icons.sentiment_very_satisfied_rounded : Icons.sentiment_very_dissatisfied_rounded);
    final sentimentColor = sentimentScore == null
        ? const Color(0xFF6A5C9A)
        : (sentimentScore >= 0.5 ? const Color(0xFF43A047) : const Color(0xFFEF5350));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar(
          expandedHeight: 248,
          pinned: true,
          stretch: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFF6A1FDB),
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => _popOrGoJournal(context),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
          ),
          actions: [
            Builder(
              builder: (anchorContext) => IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                tooltip: context.localizations.shareTooltip,
                onPressed: () => _journalDetailShareFromAnchor(context, anchorContext, entry),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              tooltip: context.localizations.moreTooltip,
              onPressed: () => _showJournalActionsSheet(context, entry),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5A1BC7),
                        Color(0xFF6A1FDB),
                        Color(0xFF8B6AE8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  right: -24,
                  top: 72,
                  child: Icon(Icons.circle, size: 140, color: Colors.white.withValues(alpha: 0.06)),
                ),
                Positioned(
                  left: -40,
                  bottom: 20,
                  child: Icon(Icons.circle, size: 100, color: Colors.white.withValues(alpha: 0.05)),
                ),
                Center(
                  child: Icon(Icons.circle, size: 220, color: Colors.white.withValues(alpha: 0.04)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 52, 24, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.auto_stories_rounded, size: 44, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _safeFormatDate(entry.createdAt, 'EEEE', context.localizations.localeName).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _safeFormatDate(entry.createdAt, 'yMMMMd', context.localizations.localeName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
                                const SizedBox(width: 6),
                                 Flexible(
                                   child: Text(
                                     _safeFormatDate(entry.createdAt, 'jm', context.localizations.localeName),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8E0F5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A1FDB).withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatColumn(
                              icon: Icons.face_retouching_natural_rounded,
                              iconColor: const Color(0xFF6A1FDB),
                              value: emotion,
                              caption: 'EMOTION',
                            ),
                          ),
                          _VerticalHairline(color: NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.35)),
                          Expanded(
                            child: _StatColumn(
                              icon: sentimentIcon,
                              iconColor: sentimentColor,
                              value: sentimentLabel,
                              caption: 'SENTIMENT',
                            ),
                          ),
                          _VerticalHairline(color: NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.35)),
                          Expanded(
                            child: _StatColumn(
                              icon: Icons.text_fields_rounded,
                              iconColor: const Color(0xFF6A5C9A),
                              value: '$wordCount',
                              caption: context.localizations.wordsLabel,
                            ),
                          ),
                          _VerticalHairline(color: NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.35)),
                          Expanded(
                            child: _StatColumn(
                              icon: Icons.local_cafe_rounded,
                              iconColor: const Color(0xFF6A5C9A),
                              value: context.localizations.minCount(readTime),
                              caption: context.localizations.readLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E0F5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 20,
                          color: NeuroColors.adolescentPrimary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.localizations.tipLongPress,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: NeuroColors.adolescentPrimaryDark.withValues(alpha: 0.62),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (entry.title != null && entry.title!.trim().isNotEmpty) ...[
                    Text(
                      entry.title!.trim(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C1C5F),
                        letterSpacing: -0.6,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFF0EDF8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF9E7AFF), Color(0xFF6A1FDB)],
                                  ),
                                ),
                              ),
                              NeuroTranslateButton(
                                text: entry.content,
                                translatedContent: entry.translatedContent,
                                onTranslationDone: (translated, isOriginal) {
                                  setState(() {
                                    _displayContent = translated;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SelectableText(
                            _displayContent,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.75,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A3F72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEDE8FF),
                          NeuroColors.adolescentSurfaceVariant.withValues(alpha: 0.95),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: NeuroColors.adolescentPrimary.withValues(alpha: 0.12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: NeuroGradients.adolescent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.localizations.yourPrivateSpace,
                                  style: TextStyle(
                                    color: NeuroColors.adolescentPrimaryDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.localizations.privateSpaceNote,
                                  style: TextStyle(
                                    color: NeuroColors.adolescentPrimaryDark.withValues(alpha: 0.78),
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalHairline extends StatelessWidget {
  const _VerticalHairline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: color);
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.caption,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2C1C5F),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NeuroColors.adolescentPrimaryDark.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showJournalActionsSheet(BuildContext context, JournalEntry entry) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.copy_all_rounded, color: Color(0xFF6A1FDB)),
                title: Text(context.localizations.copyEntry, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(context.localizations.titleAndFullText, style: const TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(ClipboardData(text: _formatEntryForShare(entry)));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.localizations.copiedToClipboard),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF2C1C5F),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF6A1FDB)),
                title: Text(context.localizations.aboutJournalPrivacy, style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog<void>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: Text(context.localizations.journalPrivacyTitle),
                      content: Text(
                        context.localizations.journalPrivacyContent,
                        style: const TextStyle(height: 1.45),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: Text(context.localizations.gotIt),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.paddingOf(ctx).bottom),
            ],
          ),
        ),
      );
    },
  );
}
