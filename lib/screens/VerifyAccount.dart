// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';


class VerifyAccount extends StatefulWidget {
   Widget? test;
   VerifyAccount({super.key,required this.test});
  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  TextEditingController passcode = TextEditingController();
  @override
  void initState() {
    passcode.text = "";
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              height: 400,
              width: double.infinity,
              color: const Color(0xFF0D99FF),
              child: const Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage('lib/assets/images/logo.jpg'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Flexible(
              flex: 1,
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Account',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Enter your passcode that send to your phone number.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your passcode.';
                            }
                            return null;
                          },
                          controller: passcode,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: "Passcode",
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _formKey.currentState!.validate();
                            // if (_formKey.currentState!.validate()) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text('Processing Data.'),
                            //     ),
                            //   );
                            // }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => widget.test!,));
                          },
                          child: const SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Confirm",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
