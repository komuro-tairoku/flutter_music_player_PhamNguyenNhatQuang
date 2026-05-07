import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBarWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;
  final bool isDark;

  const ProgressBarWidget({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxVal =
        duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final currentVal =
        position.inMilliseconds.toDouble().clamp(0.0, maxVal);

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.5,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 5.5),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor:
                isDark ? AppColors.dividerDark : AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.12),
          ),
          child: Slider(
            value: currentVal,
            min: 0.0,
            max: maxVal,
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                DurationFormatter.format(duration),
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
