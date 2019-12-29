// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/weather_icons.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Color.fromRGBO(117, 117, 117, 1),
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.model.temperature.toStringAsFixed(0);
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 2.1;
    final tempSize = MediaQuery.of(context).size.width / 5;
    final unitSize = MediaQuery.of(context).size.width / 10;
    final offset = -fontSize / 7;
    final bottomOffset = -tempSize / 5;

    Color textColor = colors[_Element.text];
    Color backgroundColor = colors[_Element.background];

    if (widget.model.temperature < 5) {
      textColor = Colors.lightBlue[200];
      backgroundColor = Colors.blueGrey;
    } else if (widget.model.temperature > 20) {
      textColor = Colors.deepOrange;
      backgroundColor = Colors.lime;
    }

    final defaultStyle = TextStyle(
      color: textColor,
      fontFamily: 'Fyodor-BoldCondensed',
      fontSize: fontSize,
    );

    final tempStyle = TextStyle(
      color: textColor,
      fontFamily: 'Fyodor-BoldCondensed',
      fontSize: tempSize,
    );

    final unitStyle = TextStyle(
      color: textColor,
      fontFamily: 'Fyodor-BoldCondensed',
      fontSize: unitSize,
    );

    IconData iconSelection;
    switch (widget.model.weatherCondition) {
      case WeatherCondition.sunny:
        iconSelection = Weather.sun;
        break;
      case WeatherCondition.cloudy:
        iconSelection = Weather.cloud;
        break;
      case WeatherCondition.foggy:
        iconSelection = Weather.fog;
        break;
      case WeatherCondition.rainy:
        iconSelection = Weather.rain;
        break;
      case WeatherCondition.snowy:
        iconSelection = Weather.snow_heavy;
        break;
      case WeatherCondition.thunderstorm:
        iconSelection = Weather.clouds_flash_alt;
        break;
      case WeatherCondition.windy:
        iconSelection = Weather.wind;
        break;
      default:
        iconSelection = Weather.temperature;
    }

    final weatherIcon = Container(
        margin: EdgeInsets.only(right: 20.0, bottom: 20),
        child: Icon(
          iconSelection,
          color: textColor,
          size: MediaQuery.of(context).size.width / 6,
        ));

    var formatter = new DateFormat('dd-MM');
    var date = formatter.format(new DateTime.now());

    return Container(
      color: backgroundColor,
      child: Center(
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 5,
              top: offset,
              child: DefaultTextStyle(
                  style: defaultStyle, child: Text(hour + ':' + minute)),
            ),
            Positioned(
              left: 5,
              bottom: bottomOffset,
              child: DefaultTextStyle(style: tempStyle, child: Text(date)),
            ),
            Positioned(
              right: 5,
              bottom: bottomOffset,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  weatherIcon,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DefaultTextStyle(style: tempStyle, child: Text(temp)),
                      DefaultTextStyle(
                        style: unitStyle,
                        child: Text(widget.model.unitString),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
