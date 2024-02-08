// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomModalMultSelect<T> extends StatelessWidget {
  final List<T> list;
  List<T> _list = [];
  List<T> _listSelected = [];

  void Function(T? value) onChange;
  bool? withSearch;
  ({bool? required, String? Function(List<T>? value)? validator})? required;

  List<T>? selectedItens;
  String label;
  bool _search = false;
  bool _search2 = false;
  EdgeInsets? padding;
  String? labelSelectedItem;
  String? Function(Object?)? validator;
  Function(List<T>? list) onConfirm;
  Function(T item) onRemove;
  Function() onCancel;

  CustomModalMultSelect({
    super.key,
    required this.onCancel,
    required this.onRemove,
    this.selectedItens,
    required this.onConfirm,
    required this.list,
    required this.onChange,
    required this.label,
    this.withSearch,
    this.required,
    this.padding,
    this.labelSelectedItem,
  }) {
    _list = list;
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: selectedItens,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (required?.required ?? false
          ? (value) => required!.validator!(value as List<T>?)
          : null),
      builder: (formFieldState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: padding ??
                    const EdgeInsets.only(
                      bottom: 5,
                      top: 5,
                    ),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: InputDecorator(
                    baseStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      errorText: formFieldState.errorText,
                      label: Text(
                        maxLines: 2,
                        '${(required?.required ?? false) ? '*' : ''}$label',
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Wrap(
                                children: selectedItens
                                        ?.map(
                                          (e) => SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.blue,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      onRemove(e);
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: const Icon(
                                                        color: Colors.white,
                                                        Icons.cancel,
                                                      ),
                                                    ),
                                                  ),
                                                  const Gap(10),
                                                  Text(
                                                    e.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const Gap(10),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        InkWell(
                          onTap: () {
                            _search = false;
                            _list = list;
                            List<T> listSelectedDelete = [];
                            showDialog(
                              context: context,
                              builder: (context) {
                                _listSelected = [...(selectedItens ?? [])];
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    listSelectedDelete = _listSelected;
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      insetPadding: EdgeInsets.zero,
                                      titlePadding: EdgeInsets.zero,
                                      iconPadding: EdgeInsets.zero,
                                      buttonPadding: EdgeInsets.zero,
                                      actionsPadding: EdgeInsets.zero,
                                      content: SizedBox(
                                        width: math.min(
                                            (listSelectedDelete.isEmpty
                                                ? 700
                                                : 1000),
                                            MediaQuery.sizeOf(context).width *
                                                .9),
                                        height: math.min(
                                            600,
                                            MediaQuery.sizeOf(context).height *
                                                0.8),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                child: LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  return Scaffold(
                                                    appBar: AppBar(
                                                      leading: const SizedBox
                                                          .shrink(),
                                                      title: !_search
                                                          ? Text(label)
                                                          : null,
                                                      actions: [
                                                        Visibility(
                                                          visible: withSearch ??
                                                              false,
                                                          child: Visibility(
                                                            visible: _search,
                                                            replacement:
                                                                IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    _search =
                                                                        true;
                                                                  },
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                  Icons.search),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: constraints
                                                                          .maxWidth *
                                                                      0.7,
                                                                  child:
                                                                      TextField(
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                        () {
                                                                          _list = list
                                                                              .where((e) => e.toString().toLowerCase().contains(value.toLowerCase()))
                                                                              .toList();
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                const Gap(20),
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                      () {
                                                                        _list =
                                                                            list;
                                                                        _search =
                                                                            false;
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .search_off),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(
                                                                () {
                                                                  formFieldState
                                                                      .didChange(
                                                                          null);
                                                                  onChange(
                                                                      null);
                                                                  setState(
                                                                      () {});
                                                                },
                                                              );
                                                            },
                                                            icon: const Icon(Icons
                                                                .delete_outline_outlined))
                                                      ],
                                                    ),
                                                    body: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            child: GridView
                                                                .builder(
                                                              gridDelegate:
                                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                                      mainAxisExtent:
                                                                          50,
                                                                      crossAxisCount:
                                                                          1),
                                                              itemCount:
                                                                  _list.length,
                                                              shrinkWrap: true,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final e = _list[
                                                                    index];
                                                                return Card(
                                                                  child:
                                                                      ListTile(
                                                                    selectedColor:
                                                                        Colors
                                                                            .white,
                                                                    selectedTileColor:
                                                                        Colors
                                                                            .blue,
                                                                    selected: _listSelected
                                                                        .contains(
                                                                            e),
                                                                    onTap: () {
                                                                      if (_listSelected
                                                                          .contains(
                                                                              e)) {
                                                                        _listSelected
                                                                            .remove(e);
                                                                      } else {
                                                                        _listSelected
                                                                            .add(e);
                                                                      }

                                                                      onChange(
                                                                          e);

                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    title: Text(
                                                                      e.toString(),
                                                                    ),
                                                                    subtitle:
                                                                        const Divider(),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          color: Colors.blue,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Text(
                                                                'Selecionados: ${_listSelected.length}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(
                                                                    () {
                                                                      _listSelected =
                                                                          [
                                                                        ...(selectedItens ??
                                                                            [])
                                                                      ];
                                                                    },
                                                                  );
                                                                  formFieldState
                                                                      .didChange(
                                                                          selectedItens);
                                                                  onCancel();
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  formFieldState
                                                                      .didChange(
                                                                          _listSelected);
                                                                  onConfirm(
                                                                      _listSelected);
                                                                },
                                                                child: Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green
                                                                      .shade300,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  (MediaQuery.sizeOf(context)
                                                              .width >
                                                          600)
                                                      ? (listSelectedDelete
                                                          .isNotEmpty)
                                                      : false,
                                              child: Flexible(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setStateB) {
                                                          return Scaffold(
                                                            appBar: AppBar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              leading:
                                                                  const SizedBox
                                                                      .shrink(),
                                                              title: !_search2
                                                                  ? Text(label)
                                                                  : null,
                                                              actions: [
                                                                Visibility(
                                                                  visible:
                                                                      withSearch ??
                                                                          false,
                                                                  child:
                                                                      Visibility(
                                                                    visible:
                                                                        _search2,
                                                                    replacement:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                          () {
                                                                            _search2 =
                                                                                true;
                                                                          },
                                                                        );
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .search),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              constraints.maxWidth * 0.7,
                                                                          child:
                                                                              TextField(
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                            ),
                                                                            onChanged:
                                                                                (value) {
                                                                              setStateB(
                                                                                () {
                                                                                  listSelectedDelete = _listSelected.where((e) => e.toString().toLowerCase().contains(value.toLowerCase())).toList();
                                                                                },
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const Gap(
                                                                            20),
                                                                        IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(
                                                                              () {
                                                                                listSelectedDelete = _listSelected;
                                                                                _search2 = false;
                                                                              },
                                                                            );
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.search_off),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                      () {
                                                                        _listSelected =
                                                                            [];

                                                                        setState(
                                                                            () {});
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete_outline_outlined),
                                                                )
                                                              ],
                                                            ),
                                                            body: ListView
                                                                .separated(
                                                              itemCount:
                                                                  listSelectedDelete
                                                                      .length,
                                                              separatorBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      const Divider(),
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final e =
                                                                    listSelectedDelete[
                                                                        index];
                                                                return Card(
                                                                  child:
                                                                      ListTile(
                                                                    trailing:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                          () {
                                                                            setStateB(
                                                                              () {
                                                                                _listSelected.remove(e);
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                    title: Text(
                                                                      e.toString(),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: formFieldState.hasError ? 2 : .4,
                                color: formFieldState.hasError
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            height: 50,
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      ('${selectedItens?.length} selecionado${selectedItens?.length == 1 ? '' : 's'}'),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                ),
                              ],
                            ),
                          ),
                        ),

                        ////////////////////////// COLAR AQUI
                        ///
                        ///
                        ///
                        /////////////////////////
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
