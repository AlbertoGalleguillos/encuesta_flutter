import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'poll.dart';
import 'settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Encuesta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Encuesta'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _codeController = TextEditingController();
  bool _visible = false;
  final SnackBar snackBarNotFount =
      SnackBar(content: Text('Código no encontrado'));
  final SnackBar snackBarError =
      SnackBar(content: Text('Error, comuníquese con soporte'));
  final SnackBar snackBarShortCode =
      SnackBar(content: Text('El código debe tener 6 dígitos'));

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: 120.0,
              child: TextFormField(
                enabled: !_visible,
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Código'),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ),
            _visible ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.arrow_forward),
            onPressed: () => !_visible ? searchCode(context) : null,
          );
        },
      ),
    );
  }

  void searchCode(BuildContext context) async {
    if (_codeController.text.length != 6) {
      Scaffold.of(context).showSnackBar(snackBarShortCode);
    } else {
      print(_codeController.text);
      setState(() => _visible = true);

      final String url = '${Settings.API_URL}/code/${_codeController.text}';
      final response = await http.get(url);

      switch (response.statusCode) {
        case HttpStatus.ok:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PollScreen(
                    poll: Poll.fromJson(json.decode(response.body)['question']),
                    codeId: json.decode(response.body)['code']['id'],
                  ),
            ),
          );
          break;
        case HttpStatus.notFound:
          Scaffold.of(context).showSnackBar(snackBarNotFount);
          break;
        default:
          Scaffold.of(context).showSnackBar(snackBarError);
      }

      setState(() => _visible = false);
    }
  }
}
