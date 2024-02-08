class ResultUtil {
  final List<dynamic> _list = [];
  ({
    bool enableMultSelect,
    List<dynamic> itens,
    bool showLabelFieldName,
    bool showBoxSelectedItens,
    bool enableSeach,
  })? listOptions;
  dynamic valor;

  ResultUtil({this.valor, this.listOptions}) {
    if (listOptions != null) {
      if (listOptions!.enableMultSelect) {
        if (listOptions!.itens.runtimeType != valor.runtimeType) {
          throw Exception('listOptions type must be equal to valor type');
        }
      }
    }
  }
  @override
  String toString() {
    // TODO: implement toString
    return valor.runtimeType.toString();
  }
}

class ValidatorUtil {
  dynamic valor;
  ({
    bool isValid,
    String message,
  })
      Function(dynamic valor)? validator;
  ValidatorUtil({this.validator});
}
