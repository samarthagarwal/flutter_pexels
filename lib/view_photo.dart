import 'package:flutter/material.dart';
import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhoto extends StatelessWidget {
  final PexelsPhoto photo;

  const ViewPhoto({Key key, this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(photo.src.original),
        loadingBuilder: (ctx, event) {
          if (event == null) return Container();
          return Center(
            child: CircularProgressIndicator(value: event.cumulativeBytesLoaded / event.expectedTotalBytes),
          );
        },
      ),
    );
  }
}
