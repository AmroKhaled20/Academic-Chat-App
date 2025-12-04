import 'package:ak_chat_app/pages/chat_page.dart';
import 'package:ak_chat_app/pages/signUp_page.dart';
import 'package:ak_chat_app/widgets/constans.dart';
import 'package:ak_chat_app/widgets/custom_button_widget.dart';
import 'package:ak_chat_app/widgets/custom_textfeild_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  static String id = 'Login page';

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? password;
  String? email;
  String? emailerror;
  String? passworderror;
  bool isloading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kPraimaryColor,
        body: ModalProgressHUD(
          inAsyncCall: isloading,
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
                      ),
                    ),
                    SizedBox(height: 100),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          CustomTextfeildWidget(
                            onchanged: (data) {
                              email = data;
                            },
                            errorText: emailerror,
                            hintText: 'Email',
                            icon: Icons.email,
                            textController: emailController,
                          ),
                          SizedBox(height: 10),
                          CustomTextfeildWidget(
                            onchanged: (data) {
                              password = data;
                            },
                            errorText: passworderror,
                            obsecure: true,
                            hintText: 'Password',
                            icon: Icons.password,
                            textController: passwordController,
                          ),
                          SizedBox(height: 25),
                          CustomButtonWidget(
                            buttonText: 'Sign In',
                            onTap: () async {
                              setState(() {
                                emailerror = null;
                                passworderror = null;
                              });

                              // validation
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
                              //-------------------------------------------------------------------------------------------------
                              try {
                                setState(() {
                                  isloading = true;
                                });
                                email = email!.toLowerCase().trim();

                                await signIn_user();
                                final user = FirebaseAuth.instance.currentUser;
                                var userDoc =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user!.uid)
                                        .get();

                                String userName =
                                    userDoc.data()?['userName'] ??
                                    'Unknown User';

                                String color =
                                    userDoc.data()?['color'] ?? '0xffFFFFFF';
                                
                                String argumentID = user.uid;


                                if (!mounted) return;
                                Navigator.pushReplacementNamed(
                                  context,
                                  ChatPage.id,
                                  arguments: {
                                    'email': email,
                                    'userName': userName,
                                    'color': color,
                                    'argumentID':argumentID
                                  },
                                );
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  if (e.code == 'invalid-email') {
                                    emailerror = 'Invalid email format.';
                                  } else if (e.code == 'user-not-found') {
                                    emailerror =
                                        'No account found with this email';
                                  } else if (e.code == 'wrong-password') {
                                    passworderror =
                                        'Wrong password provided for that user.';
                                  }
                                });
                              } catch (e) {
                                print(e.toString());
                                if (!mounted) return;
                              
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Sign In failed, please try again.",
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
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(5),
                                  minimumSize: Size(0, 0),
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      SignupPage.id,
                                    ),
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 123, 196, 255),
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

  Future<void> signIn_user() async {
    
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!);
  }
}
