import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/config/app.config.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/dart_util.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameValueController = TextEditingController();
  final _passwordValueController = TextEditingController();
  

  Future<(bool, String, String)> _authenRequest() async{
    String username = _usernameValueController.text.trim();
    DateTime now = DateTime.now();
    String formatteDateString = DateUtil.getFormetterDate(now);

    String combinedString = "$username&$formatteDateString";
    print(combinedString);


    String authenrequestString = sha256
    .convert(utf8.encode(combinedString))
    .toString();

    print(authenrequestString);

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}/authen/authen_request"),
      headers : <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String>{'authen_request': authenrequestString}),
    );

    final json = jsonDecode(response.body);
    print(json);

    

    return (
      json["isError"] as bool,
      json["data"] as String,
      json["errorMessage"] as String,
    );

  }
  Future<({bool isError, String data, String errorMessage})> _accessRequest(
    String authenToken,
  ) async {
    String username = _usernameValueController.text.trim();
    String password = _passwordValueController.text.trim();
    String passwordEncode = sha256.convert(utf8.encode(password)).toString();
    String combinedString = "$username&$passwordEncode&$authenToken";
    String authenSignature = sha256.convert(utf8.encode(combinedString)).toString();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}/authen/access_request"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'authen_token': authenToken,
        'authen_signature': authenSignature,
      })
    );
    
    final json = jsonDecode(response.body);
    print(json);

    if(!json["isError"]){
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString("access_token", json["data"]["access_token"]);
        await prefs.setString("username", username);
        final imageUrl = json["data"]["image_url"];
        if (imageUrl is String && imageUrl.isNotEmpty) {
          await prefs.setString("image_url", imageUrl);
        } else {
          await prefs.remove("image_url");
        }
    }
    
    return(
      isError: json["isError"] as bool,
      data: json["isError"] ? json["data"] as String : json["data"]["access_token"] as String,
      errorMessage: json["errorMessage"] as String,
    );
    
  }

  void _doLogin(BuildContext context) async{
    var (isError, authenToken, errorMessage) = await _authenRequest();
    if(isError){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(content: Text(errorMessage));
        },
      );
    }
    else{

      var result = await _accessRequest(authenToken);
      if(result.isError){
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(content: Text(result.errorMessage));
          },
        );
      }else{
        Navigator.push(context, MaterialPageRoute(builder:(context)=>const HomeScreen()));
          }

    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/sea.avif"),
            fit: BoxFit.fill,
          ), // DecorationImage
        ), // BoxDecoration
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withValues(alpha: 0.1),
          ), // BoxDecoration
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [ 
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Text("Username"),
                ), // Container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    controller:   _usernameValueController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอก Username";
                      }
                      return null;
                    },
                  ), // TextFormField
                ), // Container
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Text("Password"),
                ), // Container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordValueController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอก Password";
                      }
                      return null;
                    },
                  ), // TextFormField
                ), // Container
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: handle login logic here
                        _doLogin(context);
                      }
                    },
                    child: Text("Login"),
                  ), // ElevatedButton
                ), // Container
              ],
            ), // Column
          ), // Form
        ), // Container
      ), // Container
    ); // Scaffold
  }
}
