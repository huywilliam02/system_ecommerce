import 'package:citgroupvn_ecommerce_delivery/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/notification_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/notification_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/date_converter.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  List<NotificationModel>? _notificationList;
  bool _hasNotification = false;

  List<NotificationModel>? get notificationList => _notificationList;
  bool get hasNotification => _hasNotification;

  Future<void> getNotificationList() async {
    Response response = await notificationRepo.getNotificationList();
    if (response.statusCode == 200) {
      _notificationList = [];
    response.body.forEach((notification) {
        NotificationModel notify = NotificationModel.fromJson(notification);
        notify.title = notification['data']['title'];
        notify.description = notification['data']['description'];
        notify.image = notification['data']['image'];
        _notificationList!.add(notify);
      });
      _notificationList!.sort((a, b) {
        return DateConverter.isoStringToLocalDate(a.updatedAt!).compareTo(DateConverter.isoStringToLocalDate(b.updatedAt!));
      });
      Iterable iterable = _notificationList!.reversed;
      _notificationList = iterable.toList() as List<NotificationModel>?;
      _hasNotification = _notificationList!.length != getSeenNotificationCount();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void saveSeenNotificationCount(int count) {
    notificationRepo.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationRepo.getSeenNotificationCount();
  }

}
