import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import '../values/app_routes.dart';
import '../components/app_text_form_field.dart';
import '../utils/extensions.dart';
import '../values/app_colors.dart';
import '../values/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool isLoggingIn = false;

class _LoginPageState extends State<LoginPage> {
  
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
                Container(
                  height: size.height,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
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
                      AppTextFormField(
                        labelText: 'Usuário',
                        maxLength: 20,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        
                        onChanged: (value) {
                          _formKey.currentState?.validate();
                        },
                        validator: (value) {
                          return value!.isEmpty
                              ? 'Por favor, preencha o campo com um e-mail válido'
                              : value.trim() != value 
                              ? 'Por favor, preencha o campo com um e-mail válido'
                              : AppConstants.emailRegex.hasMatch(value)
                                  ? null
                                  : 'E-mail inválido';
                        },
                        controller: emailController,
                        prefixIcon: Icon(Icons.account_box),
                      ),
                      AppTextFormField(
                        labelText: 'Senha',
                        maxLength: 20,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          _formKey.currentState?.validate();
                        },
                        validator: (value) {
                          return value!.isEmpty
                              ? 'Por favor, insira a senha'
                              : value.length <= 2 
                              ? 'Sua senha deve conter mais que 2 caracteres'
                              : AppConstants.passwordRegex.hasMatch(value)
                                  ? null
                                  : 'Senha inválida';
                        },
                        controller: passwordController,
                        obscureText: isObscure,
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                const Size(48, 48),
                              ),
                            ),
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FilledButton(
                        onPressed:  () {
                              setState(() {
                                final isValidForm = _formKey.currentState!.validate();
                                  if (isValidForm) {
                                    authenticate(emailController.text,passwordController.text);
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Por favor, verifique os campos.'),
                                    ),
                                  );
                                  }
                              });
                              }
                            ,
                        style: const ButtonStyle().copyWith(
                          backgroundColor: MaterialStateProperty.all(Color.fromRGBO(88,190,110,1)),
                        ),
                        child: 
                            !isLoggingIn 
                            ? Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                            )
                            : LoadingAnimationWidget.fourRotatingDots(
                                color: Colors.white,
                                size: 20,
                              )
                          ,
                      ),
                      const SizedBox(
                        height: 90,
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
      ),
    );
    
  }

    Future<void> authenticate(email,password) async{
    
    isLoggingIn = true;
    var userFound = false;

    //CONSUMIRÁ O SERVIÇO DE UM MOCKAPI EXTERNO
    final response = await http.get(
        Uri.parse('$baseApi/users')
    );

    //A MOCKAPI APENAS RETORNA UMA LISTA DOS DADOS CADASTRADOS.
    //POR ESSE MOTIVO A AUTENTIÇÃO ESTÁ SENDO REALIZADA NO FRONT.
    final users = jsonDecode(response.body);
    users.map((user) {
        if (user['email'].toString() == email && user['password'].toString() == password){
            //SE USUÁRIO E SENHA FOREM ENCONTRADOS A TELA SEGUINTE É CARREGADA
            AppRoutes.informationCollectionScreen.pushName();
            userFound = true;
        }
    }).toList();

    //SE NÃO ENCONTRAR USUÁRIO E SENHA, EXIBE A MENSAGEM
    setState(() {
      if(!userFound){
        isLoggingIn = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Usuário e/ou senha inválido(s)'),
        ));
      }
    });

  }

  //MÉTODO PARA ACESSAR SITE EXTERNO
  launchURL() async {
    const url = 'https://google.com.br';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Não foi possível acessar $url';
      }
  }

}

