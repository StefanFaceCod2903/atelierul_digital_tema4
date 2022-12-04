import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

///This app is just for replicating a UI
class MyApp extends StatefulWidget {
  ///
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChooseMovie(),
    );
  }
}

///This is the page where we select a movie
class ChooseMovie extends StatefulWidget {
  ///
  const ChooseMovie({super.key});

  @override
  State<ChooseMovie> createState() => _ChooseMovieState();
}

class _ChooseMovieState extends State<ChooseMovie> {
  PageController pageController = PageController();
  bool isLoading = false;
  List<String> images = [];
  List<String> titles = [];
  List<List<String>> genres = [];
  List<double> ratings = [];
  List<int> hours = [];

  Future<void> _getMovies() async {
    const url = 'https://yts.mx/api/v2/list_movies.json';
    final response = await get(Uri.parse(url));
    final rawResponse = jsonDecode(response.body) as Map<String, dynamic>;
    //print(rawResponse['data']['movies']);
    final data = rawResponse['data'] as Map<String, dynamic>;
    final movies =
        List<Map<dynamic, dynamic>>.from(data['movies'] as List<dynamic>);
    for (final item in movies) {
      images.add(item['medium_cover_image'] as String);
      titles.add(item['title'] as String);
      final rating = item['rating'] as String;
      ratings.add(double.parse(rating));
      final duration = item['runtime'] as double;
      hours.add(duration.round());
      final currentGenres = <String>[];
      final genresList = List<dynamic>.from(item['genres'] as List<dynamic>);
      for (final genre in genresList) {
        currentGenres.add(genre as String);
      }
      genres.add(currentGenres);
    }
    setState(() {
      isLoading = true;
    });
  }

  @override
  void initState() {
    _getMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A9ED8), Color(0xFF4252A0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Center(child: Text('Movies')),
          leading: const Icon(Icons.list),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: isLoading
            ? PageView.builder(
                controller: pageController,
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image(
                            image: NetworkImage(images[index]),
                            //imageFromAPI,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          titles[index],
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '${genres[index].join(", ")} - ${hours[index]} hours',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${ratings[index]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Rating',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        child: const Text('View more'),
                      ),
                    ],
                  );
                },
              )
            : const Center(
                child: Icon(Icons.downloading),
              ),
      ),
    );
  }
}
