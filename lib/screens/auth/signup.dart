import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:cipher_schools_assignment/main.dart';
import 'package:cipher_schools_assignment/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import '../../helpers/services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool termsCheckValue = false;
  bool _isLoading = false;

  Future<void> _signUpWithEmail() async {
    if (!termsCheckValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, MyApp.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: kRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Sign Up', style: TextStyle(color: kDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.0,
              ),
              CustomTextField(
                controller: nameController,
                hintText: 'Full name',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(
                height: 12.0,
              ),
              CustomTextField(
                controller: emailController,
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 12.0,
              ),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                isObscure: true,
              ),
              SizedBox(
                height: 12.0,
              ),
              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm password',
                isObscure: true,
                isLast: true,
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: termsCheckValue,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      side: BorderSide(color: kPrimaryColor, width: 1.5),
                      activeColor: kPrimaryColor,
                      onChanged: (newValue) {
                        setState(() {
                          termsCheckValue = newValue!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'By signing up, you agree to the ',
                        style: TextStyle(fontSize: 14.0, color: kDark, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'Terms of Service and Privacy Policy',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 60.0,
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : _signUpWithEmail,
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 15.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 0.8,
                      color: kGrey,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Center(
                    child: Text(
                      'Or',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: kGrey,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      height: 0.8,
                      color: kGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              GoogleSignInButton(),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, MyApp.loginRoute),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: kDark,
                      ),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
