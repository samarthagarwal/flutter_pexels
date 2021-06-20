import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:flutter_pexels/models/pexels_video.dart';
import 'package:flutter_pexels/services/pexels_service.dart';
import 'package:flutter_pexels/widgets/color_loader.dart';
import 'package:flutter_pexels/widgets/photo_card.dart';
import 'package:flutter_pexels/widgets/video_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class PexelsSearchDelegate extends SearchDelegate {
  final String searchType;
  StreamController<List> _streamController = StreamController<List>.broadcast();
  List _all = [];
  ScrollController _listScrollController = ScrollController();
  bool _loadingMore = false;
  int _currentPage = 2;
  int _pageSize = 10;
  bool _listIsLoadMoreEnabled = true;

  PexelsSearchDelegate({this.searchType = "photo"}) {
    _listScrollController.addListener(() async {
      if (_listScrollController.position.extentAfter < 500 && !_loadingMore && _listIsLoadMoreEnabled) {
        Fluttertoast.showToast(
          msg: "Loading more " + (this.searchType == "photo" ? "photos..." : "videos..."),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _loadingMore = true;
        List items = [];
        if (searchType == "photo") {
          items = await GetIt.I.get<PexelsService>().searchPhotos(query, ++_currentPage, _pageSize);
        } else {
          items = await GetIt.I.get<PexelsService>().searchVideos(query, ++_currentPage, _pageSize);
        }
        _all.addAll(items);
        _streamController.add(_all);
        _loadingMore = false;

        if (items.length < _pageSize) {
          Fluttertoast.showToast(
            msg: "You have reached the end of the catalog.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          _listIsLoadMoreEnabled = false;
        }
      }
    });
  }

  @override
  String get searchFieldLabel => "Search";

  @override
  TextStyle get searchFieldStyle => TextStyle(color: Colors.white);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context).copyWith(
      primaryColor: Color(0xff09a181),
      textTheme: Theme.of(context).textTheme.copyWith(
            headline6: TextStyle(
              color: Colors.white,
            ),
          ),
    );
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 5) {
      return Center(
        child: Text("Please type at-least 5 characters to search"),
      );
    }

    if (searchType == "photo") {
      GetIt.I.get<PexelsService>().searchPhotos(query).then((value) {
        _streamController.add(value);
      });
    } else {
      GetIt.I.get<PexelsService>().searchVideos(query).then((value) {
        _streamController.add(value);
      });
    }

    return StreamBuilder<List>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: ColorLoader(),
            );
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text("No results found. Please try changing the search keyword."),
            );
          }

          return ListView.builder(
            controller: _listScrollController,
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, index) {
              Widget widget;

              if (searchType == "photo") {
                PexelsPhoto photo = snapshot.data[index];
                widget = PhotoCard(photo: photo);
              } else if (searchType == "video") {
                PexelsVideo video = snapshot.data[index];
                widget = VideoCard(video: video);
              }

              return Container(
                child: widget,
              );
            },
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 5) {
      return Center(
        child: Text("Please type at-least 5 characters to search"),
      );
    }
    return Container();
  }
}
