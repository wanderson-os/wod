import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:wod/src/model/class.dart';
import 'package:wod/src/util/wod_configs.dart';

import 'widgets/custom/custom_modal_mult_select.dart';
import 'widgets/custom/custom_modal_select.dart';
import 'widgets/custom/custom_text_field.dart';

class Wod {
  RecordWodFieldList wodFields = [];
  RecordWodFieldList _wodFieldsModel = [];
  Wod();

  /// usage when you need to set a wod schema
  setWodFieldsModel(List<RecordWodField> wodFields) {
    _wodFieldsModel.clear();
    _wodFieldsModel = List.from(wodFields);
  }

  RecordWodField? getFieldByName(String fieldName) {
    return _wodFieldsModel
        .where((element) => element.fieldName == fieldName)
        .firstOrNull;
  }

  Wod replaceField({required String fieldName, required RecordWodField field}) {
    final index =
        _wodFieldsModel.indexWhere((element) => element.fieldName == fieldName);
    if (index != -1) {
      _wodFieldsModel[index] = field;
    }
    return this;
  }

  /// return a list of widgets with the fields of the wod
  List<({String fieldName, Widget fieldWidget, dynamic value})>
      getWodWidgets() {
    List<({String fieldName, Widget fieldWidget, dynamic value})> wodWidgets =
        [];

    var fieldNamesCount = <String, int>{};
    var duplicates = <RecordWodField>[];

    for (var model in _wodFieldsModel) {
      if (fieldNamesCount.containsKey(model.fieldName)) {
        fieldNamesCount[model.fieldName] =
            fieldNamesCount[model.fieldName]! + 1;
        if (fieldNamesCount[model.fieldName]! >= 1) {
          duplicates.add(model);
        }
      } else {
        fieldNamesCount[model.fieldName] = 1;
      }
    }
    if (duplicates.isNotEmpty) {
      throw Exception(
          'duplicates wod field: \n The wod scheme on field "fieldName" must be unique, and i have ${duplicates.length} wod field${duplicates.length > 1 ? 's' : ''}  in ocurrence...\nsee in the list.\n\n${duplicates.map((e) => '\n$e').toList()}\n');
    }
    for (var field in _wodFieldsModel) {
      final render = _renderWidget(field);
      wodWidgets.add((
        fieldName: field.fieldName,
        fieldWidget: render.widget,
        value: field.valor.valor
      ));
    }
    return wodWidgets;
  }

  ///
  ///
  /// return a list of widgets with the fields of the wod

  ({
    bool isValid,
    List<
        ({
          ResultUtil valor,
          String fieldName,
          String fieldLabel,
        })> fields
  }) validate() {
    List<
        ({
          ResultUtil valor,
          String fieldName,
          String fieldLabel,
        })> list = [];
    for (var field in _wodFieldsModel) {
      if (field.validatorUtil != null) {
        if (field.validatorUtil!.validator != null) {
          if (!field.validatorUtil!.validator!(field.valor.valor).isValid) {
            list.add(
              (
                fieldLabel: field.fieldLabel.toString(),
                fieldName: field.fieldName.toString(),
                valor: field.valor.valor,
              ),
            );
          }
        }
      }
    }
    return (
      isValid: list.isEmpty,
      fields: list,
    );
  }

  List<RecordFieldWidget> _getFieldsWidgets(
      {required List<String> fieldsName}) {
    if (_wodFieldsModel.isEmpty) {
      throw Exception(
          'wodFieldsModel is empty, you must setWodFieldsModel before call this method');
    } else {
      List<RecordFieldWidget> listFieldsWidgets = [];
      if (fieldsName.isEmpty) {
        for (var fieldSchema in _wodFieldsModel) {
          final render = _renderWidget(fieldSchema);
          final fieldWidget = (
            fieldName: fieldSchema.fieldName,
            fieldWidget: render.widget,
            onAction: render.onAction,
            fieldLabel: fieldSchema.fieldLabel,
            valor: fieldSchema.valor,
            tipo: fieldSchema.tipo,
          );
          listFieldsWidgets.add(fieldWidget);
        }
      } else {
        try {
          final fields = _wodFieldsModel
              .where((element) => fieldsName.contains(element.fieldName))
              .toList();

          if (fields.isNotEmpty) {
            for (var fieldSchema in fields) {
              final render = _renderWidget(fieldSchema);
              final fieldWidget = (
                fieldName: fieldSchema.fieldName,
                fieldWidget: render.widget,
                fieldLabel: fieldSchema.fieldLabel,
                valor: fieldSchema.valor,
                tipo: fieldSchema.tipo,
                onAction: render.onAction,
              );
              listFieldsWidgets.add(fieldWidget);
            }
          } else {
            if (fieldsName.length == 1) {
              final stringLabel =
                  'field not found: ${fieldsName.first}\n The wod scheme on field "${fieldsName.first}" must be unique, and must be not null\n';
              // log(stringLabel);
              listFieldsWidgets.add(
                (
                  fieldName: fieldsName.first,
                  fieldLabel: stringLabel,
                  valor: ResultUtil(valor: stringLabel),
                  fieldWidget: Text(stringLabel),
                  tipo: null.runtimeType,
                  onAction: Stream.value(fields.first),
                ),
              );
            } else {
              final stringLabel =
                  'fields not found: ${fieldsName.join(', ')}\n The wod scheme on field "${fieldsName.join(', ')}" must be unique, and must be not null\n';
              // log(stringLabel);
              RecordFieldWidget fieldSchema = (
                fieldName: fieldsName.join(', '),
                fieldLabel: stringLabel,
                valor: ResultUtil(valor: stringLabel),
                fieldWidget: Text(stringLabel),
                tipo: null.runtimeType,
                onAction: Stream.value(fields.first),
              );
              listFieldsWidgets.add(fieldSchema);
            }
            throw Exception(
                'field not found: ${fieldsName.join(', ')}\n The wod scheme on field "${fieldsName.join(', ')}" must be unique, and must be not null\n');
          }
        } catch (e, s) {
          return listFieldsWidgets;
        }
      }
      return listFieldsWidgets;
    }
  }

  /// return a widget with the field of the wod

  RecordFieldWidget getFieldWidgetByName(String fieldName) {
    return _getFieldsWidgets(
      fieldsName: [fieldName],
    ).first;
  }

  /// return a list of widgets with the fields of the wod

  List<RecordFieldWidget> getFieldsWidget() {
    return _getFieldsWidgets(
      fieldsName: [],
    );
  }

  /// return a list of widgets with the fields of the wod by names
  ///
  List<RecordFieldWidget> getFieldsWidgetsByNames(List<String> fieldNames) {
    return _getFieldsWidgets(fieldsName: fieldNames);
  }

  /// return a list of wod fields in this schema
  RecordWodFieldList wodFieldsModel() {
    for (var field in _wodFieldsModel) {
      wodFields.add(field);
    }
    return wodFields;
  }

  dynamic getValue(String value) {
    final field = _wodFieldsModel
        .where((element) => element.fieldName == value)
        .firstOrNull;
    if (field != null) {
      return field.valor.valor;
    } else {
      return null;
    }
  }
}

/// usage with wod schema of validate fields from validateUtilClass
String? Function(String?)? _validator(RecordWodField recordField) {
  return (value) {
    if (recordField.validatorUtil != null) {
      if (recordField.validatorUtil!.validator != null) {
        if (!recordField
            .validatorUtil!.validator!(recordField.valor.valor).isValid) {
          return recordField
              .validatorUtil!.validator!(recordField.valor.valor).message;
        }
      }
    }
    return null;
  };
}

/// render a widget from wod schema by type of field
({Widget widget, Stream<RecordWodField> onAction}) _renderWidget(
    RecordWodField field) {
  StreamController<RecordWodField> streamController = StreamController();
  Stream<RecordWodField> stream = streamController.stream.asBroadcastStream();
  bool enableMultSelect = field.valor.listOptions?.enableMultSelect ?? false;

  Widget w = switch (field.tipo.toString().split('<')[0]) {
    'String' => StatefulBuilder(
        key: Key(field.fieldName.hashCode.toString()),
        builder: (context, setState) {
          return TextFormField(
            keyboardType: TextInputType.text,
            readOnly: !field.enabled,
            minLines: 1,
            maxLines: 3,
            validator: _validator(field),
            initialValue: field.valor.valor?.toString() ?? '',
            onChanged: (value) {
              setState(
                () {
                  field.valor.valor = value;
                  streamController.sink.add(field);
                },
              );
            },
            key: Key(field.fieldName.hashCode.toString()),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text((field.requiredIcon ? '*' : '') + field.fieldLabel),
                ],
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }),
    'bool' => Row(
        children: [
          Text('${field.fieldLabel}:'),
          const Gap(10),
          StatefulBuilder(builder: (context, setState) {
            return Checkbox(
              value: field.valor.valor ?? false,
              onChanged: field.enabled
                  ? (value) {
                      setState(
                        () {
                          field.valor.valor = value;
                          streamController.sink.add(field);
                        },
                      );
                    }
                  : null,
            );
          }),
        ],
      ),
    'DateTime' => StatefulBuilder(builder: (context, setState) {
        final dataBr =
            field.valor.valor == null ? null : (field.valor.valor as DateTime);
        String dataString = dataBr == null ? 'selecione uma data' : '';
        dataString = field.enabled ? dataString : '';
        if (dataBr != null) {
          String dia =
              dataBr.day < 10 ? '0${dataBr.day}' : dataBr.day.toString();

          String mes =
              dataBr.month < 10 ? '0${dataBr.month}' : dataBr.month.toString();
          int ano = dataBr.year;
          dataString = '$dia/$mes/$ano';
        }

        return Visibility(
          visible: field.enabled,
          replacement: TextFormField(
            readOnly: true,
            validator: _validator(field),
            initialValue: dataString,
            key: Key(field.fieldName.hashCode.toString()),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: field.fieldLabel,
            ),
          ),
          child: FormField(
            validator: _validator(field),
            builder: (f) {
              return InputDecorator(
                decoration: InputDecoration(
                  errorText: f.errorText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: field.fieldLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                        color: f.errorText == null ? Colors.black : Colors.red,
                        width: 20,
                        strokeAlign: 20),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          DateTime firstDate = DateTime(1999);
                          DateTime lastDate = DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ); // 10 anos a partir de hoje
                          field.valor.valor = await showDatePicker(
                            context: context,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            initialDate: field.valor.valor ?? DateTime.now(),
                          );
                          setState(() {
                            streamController.sink.add(field);
                          });
                        },
                        icon: const Icon(Icons.calendar_today),
                      ),
                      const Gap(20),
                      Text(dataString),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    'int' => StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            readOnly: !field.enabled,
            validator: _validator(field),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            enableInteractiveSelection: false,
            selectionControls: MaterialTextSelectionControls(),
            initialValue: field.valor.valor?.toString(),
            onChanged: (value) {
              setState(
                () {
                  if (value.isEmpty) {
                    field.valor.valor = '';
                  } else {
                    field.valor.valor = int.tryParse(value);
                  }
                  streamController.sink.add(field);
                },
              );
            },
            key: Key(field.fieldName),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text((field.requiredIcon ? '*' : '') + field.fieldLabel),
                ],
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    'double' => StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            readOnly: !field.enabled,
            validator: _validator(field),
            keyboardType:TextInputType.numberWithOptions(decimal: true);,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^-?([0-9]+(\.[0-9]+)?)$')),
            ],
            enableInteractiveSelection: false,
            selectionControls: MaterialTextSelectionControls(),
            initialValue: field.valor.valor?.toString()??'',
            onChanged: (value) {
              setState(
                () {
                  if (value.isEmpty) {
                    field.valor.valor = '';
                  } else {
                    field.valor.valor = double.tryParse(value);
                  }
                  streamController.sink.add(field);
                },
              );
            },
            key: Key(field.fieldName),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text((field.requiredIcon ? '*' : '') + field.fieldLabel),
                ],
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    const ('List') => Builder(
        builder: (context) {
          if (field.valor.listOptions == null) {
            throw Exception('listOptions must be not null');
          }
          final (
            :enableSeach,
            :enableMultSelect,
            :itens,
            :showLabelFieldName,
            :showBoxSelectedItens
          ) = field.valor.listOptions!;
          final isEnable = field.enabled;
          final valueIsList =
              field.valor.valor.runtimeType.toString().contains('List');
          final hintText =
              'Selecione um item${enableMultSelect ? ' (Múltiplos itens permitidos)' : ''}';

          if (isEnable) {
            if (enableMultSelect) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return (CustomModalMultSelect<dynamic>(
                    onCancel: () {},
                    onConfirm: (list) {},
                    onRemove: (item) {},
                    selectedItens: field.valor.valor,
                    label: field.fieldLabel,
                    list: field.valor.listOptions?.itens ?? [],
                    onChange: (value) {
                      field.valor.valor = value;
                      streamController.sink.add(field);
                    },
                    withSearch: enableSeach,
                    required: (
                      required: field.requiredIcon,
                      validator: (value) {
                        if (field.validatorUtil != null) {
                          if (field.validatorUtil!.validator != null) {
                            if (!field.validatorUtil!
                                .validator!(field.valor.valor).isValid) {
                              return field.validatorUtil!
                                  .validator!(field.valor.valor).message;
                            }
                          }
                        }
                        return null;
                      },
                    ),
                  ));
                },
              );
            } else {
              return StatefulBuilder(
                builder: (context, setState) {
                  return CustomModalSelect<dynamic>(
                    withSearch: enableSeach,
                    required: (
                      required: field.requiredIcon,
                      validator: (value) {
                        if (field.validatorUtil != null) {
                          if (field.validatorUtil!.validator != null) {
                            if (!field.validatorUtil!
                                .validator!(field.valor.valor).isValid) {
                              return field.validatorUtil!
                                  .validator!(field.valor.valor).message;
                            }
                          }
                        }
                        return null;
                      },
                    ),
                    list: field.valor.listOptions?.itens ?? [],
                    onChange: (value) {
                      field.valor.valor = value;
                      streamController.sink.add(field);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    value: field.valor.valor,
                    label: field.fieldLabel,
                  );
                },
              );
            }
          } else {
            if (valueIsList) {
              return InputDecorator(
                decoration: InputDecoration(
                  floatingLabelStyle:
                      const TextStyle(fontSize: 18, color: Colors.black),
                  hintStyle: const TextStyle(fontSize: 18),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: field.fieldLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 95,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      children: ((field.valor.valor) ?? [])
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Text(
                                e.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              );
            } else {
              return SizedBox(
                width: double.maxFinite,
                child: CustomTextField(
                  required: field.requiredIcon,
                  initialValue: field.valor.valor?.toString(),
                  keyTextField: Key(field.hashCode.toString()),
                  readOnly: true,
                  label: field.fieldLabel,
                ),
              );
            }
          }
        },
      ),

    // LayoutBuilder(
    //     builder: (context, constraints) {
    //       if (field.valor.listOptions == null) {
    //         throw Exception('listOptions must be not null');
    //       }
    //       final (
    //         :enableMultSelect,
    //         :itens,
    //         :showLabelFieldName,
    //         :showBoxSelectedItens
    //       ) = field.valor.listOptions!;
    //       final isEnable = field.enabled;
    //       final hintText =
    //           'Selecione um item${enableMultSelect ? ' (Múltiplos itens permitidos)' : ''}';
    //       return StatefulBuilder(
    //         builder: (context, setState) {
    //           return Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               FormField(
    //                 validator: _validator(field),
    //                 builder: (f) {
    //                   bool isList = field.valor.valor.runtimeType
    //                       .toString()
    //                       .contains('List');
    //                   return Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       if (showLabelFieldName)
    //                         Align(
    //                           alignment: Alignment.centerLeft,
    //                           child: SingleChildScrollView(
    //                             scrollDirection: Axis.horizontal,
    //                             child: Row(
    //                               mainAxisSize: MainAxisSize.min,
    //                               children: [
    //                                 Text(field.fieldLabel),
    //                               ],
    //                             ),
    //                           ),
    //                         )
    //                       else
    //                         const SizedBox(),
    //                       Visibility(
    //                         visible: showBoxSelectedItens,
    //                         child: SingleChildScrollView(
    //                           scrollDirection: Axis.vertical,
    //                           child: Container(
    //                             decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(5),
    //                               border: Border.all(
    //                                 color: (isList
    //                                         ? ((field.valor.valor ?? [])
    //                                             .isEmpty)
    //                                         : (field.valor.valor == null))
    //                                     ? (Colors.transparent)
    //                                     : (f.errorText != null
    //                                         ? Colors.red
    //                                         : Colors.black),
    //                               ),
    //                             ),
    //                             constraints: BoxConstraints(
    //                                 maxHeight: 100,
    //                                 minWidth: constraints.maxWidth),
    //                             child: SingleChildScrollView(
    //                               scrollDirection: Axis.vertical,
    //                               child: isList
    //                                   ? Wrap(
    //                                       runAlignment: WrapAlignment.start,
    //                                       spacing: 1,
    //                                       runSpacing: 1,
    //                                       children: [
    //                                         ...field.valor.valor.map(
    //                                           (e) {
    //                                             String label = e.toString();
    //                                             try {
    //                                               label = e.toStringCustom();
    //                                             } catch (e) {}

    //                                             return SingleChildScrollView(
    //                                               scrollDirection:
    //                                                   Axis.horizontal,
    //                                               child: StatefulBuilder(
    //                                                 builder: (context,
    //                                                     setStateAnimate) {
    //                                                   return AnimatedScale(
    //                                                     scale: field.valor.valor
    //                                                             .contains(e)
    //                                                         ? 1
    //                                                         : 0,
    //                                                     onEnd: () {
    //                                                       setState(() {});
    //                                                     },
    //                                                     duration:
    //                                                         const Duration(
    //                                                             milliseconds:
    //                                                                 200),
    //                                                     child: Container(
    //                                                       decoration:
    //                                                           BoxDecoration(
    //                                                         color: Colors.blue,
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     16),
    //                                                         border: Border.all(
    //                                                           color:
    //                                                               Colors.black,
    //                                                         ),
    //                                                       ),
    //                                                       margin:
    //                                                           const EdgeInsets
    //                                                               .all(5),
    //                                                       child: Row(
    //                                                         mainAxisSize:
    //                                                             MainAxisSize
    //                                                                 .min,
    //                                                         children: [
    //                                                           InkWell(
    //                                                             onTap: isEnable
    //                                                                 ? () {
    //                                                                     _addOrRemove(
    //                                                                         setStateAnimate,
    //                                                                         enableMultSelect,
    //                                                                         field,
    //                                                                         e);
    //                                                                     streamController
    //                                                                         .sink
    //                                                                         .add(field);
    //                                                                   }
    //                                                                 : null,
    //                                                             child:
    //                                                                 Container(
    //                                                               margin:
    //                                                                   const EdgeInsets
    //                                                                       .all(
    //                                                                       2),
    //                                                               decoration:
    //                                                                   const BoxDecoration(
    //                                                                 color: Colors
    //                                                                     .white,
    //                                                                 shape: BoxShape
    //                                                                     .circle,
    //                                                               ),
    //                                                               child: const Icon(
    //                                                                   Icons
    //                                                                       .close_outlined,
    //                                                                   size: 22,
    //                                                                   color: Colors
    //                                                                       .black),
    //                                                             ),
    //                                                           ),
    //                                                           Padding(
    //                                                             padding:
    //                                                                 const EdgeInsets
    //                                                                     .all(5),
    //                                                             child: Text(
    //                                                               label,
    //                                                               style: const TextStyle(
    //                                                                   color: Colors
    //                                                                       .white),
    //                                                             ),
    //                                                           ),
    //                                                         ],
    //                                                       ),
    //                                                     ),
    //                                                   );
    //                                                 },
    //                                               ),
    //                                             );
    //                                           },
    //                                         ).toList(),
    //                                       ],
    //                                     )
    //                                   : Visibility(
    //                                       visible: field.valor.valor != null,
    //                                       child: SingleChildScrollView(
    //                                         scrollDirection: Axis.horizontal,
    //                                         child: Row(
    //                                           mainAxisSize: MainAxisSize.min,
    //                                           children: [
    //                                             StatefulBuilder(
    //                                               builder: (context,
    //                                                   setStateAnimate) {
    //                                                 return AnimatedScale(
    //                                                   scale:
    //                                                       field.valor.valor ==
    //                                                               null
    //                                                           ? 0
    //                                                           : 1,
    //                                                   onEnd: () {
    //                                                     setState(() {});
    //                                                   },
    //                                                   duration: const Duration(
    //                                                       milliseconds: 200),
    //                                                   child: Container(
    //                                                     decoration:
    //                                                         BoxDecoration(
    //                                                       color: Colors.blue,
    //                                                       borderRadius:
    //                                                           BorderRadius
    //                                                               .circular(16),
    //                                                       border: Border.all(
    //                                                         color: Colors.black,
    //                                                       ),
    //                                                     ),
    //                                                     margin: const EdgeInsets
    //                                                         .all(5),
    //                                                     child: Row(
    //                                                       mainAxisSize:
    //                                                           MainAxisSize.min,
    //                                                       children: [
    //                                                         InkWell(
    //                                                           onTap: isEnable
    //                                                               ? () {
    //                                                                   setStateAnimate(
    //                                                                     () {
    //                                                                       field.valor.valor =
    //                                                                           null;
    //                                                                       streamController
    //                                                                           .sink
    //                                                                           .add(field);
    //                                                                     },
    //                                                                   );
    //                                                                 }
    //                                                               : null,
    //                                                           child: Container(
    //                                                             margin:
    //                                                                 const EdgeInsets
    //                                                                     .all(2),
    //                                                             decoration:
    //                                                                 const BoxDecoration(
    //                                                               color: Colors
    //                                                                   .white,
    //                                                               shape: BoxShape
    //                                                                   .circle,
    //                                                             ),
    //                                                             child: const Icon(
    //                                                                 Icons
    //                                                                     .close_outlined,
    //                                                                 size: 22,
    //                                                                 color: Colors
    //                                                                     .black),
    //                                                           ),
    //                                                         ),
    //                                                         Padding(
    //                                                           padding:
    //                                                               const EdgeInsets
    //                                                                   .all(5),
    //                                                           child: Text(
    //                                                             style: const TextStyle(
    //                                                                 color: Colors
    //                                                                     .white),
    //                                                             field
    //                                                                 .valor.valor
    //                                                                 .toString(),
    //                                                           ),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                 );
    //                                               },
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                       Visibility(
    //                         visible: isEnable,
    //                         child: Column(
    //                           mainAxisSize: MainAxisSize.min,
    //                           children: [
    //                             Visibility(
    //                               visible: showBoxSelectedItens,
    //                               child: AnimatedScale(
    //                                 scale: (isList
    //                                         ? (field.valor.valor.isEmpty)
    //                                         : (field.valor.valor == null))
    //                                     ? 0
    //                                     : 1,
    //                                 onEnd: () {
    //                                   setState(() {});
    //                                 },
    //                                 duration: const Duration(milliseconds: 300),
    //                                 child: const Icon(Icons.arrow_drop_down),
    //                               ),
    //                             ),
    //                             SingleChildScrollView(
    //                               scrollDirection: Axis.horizontal,
    //                               child: Container(
    //                                 width: constraints.maxWidth,
    //                                 decoration: BoxDecoration(
    //                                   borderRadius: BorderRadius.circular(5),
    //                                   border: Border.all(
    //                                     color: f.errorText == null
    //                                         ? Colors.transparent
    //                                         : Colors.red,
    //                                   ),
    //                                 ),
    //                                 child: DropdownMenu(
    //                                   width: constraints.maxWidth - 10,
    //                                   trailingIcon: Transform.rotate(
    //                                     angle: 90 * 3.14 / 180,
    //                                     child: const Icon(
    //                                       Icons.arrow_forward_ios,
    //                                       color: Colors.black,
    //                                     ),
    //                                   ),
    //                                   initialSelection: isList ? null : null,
    //                                   enableSearch: true,
    //                                   expandedInsets: EdgeInsets.zero,
    //                                   textStyle:
    //                                       const TextStyle(color: Colors.black),
    //                                   hintText: hintText,
    //                                   menuStyle: MenuStyle(
    //                                       fixedSize: MaterialStateProperty.all<
    //                                               Size?>(
    //                                           Size(constraints.maxWidth, 200))),
    //                                   enableFilter: true,
    //                                   dropdownMenuEntries: itens.map(
    //                                     (e) {
    //                                       String label = e.toString();
    //                                       // try {
    //                                       //   label = e.toStringCustom();
    //                                       // } catch (e) {
    //                                       //   log(e.toString());
    //                                       // }
    //                                       return DropdownMenuEntry(
    //                                         labelWidget: SizedBox(
    //                                           child: Text(
    //                                             label,
    //                                             maxLines: 1,
    //                                             overflow: TextOverflow.ellipsis,
    //                                           ),
    //                                         ),
    //                                         trailingIcon:
    //                                             const SizedBox.shrink(),
    //                                         leadingIcon: Checkbox(
    //                                           value: isList
    //                                               ? (field.valor.valor
    //                                                   .contains(e))
    //                                               : (field.valor.valor == e),
    //                                           onChanged: isEnable
    //                                               ? (d) {
    //                                                   if (isList) {
    //                                                     _addOrRemove(
    //                                                       setState,
    //                                                       enableMultSelect,
    //                                                       field,
    //                                                       e,
    //                                                     );
    //                                                   } else {
    //                                                     if (field.valor.valor ==
    //                                                         e) {
    //                                                       field.valor.valor =
    //                                                           null;
    //                                                     } else {
    //                                                       field.valor.valor = e;
    //                                                     }
    //                                                     setState(() {});
    //                                                   }
    //                                                   streamController.sink
    //                                                       .add(field);
    //                                                 }
    //                                               : null,
    //                                         ),
    //                                         style: ButtonStyle(
    //                                           elevation: MaterialStateProperty
    //                                               .all<double>(0),
    //                                           maximumSize: MaterialStateProperty
    //                                               .all<Size?>(Size(
    //                                                   constraints.maxWidth,
    //                                                   50)),
    //                                           padding: MaterialStateProperty
    //                                               .all<EdgeInsetsGeometry?>(
    //                                             const EdgeInsets.all(0),
    //                                           ),
    //                                         ),
    //                                         value: e,
    //                                         label: label,
    //                                       );
    //                                     },
    //                                   ).toList(),
    //                                   onSelected: (value) {
    //                                     if (isEnable) {
    //                                       if (value == null) {
    //                                         return;
    //                                       }
    //                                       try {
    //                                         var list =
    //                                             field.valor.valor as List;
    //                                         final element = list
    //                                             .where((element) =>
    //                                                 element.id == value.id)
    //                                             .firstOrNull;
    //                                         if (element != null) {
    //                                           list.remove(element);
    //                                         } else {
    //                                           if (!enableMultSelect) {
    //                                             list.clear();
    //                                           }
    //                                           list.add(value);
    //                                         }
    //                                       } catch (error) {
    //                                         try {
    //                                           var list =
    //                                               field.valor.valor as List;
    //                                           if (list.contains(value)) {
    //                                             list.remove(value);
    //                                           } else {
    //                                             if (!enableMultSelect) {
    //                                               list.clear();
    //                                             }
    //                                             list.add(value);
    //                                           }
    //                                         } catch (e) {
    //                                           if (field.valor.valor == null) {
    //                                             field.valor.valor = value;
    //                                           } else {
    //                                             field.valor.valor = null;
    //                                           }
    //                                         }
    //                                       }
    //                                       setState(() {});
    //                                       streamController.sink.add(field);
    //                                     }
    //                                   },
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       AnimatedOpacity(
    //                         opacity: f.errorText == null ? 0 : 1,
    //                         duration: const Duration(milliseconds: 300),
    //                         child: Text(
    //                           f.errorText ?? '',
    //                           style: const TextStyle(
    //                               color: Colors.red, fontSize: 12),
    //                         ),
    //                       ),
    //                     ],
    //                   );
    //                 },
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     },
    //   ),

    _ => Text(field.valor.valor.toString()),
  };
  return (
    widget: Container(
      key: Key(field.hashCode.toString()),
      child: w,
    ),
    onAction: stream
  );
}
