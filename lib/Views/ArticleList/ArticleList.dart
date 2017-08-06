import "dart:async";

import "package:flutter/material.dart";

import "../../Utilities.dart";
import "../../Data/Article.dart";
import "../../Data/MagazineDataSource.dart";
import "ArticleListItem.dart";

class ArticleList extends StatefulWidget {
    ArticleList({Key key, this.issueID}) : super(key: key);

    final String issueID;

    @override
    ArticleListState createState() => new ArticleListState();
}

class ArticleListState extends State<ArticleList> {

    bool _showSpinner = false;
    List<Article> _articles = new List<Article>();

    Future<Null> _refresh() async {

        var result = await on(MagazineDataSource.retrieveArticles(this.widget.issueID));

        if (result.error != null) {
            // TODO: show error message in panel
            setState(() { _showSpinner = false; });
            return;
        }

        setState(() {
            _showSpinner = false;
            _articles = result.data;
        });
    }

    @override
    initState() {
        super.initState();

        _showSpinner = true;

        _refresh();
    }

    @override
    Widget build(BuildContext context) {

        Widget buildChild() {

            if (_showSpinner) {

                return new Center(
                    child: new CircularProgressIndicator()
                );
            }
            else if (_articles == null || _articles.length == 0) {

                return new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: new Center(
                        child: new Column(
                            children: <Widget>[
                                const Text("No articles available."),
                                new RaisedButton(
                                    child: new Text("Go back"),
                                    onPressed: () => Navigator.pop(context),
                                ),
                            ],
                        ),
                    ),
                );
            }
            else {

                return new ListView.builder(
                    padding: kMaterialListPadding,
                    itemCount: _articles.length,

                    itemBuilder: (BuildContext context, int index) {

                        var article = _articles[index];

                        return new Column(
                            children: [
                                new ArticleListItem(issueID: widget.issueID, article: article),
                                new Divider(),
                            ]
                        );
                    },
                );
            }
        }

        return new Scaffold(

            appBar: new AppBar(
                title: new Text("Articles"),
            ),

            body: buildChild(),
        );
    }
}
