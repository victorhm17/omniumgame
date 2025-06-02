import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:omnium_game/features/auth/cubit/auth_cubit.dart";
import "package:omnium_game/features/auth/repositories/auth_repository.dart";
import "package:firebase_auth/firebase_auth.dart"; // Adicionado import para FirebaseAuthException

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController(); // RF01.1
  // TODO: Adicionar controller para Data de Nascimento (RF01.1)
  // TODO: Adicionar controller para Nome (RF01.1)

  bool _termsAccepted = false; // RF01.3

  void _submitSignup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Você precisa aceitar os Termos de Uso e a Política de Privacidade.")),
        );
        return;
      }
      // TODO: Implementar verificação Captcha (RF01.4) - Isso geralmente requer um widget de terceiros ou WebView.

      final authRepository = RepositoryProvider.of<AuthRepository>(context);
      authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // TODO: Passar nome de usuário, data de nascimento, etc.
      ).then((user) {
        if (user != null) {
          // Navegação tratada pelo GoRouter redirect
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cadastro realizado com sucesso! Bem-vindo(a)!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Falha no cadastro. Tente novamente.")),
          );
        }
      }).catchError((error) {
        String errorMessage = "Erro no cadastro.";
        if (error is FirebaseAuthException) {
          if (error.code == 'email-already-in-use') {
            errorMessage = "Este email já está em uso.";
          } else if (error.code == 'weak-password') {
            errorMessage = "A senha é muito fraca.";
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta - OmniumGame"),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro de autenticação: ${state.message}")),
            );
          }
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
                    "Crie sua conta",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // TODO: Adicionar campo Nome (RF01.1)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nome de Usuário",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira um nome de usuário";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu email";
                      }
                      if (!value.contains("@")) {
                        return "Email inválido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // TODO: Adicionar campo Data de Nascimento (RF01.1) - Usar DatePicker
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira sua senha";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirmar Senha",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, confirme sua senha";
                      }
                      if (value != _passwordController.text) {
                        return "As senhas não coincidem";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (bool? value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Mostrar Termos de Uso e Política de Privacidade (RF11.1)
                            // Pode ser um modal, nova tela ou link.
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Termos e Privacidade"),
                                content: const SingleChildScrollView(
                                  child: Text(
                                    "Aqui serão exibidos os Termos de Uso e a Política de Privacidade completos..."
                                    "\n\nPor favor, leia atentamente antes de prosseguir."
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text("FECHAR"),
                                  )
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            "Eu li e concordo com os Termos de Uso e a Política de Privacidade.",
                            style: TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // TODO: Adicionar widget Captcha (RF01.4)
                  // Exemplo: CaptchaWidget(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _submitSignup(context),
                    child: const Text("CADASTRAR"),
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context).go("/login");
                    },
                    child: const Text("Já tem uma conta? FAÇA LOGIN"),
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
