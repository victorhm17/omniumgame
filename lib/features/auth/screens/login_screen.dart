import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:omnium_game/features/auth/cubit/auth_cubit.dart";
import "package:omnium_game/features/auth/repositories/auth_repository.dart"; // Para o LoginCubit se for separado

// Se criarmos um LoginCubit dedicado:
// import 'package:omnium_game/features/auth/cubit/login_cubit/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Supondo que teremos um LoginCubit para gerenciar o estado do formulário de login
  // Se não, usaremos o AuthCubit diretamente para a ação de login.

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Exemplo se tivéssemos um LoginCubit dedicado:
      // context.read<LoginCubit>().logInWithCredentials(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );

      // Usando AuthRepository diretamente (ou através de um LoginCubit que o chame)
      // Esta é uma simplificação, o ideal é ter um Cubit para a tela de Login
      // que lide com o estado de loading e erros do formulário.
      final authRepository = RepositoryProvider.of<AuthRepository>(context);
      authRepository.logInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).then((user) {
        if (user != null) {
          // A navegação será tratada pelo redirect do GoRouter baseado no AuthState
        } else {
          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Falha no login. Verifique suas credenciais.")),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro no login: ${error.toString()}")),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login - OmniumGame"),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro de autenticação: ${state.message}")),
            );
          }
          // A navegação para /home em caso de AuthAuthenticated é tratada pelo GoRouter redirect
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "Bem-vindo(a) de volta!",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu email";
                      }
                      if (!value.contains("@")) { // Validação simples
                        return "Email inválido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira sua senha";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _submitLogin(context),
                    child: const Text("ENTRAR"),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar "Esqueci minha senha"
                    },
                    child: const Text("Esqueceu sua senha?"),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("OU CONECTE-SE COM", style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.facebook), // Usar ícone específico do Facebook
                    label: const Text("ENTRAR COM FACEBOOK"),
                    onPressed: () {
                      context.read<AuthCubit>().logInWithFacebookRequested();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2), // Cor do Facebook
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // TODO: Adicionar botão de login com Instagram
                  // ElevatedButton.icon(
                  //   icon: Icon(Icons.camera_alt), // Usar ícone específico do Instagram
                  //   label: const Text("Entrar com Instagram"),
                  //   onPressed: () {
                  //     // context.read<AuthCubit>().logInWithInstagramRequested();
                  //   },
                  // ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context).go("/signup");
                    },
                    child: const Text("Não tem uma conta? CADASTRE-SE"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

