import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/models/requests/login_requests.dart';
import 'package:storyapp/provider/login_provider.dart';
import 'package:storyapp/utils/helper.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/widget/snackbar_custom.dart';
import 'package:validators/validators.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSucces;
  final VoidCallback onRegisterClicked;

  const LoginPage({
    super.key,
    required this.onLoginSucces,
    required this.onRegisterClicked,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  "assets/login.png",
                  width: 200,
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Login",
                style: TextStyle(fontSize: 28),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        cursorColor: const Color(0xff32323C),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: AppLocalizations.of(context)!.fieldEmail,
                          labelStyle: const TextStyle(
                            color: Color(0xffBDBDBD),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xff32323C),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xffBDBDBD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText:
                              AppLocalizations.of(context)!.fieldPassword,
                          labelStyle: const TextStyle(
                            color: Color(0xffBDBDBD),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xff32323C),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xffBDBDBD),
                            ),
                          ),
                        ),
                        cursorColor: const Color(0xff32323C),
                        keyboardType: TextInputType.visiblePassword,
                        validator: validatePassword,
                      )
                    ],
                  ),
                ),
              ),
              Consumer<LoginProvider>(
                builder: (context, provider, _) {
                  _handleLoginState(provider);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton(
                      isLoading: (provider.loginState == ResultState.loading),
                      onPressed: () => _onLoginPressed(provider),
                      text: "Login",
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have a account?",
                    style: TextStyle(
                        color: Color.fromARGB(237, 146, 143, 143),
                        fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: widget.onRegisterClicked,
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                        color: Colors.orangeAccent,
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

  _onLoginPressed(LoginProvider provider) {
    if (_formKey.currentState?.validate() == true) {
      provider.login(_getLoginRequest());
    }
  }

  _handleLoginState(LoginProvider provider) {
    switch (provider.loginState) {
      case ResultState.hasData:
        afterBuild(widget.onLoginSucces);
        showCustomSnackbar(context, provider.loginMessage);
        break;
      case ResultState.noData:
        showCustomSnackbar(context, provider.loginMessage);
        break;
      case ResultState.error:
        break;
      default:
        break;
    }
  }

  _getLoginRequest() => LoginRequest(
        email: _emailController.text,
        password: _passwordController.text,
      );

  String? validateEmail(String? value) =>
      isEmail(value.toString()) ? "Invalid email fromat" : null;

  String? validatePassword(String? value) => (value!.length < 8)
      ? "Password must contains minimum 8 characters"
      : null;
}
