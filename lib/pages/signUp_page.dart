import 'package:ak_chat_app/helpers/get_userColor_helper.dart';
import 'package:ak_chat_app/pages/chat_page.dart';
import 'package:ak_chat_app/widgets/constans.dart';
import 'package:ak_chat_app/widgets/custom_button_widget.dart';
import 'package:ak_chat_app/widgets/custom_textfeild_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  static String id = 'Register page';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? email;
  String? password;
  String? userName;
  String? userNameError;
  String? emailerror;
  String? passworderror;
  String? color;
  String? uid;

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kPraimaryColor,
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0.4,
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            strokeWidth: 5,
          ),
          blur: 2,
          dismissible: false,
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    SizedBox(height: 70),
                    Image.asset('assets/images/scholar.png', scale: 0.6),

                    Text(
                      'Academic Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 37,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        // fontFamily: 'Pacifico',
                      ),
                    ),

                    SizedBox(height: 70),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          CustomTextfeildWidget(
                            hintText: 'Username',
                            errorText: userNameError,
                            onchanged: (data) {
                              userName = data;
                            },
                            icon: Icons.person,
                          ),
                          SizedBox(height: 10),

                          CustomTextfeildWidget(
                            errorText: emailerror,
                            onchanged: (data) {
                              email = data;
                            },
                            hintText: 'Email',
                            icon: Icons.email,
                          ),

                          SizedBox(height: 10),

                          CustomTextfeildWidget(
                            obsecure: true,
                            errorText: passworderror,
                            onchanged: (data) {
                              password = data;
                            },
                            hintText: 'Password',
                            icon: Icons.password,
                          ),

                          SizedBox(height: 25),

                          CustomButtonWidget(
                            buttonText: 'Register',
                            onTap: () async {
                              setState(() {
                                emailerror = null;
                                passworderror = null;
                                userNameError = null;
                              });

                              //validation
                              if (userName == null || userName!.isEmpty) {
                                setState(() {
                                  userNameError = 'Please enter your name';
                                });
                                return;
                              }
                              if (email == null || email!.isEmpty) {
                                setState(() {
                                  emailerror = 'Please enter your email';
                                });
                                return;
                              }
                              if (password == null || password!.isEmpty) {
                                setState(() {
                                  passworderror = 'Please enter your password';
                                });
                                return;
                              }
                              //---------------------------------------------------------------------------------------------------
                              try {
                                setState(() {
                                  isLoading = true;
                                });

                                email = email!.toLowerCase().trim();

                                await userRegister();

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Registration Successful!",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(10),
                                    duration: const Duration(seconds: 3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );

                                Navigator.pushReplacementNamed(
                                  context,
                                  ChatPage.id,
                                  arguments: {
                                    'email': email,
                                    'userName': userName,
                                    'color': color,
                                    'argumentID': uid,
                                  },
                                );
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  if (e.code == 'weak-password') {
                                    passworderror =
                                        'The password provided is too weak.';
                                  } else if (e.code == 'email-already-in-use') {
                                    emailerror =
                                        'The account already exists for that email.';
                                  } else if (e.code == 'invalid-email') {
                                    emailerror = 'Invalid email format.';
                                  }
                                });
                              } catch (e) {
                                print(e.toString());
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Registration failed, please try again.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                    margin: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(5),
                                  minimumSize: Size(0, 0),
                                ),
                                onPressed: () => Navigator.pop(context),

                                child: Text(
                                  "Login",

                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      123,
                                      196,
                                      255,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> userRegister() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    uid = userCredential.user!.uid;
    color = await getColor(colors) as String;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'userName': userName,
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
