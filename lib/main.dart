import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import './models/movieModel.dart';
import './models/tmdb.dart';
import './models/movieShowingsModel.dart';
import './models/tms.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'movieDetails.dart';

void main() async => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: const MyMovieApp(),
    ));

class MyMovieApp extends StatefulWidget {
  const MyMovieApp({Key? key}) : super(key: key);
  @override
  _MyMovieApp createState() => _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp> {
  late Movie nowPlayingMovies;
  late Movie upcomingMovies;
  late Movie popularMovies;
  late Movie topRatedMovies;

  late Shows showtimesM;

  bool loadedPlaying = false; 
  bool loadedUpcoming = false; 
  bool loadedPopular = false; 
  bool loadedTop = false;

  bool loadedShows = false;

  int heroTag = 0;
  int _currentIdex = 0;
  
  @override
  void initState() {
    super.initState();
    _fetchShowtimeMovies();
    _fillMoviesLists();
  }
  
  // Executes all movies filler functions
  Future<void> _fillMoviesLists() async{
    _fetchNowPlayingMovies();
    _fetchUpcomingMovies();
    _fetchPopularMovies();
    _fetchTopRatedMovies();
  }
  
  // Now Playing movies
  Future<void> _fetchNowPlayingMovies() async {
    var response = await http.get(Uri.parse(Tmdb.nowPlayingUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
      loadedPlaying = true;
    });
  }

  // Upcoming Movies
  Future<void> _fetchUpcomingMovies() async {
    var response = await http.get(Uri.parse(Tmdb.upcomingUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      upcomingMovies = Movie.fromJson(decodeJson);
      loadedUpcoming = true;
    });
  }
  // Popular Movies
  Future<void> _fetchPopularMovies() async {
    var response = await http.get(Uri.parse(Tmdb.popularUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      popularMovies = Movie.fromJson(decodeJson);
      loadedPopular = true;
    });
  }

  // Top Rated Movies
  Future<void> _fetchTopRatedMovies() async {
    var response = await http.get(Uri.parse(Tmdb.topRatedUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      topRatedMovies = Movie.fromJson(decodeJson);
      loadedTop = true;
    });
  }

  // Fetch Movies Showtimes near 1km 
  Future<void> _fetchShowtimeMovies() async {
    Position currentLocation = await _getGeoLocationPosition();
    var response = await http.get(Uri.parse(Tms.getUrl(currentLocation.latitude.toString(), currentLocation.longitude.toString())));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      showtimesM = Shows.fromJson(decodeJson);
      loadedShows = true;
    });
  }

  // Get Location from deviece
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
      
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // ListView Builders VistaPrincipal

  Widget _buildCarouselSlider() => CarouselSlider(
        items: nowPlayingMovies == null
            ? <Widget>[const Center(child: CircularProgressIndicator())]
            : nowPlayingMovies.results!
                .map((movieItem) => _buildMovieItem(movieItem))
                .toList(),
         options: CarouselOptions(
           autoPlay: false,
           height: 240.0,
           viewportFraction: 0.5,
         ),
  );
  
  // Builds Image poster and adds onTap movieDetail
  Widget _buildMovieItem(Results movieItem) {
    heroTag += 1;
    movieItem.heroTag = heroTag;
    return Material(
        elevation: 15.0,
        child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MovieDetail(movie: movieItem,)
              ));
            },
            child: Hero(
              tag: heroTag,
              child: Image.network("${Tmdb.baseImageUrl}w342${movieItem.posterPath}",
                  fit: BoxFit.cover),
            )));
  }

  // Builds Item for the list with Image Poster and Movie Title
  Widget _buildMovieListItem(Results movieItem) => Material(
        child: Container(
            width: 128.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding:const EdgeInsets.all(6.0),
                    child: _buildMovieItem(movieItem)),
                Padding(
                    padding:const EdgeInsets.only(left: 6.0, top: 2.0),
                    child: Text(
                      movieItem.title!,
                      style:const TextStyle(fontSize: 8.0),
                      overflow: TextOverflow.ellipsis,
                    )),
                Padding(
                  padding:const EdgeInsets.only(left: 6.0, top: 2.0),
                  child: Text(
                      DateFormat('yyyy')
                          .format(DateTime.parse(movieItem.releaseDate!)),
                      style:const TextStyle(fontSize: 8.0)),
                ),
              ],
            )),
      );

  // Build the List needs list of movies and section title
  Widget _buildMoviesListView(Movie movie, String movieListTitle) => Container(
        height: 258.0,
        padding:const EdgeInsets.only(top: 10.0, bottom: 10.00),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:const EdgeInsets.only(left: 7.0, bottom: 7.0),
              child: Text(
                movieListTitle,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]),
              ),
            ),
            Flexible(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: movie == null
                    ? <Widget>[const Center(child: CircularProgressIndicator())]
                    : movie.results!
                        .map((movieItem) => Padding(
                              padding:const EdgeInsets.only(left: 6.0, right: 2.0),
                              child: _buildMovieListItem(movieItem),
                            ))
                        .toList(),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<void>( //FutureBuilder chooses wich widget to load
        future: _fillMoviesLists(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot){
          Widget body;
          if (loadedPlaying && loadedUpcoming && loadedPopular && loadedTop && _currentIdex == 0){
            body = vistaPrincipal();
          }else if (loadedShows && _currentIdex==1){
            body = nearbyMovies();
          }else if (snapshot.hasError){
            body = const Scaffold(
               body: Center(
                 child: Text("Hubo un Error inesperado")
                 ,)
              ,);
          }
          else{
             body = const Scaffold(
               body: Center(
                 child: CircularProgressIndicator()
                 ,)
              ,);
          }
          return body;
        },
      );
  }

  // Our Hompage
  Widget vistaPrincipal(){
    return Scaffold(
      appBar: appBar(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBookIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('NOW PLAYING',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              expandedHeight: 290.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: <Widget>[
                    //Container(
                      //child: 
                      Image.network(
                        "${Tmdb.baseImageUrl}w500/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg",
                        fit: BoxFit.cover,
                        width: 1000.0,
                        colorBlendMode: BlendMode.dstATop,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    //),
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: _buildCarouselSlider(),
                    ),
                  ],
                ),
              ),
            )
          ];
        },
        body: ListView(children: <Widget>[
          _buildMoviesListView(upcomingMovies, 'COMMING SOON'),
          _buildMoviesListView(popularMovies, 'POPULAR'),
          _buildMoviesListView(topRatedMovies, 'TOP RATES'),
        ]),
      ),
      // Navegacion inferior
      bottomNavigationBar: bottomBar(),
    );
  }

  // Widget, shows movies playing in theaters around 1km
  Widget nearbyMovies(){
    return Scaffold(
      appBar: appBar(),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: showtimesM.movies!.length,
        itemBuilder: (BuildContext context, int index) {
          var showItem = showtimesM.movies!.elementAt(index);
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                Text(showItem.title!, style: const TextStyle(fontSize: 20)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: showItem.theaters!.length,
                  itemBuilder: (BuildContext context, int index){
                    var theaterTime = showItem.theaters!.elementAt(index);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(theaterTime.theater!),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: times(theaterTime.showtimes!),)
                        ),
                      ],
                    );
                  })
              ],),
          );
        }),
      bottomNavigationBar: bottomBar(),
    );
  }
  // Fills a list with the movie showtimes with their fandango ticket.
  List<Widget> times(List<Showtimes> tiempos){
    List<Widget> elementos = [];
    for(var t in tiempos){
      elementos.add(
        TextButton(
          onPressed: (){_launchURL(t.ticketURI!);},
          child: Text(t.dateTime!)
        )
      );
    }
    return elementos;
  }
  // Launches the link of the showtime
  _launchURL(String destino) async {
  var url = destino;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Nos se puedo lanzar $url';
  }
}

  // Our Apps Appbar
  AppBar appBar(){
    return AppBar(
        elevation: 0.0,
        title: const Text(
          'Movie App',
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true
      );
  }

  // Our BottomNavigationBar
  BottomNavigationBar bottomBar(){
    return BottomNavigationBar(
          fixedColor: Colors.lightBlue,
          currentIndex: _currentIdex,
          onTap: (int index) {
            setState(() => _currentIdex = index);
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.local_movies), label: 'All movies'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_activity), label: 'Nearby Movies'),
          ]);
  }
}
