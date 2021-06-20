import 'dart:async';
import 'dart:convert';

import 'package:flutter_pexels/models/pexels_photo.dart';
import 'package:flutter_pexels/models/pexels_video.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PexelsService {
  final String BASE_URL = "https://api.pexels.com/v1/";
  final Map<String, String> headers = {
    "Authorization": "563492ad6f91700001000001fb25a682d94a43868ddcc00878f52070",
  };
  SharedPreferences sharedPreferences;

  PexelsService() {
    print("PexelsService initialized");
  }

  Future<List<PexelsPhoto>> getCuratedPhotos([int page = 1, int perPage = 10]) async {
    List<PexelsPhoto> photos = [];
    try {
      Response response = await get(Uri.parse(BASE_URL + "/curated?page=" + page.toString() + "&per_page=" + perPage.toString()), headers: headers);
      for (int i = 0; i < json.decode(response.body.toString())["photos"].length; ++i) {
        photos.add(PexelsPhoto.fromJson(json.decode(response.body.toString())["photos"][i]));
      }
      print(photos.length.toString() + " photos fetched!");
      return photos;
    } catch (ex) {
      print(ex);
    }
  }

  Future<List<PexelsVideo>> getPopularVideos([int page = 1, int perPage = 10]) async {
    List<PexelsVideo> videos = [];
    try {
      Response response = await get(Uri.parse(BASE_URL + "/videos/popular?page=" + page.toString() + "&per_page=" + perPage.toString()), headers: headers);
      for (int i = 0; i < json.decode(response.body.toString())["videos"].length; ++i) {
        videos.add(PexelsVideo.fromJson(json.decode(response.body.toString())["videos"][i]));
      }
      return videos;
    } catch (ex) {
      print(ex);
    }
  }

  Future<List<PexelsPhoto>> searchPhotos(String query, [int page = 1, int perPage = 10]) async {
    List<PexelsPhoto> photos = [];
    try {
      Response response = await get(Uri.parse(BASE_URL + "/search?query=" + query.toString() + "&page=" + page.toString() + "&per_page=" + perPage.toString()),
          headers: headers);
      for (int i = 0; i < json.decode(response.body.toString())["photos"].length; ++i) {
        photos.add(PexelsPhoto.fromJson(json.decode(response.body.toString())["photos"][i]));
      }
      print(photos.length.toString() + " photos fetched!");
      return photos;
    } catch (ex) {
      print(ex);
    }
  }

  Future<List<PexelsVideo>> searchVideos(String query, [int page = 1, int perPage = 10]) async {
    List<PexelsVideo> videos = [];
    try {
      Response response = await get(
          Uri.parse(BASE_URL + "/videos/search?query=" + query.toString() + "&page=" + page.toString() + "&per_page=" + perPage.toString()),
          headers: headers);
      for (int i = 0; i < json.decode(response.body.toString())["videos"].length; ++i) {
        videos.add(PexelsVideo.fromJson(json.decode(response.body.toString())["videos"][i]));
      }
      return videos;
    } catch (ex) {
      print(ex);
    }
  }

  Future<List> getFavorites() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List favorites = [];
    List<String> favoritesString = sharedPreferences.getStringList("favorites") ?? [];
    for (int i = 0; i < favoritesString.length; ++i) {
      Map m = json.decode(favoritesString[i]);
      favorites.add({
        "id": m["id"],
        "data": json.decode(m["data"]),
        "type": m["type"],
      });
    }

    print(favorites.length.toString() + " favorites found!");
    return favorites;
  }

  Future<void> toggleFavorite(String id, Map data, String type) async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<String> favoritesString = sharedPreferences.getStringList("favorites") ?? [];
    Map<String, String> map = {
      "id": id,
      "data": json.encode(data),
      "type": type,
    };

    int foundIndex = -1;
    for (int i = 0; i < favoritesString.length; ++i) {
      Map m = json.decode(favoritesString[i]);
      if (m["id"] == id && m["type"] == type) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex == -1) {
      favoritesString.add(json.encode(map));
    } else {
      favoritesString.removeAt(foundIndex);
    }

    print(favoritesString);
    sharedPreferences.setStringList("favorites", favoritesString);
    print("Set as favorite");
  }

  Future<bool> isFavorite(String id, String type) async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<String> favoritesString = sharedPreferences.getStringList("favorites");
    if (favoritesString == null) {
      return false;
    }

    bool flag = false;
    for (int i = 0; i < favoritesString.length; ++i) {
      if (json.decode(favoritesString[i])["id"] == id && json.decode(favoritesString[i])["type"] == type) {
        flag = true;
        break;
      }
    }

    return flag;
  }

  savePhoto(PexelsPhoto photo) async {
    Response response = await get(Uri.parse(photo.src.original));
    var saved = await ImageGallerySaver.saveImage(response.bodyBytes, name: photo.id.toString());
    print(saved);
  }
}
