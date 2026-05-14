import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:neuronet_core/neuronet_core.dart';

class GuardianEducationalPageDetailScreen extends StatelessWidget {
  const GuardianEducationalPageDetailScreen({
    super.key,
    required this.page,
  });

  final EducationalPage page;

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    final d = difficulty.toLowerCase();
    if (d == context.localizations.beginner.toLowerCase()) {
      return Colors.green;
    } else if (d == context.localizations.intermediate.toLowerCase()) {
      return Colors.orange;
    } else if (d == context.localizations.advanced.toLowerCase()) {
      return Colors.red;
    }
    return NeuroColors.guardianPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          page.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: NeuroColors.guardianPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Image (if available)
            if (page.featuredImageUrl != null && page.featuredImageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(page.featuredImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: NeuroColors.guardianPrimary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          page.category?.toUpperCase() ?? context.localizations.learnAndGrow.toUpperCase(),
                          style: const TextStyle(
                            color: NeuroColors.guardianPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (page.difficultyLevel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(context, page.difficultyLevel!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            page.difficultyLevel!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: NeuroColors.onSurface,
                    ),
                  ),
                  if (page.summary != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      page.summary!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: NeuroColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  // Meta info
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (page.estimatedReadTime > 0) ...[
                        const Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: NeuroColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.localizations.minRead(page.estimatedReadTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: NeuroColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      const Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: NeuroColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.localizations.viewsCountLabel(page.viewCount),
                        style: const TextStyle(
                          fontSize: 12,
                          color: NeuroColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: NeuroColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.localizations.followerCountLabel(page.followCount),
                        style: const TextStyle(
                          fontSize: 12,
                          color: NeuroColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags
                  if (page.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: page.tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Author Info
            if (page.authorName != null) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NeuroColors.guardianPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: NeuroColors.guardianPrimary,
                        child: Text(
                          page.authorName![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.authorName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (page.authorCredentials != null)
                              Text(
                                page.authorCredentials!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NeuroColors.onSurfaceVariant,
                                ),
                              ),
                            if (page.authorBio != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                page.authorBio!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NeuroColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(24),
              child: MarkdownBody(
                data: page.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    height: 1.7,
                    color: NeuroColors.onSurface,
                    fontSize: 16,
                  ),
                  h1: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NeuroColors.guardianPrimary,
                    fontSize: 20,
                  ),
                  h2: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NeuroColors.guardianPrimary,
                    fontSize: 18,
                  ),
                  listBullet: const TextStyle(
                    color: NeuroColors.guardianPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  blockquote: const TextStyle(
                    color: NeuroColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: NeuroColors.guardianPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: NeuroColors.guardianPrimary,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(context.localizations.iveReadThis),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
