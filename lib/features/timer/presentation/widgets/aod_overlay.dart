import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/timer_provider.dart';
import '../../../../core/constants/app_colors.dart';

class AodOverlay extends ConsumerWidget {
  const AodOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    if (!timerState.isAodActive) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.oledBlack,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ultra-dim status header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.moon, size: 14, color: AppColors.aodDimText),
                  SizedBox(width: 8),
                  Text(
                    'AOD • ULTIMATE FOCUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: AppColors.aodDimText,
                    ),
                  ),
                ],
              ),

              // Central Dim Typographic Timer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerState.formattedTime,
                    style: const TextStyle(
                      fontSize: 84,
                      fontWeight: FontWeight.w100,
                      letterSpacing: -4.0,
                      color: AppColors.aodDimText,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timerState.activeMode?.title.toUpperCase() ?? 'FOCUS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: AppColors.aodDimText,
                    ),
                  ),
                ],
              ),

              // Bottom hint
              Column(
                children: [
                  const Text(
                    'Double tap back or lift device to exit AOD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: AppColors.aodDimText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(timerProvider.notifier).cancelTimer(reason: 'ui');
                    },
                    icon: const Icon(LucideIcons.x, size: 12, color: AppColors.aodDimText),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.aodDimText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
