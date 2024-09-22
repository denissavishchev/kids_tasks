import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/login_provider.dart';
import '../../widgets/button_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: kGrey,
      body: SafeArea(
          child: Consumer<LoginProvider>(
            builder: (context, data, _){
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: size.width,
                            height: 40,
                            child: Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                    onPressed: () => data.toLoginScreen(context),
                                    icon: const Icon(Icons.clear, size: 34,))
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => data.selectRole('parent'),
                                child: Container(
                                  width: size.width * 0.45,
                                  height: size.height * 0.4,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: kBlue.withOpacity(data.role == 'parent' ? 0.8 : 0.3),
                                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: Image.asset('assets/images/selectParents.png'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => data.selectRole('child'),
                                child: Container(
                                  width: size.width * 0.45,
                                  height: size.height * 0.4,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: kBlue.withOpacity(data.role == 'child' ? 0.8 : 0.3),
                                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: Image.asset('assets/images/selectKids.png'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18,),
                          Form(
                            key: data.registerKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: data.nameController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: kDarkGrey,
                                  decoration: textFieldDecoration.copyWith(
                                      label: const Text('Имя',)),
                                  maxLength: 64,
                                  validator: (value){
                                    if(value == null || value.isEmpty) {
                                      return 'Это поле не может быть пустым';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: data.surnameController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: kDarkGrey,
                                  decoration: textFieldDecoration.copyWith(
                                      label: const Text('Фамилия',)),
                                  maxLength: 64,
                                  validator: (value){
                                    if(value == null || value.isEmpty) {
                                      return 'Это поле не может быть пустым';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: data.emailController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: kDarkGrey,
                                  decoration: textFieldDecoration.copyWith(
                                      label: const Text('Электронная почта',)),
                                  maxLength: 64,
                                  validator: (value){
                                    if(value == null || value.isEmpty) {
                                      return 'Это поле не может быть пустым';
                                    }else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value)){
                                      return 'Неправильный адрес электронной почты';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18,),
                                TextFormField(
                                  controller: data.passwordController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: kDarkGrey,
                                  obscureText: !data.isSignUpPasswordVisible,
                                  decoration: textFieldDecoration.copyWith(
                                      label: const Text('Пароль',),
                                      suffixIcon: IconButton(
                                          onPressed: () => data.switchSignUpPasswordVisibility(),
                                          icon: Icon(data.isSignUpPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility))),
                                  maxLength: 64,
                                  validator: (value){
                                    if(value == null || value.isEmpty) {
                                      return 'Это поле не может быть пустым';
                                    }else if(data.passwordController.text != data.confirmPasswordController.text){
                                      return 'Пароли должны быть одинаковыми';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18,),
                                TextFormField(
                                  controller: data.confirmPasswordController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  cursorColor: kDarkGrey,
                                  obscureText: !data.isSignUpPasswordVisible,
                                  decoration: textFieldDecoration.copyWith(
                                      label: const Text('Подтвердите пароль',),
                                      suffixIcon: IconButton(
                                          onPressed: () => data.switchSignUpPasswordVisibility(),
                                          icon: Icon(data.isSignUpPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility))),
                                  maxLength: 64,
                                  validator: (value){
                                    if(value == null || value.isEmpty) {
                                      return 'Это поле не может быть пустым';
                                    }else if(data.passwordController.text != data.confirmPasswordController.text){
                                      return 'Пароли должны быть одинаковыми';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 36,),
                                ButtonWidget(
                                    onTap: () {
                                      if(data.registerKey.currentState!.validate()){
                                        data.signUp(context);
                                      }
                                    },
                                    text: 'Зарегистрироваться'
                                ),
                                SizedBox(
                                  height: MediaQuery.viewInsetsOf(context).bottom == 0
                                      ? size.height * 0.05 : size.height * 0.4,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data.isLoading
                      ? Container(
                          width: size.width,
                          height: size.height,
                          color: kGrey.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator(color: kBlue,),),
                        ) : const SizedBox.shrink()
                ],
              );
            },
          )
      ),
    );
  }
}
