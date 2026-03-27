import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/constants.dart';
import 'package:shop_blink/providers/product_provider.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({Key? key}) : super(key: key);

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  validate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_search.text.trim().length == 13) {
        Provider.of<ProductProvider>(
          context,
          listen: false,
        ).searchCodBarr(_search.text.trim());
        _search.text = '';
        _formKey.currentState!.reset();
        hideKeyboard(context);
        return;
      }
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).searchProducts(_search.text.trim());
      _search.text = '';
      _formKey.currentState!.reset();
      hideKeyboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        onFieldSubmitted: (value) {
          if (value.trim().length == 13) {
            validate();
          }
        },
        style: const TextStyle(color: Colors.black),
        autofocus: true,
        // keyboardType: TextInputType.text,
        validator: (s) {
          if (s!.trim().isEmpty) {
            return 'Informar um valor para pesquisa';
          }
          if (s.trim().length < 3) {
            return 'A pesquisa deverá ter ao menos 3 letras';
          }
          return null;
        },
        controller: _search,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Pesquisar...',
          border: outlineInputBorder,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset('assets/icons/Search.svg'),
          ),
          suffixIcon: SizedBox(
            height: 48,
            width: 48,
            child: ElevatedButton(
              onPressed: () {
                validate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(defaultBorderRadius),
                  ),
                ),
              ),
              child: SvgPicture.asset('assets/icons/Filter.svg'),
            ),
          ),
        ),
        // decoration: InputDecoration(
        //   hintText: 'Pesquisar...',
        //   filled: true,
        //   fillColor: Colors.white,
        //   border: outlineInputBorder,
        //   // enabledBorder: outlineInputBorder,
        //   // focusedBorder: outlineInputBorder,
        //   prefixIcon: Padding(
        //     padding: const EdgeInsets.all(12.0),
        //     child: SvgPicture.asset('assets/icons/Search.svg'),
        //   ),
        //   suffixIcon: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         SizedBox(
        //           height: 48,
        //           width: 48,
        //           child: ElevatedButton(
        //             onPressed: () {
        //               validate();
        //             },
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: primaryColor,
        //               shape: const RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.all(
        //                   Radius.circular(defaultBorderRadius),
        //                 ),
        //               ),
        //             ),
        //             child: SvgPicture.asset('assets/icons/Filter.svg'),
        //           ),
        //         ),
        //         const SizedBox(width: 4),
        //         SizedBox(
        //           height: 48,
        //           width: 48,
        //           child: ElevatedButton(
        //               onPressed: () {
        //                 Navigator.of(context).pushNamed(ScannerPage.routeName);
        //               },
        //               style: ElevatedButton.styleFrom(
        //                 backgroundColor: primaryColor,
        //                 shape: const RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.all(
        //                     Radius.circular(defaultBorderRadius),
        //                   ),
        //                 ),
        //               ),
        //               child: const Icon(Icons.barcode_reader,
        //                   color: Colors.white)),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
