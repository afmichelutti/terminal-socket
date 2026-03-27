import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/providers/company_provider.dart';
import 'package:shop_blink/ui/components/company_card.dart';

class CompaniesList extends StatelessWidget {
  const CompaniesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final companies = Provider.of<CompanyProvider>(context).companies;
    return (companies.isNotEmpty)
        ? ListView.builder(
          shrinkWrap: true,
          itemCount: companies.length,
          itemBuilder:
              (context, index) => CompanyCard(company: companies[index]),
        )
        : const Center(child: Text('Não há lojas configuradas para conexão'));
  }
}
