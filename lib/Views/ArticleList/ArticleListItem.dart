import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_webview_plugin/flutter_webview_plugin.dart";

import "../../Data/Article.dart";

class ArticleListItem extends StatefulWidget {
    ArticleListItem({Key key, this.issueID, this.article}) : super(key: key);

    final String issueID;
    final Article article;

    @override
    _ArticleListItemState createState() => new _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem> {

    void _onTap() {

        _openArticle();
    }

    _openArticle() {

        var baseStoragePath = "file:///data/user/0/net.justin_credible.theweek/files";

        var fullURI = "${baseStoragePath}/issues/${widget.issueID}/editions/${widget.issueID}/${widget.article.localURI}";

        var webView = new FlutterWebviewPlugin();
        webView.launch(fullURI, fullScreen: true);
    }

    @override
    Widget build(BuildContext context) {

        return new ListTile(

            onTap: _onTap,

            title: new Text(widget.article.title),

            subtitle: new Text(widget.article.summary),
        );
    }
}
