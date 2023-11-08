// in this code we use the api in our app
// here we called the api in our first we
// convert it in json and then call in our app
import 'dart:convert';
import 'package:http/http.dart' as http;

//var baseURL = "https://opentdb.com/api.php?amount=20";
var baseURL = "https://herosapp.nyc3.digitaloceanspaces.com/quiz.json";
getQuiz() async {
  var res = await http.get(Uri.parse(baseURL));
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body.toString());
    print("data is loaded");
    return data;
  }
}
