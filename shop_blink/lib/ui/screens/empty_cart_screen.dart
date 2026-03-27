import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class EmptyCartScreen extends StatefulWidget {
  const EmptyCartScreen({Key? key}) : super(key: key);

  @override
  _EmptyCartScreenState createState() => _EmptyCartScreenState();
}

class _EmptyCartScreenState extends State<EmptyCartScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Carrinho Vazio', style: boldTextStyle(size: 20)),
          16.height,
          Text(
            'Vamos fazer o pedido indo à pagina inicial e pesquisando o produto desejado',
            style: primaryTextStyle(size: 15),
            textAlign: TextAlign.center,
          ).paddingSymmetric(vertical: 8, horizontal: 60),
          const Spacer(),
          // AppButton(
          //   shapeBorder: RoundedRectangleBorder(borderRadius: radius(30)),
          //   color: const Color(0xFF2D3E5E),
          //   onTap: () {},
          //   child: Text('Start Shop', style: boldTextStyle(color: white))
          //       .paddingSymmetric(horizontal: 32),
          // ),
          60.height,
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset('assets/images/empty_screens/emptyCart4.png')),
          const Spacer(),
        ],
      ),
    );
  }
}
