
import 'package:animated_splash/animated_splash.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'pages/login.dart';

import 'common/global.dart';
import 'common/routers.dart';

import 'pages/home.dart';

import 'states/theme_model.dart';
import 'states/user_model.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  Global.init().then((e) {
    SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
        .then((v)  async{

         runApp(MyApp());
         //
    });
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final router = Router();

  @override
  Widget build(BuildContext context) {
    Routers.configRoutes(router);
    Routers.router = router;

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider.value(value: ThemeModel()), 
        ChangeNotifierProvider.value(value: UserModel()),
      ],
      child: Consumer2<ThemeModel, UserModel>(
        builder: (BuildContext context, themeModel, userModel, Widget child) {
          return MaterialApp(
            title: '记作业',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: themeModel.theme,
              //appBarTheme: AppBarTheme(brightness: Brightness.light),
            ),
      
            home: AnimatedSplash(
              imagePath: 'images/splash.png',
              home: _firstPage(userModel),
              duration: 3000,
              type: AnimatedSplashType.StaticDuration,
            ),
            onGenerateRoute: Routers.router.generator,
            debugShowMaterialGrid: false,
          );
        },
      ),
    );
  }

  Widget _firstPage(UserModel userModel) {

    if (userModel.isLogin) {
        return HomePage();
    } else {
      return LoginPage();
      //return HomePage();
    }
  }
}
