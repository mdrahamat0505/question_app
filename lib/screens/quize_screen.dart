import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constraints/color.dart';
import '../constraints/text_style.dart';
import '../services/api_services.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  int seconds = 10;
  Timer? timer;
  late Future quiz;

  int points = 0;

  var isLoaded = false;

  var optionsList = [];
  var optionsListKey = [];

  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    quiz = getQuiz();
    startTimer();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          gotoNextQuestion();
        }
      });
    });
  }

  gotoNextQuestion() {
    if (currentQuestionIndex < 8) {
    isLoaded = false;
    currentQuestionIndex++;
    timer!.cancel();
    resetColors();
    seconds = 10;
    startTimer();
  }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [blue, darkBlue],
          )),
          child: FutureBuilder(
            future: quiz,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data["questions"];

                if (isLoaded == false) {
                  try {
                    isLoaded = true;
                    optionsList =
                        data[currentQuestionIndex]["answers"].values.toList();
                    optionsListKey =
                        data[currentQuestionIndex]["answers"].keys.toList();
                    //optionsList.add(data[currentQuestionIndex]["correct_answer"]);
                    optionsList.shuffle();
                  } catch (e) {
                    log("$e");
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: lightgrey, width: 2),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.xmark,
                                  color: Colors.white,
                                  size: 24,
                                )),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              normalText(
                                  color: Colors.white,
                                  size: 24,
                                  text: "$seconds"),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: seconds / 10,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: normalText(
                              color: lightgrey,
                              size: 18,
                              text:
                                  "Question ${currentQuestionIndex + 1} of ${data.length}")),
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: normalText(
                              color: lightgrey,
                              size: 18,
                              text: "Current score: $points")),
                      const SizedBox(height: 10),
                      Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  normalText(
                                      color: Colors.blue,
                                      size: 18,
                                      text: 'Question:'),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: CircleAvatar(
                                          radius: 30, // Image radius
                                          backgroundImage: NetworkImage(
                                              "${data[currentQuestionIndex < 8 ? currentQuestionIndex : 1]["questionImageUrl"]}"),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: normalText(
                                            color: Colors.blue,
                                            size: 18,
                                            text: data[currentQuestionIndex < 8
                                                ? currentQuestionIndex
                                                : 0]["question"]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: headingText(
                                        color: Colors.blue,
                                        size: 18,
                                        text:
                                            'Score of the question: ${data[currentQuestionIndex < 8 ? currentQuestionIndex : 0]["score"]}'),
                                  ),
                                ]),
                          )),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var answer = currentQuestionIndex < 8
                              ? data[currentQuestionIndex]["correctAnswer"]
                              : data[0]["correctAnswer"];

                          return GestureDetector(
                            onTap: () {
                              log('===========${optionsListKey[index]}');

                              if (currentQuestionIndex < 8) {
                                setState(
                                  () {
                                    if (answer.toString() ==
                                        optionsListKey[index]) {
                                      optionsColor[index] = Colors.green;
                                      points = data[currentQuestionIndex]
                                              ["score"] +
                                          points;

                                      final score = Hive.box('score');

                                      final values = score.get('score');
                                      if (points >= values) {
                                        score.clear();
                                        score.put('score', points);
                                      } else if (values == null) {
                                        score.clear();
                                        score.put('score', points);
                                      }
                                    } else {
                                      optionsColor[index] = Colors.red;

                                      for (int i = 0;
                                          i <= optionsListKey.length;
                                          i++) {
                                        if (answer.toString() ==
                                            optionsListKey[i]) {
                                          optionsColor[i] = Colors.green;
                                        }
                                      }
                                    }

                                    if (currentQuestionIndex <
                                        data.length - 1) {
                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        gotoNextQuestion();
                                      });
                                    } else {
                                      timer!.cancel();
                                      isLoaded = false;
                                    }
                                  },
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              alignment: Alignment.center,
                              width: size.width - 100,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: optionsColor[index],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: headingText(
                                color: blue,
                                size: 18,
                                text: optionsList[index].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
