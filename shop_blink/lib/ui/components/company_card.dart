import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shop_blink/models/company.dart';
import 'package:shop_blink/providers/company_provider.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({Key? key, required this.company}) : super(key: key);
  final Company company;
  @override
  Widget build(BuildContext context) {
    debugPrint(company.toString());
    return Card(
      elevation: !company.selected ? 6 : 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurple.withAlpha(30),
        onTap: () {
          Provider.of<CompanyProvider>(
            context,
            listen: false,
          ).selectCompany(company.id);
        },
        child: Column(
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      company.name.capitalizeFirstLetter(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color:
                            !company.selected
                                ? Colors.deepPurple
                                : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    company.cnpj,
                    style: TextStyle(
                      color:
                          !company.selected ? Colors.deepPurple : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    company.fantasy.capitalizeFirstLetter(),
                    style: TextStyle(
                      color:
                          !company.selected ? Colors.deepPurple : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    company.id.toString(),
                    style: TextStyle(
                      color:
                          !company.selected ? Colors.deepPurple : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
