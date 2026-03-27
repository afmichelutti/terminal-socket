import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/auth_provider.dart';
import 'package:shop_blink/services/local_storage.dart';
import 'package:shop_blink/ui/screens/loading_screen.dart';

class TokenForm extends StatefulWidget {
  const TokenForm({Key? key}) : super(key: key);

  @override
  State<TokenForm> createState() => _TokenFormState();
}

class _TokenFormState extends State<TokenForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _token = TextEditingController();

  @override
  void initState() {
    _token.text = LocalStorage.prefs.getString('token_server') ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  validate(String token) {
    if (_formKey.currentState!.validate()) {
      LocalStorage.prefs.setString('token_socket', token);
      Provider.of<AuthProvider>(context, listen: false).getStatus();
      _formKey.currentState!.save();
      Navigator.of(context).pushReplacementNamed(LoadingScreen.routeName);
    }
    hideKeyboard(context);
  }

  @override
  Widget build(BuildContext context) {
    final _isLoading = Provider.of<AuthProvider>(context).isLoading;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        keyboardType: TextInputType.name,
        validator: (s) {
          if (s!.trim().isEmpty) {
            return 'Informar um valor para o token';
          }
          if (s.trim().length < 20) {
            return 'O token deverá ter ao menos 20 caracteres';
          }
          return null;
        },
        controller: _token,
        decoration: InputDecoration(
          hintText: 'token do servidor',
          filled: true,
          fillColor: Colors.white,
          border: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          prefixIcon: const Icon(Icons.key),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child:
                (!_isLoading)
                    ? SizedBox(
                      height: 48,
                      width: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          validate(_token.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          // primary: primaryColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(defaultBorderRadius),
                            ),
                          ),
                        ),
                        //child: SvgPicture.asset('assets/icons/Filter.svg'),
                        child: const Icon(
                          Icons.connect_without_contact_outlined,
                        ),
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 0.6,
                        ),
                      ),
                      height: 48,
                      width: 48,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
