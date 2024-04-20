import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as i;
import 'package:screenshot/screenshot.dart';
import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/body/bluetoothPrinterBody.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/order_details_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/profile_model.dart';
import 'package:citgroupvn_ecommerce_store/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';

class InVoicePrintScreen extends StatefulWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  final bool? isPrescriptionOrder;
  final double dmTips;
  const InVoicePrintScreen({Key? key, required this.order, required this.orderDetails, this.isPrescriptionOrder = false, required this.dmTips}) : super(key: key);

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
  PrinterType _defaultPrinterType = PrinterType.bluetooth;
  final bool _isBle = GetPlatform.isIOS;
  final PrinterManager _printerManager = PrinterManager.instance;
  final List<BluetoothPrinter> _devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  BTStatus currentStatus = BTStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  bool _paper80MM = true;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  BluetoothPrinter? _selectedPrinter;
  bool _searchingMode = true;

  @override
  void initState() {
    if (Platform.isWindows) _defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      currentStatus = status;

      if (status == BTStatus.connected && pendingTask != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    _devices.clear();
    _subscription = _printerManager.discovery(type: _defaultPrinterType, isBle: _isBle).listen((device) {
      _devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: _defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void _setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    _selectDevice(device);
  }

  void _setIpAddress(String value) {
    _ipAddress = value;
    BluetoothPrinter device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    _selectDevice(device);
  }

  void _selectDevice(BluetoothPrinter device) async {
    if (_selectedPrinter != null) {
      if ((device.address != _selectedPrinter!.address) || (device.typePrinter == PrinterType.usb && _selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance.disconnect(type: _selectedPrinter!.typePrinter);
      }
    }

    _selectedPrinter = device;
    setState(() {});
  }

  Future _printReceipt(i.Image image) async {
    i.Image resized = i.copyResize(image, width: _paper80MM ? 500 : 365);
    CapabilityProfile profile = await CapabilityProfile.load();
    Generator generator = Generator(_paper80MM ? PaperSize.mm80 : PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.image(resized);
    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    if (_selectedPrinter == null) return;
    var bluetoothPrinter = _selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try{
        Future.delayed(Duration(seconds: GetPlatform.isIOS ? 2 : 1), () {
          _printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
          pendingTask = null;
        });
      }catch(_) {}
    } else {
      _printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _searchingMode ? SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.fontSizeLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text('paper_size'.tr, style: robotoMedium),
          Row(children: [
            Expanded(child: RadioListTile(
              title: Text('80_mm'.tr),
              groupValue: _paper80MM,
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: true,
              onChanged: (bool? value) {
                _paper80MM = true;
                setState(() {});
              },
            )),
            Expanded(child: RadioListTile(
              title: Text('58_mm'.tr),
              groupValue: _paper80MM,
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: false,
              onChanged: (bool? value) {
                _paper80MM = false;
                setState(() {});
              },
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ListView.builder(
            itemCount: _devices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () {
                    _selectDevice(_devices[index]);
                    setState(() {
                      _searchingMode = false;
                    });
                  },
                  child: Stack(children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('${_devices[index].deviceName}'),

                      Platform.isAndroid && _defaultPrinterType == PrinterType.usb ? const SizedBox() : Visibility(
                        visible: !Platform.isWindows,
                        child: Text("${_devices[index].address}"),
                      ),

                      index != _devices.length-1 ? Divider(color: Theme.of(context).disabledColor) : const SizedBox(),

                    ]),

                    (_selectedPrinter != null && ((_devices[index].typePrinter == PrinterType.usb && Platform.isWindows
                        ? _devices[index].deviceName == _selectedPrinter!.deviceName
                        : _devices[index].vendorId != null && _selectedPrinter!.vendorId == _devices[index].vendorId) ||
                        (_devices[index].address != null && _selectedPrinter!.address == _devices[index].address))) ? const Positioned(
                      top: 5, right: 5,
                      child: Icon(Icons.check, color: Colors.green),
                    ) : const SizedBox(),

                  ]),
                ),
              );
            },
          ),
          Visibility(
            visible: _defaultPrinterType == PrinterType.network && Platform.isWindows,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextFormField(
                controller: _ipController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  label: Text('ip_address'.tr),
                  prefixIcon: const Icon(Icons.wifi, size: 24),
                ),
                onChanged: _setIpAddress,
              ),
            ),
          ),
          Visibility(
            visible: _defaultPrinterType == PrinterType.network && Platform.isWindows,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextFormField(
                controller: _portController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  label: Text('port'.tr),
                  prefixIcon: const Icon(Icons.numbers_outlined, size: 24),
                ),
                onChanged: _setPort,
              ),
            ),
          ),
          Visibility(
            visible: _defaultPrinterType == PrinterType.network && Platform.isWindows,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: OutlinedButton(
                onPressed: () async {
                  if (_ipController.text.isNotEmpty) _setIpAddress(_ipController.text);
                  setState(() {
                    _searchingMode = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                  child: Text("print_ticket".tr, textAlign: TextAlign.center),
                ),
              ),
            ),
          )
        ],
      ),
    ) : InvoiceDialog(
      order: widget.order, orderDetails: widget.orderDetails, isPrescriptionOrder: widget.isPrescriptionOrder,
      onPrint: (i.Image? image) => _printReceipt(image!), paper80MM: _paper80MM, dmTips: widget.dmTips,
    );
  }
}

class InvoiceDialog extends StatelessWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  final Function(i.Image? image) onPrint;
  final bool? isPrescriptionOrder;
  final bool paper80MM;
  final double dmTips;
  const InvoiceDialog({Key? key, required this.order, required this.orderDetails, required this.onPrint, required this.isPrescriptionOrder, required this.paper80MM, required this.dmTips}) : super(key: key);

  String _priceDecimal(double price) {
    return price.toStringAsFixed(Get.find<SplashController>().configModel!.digitAfterDecimalPoint!);
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = window.physicalSize.width > 1000 ? Dimensions.fontSizeExtraSmall : Dimensions.paddingSizeSmall;
    ScreenshotController controller = ScreenshotController();
    Store store = Get.find<AuthController>().profileModel!.stores![0];

    double itemsPrice = 0;
    double addOns = 0;

    if(isPrescriptionOrder!){
      double orderAmount = order!.orderAmount ?? 0;
      double discount = order!.storeDiscountAmount ?? 0;
      double tax = order!.totalTaxAmount ?? 0;
      double deliveryCharge = order!.deliveryCharge ?? 0;
      itemsPrice = (orderAmount + discount) - (tax + deliveryCharge );
    }
    for(OrderDetailsModel orderDetails in orderDetails!) {
      for(AddOn addOn in orderDetails.addOns!) {
        addOns = addOns + (addOn.price! * addOn.quantity!);
      }
      if(!isPrescriptionOrder!) {
        itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
      }
    }

    return OrientationBuilder(builder: (context, orientation) {
      double fixedSize = window.physicalSize.width / (orientation == Orientation.portrait ? 720 : 1400);
      double printWidth = (paper80MM ? 280 : 185) / fixedSize;
      bool taxIncluded = order!.taxStatus!;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Screenshot(
            controller: controller,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
              ),
              width: printWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                Text(store.name!, style: robotoMedium.copyWith(fontSize: fontSize)),
                Text(store.address!, style: robotoRegular.copyWith(fontSize: fontSize)),
                Text(store.phone!, style: robotoRegular.copyWith(fontSize: fontSize)),
                Text(store.email!, style: robotoRegular.copyWith(fontSize: fontSize)),
                const SizedBox(height: 10),

                Row(children: [
                  Text('${'order_id'.tr}:', style: robotoRegular.copyWith(fontSize: fontSize)),
                  const SizedBox(width: 5),
                  Expanded(child: Text(order!.id.toString(), style: robotoMedium.copyWith(fontSize: fontSize))),
                  Text(DateConverter.dateTimeStringToMonthAndTime(order!.createdAt!), style: robotoRegular.copyWith(fontSize: fontSize)),
                ]),
                order!.scheduled == 1 ? Text(
                  '${'scheduled_order_time'.tr} ${DateConverter.dateTimeStringToDateTime(order!.scheduleAt!)}',
                  style: robotoRegular.copyWith(fontSize: fontSize),
                ) : const SizedBox(),
                const SizedBox(height: 5),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(order!.orderType!.tr, style: robotoRegular.copyWith(fontSize: fontSize)),
                  Text(order!.paymentMethod!.tr, style: robotoRegular.copyWith(fontSize: fontSize)),
                ]),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),

                Align(
                  alignment: Get.find<LocalizationController>().isLtr ? Alignment.topLeft : Alignment.topRight,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${order!.customer!.fName} ${order!.customer!.lName}', style: robotoRegular.copyWith(fontSize: fontSize)),
                    Text(order!.deliveryAddress!.address!, style: robotoRegular.copyWith(fontSize: fontSize)),
                    Text(order!.deliveryAddress!.contactPersonNumber!, style: robotoRegular.copyWith(fontSize: fontSize)),
                  ]),
                ),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(flex: 1, child: Text('sl'.tr.toUpperCase(), style: robotoMedium.copyWith(fontSize: fontSize))),
                  Expanded(flex: 6, child: Text('item_info'.tr, style: robotoMedium.copyWith(fontSize: fontSize))),
                  Expanded(flex: 1, child: Text(
                    'qty'.tr, style: robotoMedium.copyWith(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  )),
                  Expanded(flex: 2, child: Text(
                    'price'.tr, style: robotoMedium.copyWith(fontSize: fontSize),
                    textAlign: TextAlign.right,
                  )),
                ]),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),

                ListView.builder(
                  itemCount: orderDetails!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {

                    String addOnText = '';
                    for (var addOn in orderDetails![index].addOns!) {
                      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
                    }

                    String variationText = '';
                    if(orderDetails![index].variation!.isNotEmpty) {
                      if(orderDetails![index].variation!.isNotEmpty) {
                        List<String> variationTypes = orderDetails![index].variation![0].type!.split('-');
                        if(variationTypes.length == orderDetails![index].itemDetails!.choiceOptions!.length) {
                          int index = 0;
                          for (var choice in orderDetails![index].itemDetails!.choiceOptions!) {
                            variationText = '$variationText${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
                            index = index + 1;
                          }
                        }else {
                          variationText = orderDetails![index].itemDetails!.variations![0].type!;
                        }
                      }
                    }else if(orderDetails![index].foodVariation!.isNotEmpty) {
                      for(FoodVariation variation in orderDetails![index].foodVariation!) {
                        variationText += '${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
                        for(VariationValue value in variation.variationValues!) {
                          variationText += '${variationText.endsWith('(') ? '' : ', '}${value.level}';
                        }
                        variationText += ')';
                      }
                    }
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 1, child: Text(
                        (index+1).toString(),
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                      Expanded(flex: 5, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          orderDetails![index].itemDetails!.name!,
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ),
                        const SizedBox(height: 2),

                        addOnText.isNotEmpty ? Text(
                          '${'addons'.tr}: $addOnText',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ) : const SizedBox(),

                        (orderDetails![index].variation != null && orderDetails![index].variation!.isNotEmpty) || (orderDetails![index].foodVariation != null && orderDetails![index].foodVariation!.isNotEmpty) ? Text(
                          '${'variations'.tr}: $variationText',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ) : const SizedBox(),

                      ])),
                      Expanded(flex: 2, child: Text(
                        orderDetails![index].quantity.toString(), textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                      Expanded(flex: 2, child: Text(
                        _priceDecimal(orderDetails![index].price!), textAlign: TextAlign.right,
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                    ]);
                  },
                ),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),

                PriceWidget(title: 'item_price'.tr, value: _priceDecimal(itemsPrice), fontSize: fontSize),
                const SizedBox(height: 5),
                addOns > 0 ? PriceWidget(title: 'add_ons'.tr, value: _priceDecimal(addOns), fontSize: fontSize) : const SizedBox(),
                SizedBox(height: addOns > 0 ? 5 : 0),
                PriceWidget(title: '${'subtotal'.tr}${taxIncluded ? '(${'tax_included'.tr})' : ''}', value: _priceDecimal(itemsPrice + addOns), fontSize: fontSize),
                const SizedBox(height: 5),
                PriceWidget(title: 'discount'.tr, value: _priceDecimal(order!.storeDiscountAmount!), fontSize: fontSize),
                const SizedBox(height: 5),
                PriceWidget(title: 'coupon_discount'.tr, value: _priceDecimal(order!.couponDiscountAmount!), fontSize: fontSize),
                const SizedBox(height: 5),
                !taxIncluded ? PriceWidget(title: 'vat_tax'.tr, value: _priceDecimal(order!.totalTaxAmount!), fontSize: fontSize) : const SizedBox(),
                SizedBox(height: taxIncluded ? 0 : 5),
                PriceWidget(title: 'delivery_man_tips'.tr, value: _priceDecimal(dmTips), fontSize: fontSize),
                const SizedBox(height: 5),
                PriceWidget(title: 'delivery_fee'.tr, value: _priceDecimal(order!.deliveryCharge!), fontSize: fontSize),
                SizedBox(height: (order!.additionalCharge != null && order!.additionalCharge! > 0) ? 5 : 0),
                (order!.additionalCharge != null && order!.additionalCharge! > 0)
                    ? PriceWidget(title: Get.find<SplashController>().configModel!.additionalChargeName!, value: _priceDecimal(order!.additionalCharge!), fontSize: fontSize)
                    : const SizedBox(),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                PriceWidget(title: 'total_amount'.tr, value: _priceDecimal(order!.orderAmount!), fontSize: fontSize+2),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),

                Text('thank_you'.tr, style: robotoRegular.copyWith(fontSize: fontSize)),
                Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),

                Text(
                  '${Get.find<SplashController>().configModel!.businessName}. ${Get.find<SplashController>().configModel!.footerText}',
                  style: robotoRegular.copyWith(fontSize: fontSize),
                ),

              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomButton(buttonText: 'print_invoice'.tr, height: 40, onPressed: () {
            controller.capture(delay: const Duration(milliseconds: 10)).then((capturedImage) async {
              Get.back();
              onPrint(i.decodeImage(capturedImage!));
            }).catchError((onError) {
              debugPrint(onError);
            });
          }),

        ]),
      );
    });
  }

}

class PriceWidget extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;
  const PriceWidget({Key? key, required this.title, required this.value, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: robotoRegular.copyWith(fontSize: fontSize)),
      Text(value, style: robotoMedium.copyWith(fontSize: fontSize)),
    ]);
  }
}
