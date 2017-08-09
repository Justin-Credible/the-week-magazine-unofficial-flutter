import "dart:async";
import "dart:io";

import "package:flutter/material.dart";

import "../../Utilities.dart";
import "../../Data/Article.dart";
import "../../Data/MagazineDataSource.dart";
import "../../Data/MagazineDataUtils.dart";
import "../../Data/ContentManager.dart";
import "ArticleListItem.dart";

class ArticleList extends StatefulWidget {
    ArticleList({Key key, this.issueID}) : super(key: key);

    final String issueID;

    @override
    ArticleListState createState() => new ArticleListState();
}

class ArticleListState extends State<ArticleList> {

    bool _showSpinner = false;
    String _coverImageURL;
    Map<String, List<Article>> _articlesBySection = new Map<String, List<Article>>();

    Future<Null> _refresh() async {

        var retrieveArticlesResult = await on(MagazineDataSource.retrieveArticles(this.widget.issueID));

        if (retrieveArticlesResult.error != null) {
            // TODO: show error message in panel
            setState(() { _showSpinner = false; });
            return;
        }

        List<Article> allArticles = retrieveArticlesResult.data;
        Map<String, List<Article>> articlesBySection;

        try {
            articlesBySection = MagazineDataUtils.getArticlesBySection(allArticles, false, false);
        }
        catch (error) {
            // TODO: show error message in panel
            setState(() { _showSpinner = false; });
            return;
        }

        var retrieveCoverImageResult = await on(ContentManager.instance.getCoverImageFilePath(widget.issueID));

        String coverImageURL;

        if (retrieveArticlesResult.error == null) {
            coverImageURL = retrieveCoverImageResult.data;
        }

        setState(() {
            _showSpinner = false;
            _coverImageURL = coverImageURL;
            _articlesBySection = articlesBySection;
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
            else if (_articlesBySection == null || _articlesBySection.length == 0) {

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
                return _buildListView(context);
            }
        }

        return new Scaffold(

            appBar: new AppBar(
                title: new Text("Articles"),
            ),

            body: buildChild(),
        );
    }

    Widget _buildListView(BuildContext context) {

        final ThemeData themeData = Theme.of(context);
        final TextStyle headerStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

        return new ListView.builder(
            padding: kMaterialListPadding,
            itemCount: _articlesBySection.length,

            itemBuilder: (BuildContext context, int index) {

                var articles = _articlesBySection.values.elementAt(index);
                var categoryTitle = _articlesBySection.keys.elementAt(index);

                var children = new List<Widget>();

                // Add the magazine cover image before any of the sections.
                if (index == 0 && _coverImageURL != null) {
                    children.add(new Image(
                        image: new FileImage(new File(_coverImageURL)),
                        height: 400.0,
                    ));
                }

                children.add(new Container(
                    height: 48.0,
                    padding: const EdgeInsets.only(left: 16.0),
                    alignment: FractionalOffset.centerLeft,
                    child: new Text(categoryTitle, style: headerStyle)
                ));

                for (var article in articles) {
                    children.add(new ArticleListItem(issueID: widget.issueID, article: article));
                }

                children.add(new Divider());

                return new Column(children: children);
            },
        );
    }
}
