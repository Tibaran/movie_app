import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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

  
  //static final DateTime now = DateTime.now();
  //static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  //String _currentDate = formatter.format(now);
  //final Widget _body = const Scaffold(body: Center(child: CircularProgressIndicator(),),);

  @override
  void initState() {
    super.initState();
    _fetchShowtimeMovies();
    _fillMoviesLists();
  }

  Future<void> _fillMoviesLists() async{
    _fetchNowPlayingMovies();
    _fetchUpcomingMovies();
    _fetchPopularMovies();
    _fetchTopRatedMovies();
  }

  Future<void> _fetchShowtimeMovies() async {
    var response = await http.get(Uri.parse(Tms.testUrlD));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      showtimesM = Shows.fromJson(decodeJson);
      loadedShows = true;
    });
  }

  Future<void> _fetchNowPlayingMovies() async {
    var response = await http.get(Uri.parse(Tmdb.nowPlayingUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
      loadedPlaying = true;
    });
  }
  

  Future<void> _fetchUpcomingMovies() async {
    var response = await http.get(Uri.parse(Tmdb.upcomingUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      upcomingMovies = Movie.fromJson(decodeJson);
      loadedUpcoming = true;
    });
  }

  Future<void> _fetchPopularMovies() async {
    var response = await http.get(Uri.parse(Tmdb.popularUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      popularMovies = Movie.fromJson(decodeJson);
      loadedPopular = true;
    });
  }

  Future<void> _fetchTopRatedMovies() async {
    var response = await http.get(Uri.parse(Tmdb.topRatedUrl));
    var decodeJson = jsonDecode(response.body);
    setState(() {
      topRatedMovies = Movie.fromJson(decodeJson);
      loadedTop = true;
    });
  }

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
    return  FutureBuilder<void>(
        future: _fillMoviesLists(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot){
          Widget body;
          if (loadedPlaying && loadedUpcoming && loadedPopular && loadedTop && _currentIdex == 0){
            body = vistaPrincipal();
          }else if (loadedShows && _currentIdex==1){
            body = nearbyMovies();
          }else if (_currentIdex==2){
            body = accountWidget();
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

  AppBar cabezeraSuperior(){
    return AppBar(
        elevation: 0.0,
        title: const Text(
          'Movie App',
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () {},
          )
        ],
      );
  }

  BottomNavigationBar menuInferior(){
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Account'),
          ]);
  }

  Widget vistaPrincipal(){
    return Scaffold(
      appBar: cabezeraSuperior(),
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
      bottomNavigationBar: menuInferior(),
    );
  }

  Widget nearbyMovies(){
    return Scaffold(
      appBar: cabezeraSuperior(),
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
                            children: tiempos(theaterTime.showtimes!),)
                        ),
                      ],
                      );
                  })
              ],),
          );
        }),
      bottomNavigationBar: menuInferior(),
    );
  }
  List<Widget> tiempos(List<Showtimes> tiempos){
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
  _launchURL(String destino) async {
  var url = destino;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Nos se puedo lanzar $url';
  }
}
  /*
  ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: showtimesM.movies!.length,
        itemBuilder: (BuildContext context, int index) {
          var showItem = showtimesM.movies!.elementAt(index);
          return Container(
            child: Column(
              children: [
                Text(showItem.title!),
                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: showItem.theaters!.length,
                  itemBuilder: (BuildContext context, int index){
                    var theaterTime = showItem.theaters!.elementAt(index);
                    return Column(
                      children: [
                        Text(theaterTime.theater!),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: theaterTime.showtimes!.length,
                          itemBuilder: (BuildContext context, int index){
                            var showtime = theaterTime.showtimes!.elementAt(index);
                            return TextButton(
                              onPressed: (){print(showtime.dateTime!);}, 
                              child: Text(showtime.dateTime!));
                          })
                      ],
                      );
                  })
              ],),
          );
        })
  */

  Widget accountWidget(){
    return Scaffold(
      appBar: cabezeraSuperior(),
      body: const Text("Cuenta"),
      // Navegacion inferior
      bottomNavigationBar: menuInferior(),
    );
  }
}
