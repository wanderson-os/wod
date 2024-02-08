import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wod/src/model/class.dart';

typedef RecordWodFieldList = List<RecordWodField>;
typedef RecordWodField = ({
  bool requiredIcon,
  bool enabled,
  String fieldLabel,
  String fieldName,
  Type tipo,
  ResultUtil valor,
  ValidatorUtil? validatorUtil
});
typedef RecordFieldWidget = ({
  String fieldName,
  Widget fieldWidget,
  String fieldLabel,
  Stream<RecordWodField> onAction,
  ResultUtil valor,
  Type tipo,
});
