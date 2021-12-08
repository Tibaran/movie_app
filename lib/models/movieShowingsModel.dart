// ignore_for_file: file_names
class Shows{
  List<Movies>? movies;

  Shows({this.movies});

  Shows.fromJson(List<dynamic> json){
    if (json != null) {
      movies = [];
      for ( var v in json){
        movies!.add(Movies.fromJson(v));
      }
    }

  }
}
class Movies{
  List<Theaters>? theaters;
  String? title;

  Movies({
    this.theaters,
    this.title
  });
  Movies.fromJson(Map<String, dynamic> json) {
    
    if (json != null) {
      List<String> ids = [];
      theaters = [];
      json['showtimes'].forEach((v) {
        var id = v['theatre']['id'];
        var theaterName = v['theatre']['name'];
        if(!ids.contains(id)){
          theaters!.add(Theaters.fromJson(json, id, theaterName));
          ids.add(id);
        }
      });
    }
    title = json['title'];
  }
}

class Theaters{
  String? id;
  String? theater;
  List<Showtimes>? showtimes;


  Theaters(
    {this.id,
      this.theater,
      this.showtimes});
  
  Theaters.fromJson(Map<String, dynamic> json, String theaterId, String theaterName) {
    showtimes = [];
    json['showtimes'].forEach((v) {
      if(v['theatre']['id'] == theaterId){
        showtimes!.add(Showtimes.fromJson(v['ticketURI'], v['dateTime']));
      }
    });
    id = theaterId;
    theater = theaterName;
  }
}
class Showtimes{
  String? ticketURI;
  String? dateTime;

  Showtimes({
    this.ticketURI,
    this.dateTime
  });

  Showtimes.fromJson(String? ticketUrl, String? time){
    ticketURI = ticketUrl;
    dateTime = time!.split("T")[1];
  }

}
