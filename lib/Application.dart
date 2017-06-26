import "package:flutter/material.dart";

import "Views/Root.dart";
import "Views/Menu/About.dart";

class Application extends StatelessWidget {

    @override
    Widget build(BuildContext context) {

        return new MaterialApp(

            title: "The Week",

            theme: new ThemeData(
                primarySwatch: Colors.red,
            ),

            home: new Root(),

            routes: {
                "/about": (BuildContext context) => new About(),
            },
        );
    }
}
