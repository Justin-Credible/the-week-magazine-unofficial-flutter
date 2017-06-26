import "package:flutter/material.dart";

import "Menu/Menu.dart";
import "IssueList/IssueList.dart";

class Root extends StatefulWidget {
    Root({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _RootState createState() => new _RootState();
}

class _RootState extends State<Root> {

    final GlobalKey<IssueListState> _issueListKey = new GlobalKey<IssueListState>();

    void _refreshPressed() {

        _issueListKey.currentState.refresh();
    }

    @override
    Widget build(BuildContext context) {

        return new Scaffold(

            appBar: new AppBar(

                title: new Text("Issues"),

                actions: [
                    new IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh",
                        onPressed: _refreshPressed,
                    ),
                ],
            ),

            drawer: new Menu(),

            body: new IssueList(
                key: _issueListKey,
                title: "Issues"
            ),
        );
    }
}
