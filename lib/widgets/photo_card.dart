import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pexels/extensions/hex.dart';
import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:flutter_pexels/services/pexels_service.dart';
import 'package:flutter_pexels/view_photo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCard extends StatelessWidget {
  final PexelsPhoto photo;
  StreamController<bool> _favoriteStreamController = StreamController<bool>();

  PhotoCard({Key key, this.photo}) {
    GetIt.I.get<PexelsService>().isFavorite(photo.id.toString(), "photo").then((value) {
      _favoriteStreamController.add(value);
    });
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
            height: 300.0,
            child: Stack(
              fit: StackFit.loose,
              children: [
                CachedNetworkImage(
                  imageUrl: photo.src.medium,
                  height: photo.height.toDouble(),
                  width: photo.width.toDouble(),
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 200),
                  fadeInCurve: Curves.easeIn,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.fullscreen,
                              size: 50.0,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ViewPhoto(photo: photo),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: HexColor.fromHex(photo.avgColor).withOpacity(0.9),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Photographed by",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                photo.photographer,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                              await GetIt.I.get<PexelsService>().toggleFavorite(photo.id.toString(), photo.toJson(), "photo");
                              bool favorite = await GetIt.I.get<PexelsService>().isFavorite(photo.id.toString(), "photo");
                              String message;
                              if (favorite)
                                message = "Photo saved to favorites";
                              else
                                message = "Photo removed from favorites";
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
                      IconButton(
                        icon: Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await Fluttertoast.showToast(
                            msg: "Downloading photo...",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                          );

                          PermissionStatus status = await Permission.storage.request();

                          if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
                            await Fluttertoast.showToast(
                              msg: "Image download canceled.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }

                          await GetIt.I.get<PexelsService>().savePhoto(photo);

                          await Fluttertoast.showToast(
                            msg: "Photo saved to gallery.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                      ),
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
