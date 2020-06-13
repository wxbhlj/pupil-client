import 'package:flutter/material.dart';

Widget buildListMenuItem(context, IconData icon, String title, Function onTap, {String title2 = ''}) {
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
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(title),
            ),
            Text(title2, style:TextStyle(color: Colors.grey))
          ],
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: onTap,
      ),
    );
  }