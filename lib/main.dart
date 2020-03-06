import 'package:flutter/material.dart';
import 'package:twitter_1user/twitter_1user.dart';
import 'cotoha_api.dart';

void main() => runApp(MyApp());

enum Target { Male, Female, Ossan }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COTOHA Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTweetPage(title: '中の人を隠すTwitterクライアント'),
    );
  }
}

class MyTweetPage extends StatefulWidget {
  MyTweetPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyTweetPageState createState() => _MyTweetPageState();
}

class _MyTweetPageState extends State<MyTweetPage> {
  var _target = Target.Female;
  final _txtController = TextEditingController();
  final CotohaApi _cotoha = CotohaApi(
      'clientId', 'clientSecret', 'devApiBaseUrl', 'accessTokenPublishUrl');
  final Twitter _twitter = Twitter(
      'CONSUMER KEY', 'CONSUMER SECRET', 'ACCESS TOKEN', 'ACCESS TOKEN SECRET');

  void _onChanged(Target target) {
    setState(() {
      _target = target;
    });
  }

  String _compareAttribute(Map<String, dynamic> att) {
    String result = '';
    var point = 0;

    // 年齢結果 帰ってくる値を調べきれてないので今回は見送り
    if (att['age'] != null) {
      var age = att['age'];
    }
    // 性別結果
    if (att['gender'] != null) {
      result += "gender:" + "\n";
      if (_target == Target.Male) {
        if (att['gender'] == '女性') {
          result += "男性らしさが足りていません!!" + "\n";
          point -= 1;
        } else if (att['gender'] == '男性') {
          result += "いい感じに男性らしさが出ています。" + "\n";
          point += 1;
        } else {
          result += "性別は解析不能でした。" + "\n";
        }
      } else if (_target == Target.Female) {
        if (att['gender'] == '女性') {
          result += "いい感じに女性らしさが出ています。" + "\n";
          point += 1;
        } else if (att['gender'] == '男性') {
          result += "女性らしさが足りていません!!" + "\n";
          point -= 1;
        } else {
          result += "性別は判断できません。" + "\n";
        }
      }
      result += "\n";
    }
    // 未婚/既婚結果
    if (att['civilstatus'] != null) {
      result += "civilstatus:" + "\n";
      if (att['civilstatus'] == '未婚') {
        result += "いい感じに未婚感が出ています。" + "\n";
        point += 1;
      } else if (att['civilstatus'] == '既婚') {
        result += "既婚者のオーラが出ています!!" + "\n";
        point -= 1;
      } else {
        result += "婚姻状況は判断できません。" + "\n";
      }
      result += "\n";
    }
    result += "最終結論:" + "\n";
    if (0 < point) {
      result += "安心してツイートしてください!!";
    } else if (0 == point) {
      result += "微妙ですね。慎重にツイートしてください。";
    }
    if (point < 0) {
      result += "危険です!! もう一度ツイートを見直しましょう!!";
    }
    return result;
  }

  void tweet() async {
    String result = '';
    String message = _txtController.text;
    if (message == '') {
      result = '本文を入力してください';
    } else {
      Map<String, dynamic> attribute =
          await _cotoha.userAttribute(message, 'kuzure', true);
      result = _compareAttribute(attribute);
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("解析結果"),
          content: Text(result),
          actions: <Widget>[
            FlatButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Tweetする"),
              onPressed: () {
                _twitter.request('post', 'statuses/update.json',
                    {'status': message + " #cotohaapi"});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          RadioListTile(
              title: Text('独身女性モード'),
              value: Target.Female,
              groupValue: _target,
              onChanged: _onChanged),
          RadioListTile(
              title: Text('独身男性モード'),
              value: Target.Male,
              groupValue: _target,
              onChanged: _onChanged),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _txtController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '宣伝しよう',
              ),
            ),
          ),
          Container(
              child: FutureBuilder(
                  future: _cotoha.init(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.data == true) {
                      return FlatButton(
                        child: Text("Check & Tweet"),
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: () {
                          tweet();
                        },
                      );
                    } else {
                      return Text('COTOHAへの通信エラー');
                    }
                  })),
        ],
      ),
    );
  }
}
