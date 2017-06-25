import "package:flutter/material.dart";
import "Views/Issues.dart";

class Application extends StatelessWidget {

    @override
    Widget build(BuildContext context) {

        return new MaterialApp(

            title: "The Week",

            theme: new ThemeData(
                primarySwatch: Colors.red,
            ),

            home: new Issues(title: "Issues"),
        );
    }
}
