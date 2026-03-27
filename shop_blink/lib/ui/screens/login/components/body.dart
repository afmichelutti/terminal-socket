import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/ui/components/already_have_an_account_acheck.dart';
import 'package:shop_blink/ui/components/rounded_button.dart';
import 'package:shop_blink/ui/screens/Signup/signup_screen.dart';
import 'package:shop_blink/ui/screens/config_token_screen.dart';
import 'package:shop_blink/ui/screens/salesmans_screens.dart';
import 'package:shop_blink/ui/screens/wellcome/components/background.dart';
import 'package:shop_blink/ui/widgets/custom_pass_text_field.dart';
import 'package:shop_blink/ui/widgets/custom_text_field.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loginOk = false;

  void validateForm() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        context,
        emailController.text,
        passwordController.text,
      );
      if (authProvider.authStatus == AuthStatus.authenticated) {
        if (authProvider.validToken.isEmpty) {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              ConfigTokenScreen.routeName,
            );
          }
          return;
        }
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            SalesmansScreen.routeName,
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: 'Seu e-mail',
                      onChanged: (String value) {
                        emailController.text = value;
                      },
                      validator: (value) {
                        if (!EmailValidator.validate(value ?? '')) {
                          return 'E-mail não é válido';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                    CustomPassTextField(
                      onChanged: (String value) {
                        passwordController.text = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe uma senha';
                        }
                        if (value.length < 8) {
                          return 'Senha deverá ter 6 ou mais caracteres';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: kPrimaryColor,
                      ),
                      hintText: 'Sua senha',
                    ),
                  ],
                ),
              ),
            ),
            RoundedButton(
              text: "Entrar",
              press: () {
                validateForm();
              },
              color: kPrimaryColor,
              textColor: Colors.white,
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: true,
              press: () {
                Navigator.pushReplacementNamed(context, SignUpScreen.routeName);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return const SignUpScreen();
                //     },
                //   ),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
