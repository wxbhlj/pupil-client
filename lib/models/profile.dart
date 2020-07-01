

import 'user.dart';

class Profile {
  User get user  {
    if(users.length > 0) {
      return users[current];
    } else {
      return null;
    }
  }
  int theme;
  int current;
  
  List<User> users = List();

  Profile({this.theme});

  Profile.fromJson(Map<String, dynamic> json) {

    theme = json['theme'];
    current = json['current'];
    if (json['users'] != null) {
      users = new List<User>();
      json['users'].forEach((v) {
        users.add(new User.fromJson(v));
      });
    }

    
  }

  updateUser(User user) {
    if(user == null) {
      return removeCurrentUser();
    }
    if(users != null && users.length > 0) {
      for(int i = 0; i < users.length; i++) {
        User u = users[i];
        if(u.userId == user.userId) {
          users[i] = user;
          current = i;
          return;
        }
      }
    }
    users.add(user);
    current = users.length -1;
  }

  removeCurrentUser() {
    if(users != null && users.length > current) {
      users.removeAt(current);
      if(users.length > 0) {
        current = 0;
      }
    }
  }

  toNextUser() {
    current ++;
    if(current >= users.length) {
      current = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['theme'] = this.theme;
    data['current'] = this.current;
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }

    return data;
  }

}