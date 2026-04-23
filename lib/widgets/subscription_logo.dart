import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Converts a plain subscription name into a best-guess domain.
/// e.g. "Netflix" → "netflix.com", "Google One" → "google.com"
String _nameToDomain(String name) {
  // Known overrides for common multi-word or branded names
  const overrides = <String, String>{
    'google one': 'google.com',
    'google drive': 'google.com',
    'google photos': 'google.com',
    'youtube premium': 'youtube.com',
    'youtube music': 'youtube.com',
    'apple music': 'apple.com',
    'apple tv': 'apple.com',
    'apple tv+': 'apple.com',
    'apple one': 'apple.com',
    'icloud': 'apple.com',
    'amazon prime': 'amazon.com',
    'amazon music': 'amazon.com',
    'microsoft 365': 'microsoft.com',
    'office 365': 'microsoft.com',
    'xbox game pass': 'xbox.com',
    'xbox': 'xbox.com',
    'playstation now': 'playstation.com',
    'playstation plus': 'playstation.com',
    'ps plus': 'playstation.com',
    'disney plus': 'disneyplus.com',
    'disney+': 'disneyplus.com',
    'paramount plus': 'paramountplus.com',
    'paramount+': 'paramountplus.com',
    'hbo max': 'hbomax.com',
    'max': 'max.com',
    'adobe creative cloud': 'adobe.com',
    'adobe cc': 'adobe.com',
    'notion ai': 'notion.so',
    'chatgpt plus': 'openai.com',
    'chatgpt': 'openai.com',
    'github copilot': 'github.com',
    'dropbox plus': 'dropbox.com',
    'nordvpn': 'nordvpn.com',
    'nord vpn': 'nordvpn.com',
    'express vpn': 'expressvpn.com',
    'expressvpn': 'expressvpn.com',
    'duolingo plus': 'duolingo.com',
    'linkedin premium': 'linkedin.com',
    'ny times': 'nytimes.com',
    'new york times': 'nytimes.com',
    'washington post': 'washingtonpost.com',
    'the guardian': 'theguardian.com',
    'audible': 'audible.com',
    'kindle unlimited': 'amazon.com',
    'peacock': 'peacocktv.com',
    'crunchyroll': 'crunchyroll.com',
    'funimation': 'funimation.com',
    'sling tv': 'sling.com',
    'sling': 'sling.com',
    'fubo tv': 'fubo.tv',
    'fubo': 'fubo.tv',
    'paramount': 'paramountplus.com',
    'todoist': 'todoist.com',
    '1password': '1password.com',
    'lastpass': 'lastpass.com',
    'dashlane': 'dashlane.com',
    'grammarly': 'grammarly.com',
    'canva pro': 'canva.com',
    'figma': 'figma.com',
    'zoom': 'zoom.us',
    'slack': 'slack.com',
    'discord nitro': 'discord.com',
    'discord': 'discord.com',
    'twitch': 'twitch.tv',
    'calm': 'calm.com',
    'headspace': 'headspace.com',
    'peloton': 'onepeloton.com',
    'myfitnesspal': 'myfitnesspal.com',
    'noom': 'noom.com',
    'strava': 'strava.com',
    'allrecipes': 'allrecipes.com',
    'masterclass': 'masterclass.com',
    'skillshare': 'skillshare.com',
    'coursera plus': 'coursera.org',
    'coursera': 'coursera.org',
    'udemy': 'udemy.com',
    'pluralsight': 'pluralsight.com',
    'brilliant': 'brilliant.org',
    'pocketcasts': 'pocketcasts.com',
    'overcast': 'overcast.fm',
    'proton mail': 'proton.me',
    'protonmail': 'proton.me',
    'hey': 'hey.com',
    'fastmail': 'fastmail.com',
    'bear': 'bear.app',
    'obsidian': 'obsidian.md',
  };

  final lower = name.trim().toLowerCase();
  if (overrides.containsKey(lower)) return overrides[lower]!;

  // Strip common suffixes (Plus, Pro, Premium, +)
  final cleaned = lower
      .replaceAll(RegExp(r'\+$'), '')
      .replaceAll(RegExp(r'\b(plus|pro|premium|unlimited|one|pass|go|lite|basic|standard|ultimate)\b'), '')
      .trim();

  // Take the first word as the brand
  final firstWord = cleaned.split(RegExp(r'\s+')).first;

  // Most SaaS companies use .com
  return '$firstWord.com';
}

class SubscriptionLogoWidget extends StatefulWidget {
  final String name;
  final String category;
  final double size;
  final double borderRadius;
  final bool isActive;

  const SubscriptionLogoWidget({
    super.key,
    required this.name,
    required this.category,
    this.size = 52,
    this.borderRadius = 16,
    this.isActive = true,
  });

  @override
  State<SubscriptionLogoWidget> createState() => _SubscriptionLogoWidgetState();
}

class _SubscriptionLogoWidgetState extends State<SubscriptionLogoWidget> {
  int _retryKey = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        if (mounted) {
          setState(() {
            _retryKey++;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final domain = _nameToDomain(widget.name);
    final logoUrl = 'https://logos.hunter.io/$domain';
    final fallbackEmoji = AppConstants.categoryIcons[widget.category] ?? '📦';

    return Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.isActive
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Image.network(
        logoUrl,
        key: ValueKey('${widget.name}_$_retryKey'),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fall back to the category emoji
          return Center(
            child: Text(
              fallbackEmoji,
              style: TextStyle(
                fontSize: widget.size * 0.45,
                color: widget.isActive ? null : cs.outline.withValues(alpha: 0.5),
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary.withValues(alpha: 0.4),
              ),
            ),
          );
        },
      ),
    );
  }
}
