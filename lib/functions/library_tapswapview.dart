import 'package:flutter/material.dart';

class Tapswapview extends StatefulWidget {
  final ValueNotifier<bool> isGridView; // ใช้ ValueNotifier

  const Tapswapview({Key? key, required this.isGridView}) : super(key: key);

  @override
  State<Tapswapview> createState() => _TapswapviewState();
}

class _TapswapviewState extends State<Tapswapview> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isGridView,
      builder: (context, isGridView, child) {
        return GestureDetector(
          onTap: () {
            widget.isGridView.value =
                !isGridView; // ใช้ _isGridView.value = !isGridView;
          },
          child: Icon(
            isGridView ? Icons.grid_view_outlined : Icons.list,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
