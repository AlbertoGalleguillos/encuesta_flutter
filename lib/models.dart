class Poll {
  int id;
  int userId;
  String title;
  String imagePath;
  List alternatives;

  Poll({this.id, this.userId, this.title, this.imagePath, this.alternatives});

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      imagePath: json['image_path'],
      alternatives: json['alternatives'],
    );
  }
}

class Alternative {
  int id;
  String body;
}
