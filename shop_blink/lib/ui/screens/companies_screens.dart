import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/company.dart';
import 'package:shop_blink/providers/company_provider.dart';
import 'package:shop_blink/services/local_storage.dart';
import 'package:shop_blink/ui/components/section_title.dart';
import 'package:shop_blink/ui/screens/salesmans_screens.dart';
import 'package:shop_blink/ui/widgets/custom_loading.dart';
import 'package:nb_utils/nb_utils.dart';

class CompaniesScreens extends StatefulWidget {
  const CompaniesScreens({Key? key}) : super(key: key);
  static const routeName = '/companies_screen';

  @override
  State<CompaniesScreens> createState() => _CompaniesScreensState();
}

class _CompaniesScreensState extends State<CompaniesScreens> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProvider>(
        context,
        listen: false,
      ).getCompanies(LocalStorage.prefs.getString('token_server') ?? '');
    });
    super.initState();
  }

  void _selectCompany(Company company) {
    LocalStorage.prefs.setInt('company', company.id);
    Navigator.of(context).pushNamedAndRemoveUntil(
      SalesmansScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final companies =
        Provider.of<CompanyProvider>(context, listen: false).companies;
    final _isLoading = Provider.of<CompanyProvider>(context).isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.4),
        title: const Text('Lojas'),
      ),
      body:
          (_isLoading)
              ? const CustomLoading(title: 'Carregando Lojas...')
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
                      const SectionTitle(title: 'Selecione a loja de operação'),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: companies.length,
                          itemBuilder:
                              (ctx, i) => InkWell(
                                onTap: () => _selectCompany(companies[i]),
                                child: Card(
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
                                        companies[i].name
                                            .capitalizeFirstLetter(),
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            companies[i].cnpj,
                                            style: const TextStyle(
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          const Spacer(),
                                          Expanded(
                                            child: Text(
                                              companies[i].fantasy
                                                  .capitalizeFirstLetter(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.deepPurple,
                                        ),
                                        onPressed:
                                            () => _selectCompany(companies[i]),
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
