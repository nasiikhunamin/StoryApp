import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/models/requests/register_requests.dart';
import 'package:storyapp/provider/register_provider.dart';
import 'package:storyapp/utils/form_validator.dart';
import 'package:storyapp/utils/helper.dart';
import 'package:storyapp/utils/result_state.dart';
import 'package:storyapp/widget/costume_button.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onRegister;
  const RegisterPage({
    super.key,
    required this.onRegister,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    "assets/register_logo.png",
                    width: 200,
                  ),
                ),
                const SizedBox(height: 15),
                const Text("Register"),
                const SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        cursorColor: const Color(0xff32323C),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Nama",
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
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        cursorColor: const Color(0xff32323C),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Email",
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
                          labelText: "Password",
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Consumer<RegisterProvider>(
                  builder: (context, provider, _) {
                    _handleRegister(provider);
                    return CustomButton(
                      isLoading: provider.registerState == ResultState.loading,
                      onPressed: () => _onRegisterClicked(provider),
                      text: "Register",
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onRegisterClicked(RegisterProvider registerProvider) {
    if (_formKey.currentState?.validate() == true) {
      registerProvider.register(_getRegisterRequest());
    }
  }

  _handleRegister(RegisterProvider registerProvider) {
    switch (registerProvider.registerState) {
      case ResultState.hasData:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  registerProvider.registerMessage,
                ),
              ),
            );
          },
        );
        afterBuild(() => widget.onRegister());
        break;
      case ResultState.noData:
      case ResultState.error:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(registerProvider.registerMessage),
              ),
            );
          },
        );
        break;
      default:
        break;
    }
  }

  _getRegisterRequest() => RegisterRequest(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
}
