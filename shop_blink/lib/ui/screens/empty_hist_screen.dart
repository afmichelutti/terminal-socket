import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class EmptyHistScreen extends StatefulWidget {
  const EmptyHistScreen({Key? key}) : super(key: key);

  @override
  _EmptyHistScreenState createState() => _EmptyHistScreenState();
}

class _EmptyHistScreenState extends State<EmptyHistScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text('Histórico vazio', style: boldTextStyle(size: 20)),
            16.height,
            Text(
              'Não há ainda nenhum compra realizada para mostrar no histórico. Faça a primeira compra!',
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
                child:
                    Image.asset('assets/images/empty_screens/emptyCart2.png')),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
