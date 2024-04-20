import 'package:citgroupvn_ecommerce_store/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/repository/addon_repo.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class AddonController extends GetxController implements GetxService {
  final AddonRepo addonRepo;
  AddonController({required this.addonRepo});

  List<AddOns>? _addonList;
  bool _isLoading = false;

  List<AddOns>? get addonList => _addonList;
  bool get isLoading => _isLoading;

  Future<List<int?>> getAddonList() async {
    Response response = await addonRepo.getAddonList();
    List<int?> addonsIds = [];
    if(response.statusCode == 200) {
      _addonList = [];
      response.body.forEach((addon) {
        _addonList!.add(AddOns.fromJson(addon));
        addonsIds.add(AddOns.fromJson(addon).id);
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
    return addonsIds;
  }

  Future<void> addAddon(AddOns addonModel) async {
    _isLoading = true;
    update();
    Response response = await addonRepo.addAddon(addonModel);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('addon_added_successfully'.tr, isError: false);
      getAddonList();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateAddon(AddOns addonModel) async {
    _isLoading = true;
    update();
    Response response = await addonRepo.updateAddon(addonModel);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('addon_updated_successfully'.tr, isError: false);
      getAddonList();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteAddon(int? addonID) async {
    _isLoading = true;
    update();
    Response response = await addonRepo.deleteAddon(addonID);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('addon_removed_successfully'.tr, isError: false);
      getAddonList();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

}