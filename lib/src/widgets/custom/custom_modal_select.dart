// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomModalSelect<T> extends StatelessWidget {
  List<T> list;
  List<T> _list = [];
  void Function(T? value) onChange;
  bool? withSearch;
  ({bool? required, String? Function(T? value)? validator})? required;

  T? value;
  String label;
  bool _search = false;
  EdgeInsets? padding;
  String? labelSelectedItem;
  String? Function(Object?)? validator;

  final FocusNode _focusNodeTf = FocusNode(
    canRequestFocus: true,
  );
  final FocusNode _focusNodeKeyboard = FocusNode(
    canRequestFocus: true,
  );

  CustomModalSelect({
    super.key,
    required this.list,
    required this.onChange,
    required this.value,
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
      autovalidateMode: AutovalidateMode.disabled,
      validator: (required?.required ?? false
          ? (value) => required!.validator!(value as T?)
          : null),
      builder: (formFieldState) => Padding(
        padding: padding ??
            const EdgeInsets.only(
              bottom: 5,
              top: 5,
            ),
        child: InkWell(
          onTap: () {
            _search = false;
            _list = list;
            showDialog(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return KeyboardListener(
                      autofocus: true,
                      focusNode: _focusNodeKeyboard,
                      onKeyEvent: (event) {
                        if (withSearch ?? false) {
                          if (!_focusNodeTf.hasFocus) {
                            setState(() {
                              _search = true;
                              _focusNodeTf.requestFocus();
                              _focusNodeKeyboard.unfocus();
                            });
                          }
                        }
                      },
                      child: AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        insetPadding: EdgeInsets.zero,
                        titlePadding: EdgeInsets.zero,
                        title: AppBar(
                            title: !_search ? Text(label) : null,
                            automaticallyImplyLeading: false,
                            actions: [
                              Visibility(
                                visible: withSearch ?? false,
                                child: Visibility(
                                  visible: _search,
                                  replacement: IconButton(
                                    onPressed: () {
                                      setState(
                                        () {
                                          _search = true;
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.search),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: min(
                                            400,
                                            MediaQuery.sizeOf(context).width *
                                                0.5),
                                        child: TextField(
                                          focusNode: _focusNodeTf,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                _list = list
                                                    .where((e) => e
                                                        .toString()
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                    .toList();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const Gap(20),
                                      IconButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              _list = list;
                                              _search = false;
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.search_off),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        formFieldState.didChange(null);
                                        onChange(null);
                                      },
                                    );
                                  },
                                  icon:
                                      const Icon(Icons.delete_outline_outlined))
                            ]),
                        content: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          height:
                              min(600, MediaQuery.sizeOf(context).height * 0.5),
                          width:
                              min(600, MediaQuery.sizeOf(context).width * 0.8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                height: 1,
                              ),
                              itemCount: _list.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final e = _list[index];
                                return ListTile(
                                  selectedColor: Colors.white,
                                  selectedTileColor: Colors.blue,
                                  selected: value == e,
                                  onTap: () {
                                    onChange(e);
                                    formFieldState.didChange(e);
                                  },
                                  title: Text(
                                    e.toString(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return InputDecorator(
              textAlign: TextAlign.start,
              baseStyle: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                ),
                errorText: formFieldState.errorText,
                hintTextDirection: TextDirection.ltr,
                label: Text(
                  maxLines: 2,
                  '${(required?.required ?? false) ? '*' : ''}$label',
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: Text(
                          labelSelectedItem ?? (value?.toString() ?? ' '))),
                  const Icon(Icons.arrow_drop_down_outlined),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
