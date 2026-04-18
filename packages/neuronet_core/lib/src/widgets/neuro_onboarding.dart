import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Data model for an individual onboarding slide.
class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// A premium, reusable onboarding screen for NEURONET apps.
class NeuroOnboardingScreen extends StatefulWidget {
  final List<OnboardingPageData> pages;
  final VoidCallback onFinish;
  final Color primaryColor;
  final String finishButtonText;

  const NeuroOnboardingScreen({
    super.key,
    required this.pages,
    required this.onFinish,
    required this.primaryColor,
    this.finishButtonText = 'Get Started',
  });

  @override
  State<NeuroOnboardingScreen> createState() => _NeuroOnboardingScreenState();
}

class _NeuroOnboardingScreenState extends State<NeuroOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuroColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(data: widget.pages[index]);
            },
          ),
          
          // Navigation UI (Indicator and Buttons)
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Animated Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.pages.length,
                    (index) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                          ? widget.primaryColor 
                          : widget.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Action Buttons
                Row(
                  children: [
                    if (_currentPage < widget.pages.length - 1)
                      TextButton(
                        onPressed: widget.onFinish,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: NeuroColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60), // Placeholder to maintain balance
                    
                    const Spacer(),
                    
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          widget.onFinish();
                        } else {
                          _pageController.nextPage(
                            duration: 400.ms,
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(140, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NeuroRadius.lg),
                        ),
                        elevation: 4,
                        shadowColor: widget.primaryColor.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        _currentPage == widget.pages.length - 1 
                          ? widget.finishButtonText 
                          : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 110,
              color: data.color,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut)
          .animate()
          .fade(duration: 600.ms)
          .scale(delay: 100.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 64),
          
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: NeuroStyles.headlineMedium.copyWith(
              color: NeuroColors.onSurface,
              height: 1.2,
            ),
          )
          .animate()
          .fade(delay: 300.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: NeuroStyles.bodyLarge.copyWith(
              color: NeuroColors.onSurfaceVariant,
              height: 1.5,
            ),
          )
          .animate()
          .fade(delay: 500.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
          
          const SizedBox(height: 100), // Space for navigation UI
        ],
      ),
    );
  }
}
