class User {
  String avatar;
  int avgScore;
  int coinsTotal;
  int coinsUsed;
  int loginTime;
  String nick;
  String token;
  int userId;

  User(
      {this.avatar,
      this.avgScore,
      this.coinsTotal,
      this.coinsUsed,
      this.loginTime,
      this.nick,
      this.token,
      this.userId});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    avgScore = int.parse(json['avgScore'].toString());
    coinsTotal = int.parse(json['coinsTotal'].toString());
    coinsUsed = int.parse(json['coinsUsed'].toString());
    loginTime = int.parse(json['loginTime'].toString());
    nick = json['nick'];
    token = json['token'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['avgScore'] = this.avgScore;
    data['coinsTotal'] = this.coinsTotal;
    data['coinsUsed'] = this.coinsUsed;
    data['loginTime'] = this.loginTime;
    data['nick'] = this.nick;
    data['token'] = this.token;
    data['userId'] = this.userId;
    return data;
  }
}