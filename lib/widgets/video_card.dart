import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pexels/models/pexels_video.dart';
import 'package:flutter_pexels/services/pexels_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final PexelsVideo video;

  VideoCard({Key key, this.video}) {}

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  StreamController<bool> _favoriteStreamController = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    GetIt.I.get<PexelsService>().isFavorite(widget.video.id.toString(), "video").then((value) {
      _favoriteStreamController.add(value);
    });

    VideoFiles chosenVideoFile;

    for (int i = 0; i < widget.video.videoFiles.length; ++i) {
      if (widget.video.videoFiles[i].quality == "sd") {
        chosenVideoFile = widget.video.videoFiles[i];
        break;
      }
    }

    _videoPlayerController = VideoPlayerController.network(chosenVideoFile.link);
    _chewieController = ChewieController(
      allowPlaybackSpeedChanging: false,
      videoPlayerController: _videoPlayerController,
      placeholder: Image.network(
        widget.video.videoPictures[0].picture,
        fit: BoxFit.cover,
      ),
      showControls: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 20.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            color: Colors.black,
            height: 196.0,
            child: Stack(
              children: [
                Chewie(
                  controller: _chewieController,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StreamBuilder<bool>(
                        stream: _favoriteStreamController.stream,
                        builder: (context, snapshot) {
                          return IconButton(
                            icon: Icon(
                              (snapshot.data == null || snapshot.data == false) ? Icons.favorite_border_outlined : Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await GetIt.I.get<PexelsService>().toggleFavorite(widget.video.id.toString(), widget.video.toJson(), "video");
                              bool favorite = await GetIt.I.get<PexelsService>().isFavorite(widget.video.id.toString(), "video");
                              String message;
                              if (favorite)
                                message = "Video saved to favorites";
                              else
                                message = "Video removed from favorites";
                              Fluttertoast.showToast(
                                msg: message,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );

                              _favoriteStreamController.add(favorite);
                            },
                          );
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.download_rounded,
                      //     color: Colors.white,
                      //   ),
                      //   onPressed: () async {
                      //     Fluttertoast.showToast(
                      //       msg: "Downloading video...",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //     );
                      //     await GetIt.I.get<PexelsService>().saveVideo(widget.video);
                      //
                      //     Fluttertoast.showToast(
                      //       msg: "Video saved to gallery.",
                      //       toastLength: Toast.LENGTH_SHORT,
                      //       gravity: ToastGravity.BOTTOM,
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
