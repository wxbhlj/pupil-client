

import 'user.dart';

class Profile {
  User user;
  int theme;
  


  Profile({this.user, this.theme});

  Profile.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    theme = json['theme'];

    
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['theme'] = this.theme;

    return data;
  }

}