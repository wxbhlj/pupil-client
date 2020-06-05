import 'package:flutter/material.dart';

Widget buildListMenuItem(context, IconData icon, String title, Function onTap) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).accentColor,
        ),
        title: Text(title),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: onTap,
      ),
    );
  }