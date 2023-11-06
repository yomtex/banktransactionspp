// ignore_for_file: avoid_print

import 'package:bankapp/utils/transactions.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final String username;
  const Dashboard({super.key, required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // form  controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  List<Transaction> transactionData = [
    Transaction("Transfer to user202", "Description 1", 230.0, "dr"),
    Transaction("Received from user201", "Description 2", 150.0, "cr"),
    Transaction("Transfer to user202", "Description 1", 230.0, "dr"),
    Transaction("Received from user201", "Description 2", 150.0, "cr"),
    // Add more transactions as needed
  ];

  String? username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
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
              widget.username,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {},
              child: const Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {},
              child: const Icon(Icons.person_2_rounded),
            ),
            label: 'Profile',
          ),
          // Add more items as needed
        ],
        onTap: (int index) {
          // Handle item selection here
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            mycard(width: MediaQuery.of(context).size.width),
            const SizedBox(
              height: 15,
            ),
            sendMoney(
                hint: "Enter username",
                formkey: _formKey,
                usernameController: _usernameController),
            const SizedBox(
              height: 15,
            ),
            recentTransaction(transactionData)
          ],
        ),
      ),
    );
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
Widget sendMoney({hint, formkey, usernameController}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Form(
      key: formkey,
      child: Column(
        children: [
          TextField(
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
                // borderRadius: BorderRadius.circular(
                //     20), // Set circular border radius here
              ),
              border: const OutlineInputBorder(
                // borderRadius: BorderRadius.circular(
                //     20), // Set circular border radius here
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {},
                  child: sendOrRequestBtn(
                      cap: "Send", btncolor: Colors.blue[900])),
              InkWell(
                  onTap: () {},
                  child: sendOrRequestBtn(
                      cap: "Request", btncolor: Colors.blueAccent)),
            ],
          )
        ],
      ),
    ),
  );
}

// Send button Widget
Widget sendOrRequestBtn({cap, btncolor}) {
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
Widget mycard({width}) {
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
                text(caption: "\$130,000", size: 15.0, color: Colors.white),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                text(
                    caption: "Transaction history",
                    size: 13.0,
                    color: Colors.white),
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
                        text(caption: "Add money", size: 13.0)
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
