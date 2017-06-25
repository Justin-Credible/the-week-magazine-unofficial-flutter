import "dart:async";
import "package:flutter/material.dart";
import "Menu.dart";
import "../MagazineDataSource.dart";

class Issues extends StatefulWidget {
    Issues({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _IssuesState createState() => new _IssuesState();
}

class _IssuesState extends State<Issues> {

    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

    List _entries = new List();

    void _refreshPressed() {

        _refreshIndicatorKey.currentState.show();
    }

    Future<Null> _refresh({bool forceRefresh}) {

        var completer = new Completer();

        MagazineDataSource.retrieveIssueFeed(forceRefresh: true)
            .then((Map feed) {

            var entries = feed["entry"];

            setState(() { _entries = entries; });

            completer.complete(null);
        });

        return completer.future;
    }

    Widget _buildItems(BuildContext context, int index) {

        Map entry = _entries[index];

        return new ListTile(
            title: new Text(entry["title"])
        );
    }

    @override
    initState() {
        super.initState();

        _refresh();
    }

    @override
    Widget build(BuildContext context) {

        return new Scaffold(

            key: _scaffoldKey,

            appBar: new AppBar(

                title: new Text(widget.title),

                actions: [
                    new IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh",
                        onPressed: _refreshPressed,
                    ),
                ],
            ),

            drawer: new Menu(),

            body: new RefreshIndicator(

                key: _refreshIndicatorKey,
                onRefresh: () => _refresh(forceRefresh: true),

                child: new ListView.builder(
                    padding: kMaterialListPadding,
                    itemCount: _entries == null ? 0 : _entries.length,
                    itemBuilder: _buildItems
                ),
            ),
        );
    }
}
