import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/language_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget({Key? key, required this.languageModel, required this.localizationController, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        localizationController.setLanguage(Locale(
          AppConstants.languages[index].languageCode!,
          AppConstants.languages[index].countryCode,
        ));
        localizationController.setSelectIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Stack(children: [

          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 65, width: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 1),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  languageModel.imageUrl!, width: 36, height: 36,
                  color: languageModel.languageCode == 'en' || languageModel.languageCode == 'ar'
                      || languageModel.languageCode == 'es' || languageModel.languageCode == 'bn'
                      ? Theme.of(context).textTheme.bodyLarge!.color : null,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(languageModel.languageName!, style: robotoRegular),
            ]),
          ),

          localizationController.selectedIndex == index ? Positioned(
            top: 0, right: 0,
            child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 25),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}
