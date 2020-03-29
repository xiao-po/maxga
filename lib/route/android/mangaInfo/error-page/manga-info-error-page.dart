import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/button/copy-action-button.dart';
import 'package:maxga/http/repo/dmzj/constants/dmzj-manga-source.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/route/android/search/search-result-page.dart';

class MangaInfoErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final MangaSource source;

  const MangaInfoErrorPage(
      {Key key, @required this.title, @required this.message, this.source})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    var textColor = isDark ? Colors.grey[300] : Colors.black45;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: textColor),
        elevation: 1,
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        actions: <Widget>[CopyActionButton(keyword: title, color: textColor)],
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 8.0,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '但是你访问的是 ~ '),
                    TextSpan(
                        text: source.name,
                        style: TextStyle(color: Colors.orange)),
                    TextSpan(text: '  ~'),
                  ],
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 8.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "或许能在 "),
                    WidgetSpan(
                        child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => searchTitle(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.search,
                              size: 18,
                              color: theme.accentColor,
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              '其他网站',
                              style: TextStyle(color: theme.accentColor),
                            ),
                          ],
                        ),
                      ),
                    )),
                    TextSpan(text: "  找到你想要的?"),
                  ],
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              if (source.key == DmzjMangaSourceKey)
                ...[
                  const SizedBox(height: 8.0),
                  buildDmzjHiddenMangaError(Colors.grey[500]),
                ]
            ],
          )),
    );
  }

  Widget buildDmzjHiddenMangaError(Color textColor) {
    return Text(
      '如果访问的是隐藏漫画\n请在晚上八点之后访问，届时动漫之家会开放访问',
      textAlign: TextAlign.center,
      style: TextStyle(color: textColor),
    );
  }

  void searchTitle(BuildContext context) async {
    await LongAnimationDelay();
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchResultPage(
        keyword: title,
      );
    }));
  }
}
