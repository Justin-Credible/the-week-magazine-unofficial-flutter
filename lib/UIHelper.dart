import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter/material.dart";

class Buttons {
    static const String Yes = "Yes";
    static const String No = "No";
}

class UIHelper {

    static Future<String> confirm({String message, String title, BuildContext context}) async {
        var completer = new Completer();

        final ThemeData theme = Theme.of(context);
        final TextStyle style = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

        var dialog = new AlertDialog(
            content: new Text(message, style: style),
            title: new Text(title ?? "Confirm"),
            actions: [
                new FlatButton(
                    child: const Text(Buttons.Yes),
                    onPressed: () { Navigator.pop(context, Buttons.Yes); }
                ),
                new FlatButton(
                    child: const Text(Buttons.No),
                    onPressed: () { Navigator.pop(context, Buttons.No); },
                ),
            ]
        );

        showDialog<String>(context: context, child: dialog).then((String result) {
            completer.complete(result);
        });

        return completer.future;
    }
}
