import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/ui/components/already_have_an_account_acheck.dart';
import 'package:shop_blink/ui/components/rounded_button.dart';
import 'package:shop_blink/ui/screens/Login/login_screen.dart';
import 'package:shop_blink/ui/screens/login/components/background.dart';
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
  TextEditingController usernameController = TextEditingController();

  void validateForm() {
    if (formKey.currentState!.validate()) {
      Provider.of<AuthProvider>(context, listen: false).register(
        context,
        usernameController.text,
        emailController.text,
        passwordController.text,
      );
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
              padding: EdgeInsets.only(top: 25),
              child: Text(
                "CADASTRO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: 'Seu nome',
                      onChanged: (String value) {
                        usernameController.text = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe um nome';
                        }
                        if (value.length < 3) {
                          return 'Nome deverá ter ao menos 3 caracteres';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: kPrimaryColor,
                      ),
                    ),
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
                          return 'Senha deverá ter 8 ou mais caracteres com ao menos um caracter especial';
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
              text: "Cadastrar e Entrar",
              press: () {
                validateForm();
              },
              color: kPrimaryColor,
              textColor: Colors.white,
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return const LoginScreen();
                //     },
                //   ),
                // );
              },
            ),
            // const OrDivider(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     SocalIcon(
            //       iconSrc: "assets/icons/facebook.svg",
            //       press: () {},
            //     ),
            //     SocalIcon(
            //       iconSrc: "assets/icons/twitter.svg",
            //       press: () {},
            //     ),
            //     SocalIcon(
            //       iconSrc: "assets/icons/google-plus.svg",
            //       press: () {},
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
