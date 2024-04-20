import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce/data/model/response/banner_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/others_banner_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/promotional_banner_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/data/repository/banner_repo.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';

class BannerController extends GetxController implements GetxService {
  final BannerRepo bannerRepo;
  BannerController({required this.bannerRepo});

  List<String?>? _bannerImageList;
  List<String?>? _taxiBannerImageList;
  List<String?>? _featuredBannerList;
  List<dynamic>? _bannerDataList;
  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? _featuredBannerDataList;
  int _currentIndex = 0;
  ParcelOtherBannerModel? _parcelOtherBannerModel;
  PromotionalBanner? _promotionalBanner;

  List<String?>? get bannerImageList => _bannerImageList;
  List<String?>? get featuredBannerList => _featuredBannerList;
  List<dynamic>? get bannerDataList => _bannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;
  int get currentIndex => _currentIndex;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  Future<void> getFeaturedBanner() async {
    Response response = await bannerRepo.getFeaturedBannerList();
    if (response.statusCode == 200) {
      _featuredBannerList = [];
      _featuredBannerDataList = [];
      BannerModel bannerModel = BannerModel.fromJson(response.body);
      List<int?> moduleIdList = [];
      for (ZoneData zone in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        for (Modules module in zone.modules ?? []) {
          moduleIdList.add(module.id);
        }
      }
      for (var campaign in bannerModel.campaigns!) {
        _featuredBannerList!.add(campaign.image);
        _featuredBannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        _featuredBannerList!.add(banner.image);
        if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
          _featuredBannerDataList!.add(banner.item);
        }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
          _featuredBannerDataList!.add(banner.store);
        }else if(banner.type == 'default') {
          _featuredBannerDataList!.add(banner.link);
        }else{
          _featuredBannerDataList!.add(null);
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getBannerList(bool reload) async {
    if(_bannerImageList == null || reload) {
      _bannerImageList = null;
      Response response = await bannerRepo.getBannerList();
      if (response.statusCode == 200) {
        _bannerImageList = [];
        _bannerDataList = [];
        BannerModel bannerModel = BannerModel.fromJson(response.body);
        for (var campaign in bannerModel.campaigns!) {
          _bannerImageList!.add(campaign.image);
          _bannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _bannerImageList!.add(banner.image);
          if(banner.item != null) {
            _bannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _bannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _bannerDataList!.add(banner.link);
          }else{
            _bannerDataList!.add(null);
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getTaxiBannerList(bool reload) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      Response response = await bannerRepo.getTaxiBannerList();
      if (response.statusCode == 200) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        BannerModel bannerModel = BannerModel.fromJson(response.body);
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.image);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.image);
          if(banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _taxiBannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _taxiBannerDataList!.add(banner.link);
          }else{
            _taxiBannerDataList!.add(null);
          }
        }
        if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getParcelOtherBannerList(bool reload) async {
    if(_parcelOtherBannerModel == null || reload) {
      Response response = await bannerRepo.getParcelOtherBannerList();
      if (response.statusCode == 200) {
        _parcelOtherBannerModel = ParcelOtherBannerModel.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getPromotionalBanner(bool reload) async {
    if(_promotionalBanner == null || reload) {
      Response response = await bannerRepo.getPromotionalBanner();
      if (response.statusCode == 200) {
        _promotionalBanner = PromotionalBanner.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }
}
