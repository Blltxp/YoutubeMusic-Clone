import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final String currentTime;
  final String totalTime;
  final bool isAdPlaying;

  const SliderWidget({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    required this.currentTime,
    required this.totalTime,
    required this.isAdPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final sliderTheme = isAdPlaying
        ? SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.yellow,
            inactiveTrackColor: Colors.yellow.withOpacity(0.3),
            thumbColor: Colors.yellow,
            overlayColor: Colors.yellow.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            trackHeight: 4.0,
          )
        : SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            trackHeight: 4.0,
          );
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(sliderTheme: sliderTheme),
          child: Container(
            height: 40,
            child: Center(
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(currentTime,
                  style: const TextStyle(color: Colors.white70)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(totalTime,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        )
      ],
    );
  }
}
