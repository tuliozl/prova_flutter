import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'texts.g.dart';

class Texts = _Texts with _$Texts;

abstract class _Texts with Store{
  @observable
  List<dynamic> value = [];

  @action 
 loadText() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    final textArray = pref.getStringList('texto') ?? [];
    value = textArray;
  }

  @action
  void addNewText(text){
    value = [...value,text];
  }

}

final textItems = Texts();