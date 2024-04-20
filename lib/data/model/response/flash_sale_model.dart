import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';

class FlashSaleModel {
  int? id;
  int? moduleId;
  String? title;
  int? isPublish;
  int? adminDiscountPercentage;
  int? vendorDiscountPercentage;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;
  List<ActiveProducts>? activeProducts;
  List<Translations>? translations;

  FlashSaleModel(
      {this.id,
        this.moduleId,
        this.title,
        this.isPublish,
        this.adminDiscountPercentage,
        this.vendorDiscountPercentage,
        this.startDate,
        this.endDate,
        this.createdAt,
        this.updatedAt,
        this.activeProducts,
        this.translations});

  FlashSaleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleId = json['module_id'];
    title = json['title'];
    isPublish = json['is_publish'];
    adminDiscountPercentage = json['admin_discount_percentage'];
    vendorDiscountPercentage = json['vendor_discount_percentage'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['active_products'] != null) {
      activeProducts = <ActiveProducts>[];
      json['active_products'].forEach((v) {
        activeProducts!.add(ActiveProducts.fromJson(v));
      });
    }
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_id'] = moduleId;
    data['title'] = title;
    data['is_publish'] = isPublish;
    data['admin_discount_percentage'] = adminDiscountPercentage;
    data['vendor_discount_percentage'] = vendorDiscountPercentage;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (activeProducts != null) {
      data['active_products'] = activeProducts!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ActiveProducts {
  int? id;
  int? flashSaleId;
  int? itemId;
  int? stock;
  int? sold;
  int? availableStock;
  String? discountType;
  double? discount;
  double? discountAmount;
  double? price;
  int? status;
  String? createdAt;
  String? updatedAt;
  Item? item;

  ActiveProducts(
      {this.id,
        this.flashSaleId,
        this.itemId,
        this.stock,
        this.sold,
        this.availableStock,
        this.discountType,
        this.discount,
        this.discountAmount,
        this.price,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.item});

  ActiveProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flashSaleId = json['flash_sale_id'];
    itemId = json['item_id'];
    stock = json['stock'];
    sold = json['sold'];
    availableStock = json['available_stock'];
    discountType = json['discount_type'];
    discount = json['discount']?.toDouble();
    discountAmount = json['discount_amount'].toDouble();
    price = json['price'].toDouble();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null ? Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['flash_sale_id'] = flashSaleId;
    data['item_id'] = itemId;
    data['stock'] = stock;
    data['sold'] = sold;
    data['available_stock'] = availableStock;
    data['discount_type'] = discountType;
    data['discount'] = discount;
    data['discount_amount'] = discountAmount;
    data['price'] = price;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}
/*
class Item {
  int? id;
  String? name;
  String? description;
  String? image;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Null>? variations;
  List<Null>? addOns;
  List<Null>? attributes;
  List<Null>? choiceOptions;
  int? price;
  int? tax;
  String? taxType;
  int? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? veg;
  int? status;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  int? orderCount;
  int? avgRating;
  int? ratingCount;
  int? moduleId;
  int? stock;
  int? unitId;
  List<String>? images;
  List<Null>? foodVariations;
  String? slug;
  int? recommended;
  int? organic;
  int? maximumCartQuantity;
  int? isApproved;
  String? storeName;
  int? isCampaign;
  String? moduleType;
  int? zoneId;
  int? flashSale;
  int? storeDiscount;
  bool? scheduleOrder;
  int? minDeliveryTime;
  int? maxDeliveryTime;
  int? commonConditionId;
  int? isBasic;
  String? unitType;
  List<Translations>? translations;
  Module? module;
  Unit? unit;

  Item(
      {this.id,
        this.name,
        this.description,
        this.image,
        this.categoryId,
        this.categoryIds,
        this.variations,
        this.addOns,
        this.attributes,
        this.choiceOptions,
        this.price,
        this.tax,
        this.taxType,
        this.discount,
        this.discountType,
        this.availableTimeStarts,
        this.availableTimeEnds,
        this.veg,
        this.status,
        this.storeId,
        this.createdAt,
        this.updatedAt,
        this.orderCount,
        this.avgRating,
        this.ratingCount,
        this.moduleId,
        this.stock,
        this.unitId,
        this.images,
        this.foodVariations,
        this.slug,
        this.recommended,
        this.organic,
        this.maximumCartQuantity,
        this.isApproved,
        this.storeName,
        this.isCampaign,
        this.moduleType,
        this.zoneId,
        this.flashSale,
        this.storeDiscount,
        this.scheduleOrder,
        this.minDeliveryTime,
        this.maxDeliveryTime,
        this.commonConditionId,
        this.isBasic,
        this.unitType,
        this.translations,
        this.module,
        this.unit});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    categoryId = json['category_id'];
    if (json['category_ids'] != null) {
      categoryIds = <CategoryIds>[];
      json['category_ids'].forEach((v) {
        categoryIds!.add(new CategoryIds.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = <Null>[];
      json['variations'].forEach((v) {
        variations!.add(new Null.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = <Null>[];
      json['add_ons'].forEach((v) {
        addOns!.add(new Null.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }
    if (json['choice_options'] != null) {
      choiceOptions = <Null>[];
      json['choice_options'].forEach((v) {
        choiceOptions!.add(new Null.fromJson(v));
      });
    }
    price = json['price'];
    tax = json['tax'];
    taxType = json['tax_type'];
    discount = json['discount'];
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    veg = json['veg'];
    status = json['status'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderCount = json['order_count'];
    avgRating = json['avg_rating'];
    ratingCount = json['rating_count'];
    moduleId = json['module_id'];
    stock = json['stock'];
    unitId = json['unit_id'];
    images = json['images'].cast<String>();
    if (json['food_variations'] != null) {
      foodVariations = <Null>[];
      json['food_variations'].forEach((v) {
        foodVariations!.add(new Null.fromJson(v));
      });
    }
    slug = json['slug'];
    recommended = json['recommended'];
    organic = json['organic'];
    maximumCartQuantity = json['maximum_cart_quantity'];
    isApproved = json['is_approved'];
    storeName = json['store_name'];
    isCampaign = json['is_campaign'];
    moduleType = json['module_type'];
    zoneId = json['zone_id'];
    flashSale = json['flash_sale'];
    storeDiscount = json['store_discount'];
    scheduleOrder = json['schedule_order'];
    minDeliveryTime = json['min_delivery_time'];
    maxDeliveryTime = json['max_delivery_time'];
    commonConditionId = json['common_condition_id'];
    isBasic = json['is_basic'];
    unitType = json['unit_type'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(new Translations.fromJson(v));
      });
    }
    module =
    json['module'] != null ? new Module.fromJson(json['module']) : null;
    unit = json['unit'] != null ? new Unit.fromJson(json['unit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['category_id'] = this.categoryId;
    if (this.categoryIds != null) {
      data['category_ids'] = this.categoryIds!.map((v) => v.toJson()).toList();
    }
    if (this.variations != null) {
      data['variations'] = this.variations!.map((v) => v.toJson()).toList();
    }
    if (this.addOns != null) {
      data['add_ons'] = this.addOns!.map((v) => v.toJson()).toList();
    }
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }
    if (this.choiceOptions != null) {
      data['choice_options'] =
          this.choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['price'] = this.price;
    data['tax'] = this.tax;
    data['tax_type'] = this.taxType;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['available_time_starts'] = this.availableTimeStarts;
    data['available_time_ends'] = this.availableTimeEnds;
    data['veg'] = this.veg;
    data['status'] = this.status;
    data['store_id'] = this.storeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['order_count'] = this.orderCount;
    data['avg_rating'] = this.avgRating;
    data['rating_count'] = this.ratingCount;
    data['module_id'] = this.moduleId;
    data['stock'] = this.stock;
    data['unit_id'] = this.unitId;
    data['images'] = this.images;
    if (this.foodVariations != null) {
      data['food_variations'] =
          this.foodVariations!.map((v) => v.toJson()).toList();
    }
    data['slug'] = this.slug;
    data['recommended'] = this.recommended;
    data['organic'] = this.organic;
    data['maximum_cart_quantity'] = this.maximumCartQuantity;
    data['is_approved'] = this.isApproved;
    data['store_name'] = this.storeName;
    data['is_campaign'] = this.isCampaign;
    data['module_type'] = this.moduleType;
    data['zone_id'] = this.zoneId;
    data['flash_sale'] = this.flashSale;
    data['store_discount'] = this.storeDiscount;
    data['schedule_order'] = this.scheduleOrder;
    data['min_delivery_time'] = this.minDeliveryTime;
    data['max_delivery_time'] = this.maxDeliveryTime;
    data['common_condition_id'] = this.commonConditionId;
    data['is_basic'] = this.isBasic;
    data['unit_type'] = this.unitType;
    if (this.translations != null) {
      data['translations'] = this.translations!.map((v) => v.toJson()).toList();
    }
    if (this.module != null) {
      data['module'] = this.module!.toJson();
    }
    if (this.unit != null) {
      data['unit'] = this.unit!.toJson();
    }
    return data;
  }
}*/

class CategoryIds {
  String? id;
  int? position;
  String? name;

  CategoryIds({this.id, this.position, this.name});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['position'] = this.position;
    data['name'] = this.name;
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Module {
  int? id;
  String? moduleName;
  String? moduleType;
  String? thumbnail;
  String? status;
  int? storesCount;
  String? createdAt;
  String? updatedAt;
  String? icon;
  int? themeId;
  String? description;
  int? allZoneService;
  List<Translations>? translations;

  Module(
      {this.id,
        this.moduleName,
        this.moduleType,
        this.thumbnail,
        this.status,
        this.storesCount,
        this.createdAt,
        this.updatedAt,
        this.icon,
        this.themeId,
        this.description,
        this.allZoneService,
        this.translations});

  Module.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleName = json['module_name'];
    moduleType = json['module_type'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    storesCount = json['stores_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    icon = json['icon'];
    themeId = json['theme_id'];
    description = json['description'];
    allZoneService = json['all_zone_service'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_name'] = moduleName;
    data['module_type'] = moduleType;
    data['thumbnail'] = thumbnail;
    data['status'] = status;
    data['stores_count'] = storesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['icon'] = icon;
    data['theme_id'] = themeId;
    data['description'] = description;
    data['all_zone_service'] = allZoneService;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Unit {
  int? id;
  String? unit;
  String? createdAt;
  String? updatedAt;

  Unit({this.id, this.unit, this.createdAt, this.updatedAt});

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unit = json['unit'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unit'] = unit;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}