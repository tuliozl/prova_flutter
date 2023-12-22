import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

import '../utils/extensions.dart';
import '../values/app_colors.dart';
import '../components/texts.dart';
import 'package:flutter_mobx/flutter_mobx.dart';


class InformationCollectionPage extends StatefulWidget {
  const InformationCollectionPage({super.key});

  @override
  State<InformationCollectionPage> createState() => _InformationCollectionPageState();
}

 
class _InformationCollectionPageState extends State<InformationCollectionPage> {
  
  TextEditingController textController = TextEditingController();

  FocusNode myFocusNode = FocusNode();

  bool isEditing = false;
  int currentEdition = -1;

  @override
  void initState() {
    super.initState();
    textItems.loadText();
  }
 
  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            children: [
                Container(
                  height: size.height,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(37,75,92,1),
                        Color.fromRGBO(57,150,141,1),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        SizedBox(
                        height: 450,
                        child: Observer(builder: (_) => 
                              textItems.value.isEmpty 
                                ? Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 180),
                                    child: Card(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min, 
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 5)
                                          ),
                                          ListTile(
                                            title: Text(
                                              "Não há textos cadastrados",
                                              textAlign: TextAlign.center
                                              ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                
                              
                              : ListView.builder(
                              itemCount: textItems.value.length,
                              itemBuilder: (context, index) {
                                final item = textItems.value[index];
                                return Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, 
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                            Tooltip(
                                              message: (isEditing && index == currentEdition) ? 'Cancelar Edição' : 'Editar texto',
                                              child:
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if(isEditing && index == currentEdition){
                                                        isEditing = false;
                                                        currentEdition = -1;
                                                        textController.clear();
                                                      }else{
                                                        isEditing = true;
                                                        currentEdition = index;
                                                        textController.text = item.toString();
                                                      }
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    minimumSize: MaterialStateProperty.all(
                                                      const Size(28, 28),
                                                    ),
                                                  ),
                                                  icon: Icon((isEditing && index == currentEdition) ? Icons.edit_off : Icons.edit,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                          const SizedBox(width: 8),
                                          Tooltip(
                                            message: 'Excluir texto',
                                            child:IconButton(
                                              onPressed: () async {
                                                    if (await confirm(
                                                      context,
                                                      title: const Text('Atenção!'),
                                                      content: const Text('Deseja realmente excluir este texto?'),
                                                      textOK: const Text('Sim'),
                                                      textCancel: const Text('Cancelar'),
                                                    )) {
                                                      removeItem(index);
                                                    }
                                                    
                                                  },
                                              style: ButtonStyle(
                                                minimumSize: MaterialStateProperty.all(
                                                  const Size(28, 28),
                                                ),
                                              ),
                                              icon: Icon(Icons.close_rounded,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                      ListTile(
                                        title: Text(item.toString()),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Focus(
                        child: 
                            TextField(
                              controller: textController,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              focusNode: myFocusNode,
                              
                              onSubmitted: (value) async {
                                if(value.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Por favor, insira um texto.'),
                                    ),
                                  );
                                }else{
                                  if(!isEditing){
                                    addNewText(value); 
                                  }else{
                                    editText(value,currentEdition);
                                  }
                                  isEditing = false;
                                  currentEdition = -1;
                                  textController.clear();
                                  myFocusNode.requestFocus();
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 10.0),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                fillColor: Colors.white,
                                labelText: "Digite seu texto",
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                )
                              ),
                            ),
                        onFocusChange: (val) => {
                          myFocusNode.requestFocus()
                        },
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color.fromRGBO(1, 1, 1,0),
                            ),
                          ),
                          TextButton(
                            onPressed: launchURL,
                            style: Theme.of(context).textButtonTheme.style,
                            child: Text(
                              'Política de Privacidade',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color.fromRGBO(1, 1, 1,0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ),
    );
  }

  addNewText(value) async{
    SharedPreferences pref = await SharedPreferences.getInstance();

    final textos = pref.getStringList('texto') ?? [];

    pref.setStringList('texto', [...textos,value]);
    textItems.addNewText(value);
  }

  launchURL() async {
    const url = 'https://google.com.br';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Não foi possível acessar $url';
      }
  }

  removeItem(index) async {
    //CARREGA OS TEXTOS ARMAZENADOS
    SharedPreferences pref = await SharedPreferences.getInstance();
    final textos = pref.getStringList('texto') ?? [];

    //REMOVE O ITEM SELECIONADO
    textos.removeAt(index);

    //GRAVA A NOVA LISTA
    pref.setStringList('texto', textos);
    
    //ATUALIZA A LISTA 
    textItems.loadText(); 
  }

  editText(value,index) async{ 
    //CARREGA OS TEXTOS ARMAZENADOS
    SharedPreferences pref = await SharedPreferences.getInstance();
    final textos = pref.getStringList('texto') ?? [];
    
    //ALTERA O VALOR NA LISTA
    textos[index] = value;

    //GRAVA A NOVA LISTA
    pref.setStringList('texto', textos);
    
    //ATUALIZA A LISTA 
    textItems.loadText(); 
  }
}

