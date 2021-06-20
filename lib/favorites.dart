import 'package:flutter/material.dart';
import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:flutter_pexels/models/pexels_video.dart';
import 'package:flutter_pexels/services/pexels_service.dart';
import 'package:flutter_pexels/widgets/color_loader.dart';
import 'package:flutter_pexels/widgets/photo_card.dart';
import 'package:flutter_pexels/widgets/video_card.dart';
import 'package:get_it/get_it.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff09a181),
        title: Text("Favorite Pexels"),
      ),
      body: FutureBuilder<List>(
          future: GetIt.I.get<PexelsService>().getFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: ColorLoader(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("An error has occurred."),
              );
            }

            if (snapshot.data == null || snapshot.data.length == 0) {
              return Center(
                child: Text("You haven't added any favorites yet."),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (ctx, index) {
                  Widget widget;

                  if (snapshot.data[index]["type"] == "photo") {
                    PexelsPhoto photo = PexelsPhoto.fromJson(snapshot.data[index]["data"]);
                    widget = PhotoCard(photo: photo);
                  } else if (snapshot.data[index]["type"] == "video") {
                    PexelsVideo video = PexelsVideo.fromJson(snapshot.data[index]["data"]);
                    widget = VideoCard(video: video);
                  }

                  return Container(
                    child: widget,
                  );
                });
          }),
    );
  }
}
