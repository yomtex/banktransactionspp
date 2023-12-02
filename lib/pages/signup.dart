import 'package:bankapp/models/auth.dart';
import 'package:bankapp/models/connectivity.dart';
import 'package:bankapp/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  void _onInkWellTapped(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  AuthController authController = AuthController();

  late Position _currentPosition;
  double? _latitude = null;
  double? _longtitude = null;
  String country = '';
  String iso_code = '';
  Color? color;
  String locationData = 'Location not fetched';
  void showCustomToast(BuildContext context, String message,
      {required MaterialColor color}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0,
        left: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                // Your custom logo or icon here
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void initState() {
    super.initState();
    _getLocation();
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        // brightness: Brightness.light,
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(
        //     Icons.arrow_back_ios,
        //     size: 20,
        //     color: Colors.black,
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Create an account, It's free ",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      inputFile(
                        label: "Firstname",
                        myhint: "FIrst Name",
                        autofocus: true,
                        myctroller: _fnameController,
                        myvalidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                        },
                      ),
                      inputFile(
                        label: "Lastname",
                        myhint: "Last Name",
                        myctroller: _lnameController,
                        myvalidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                        },
                      ),
                      inputFile(
                        label: "Email",
                        myhint: "E-mail",
                        myctroller: _emailController,
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
                        label: "Username",
                        myhint: "Username",
                        myctroller: _usernameController,
                        myvalidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                        },
                      ),
                      inputFile(
                        label: "Password",
                        obscureText: true,
                        myhint: "************",
                        myctroller: _passwordController,
                        myvalidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Filed cannot be empty";
                          } else if (value.length < 6) {
                            return "Password too short";
                          }
                        },
                      ),
                      inputFile(
                        label: "Confirm Password",
                        obscureText: true,
                        myhint: "************",
                        myctroller: _passwordConfirmController,
                        myvalidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Filed cannot be empty";
                          } else if (value.length < 6) {
                            return "Password too short";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          bool isConnected = await Network.isAvailable();

                          if (isConnected) {
                            if (_formKey.currentState!.validate()) {
                              String fname = _fnameController.text.trim();
                              String lname = _lnameController.text.trim();
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();
                              String username = _usernameController.text.trim();
                              String confirmPassword =
                                  _passwordConfirmController.text.trim();
                              if (password == confirmPassword) {
                                try {
                                  String result = await authController.register(
                                      fname,
                                      lname,
                                      email,
                                      username,
                                      password,
                                      country,
                                      iso_code);
                                  // Print the result
                                  if (result == "1") {
                                    showCustomToast(context, result,
                                        color: Colors.grey);
                                    const Duration(seconds: 2);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                    );
                                  } else {
                                    showCustomToast(context, result,
                                        color: Colors.grey);
                                  }
                                  // Navigate to the dashboard or perform other actions on successful login
                                } catch (e) {
                                  showCustomToast(context, "result",
                                      color: Colors.green);
                                  print("Error: $e");
                                  // Handle login failure, e.g., show an error message
                                }
                              } else {
                                showCustomToast(context, "Password not match!",
                                    color: Colors.red);
                              }
                            }
                          } else {
                            showCustomToast(context, "No connection",
                                color: Colors.red);
                          }
                        },
                        color: const Color(0xff0095FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Already have an account?"),
                          InkWell(
                            onTap: () {
                              _onInkWellTapped(context);
                            },
                            child: const Text(
                              " Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // retryget Location
  void _getLocationWithRetry() async {
    // Call _getLocation and retry if permission is denied
    while (true) {
      await _getLocation();
      if (await Geolocator.checkPermission() != LocationPermission.denied) {
        // Break out of the loop if permission is not denied
        break;
      }
      // Delay before retrying (to avoid continuous loops)
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // get location

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Only request permission if no other permission request is ongoing
        if (!(await Geolocator.isLocationServiceEnabled())) {
          // Location services are disabled, handle accordingly
          print('Location services are disabled');
          return;
        }

        // Request location permission
        permission = await Geolocator.requestPermission();

        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // User denied location permission, handle accordingly
          print('User denied location permission');
          setState(() {
            _clearCacheAndNavigateToLogin(context);
          });
          return;
        }
      }

      // Permission granted, get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _latitude = _currentPosition.latitude;
        _longtitude = _currentPosition.longitude;

        placemarkFromCoordinates(_latitude!, _longtitude!).then((placemarks) {
          if (placemarks.isNotEmpty) {
            Placemark firstPlacemark = placemarks[0];
            country = firstPlacemark.country ?? "Unknown";
            iso_code = firstPlacemark.isoCountryCode ?? "Unknown Iso";
            print(country);
          }
        });

        print(_latitude);
      });

      // Save location data to preferences (if needed)
      // ...

      // Continue with the rest of your location handling code
    } catch (e) {
      print('Error getting location: $e');
      // Handle the error as needed, e.g., show an error message to the user
    }
  }

  Future<void> _clearCacheAndNavigateToLogin(BuildContext context) async {
    // Clear shared preferences or perform any other necessary cleanup
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset any state or variables as needed
    // ...

    // Navigate back to the login screen
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}

// we will be creating a widget for text field
Widget inputFile(
    {label,
    obscureText = false,
    myhint,
    String? Function(String?)? myvalidator,
    autofocus = false,
    myctroller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(
        height: 5,
      ),
      TextFormField(
        controller: myctroller,
        autofocus: autofocus,
        validator: myvalidator,
        obscureText: obscureText,
        decoration: InputDecoration(
            hintText: myhint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey))),
      ),
      const SizedBox(
        height: 15,
      )
    ],
  );
}
