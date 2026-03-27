import 'package:flutter/material.dart';
import 'package:shop_blink/models/category.dart';
import 'package:shop_blink/ui/components/category_card.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder:
            (context, i) => CategoryCard(
              title: demoCategories[i].title,
              icon: demoCategories[i].icon,
              onPressed: () {},
            ),
        itemCount: demoCategories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
      ),
    );
  }
}
