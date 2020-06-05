class User {
  String avatar;
  String nick;
  String token;
  int userId;


  User(
      {this.avatar,
      this.nick,
      this.token,
      this.userId});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    nick = json['nick'];
    token = json['token'];
    userId = int.parse(json['userId'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['nick'] = this.nick;
    data['token'] = this.token;
    data['userId'] = this.userId;
    return data;
  }
}
