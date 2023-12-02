import 'package:bankapp/models/auth.dart';
import 'package:bankapp/models/connectivity.dart';
import 'package:bankapp/pages/mypages.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // form  controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthController authController = AuthController();
  // Navigation
  void _onInkWellTapped(BuildContext context, mylocation) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => mylocation,
      ),
    );
  }

  String _errorMessage = "";
  bool _isVisible = false;
  bool _isLoading = false;
  bool _pageLoading = false;

  @override
  void initState() {
    super.initState();
    connection();
  }

  connection() async {
    bool isConnected = await Network.isAvailable();
    if (isConnected) {
      return "connected";
    }
  }

  @override
  Widget build(BuildContext context) {
    return _pageLoading
        ? const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            )),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              // brightness: Brightness.light,
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Login to your account",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                inputFile(
                                  label: "Email",
                                  mycontroller: _emailcontroller,
                                  myhint: "Enter your email",
                                  myvalidator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Field cannot be empty";
                                    } else if (!RegExp(
                                            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                        .hasMatch(value)) {
                                      return "Enter a valid email address";
                                    }
                                  },
                                ),
                                inputFile(
                                  label: "Password",
                                  obscureText: true,
                                  mycontroller: _passwordController,
                                  myhint: "Enter your password",
                                  myvalidator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Filed cannot be empty";
                                    } else if (value.length < 6) {
                                      return "Password too short";
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        _isVisible
                            ? Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              )
                            : Text(""),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 3, left: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              height: 60,
                              onPressed: () async {
                                String email = _emailcontroller.text.trim();
                                String password =
                                    _passwordController.text.trim();
                                bool isConnected = await Network.isAvailable();
                                if (isConnected) {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _pageLoading = true;
                                    });
                                    try {
                                      String result = await authController
                                          .authlogin(email, password);
                                      // Print the result
                                      _onInkWellTapped(context, Dashboard());
                                      // SharedPreferences pref =
                                      //     await SharedPreferences.getInstance();
                                      // String? token = pref.getString("token");
                                      // print("token: => " + token.toString());
                                      // Navigate to the dashboard or perform other actions on successful login
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                        _isVisible = true;
                                        _errorMessage =
                                            "Invalid email or password";
                                      });
                                      print("Error: $e");
                                      // Handle login failure, e.g., show an error message
                                    }
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                } else {
                                  print("Not connected");
                                }

                                // _onInkWellTapped(context, const Dashboard());
                              },
                              color: const Color(0xff0095FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    )
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: <Widget>[
                        //     const Text("Don't have an account?"),
                        //     InkWell(
                        //       onTap: () {
                        //         _onInkWellTapped(context, const SignupPage());
                        //       },
                        //       child: const Text(
                        //         " Sign up",
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.w600,
                        //           fontSize: 18,
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),
                        Container(
                          padding: const EdgeInsets.only(top: 100),
                          height: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/background.png"),
                                fit: BoxFit.fitHeight),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ),
          );
  }
}

//  Creating a widget for text field
Widget inputFile({
  label,
  obscureText = false,
  mycontroller,
  myhint,
  String? Function(String?)? myvalidator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      TextFormField(
        validator: myvalidator,
        controller: mycontroller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: myhint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
        ),
      ),
      const SizedBox(
        height: 15,
      )
    ],
  );
}
