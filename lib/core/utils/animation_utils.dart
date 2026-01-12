import 'package:flutter/material.dart';

/// Animation utilities for consistent app-wide animations
/// 
/// Uses ultra-fast fade transitions (120-180ms) for accessibility
/// and minimal cognitive load (Material Design fade-through pattern)
class AppAnimations {
  // Private constructor
  AppAnimations._();
  
  /// Ultra-short duration for micro-transitions (120ms)
  static const Duration ultraFast = Duration(milliseconds: 120);
  
  /// Short duration for standard transitions (150ms)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Medium duration for emphasized transitions (180ms)
  static const Duration medium = Duration(milliseconds: 180);
  
  /// Curve for fade-in animations (accessibility-friendly)
  static const Curve fadeInCurve = Curves.easeOut;
  
  /// Curve for fade-out animations
  static const Curve fadeOutCurve = Curves.easeIn;
  
  /// Linear curve for reduced motion scenarios
  static const Curve linear = Curves.linear;
  
  /// Fade-through page transition (Material Design pattern)
  /// 
  /// Ultra-fast cross-fade between pages with no sliding motion
  /// Accessibility-friendly for users sensitive to motion
  static PageRouteBuilder<T> fadeThrough<T>({
    required Widget page,
    Duration duration = fast,
    Curve curve = fadeInCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade out old page
        final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: fadeOutCurve,
          ),
        );
        
        // Fade in new page
        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );
        
        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: fadeOut,
            child: child,
          ),
        );
      },
    );
  }
  
  /// Simple fade transition for widgets
  /// 
  /// Use for appearing/disappearing UI elements
  static Widget fadeIn({
    required Widget child,
    Duration duration = ultraFast,
    Curve curve = fadeInCurve,
    Offset? offset,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Staggered list animation
  /// 
  /// For animating list items with slight delay between each
  static Widget staggeredFade({
    required Widget child,
    required int index,
    Duration duration = fast,
    Duration delay = const Duration(milliseconds: 30),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: fadeInCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: AlwaysStoppedAnimation(index * delay.inMilliseconds / 1000),
        builder: (context, child) => child!,
        child: child,
      ),
    );
  }
}

/// Animated page wrapper for smooth content transitions
class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.duration = AppAnimations.fast,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeIn(
      duration: duration,
      child: child,
    );
  }
}
