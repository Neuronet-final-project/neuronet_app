import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/educational_follow_provider.dart';

class PageFollowButton extends ConsumerStatefulWidget {
  const PageFollowButton({
    required this.pageSlug,
    this.isFollowed = false,
    this.onFollowChanged,
    super.key,
  });

  final String pageSlug;
  final bool isFollowed;
  final ValueChanged<bool>? onFollowChanged;

  @override
  ConsumerState<PageFollowButton> createState() => _PageFollowButtonState();
}

class _PageFollowButtonState extends ConsumerState<PageFollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFollowed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.isFollowed;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PageFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowed != widget.isFollowed) {
      setState(() {
        _isFollowed = widget.isFollowed;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    final l10n = context.localizations;
    setState(() => _isLoading = true);
    
    // Play animation
    await _animationController.forward();
    await _animationController.reverse();

    final controller = ref.read(educationalFollowControllerProvider.notifier);
    final success = _isFollowed
        ? await controller.unfollowPage(widget.pageSlug)
        : await controller.followPage(widget.pageSlug);

    if (success && mounted) {
      setState(() {
        _isFollowed = !_isFollowed;
        _isLoading = false;
      });
      widget.onFollowChanged?.call(_isFollowed);
      
      // Show feedback
      if (mounted) {
        NeuroToast.show(
          context,
          _isFollowed ? l10n.pageFollowed : l10n.pageUnfollowed,
          type: _isFollowed ? NeuroToastType.success : NeuroToastType.info,
        );
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
      NeuroToast.show(
        context,
        _isFollowed ? l10n.failedToUnfollowPage : l10n.failedToFollowPage,
        type: NeuroToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localizations;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: _isLoading
          ? SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            )
          : _isFollowed
              ? FilledButton.tonalIcon(
                  onPressed: _toggleFollow,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: Text(l10n.following),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _toggleFollow,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(l10n.follow),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
    );
  }
}

/// Compact version for use in cards
class CompactFollowButton extends ConsumerStatefulWidget {
  const CompactFollowButton({
    required this.pageSlug,
    this.isFollowed = false,
    this.onFollowChanged,
    super.key,
  });

  final String pageSlug;
  final bool isFollowed;
  final ValueChanged<bool>? onFollowChanged;

  @override
  ConsumerState<CompactFollowButton> createState() => _CompactFollowButtonState();
}

class _CompactFollowButtonState extends ConsumerState<CompactFollowButton> {
  bool _isFollowed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.isFollowed;
  }

  @override
  void didUpdateWidget(CompactFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowed != widget.isFollowed) {
      setState(() {
        _isFollowed = widget.isFollowed;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final controller = ref.read(educationalFollowControllerProvider.notifier);
    final success = _isFollowed
        ? await controller.unfollowPage(widget.pageSlug)
        : await controller.followPage(widget.pageSlug);

    if (success && mounted) {
      setState(() {
        _isFollowed = !_isFollowed;
        _isLoading = false;
      });
      widget.onFollowChanged?.call(_isFollowed);
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localizations;

    if (_isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
      );
    }

    return IconButton(
      onPressed: _toggleFollow,
      icon: Icon(
        _isFollowed ? Icons.bookmark : Icons.bookmark_border,
        color: _isFollowed ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      tooltip: _isFollowed ? l10n.unfollowTooltip : l10n.followTooltip,
    );
  }
}