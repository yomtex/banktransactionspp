// ignore_for_file: avoid_print

import 'package:bankapp/models/auth.dart';
import 'package:bankapp/pages/add_money.dart';
import 'package:bankapp/pages/login.dart';
import 'package:bankapp/utils/transactions.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mypages.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // form  controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isShow = false;
  bool _isBtnVisible = true;
  String msg = "";
  Map mapResponse = {};
  bool isNull = false;
  bool _pageLoading = true;

  //Getting current user details
  Future<void> getData() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString("oops_token");

      if (token == null) {
        failedToAuth();
        return;
      }

      final endpoint = "user";
      final url = Uri.parse('${AuthController.baseUrl}$endpoint');

      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 401) {
        // User logged out or session expired
        sharedPreferences.remove("oops_token");
        failedToAuth();
        return;
      }

      setState(() {
        _pageLoading = false;
      });

      final data = json.decode(response.body)["data"];

      if (mapResponse != null) {
        setState(() {
          mapResponse = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("No connection");
    }
  }

// Once it fails to authenticate
  void failedToAuth() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  List<Transaction> transactionData = [
    Transaction("Transfer to user202", "Nov 10th, 12:28:40 ", 230.0, "dr"),
    Transaction("Received from user201", "Nov 11th, 14:28:40 ", 150.0, "cr"),
    Transaction("Transfer to user202", "Nov 12th, 15:28:40 ", 230.0, "dr"),
    Transaction("Received from user201", "Nov 1th, 18:28:40 ", 150.0, "cr"),
    // Add more transactions as needed
  ];

  String? username;
  @override
  Widget build(BuildContext context) {
    return _pageLoading
        ? Builder(builder: (context) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              )),
            );
          })
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              // leading: null,
              title: Row(
                children: [
                  const Text(
                    "Hello, ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    mapResponse["firstname"].toString(),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  mycard(
                    width: MediaQuery.of(context).size.width,
                    context: context,
                    balance: mapResponse["wallet_balance"].toString(),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  sendMoneyWidget(
                    hint: "Enter username",
                    formkey: _formKey,
                    usernameController: _usernameController,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5),
                      child: _isShow
                          ? text(caption: msg, color: Colors.red)
                          : const Text(""),
                    ),
                  ),
                  _isLoading
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          width: MediaQuery.of(context).size.width,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[
                                400], // Background color for the circular avatar
                            radius: 25, // Adjust the radius as needed
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors
                                  .white), // Color for the progress indicator
                              strokeWidth:
                                  2, // Adjust the thickness of the indicator
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: _isBtnVisible,
                              child: InkWell(
                                onTap: () {
                                  var uname = _usernameController.text;
                                  // Regular expression to match letters only
                                  final RegExp lettersAndNumbers =
                                      RegExp(r"^[a-zA-Z]+[0-9]*$");
                                  if (uname.isEmpty) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Username cannot be empty!!";
                                    });
                                  }
                                  // Check if the value starts with a number
                                  else if (int.tryParse(uname[0]) != null) {
                                    setState(() {
                                      _isShow = true;
                                      msg =
                                          "Username cannot start with a number";
                                    });
                                  }
                                  // Check if the value contains special characters
                                  else if (!lettersAndNumbers.hasMatch(uname)) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Username can only contain letters";
                                    });
                                  }
                                  // Check if the value is less than 6
                                  else if (uname.length < 6) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Enter a valid Username";
                                    });
                                  } else {
                                    setState(() {
                                      _isBtnVisible = false;
                                      _isLoading = true;
                                      _isShow = false;
                                    });
                                    sendOrRequest(uname, "Send");
                                  }
                                },
                                child: _isLoading
                                    ? const CircleAvatar(
                                        backgroundColor: Colors
                                            .blue, // Background color for the circular avatar
                                        radius:
                                            25, // Adjust the radius as needed
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors
                                                  .white), // Color for the progress indicator
                                          strokeWidth:
                                              2, // Adjust the thickness of the indicator
                                        ),
                                      )
                                    : sendOrRequestBtnWidget(
                                        cap: "Send",
                                        btncolor: Colors.blue[900]),
                              ),
                            ),
                            Visibility(
                              visible: _isBtnVisible,
                              child: InkWell(
                                onTap: () {
                                  var uname = _usernameController.text;
                                  // Regular expression to match letters only
                                  final RegExp lettersAndNumbers =
                                      RegExp(r"^[a-zA-Z]+[0-9]*$");
                                  if (uname.isEmpty) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Username cannot be empty!!";
                                    });
                                  }
                                  // Check if the value starts with a number
                                  else if (int.tryParse(uname[0]) != null) {
                                    setState(() {
                                      _isShow = true;
                                      msg =
                                          "Username cannot start with a number";
                                    });
                                  }
                                  // Check if the value contains special characters
                                  else if (!lettersAndNumbers.hasMatch(uname)) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Username can only contain letters";
                                    });
                                  }
                                  // Check if the value is less than 6
                                  else if (uname.length < 6) {
                                    setState(() {
                                      _isShow = true;
                                      msg = "Enter a valid Username";
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                      _isShow = false;
                                    });
                                    sendOrRequest(uname, "Request");
                                  }
                                },
                                child: _isLoading
                                    ? const CircleAvatar(
                                        backgroundColor: Colors
                                            .blue, // Background color for the circular avatar
                                        radius:
                                            25, // Adjust the radius as needed
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors
                                                  .white), // Color for the progress indicator
                                          strokeWidth:
                                              2, // Adjust the thickness of the indicator
                                        ),
                                      )
                                    : sendOrRequestBtnWidget(
                                        cap: "Request", btncolor: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 15,
                  ),
                  recentTransaction(transactionData)
                ],
              ),
            ),
          );
  }

  // Method to validate username
  sendOrRequest(username, transactionType) {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isShow = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SendOrRequest(
            transactionType: transactionType,
            username: username,
          ),
        ),
      );
    });
  }
}

// Recent Transaction Widget
Widget recentTransaction(List<Transaction> transactionData) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Recent Transactions", // Replace with your title
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: transactionData.length,
          itemBuilder: (context, index) {
            Transaction transaction = transactionData[index];

            String amountText;
            Color amountColor;

            if (transaction.transactionType == "dr") {
              amountText = '- \$${transaction.amount}';
              amountColor = Colors.red;
            } else if (transaction.transactionType == "cr") {
              amountText = '+ \$${transaction.amount}';
              amountColor = Colors.green;
            } else {
              // Handle other cases, if necessary
              amountText = '\$${transaction.amount}';
              amountColor = Colors.black; // Default color
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onTap: () {
                _showTransactionDetails(context, transaction);
              },
              leading: CircleAvatar(
                radius: 20,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Transform.rotate(
                    angle: -45 * 3.141592653589793 / 180,
                    child: transaction.transactionType == "cr"
                        ? Transform.rotate(
                            angle: 45 * 3.141592653589793 / 180,
                            child: const Icon(
                              Icons.person_2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              title: Text(
                transaction.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                transaction.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              trailing: Text(
                amountText,
                style: TextStyle(fontSize: 14, color: amountColor),
              ),
            );
          },
        )
      ],
    ),
  );
}

// show transaction information
// Function to show the transaction details in a modal bottom sheet
void _showTransactionDetails(BuildContext context, Transaction transaction) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Transaction Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Info: ${transaction.title}"),
            Text("Description: ${transaction.description}"),
            Text("Amount: \$${transaction.amount}"),
            Text("Transaction Type: ${transaction.transactionType}"),
            // Add more details as needed
          ],
        ),
      );
    },
  );
}

// Form Widget(send,request)
Widget sendMoneyWidget({hint, formkey, usernameController}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Form(
      key: formkey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: const Icon(
                Icons.person_3,
                color: Colors.blueAccent,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(
            height: 0,
          ),
        ],
      ),
    ),
  );
}

// Send and request button Widget
Widget sendOrRequestBtnWidget({cap, btncolor}) {
  return Container(
    margin: const EdgeInsets.all(20),
    decoration:
        BoxDecoration(borderRadius: BorderRadius.circular(10), color: btncolor),
    child: Padding(
      padding: const EdgeInsets.all(17.0),
      child: Row(
        children: [
          text(caption: cap, size: 15.0, color: Colors.white),
        ],
      ),
    ),
  );
}

// Text style widget
Widget text({color, size, fontweight, caption}) {
  return Text(
    "$caption",
    style: TextStyle(
        fontSize: size,
        fontWeight: fontweight,
        color: color,
        fontFamily: 'Roboto'),
  );
}

// Card Widget which hold the available balance, add money and transaction history
Widget mycard({width, context, balance}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 150,
      width: width,
      decoration: BoxDecoration(
          color: Colors.blueAccent, borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                    caption: "Available balance",
                    fontweight: FontWeight.bold,
                    size: 17.0,
                    color: Colors.white),
                const SizedBox(
                  height: 10,
                ),
                text(caption: "\$$balance", size: 15.0, color: Colors.white),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionHistory(),
                      ),
                    );
                  },
                  child: text(
                      caption: "Transaction history",
                      size: 13.0,
                      color: Colors.white),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          size: 13.0,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddMoney(),
                                ),
                              );
                            },
                            child: text(caption: "Add money", size: 13.0))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
