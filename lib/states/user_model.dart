

import 'profile_model.dart';
import '../common/global.dart';
import '../models/user.dart';

class UserModel extends ProfileChangeNotifier {
  User get user => Global.profile.user;



  // APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => user != null && user.token != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
  set user(User user) {
    Global.profile.updateUser(user);
    notifyListeners();
  }

}
