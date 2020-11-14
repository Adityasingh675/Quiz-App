import 'dart:convert';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/quiz.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "https://opentdb.com/api.php?amount=50";

  Quiz quiz;
  List<Results> results;
  Color color;

  Future<void> fetchQuiz() async {
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body);
      quiz = Quiz.fromJson(decodedJson);
      color = Colors.black;
      results = quiz.results;
      print(response.body);
    } else {
      print('Error retrieving the data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuiz,
        child: FutureBuilder(
          future: fetchQuiz(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Press Button To Start");
                break;
              case ConnectionState.active:
                break;
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) return errorData(snapshot);
                return questionList();
                break;
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: ${snapshot.error}"),
          SizedBox(height: 20.0),
          RaisedButton(
            child: Text("Try Again"),
            onPressed: () {
              fetchQuiz();
              setState(
                () {
                  fetchQuiz();
                },
              );
            },
          )
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 0.0,
          child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    results[index].question,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                  ),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(results[index].category),
                          onSelected: (b) {},
                        ),
                        SizedBox(width: 10.0),
                        FilterChip(
                          backgroundColor: Colors.grey[300],
                          label: Text(results[index].difficulty),
                          onSelected: (b) {},
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(results[index].type.startsWith("m") ? "M" : "B"),
            ),
            children: results[index].allAnswers.map((m) {
              return AnswerWidget(index, m, results);
            }).toList(),
          ),
        );
      },
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;
  AnswerWidget(this.index, this.m, this.results);
  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
          } else {
            c = Colors.red;
          }
          // Change the print statements to set colors
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
