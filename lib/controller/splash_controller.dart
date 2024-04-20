import 'package:citgroupvn_ecommerce_delivery/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/splash_repo.dart';
import 'package:get/get.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});

  ConfigModel? _configModel;
  bool _firstTimeConnectionCheck = true;
  int? _storeCategoryID;
  String? _storeType;
  Map<String, dynamic>? _data = {};
  String? _htmlText;

  ConfigModel? get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  int? get storeCategoryID => _storeCategoryID;
  String? get storeType => _storeType;
  String? get htmlText => _htmlText;

  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    if(moduleType == 'food') {
      module.newVariation = true;
    }else {
      module.newVariation = false;
    }
    return module;
  }

  Future<bool> getConfigData() async {
    Response response = await splashRepo.getConfigData();
    bool isSuccess = false;
    if(response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Module getModule(String? moduleType) => Module.fromJson(_data!['module_config'][moduleType]);

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashRepo.removeSharedData();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> getHtmlText(bool isPrivacyPolicy) async {
    _htmlText = null;
    Response response = await splashRepo.getHtmlText(isPrivacyPolicy);
    if (response.statusCode == 200) {
      if(response.body != null && response.body.isNotEmpty && response.body is String) {
        _htmlText = response.body.replaceAll('href=', 'target="_blank" href=');
      }else {
        _htmlText = '';
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

}