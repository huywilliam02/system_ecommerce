import 'package:citgroupvn_ecommerce/data/model/response/language_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:flutter/material.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({BuildContext? context}) {
    return AppConstants.languages;
  }
}
