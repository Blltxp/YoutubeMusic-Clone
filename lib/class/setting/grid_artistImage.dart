// ignore_for_file: file_names

import 'package:flutter/material.dart';

class GridArtistImage extends StatefulWidget {
  // Make it a StatefulWidget
  final String imageUrl;
  final double size;
  final bool isCircular;

  const GridArtistImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.isCircular = true,
  });

  @override
  State<GridArtistImage> createState() => _GridArtistImageState();
}

class _GridArtistImageState extends State<GridArtistImage> {
  bool _isLoading = true; // Track loading state

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.isCircular
          ? BorderRadius.circular(widget.size / 2)
          : BorderRadius.zero,
      child: Image.asset(
        // Or Image.network if it's a URL
        widget.imageUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, object, stackTrace) => const Icon(Icons.error),
        frameBuilder: (BuildContext context, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
          if (frame == null) {
            // Image is still loading
            return Center(
              child: _isLoading // Only show indicator if still loading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(), // Prevents indicator from flashing
            );
          } else {
            // Image has loaded
            _isLoading = false; // Set loading to false
            return child;
          }
        },
      ),
    );
  }
}
