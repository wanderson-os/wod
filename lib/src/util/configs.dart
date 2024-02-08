import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wod/src/model/class.dart';

typedef RecordCriteriaFieldList = List<RecordCriteriaField>;
typedef RecordCriteriaField = ({
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
  Stream<RecordCriteriaField> onAction,
  ResultUtil valor,
  Type tipo,
});
