import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:photo_view/photo_view.dart';

import 'models.dart';
import 'settings.dart';
import 'result.dart';

class PollScreen extends StatefulWidget {
  final Poll poll;
  final int codeId;

  const PollScreen({Key key, this.poll, this.codeId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PollState();
}

class PollState extends State<PollScreen> {
  bool _visible = false;
  int _group;
  final SnackBar snackBarNoAnswer =
      SnackBar(content: Text('Seleccione una alternativa'));
  final SnackBar snackBarError =
      SnackBar(content: Text('Error, comuníquese con soporte'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione una opción'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              widget.poll.title,
              textAlign: TextAlign.center,
            ),
          ),
          image(widget.poll.imagePath),
          options(widget.poll.alternatives),
          _visible ? Center(child: CircularProgressIndicator()) : Container(),
        ],
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () => _vote(context),
            child: Icon(Icons.done),
          );
        },
      ),
    );
  }

  Widget image([String imagePath]) {
    if (imagePath == null) {
      return Container();
    } else {
//      return Padding(
//        padding: EdgeInsets.symmetric(horizontal: 16.0),
//        child: Image.network('${Settings.URL_BASE}/$imagePath'),
//      );
      /*return Stack(
        children: <Widget>[
          Center(
            child: CircularProgressIndicator(),
            heightFactor: 2.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: '${Settings.URL_BASE}/$imagePath',
            ),
          ),
        ],
      );*/
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroPhotoViewWrapper(
                    imageProvider:
                        NetworkImage('${Settings.URL_BASE}/$imagePath'),
                  ),
            ),
          );
        },
        child: Container(
            child: Hero(
          tag: "someTag",
          child: Image.network('${Settings.URL_BASE}/$imagePath'),
        )),
      );
    }
  }

  Widget options(List alternatives) {
    List list = <Widget>[];
    for (var alternative in alternatives) {
      list.add(
        RadioListTile(
          title: Text(alternative['body']),
          value: alternative['id'],
          groupValue: _group,
          onChanged: (value) => setState(() => _group = value),
        ),
      );
    }
    return Column(children: list);
  }

  void _vote(BuildContext context) async {
    setState(() => _visible = true);
    if (_group == null) {
      Scaffold.of(context).showSnackBar(snackBarNoAnswer);
    } else {
      final String url = '${Settings.API_URL}/answer';
      final Map mapBody = {
        'code': widget.codeId.toString(),
        'alternative': _group.toString()
      };
      final response = await http.post(url, body: mapBody);
      if (response.statusCode == HttpStatus.ok) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
                  codeId: widget.codeId,
                  alternatives: widget.poll.alternatives,
                ),
          ),
        );
      } else {
        Scaffold.of(context).showSnackBar(snackBarError);
      }
    }
    setState(() => _visible = false);
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Color backgroundColor;
  final dynamic minScale;
  final dynamic maxScale;

  const HeroPhotoViewWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundColor,
      this.minScale = 0.2,
      this.maxScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: imageProvider,
        loadingChild: loadingChild,
        backgroundColor: backgroundColor,
        minScale: minScale,
        maxScale: maxScale,
        heroTag: "someTag",
      ),
    );
  }
}
