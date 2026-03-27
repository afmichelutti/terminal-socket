import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/salesman.dart';
import 'package:shop_blink/providers/salesman_provider.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/screens/home_screen.dart';
import 'package:shop_blink/ui/widgets/custom_loading.dart';
import 'package:nb_utils/nb_utils.dart';

class SalesmansScreen extends StatefulWidget {
  const SalesmansScreen({Key? key}) : super(key: key);
  static const routeName = '/salesman_screen';

  @override
  State<SalesmansScreen> createState() => _SalesmansScreenState();
}

class _SalesmansScreenState extends State<SalesmansScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesmanProvider>(context, listen: false).getSalesmans();
    });
    super.initState();
  }

  void _selectSalesman(Salesman salesman) {
    Provider.of<SalesmanProvider>(context, listen: false).selectedSalesman =
        salesman;
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final salesmans =
        Provider.of<SalesmanProvider>(context, listen: false).salesmans;
    final _isLoading = Provider.of<SalesmanProvider>(context).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendedores'),
        backgroundColor: Colors.deepPurple.withOpacity(0.4),
      ),
      body:
          (_isLoading)
              ? const CustomLoading(title: 'Carregando vendedores...')
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 26,
                    bottom: 10,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    children: [
                      const SectionTitle(title: 'Selecione um(a) Vendedor(a)'),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: salesmans.length,
                          itemBuilder:
                              (ctx, i) => InkWell(
                                onTap: () => _selectSalesman(salesmans[i]),
                                child: Card(
                                  elevation: 2,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      // dense: true,
                                      title: Text(
                                        salesmans[i].nome
                                            .capitalizeFirstLetter(),
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      subtitle: Text(
                                        salesmans[i].id.toString(),
                                        style: TextStyle(
                                          color: Colors.deepPurple.withOpacity(
                                            0.8,
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.deepPurple,
                                        ),
                                        onPressed: () {
                                          _selectSalesman(salesmans[i]);
                                        },
                                      ),
                                    ),
                                  ),
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
