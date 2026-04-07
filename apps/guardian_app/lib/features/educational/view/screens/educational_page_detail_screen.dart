import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:neuronet_core/neuronet_core.dart';

class GuardianEducationalPageDetailScreen extends StatelessWidget {
  const GuardianEducationalPageDetailScreen({
    super.key,
    required this.page,
  });

  final EducationalPage page;

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      page.category?.toUpperCase() ?? 'LEARN',
                      style: TextStyle(
                        color: NeuroColors.guardianPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
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
                ],
              ),
            ),
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
                  label: const Text('I\'ve read this!'),
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
