import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/song/song.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/domain/usecases/song/is_favorite_song.dart';
import 'package:spotify/service_locator.dart';

abstract class SongFirebaseService {
  Future<Either> getNewsSongs();
  Future<Either> getPlayList();

  Future<Either> addOrRemoveFavoriteSong(String songId);

  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
}

class SongFirebaseServiceImple implements SongFirebaseService {
  @override
  Future<Either> getNewsSongs() async {
    try {
      List<SongEntity> songs = [];
      var data = await FirebaseFirestore.instance
          .collection('songs')
          .orderBy('releaseDate', descending: true)
          .limit(10)
          .get();
      for (var element in data.docs) {
        var songModel = SongModel.fromjson(element.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>()
            .call(params: element.reference.id);
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }
      return Right(songs);
    } catch (e) {
      return const Left('An error occurred  please try again');
    }
  }

  @override
  Future<Either> getPlayList() async {
    try {
      List<SongEntity> songs = [];
      var data = await FirebaseFirestore.instance
          .collection('songs')
          .orderBy('releaseDate', descending: true)
          .get();
      for (var element in data.docs) {
        var songModel = SongModel.fromjson(element.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>()
            .call(params: element.reference.id);
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }
      return Right(songs);
    } catch (e) {
      return const Left('An error occurred  please try again');
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;
      var user = firebaseAuth.currentUser;
      String uid = user!.uid;
      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();
      if (favoriteSongs.docs.isNotEmpty) {
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('Favorites')
            .add({'songId': songId, 'addedDate': Timestamp.now()});
        isFavorite = true;
      }
      return Right(isFavorite);
    } catch (e) {
      return Left('An error occurred  please try again');
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = firebaseAuth.currentUser;
      String uid = user!.uid;
      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();
      if (favoriteSongs.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      List<SongEntity> favoriteSongs = [];
      var user = firebaseAuth.currentUser;
      String uid = user!.uid;

      QuerySnapshot favoritesSnapshot = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('Favorites')
          .get();
      for (var element in favoritesSnapshot.docs) {
        String songId = element['songId'];
        var song =
            await firebaseFirestore.collection('songs').doc(songId).get();
        SongModel songModel = SongModel.fromjson(song.data()!);
        songModel.isFavorite = true;
        songModel.songId = songId;
        favoriteSongs.add(songModel.toEntity());
      }

      return Right(favoriteSongs);
    } catch (e) {
      return Left('An error occurred  please try again');
    }
  }
}
