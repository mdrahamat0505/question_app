import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:question_app/screens/quize_screen.dart';
import 'package:get/get.dart';
import 'package:question_app/services/hive_service.dart';

import 'constraints/color.dart';
import 'constraints/text_style.dart';

main() async{
  await Get.put(HiveService()).onInitHive();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: blue));

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const QuizApp(),
      theme: ThemeData(
        fontFamily: "quick",
      ),
      title: "Demo",
    );
  }
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;



    final score = Hive.box('score');

    final data = score.get('score');


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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(50),
              //     border: Border.all(color: lightgrey, width: 2),
              //   ),
              //   child: IconButton(
              //       onPressed: () {},
              //       icon: const Icon(
              //         CupertinoIcons.xmark,
              //         color: Colors.white,
              //         size: 28,
              //       )),
              // ),
              // Image.asset(
              //   balloon2,
              // ),
              const SizedBox(height: 50),
              normalText(color: lightgrey, size: 18, text: "Welcome to our"),
              const SizedBox(height: 20),
              headingText(color: Colors.white, size: 32, text: "Quiz App"),
              const SizedBox(height: 120),
              // normalText(
              //     color: lightgrey,
              //     size: 16,
              //     text: "Do you feel confident? Here you'll face our most difficult questions!"),
             // const Spacer(),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    alignment: Alignment.center,
                    width: size.width - 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: headingText(color: blue, size: 18, text: "New Game"),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              data != null ?
              headingText(color: Colors.white, size: 18, text: "High score of the best quiz:  $data"): headingText(color: Colors.white, size: 18, text: "High score of the best quiz:  0"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
