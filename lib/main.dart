import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pexels/favorites.dart';
import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:flutter_pexels/models/pexels_video.dart';
import 'package:flutter_pexels/pexels_search_delegate.dart';
import 'package:flutter_pexels/services/pexels_service.dart';
import 'package:flutter_pexels/widgets/color_loader.dart';
import 'package:flutter_pexels/widgets/photo_card.dart';
import 'package:flutter_pexels/widgets/video_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

void main() {
  GetIt.I.registerSingleton<PexelsService>(PexelsService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff09a181),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<List<PexelsPhoto>> _photoStreamController = StreamController<List<PexelsPhoto>>.broadcast();
  List<PexelsPhoto> _allPhotos = [];
  bool _loadingMorePhotos = false;
  int _currentPhotosPage = 2;
  bool _photoListIsLoadMoreEnabled = true;

  StreamController<List<PexelsVideo>> _videoStreamController = StreamController<List<PexelsVideo>>.broadcast();
  List<PexelsVideo> _allVideos = [];
  bool _loadingMoreVideos = false;
  int _currentVideosPage = 2;
  bool _videoListIsLoadMoreEnabled = true;

  PageController _pageController = PageController();
  ScrollController _photoListScrollController = ScrollController();
  ScrollController _videoListScrollController = ScrollController();
  int currentIndex = 0;

  int _pageSize = 10;

  _photoListScrollListener() async {
    if (_photoListScrollController.position.extentAfter < MediaQuery.of(context).size.height && !_loadingMorePhotos && _photoListIsLoadMoreEnabled) {
      Fluttertoast.showToast(
        msg: "Loading more photos...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      _loadingMorePhotos = true;
      List<PexelsPhoto> photos = await GetIt.I.get<PexelsService>().getCuratedPhotos(++_currentPhotosPage, _pageSize);
      _allPhotos.addAll(photos);
      _photoStreamController.add(_allPhotos);
      _loadingMorePhotos = false;

      if (photos.length < _pageSize) {
        Fluttertoast.showToast(
          msg: "You have reached the end of the catalog.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        _photoListIsLoadMoreEnabled = false;
      }
    }
  }

  _videoListScrollListener() async {
    if (_videoListScrollController.position.extentAfter < MediaQuery.of(context).size.height && !_loadingMoreVideos && _videoListIsLoadMoreEnabled) {
      Fluttertoast.showToast(
        msg: "Loading more videos...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      _loadingMoreVideos = true;
      List<PexelsVideo> videos = await GetIt.I.get<PexelsService>().getPopularVideos(++_currentVideosPage, _pageSize);
      _allVideos.addAll(videos);
      _videoStreamController.add(_allVideos);
      _loadingMoreVideos = false;

      if (videos.length < _pageSize) {
        Fluttertoast.showToast(
          msg: "You have reached the end of the catalog.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        _videoListIsLoadMoreEnabled = false;
      }
    }
  }

  initialize() async {
    List<PexelsPhoto> photos = await GetIt.I.get<PexelsService>().getCuratedPhotos();
    _allPhotos.addAll(photos);
    _photoStreamController.add(_allPhotos);

    List<PexelsVideo> videos = await GetIt.I.get<PexelsService>().getPopularVideos();
    _allVideos.addAll(videos);
    _videoStreamController.add(_allVideos);

    _pageController.addListener(() {
      _photoStreamController.add(_allPhotos);
      _videoStreamController.add(_allVideos);
    });
  }

  @override
  initState() {
    super.initState();

    initialize();

    _photoListScrollController = ScrollController()..addListener(_photoListScrollListener);
    _videoListScrollController = ScrollController()..addListener(_videoListScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "images/pexels_logo.png",
          width: 16.0,
          height: 16.0,
        ),
        backgroundColor: Color(0xff09a181),
        title: Text("Popular Pexels"),
        actions: [
          IconButton(
            tooltip: "Search " + (currentIndex == 0 ? "photos" : "videos"),
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PexelsSearchDelegate(
                  searchType: currentIndex == 0 ? "photo" : "video",
                ),
              );
            },
          ),
          IconButton(
            tooltip: "View favorite photos and videos",
            icon: Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => Favorites(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _getPhotosTab(context),
          _getVideosTab(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff09a181),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
          _pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 400), curve: Curves.ease);
        },
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Curated Photos"),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: "Popular Videos"),
        ],
      ),
    );
  }

  StreamBuilder<List<PexelsPhoto>> _getPhotosTab(BuildContext context) {
    return StreamBuilder<List<PexelsPhoto>>(
      stream: _photoStreamController.stream,
      builder: (ctx, snapshot) {
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

        return Scrollbar(
          child: ListView.builder(
            controller: _photoListScrollController,
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, index) {
              PexelsPhoto photo = snapshot.data[index];

              return PhotoCard(photo: photo);
            },
          ),
        );
      },
    );
  }

  StreamBuilder<List<PexelsVideo>> _getVideosTab(BuildContext context) {
    return StreamBuilder<List<PexelsVideo>>(
      stream: _videoStreamController.stream,
      builder: (ctx, snapshot) {
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

        return Scrollbar(
          child: ListView.builder(
            controller: _videoListScrollController,
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, index) {
              PexelsVideo video = snapshot.data[index];

              return VideoCard(video: video);
            },
          ),
        );
      },
    );
  }
}
