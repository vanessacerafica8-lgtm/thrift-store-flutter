// lib/pages/full_screen_image_page.dart

import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final int itemId;
  final String imageUrl;
  const FullScreenImagePage(
      {Key? key, required this.itemId, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: 'item-image-$itemId',
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
