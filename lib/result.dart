import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'settings.dart';

class ResultScreen extends StatefulWidget {
  final int codeId;
  final List alternatives;

  const ResultScreen({Key key, this.codeId, this.alternatives})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ResultState();
}

class ResultState extends State<ResultScreen> {
  List<charts.Series> result = [];

  @override
  Widget build(BuildContext context) {
    double _halfScreen = (MediaQuery.of(context).size.height - 92.0) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados'),
      ),
      body: RefreshIndicator(
        child: ListView(
          children: <Widget>[
            Container(
              child: result.isNotEmpty
                  ? SimpleBarChart(result)
                  : Center(child: CircularProgressIndicator()),
              height: _halfScreen,
            ),
            Container(
              child: _alternatives(widget.alternatives),
              height: _halfScreen,
            ),
          ],
        ),
        onRefresh: () => getTotal(),
      ),
    );
  }

  Future<void> getTotal({bool again = false}) async {
    int codeId = widget.codeId;
    List answerList = <Answer>[];

    final response = await http.get('${Settings.API_URL}/answer/$codeId');
    final List responseJson = json.decode(response.body.toString());
    responseJson.forEach((element) => answerList.add(Answer.fromJson(element)));

    if (!mounted) return;
    setState(() => result = _resultData(answerList));
    if (again)
      Future.delayed(Duration(seconds: 5), () => getTotal(again: true));
  }

  Widget _alternatives(List data) {
    print('Here ! ${DateTime.now()}');
    if (data.isEmpty) {
      return Column();
    }

    List<Widget> list = [];
    list.add(
      ListTile(
        title: Text(
          'Alternativas',
          textAlign: TextAlign.center,
        ),
      ),
    );

    for (var element in data) {
      list.add(
        ListTile(
          title: Text('${element['id']} - ${element['body']}'),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

  @override
  void initState() {
    super.initState();
    getTotal(again: true);
  }

  static List<charts.Series<Answer, String>> _resultData(List<Answer> data) {
    return [
      charts.Series<Answer, String>(
        id: 'Respuestas',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Answer answer, _) => answer.alternative.toString(),
        measureFn: (Answer answer, _) => answer.total,
        data: data,
      )
    ];
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: true,
    );
  }
}

class Answer {
  final int alternative;
  final int total;

  Answer(this.alternative, this.total);

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(json['alternative_id'], json['total']);
  }
}
