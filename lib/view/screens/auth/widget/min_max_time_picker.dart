import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class MinMaxTimePicker extends StatefulWidget {
  final List<String> times;
  final Function(int index) onChanged;
  final int initialPosition;
  const MinMaxTimePicker({Key? key, required this.times, required this.onChanged, required this.initialPosition}) : super(key: key);

  @override
  State<MinMaxTimePicker> createState() => _MinMaxTimePickerState();
}

class _MinMaxTimePickerState extends State<MinMaxTimePicker> {
  int selectedIndex = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: 0.3,
          initialPage: widget.initialPosition,
          autoPlayInterval: const Duration(seconds: 7),
          onPageChanged: (index, reason) {
            setState(() {
              selectedIndex = index;
            });
            widget.onChanged(index);
          },
          scrollDirection: Axis.vertical,
        ),
        itemCount: widget.times.length,
        itemBuilder: (context, index, _) {
          return Container(
            decoration: BoxDecoration(
              color: selectedIndex == index ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
            ),
            child: Center(child: Text(
              widget.times[index].toString(),
              style: selectedIndex == index ? robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            )),
          );
        },
      ),
    );
  }
}
