import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _carregando = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  final _userService = UserService();

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final String email = _emailController.text.trim().toLowerCase();
      final String password = _senhaController.text;

      print('[Register] Iniciando cadastro para: $email');
      final UserModel newUser = UserModel(
        name: _nomeController.text.trim(),
        phone: _telefoneController.text.trim(),
        email: email,
      );

      print('[Register] Chamando UserService.createUser...');
      await _userService.createUser(user: newUser, password: password);
      print('[Register] UserService.createUser concluído!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro ao cadastrar.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este e-mail já está cadastrado.';
          break;
        case 'weak-password':
          message = 'A senha informada é muito fraca.';
          break;
        case 'invalid-email':
          message = 'Informe um e-mail válido.';
          break;
        case 'operation-not-allowed':
          message = 'O cadastro por e-mail não está habilitado no Firebase.';
          break;
        case 'network-request-failed':
          message = 'Erro de conexão. Verifique sua internet.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Aguarde alguns instantes.';
          break;
        case 'invalid-credential':
          message = 'As credenciais informadas são inválidas.';
          break;
        default:
          message = 'Erro ao cadastrar: ${e.message ?? e.code}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String? _validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome';
    }
    if (value.trim().length < 2) {
      return 'Nome muito curto';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o telefone';
    }
    final digitos = value.replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter ao menos 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme a senha';
    }
    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Preencha seus dados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre-se para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nomeController,
                      keyboardType: TextInputType.name,
                      validator: _validarNome,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        label: 'Nome completo',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validarTelefone,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _TelefoneInputFormatter(),
                      ],
                      decoration: _buildInputDecoration(
                        label: 'Telefone',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validarEmail,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        label: 'E-mail',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscureSenha,
                      validator: _validarSenha,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        label: 'Senha',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _obscureSenha = !_obscureSenha);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: _obscureConfirmarSenha,
                      validator: _validarConfirmarSenha,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        label: 'Confirmar Senha',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmarSenha = !_obscureConfirmarSenha);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _fazerCadastro,
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'CADASTRAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _carregando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Já tem conta? Entrar',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
    );
  }
}

class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatado = _aplicarMascara(digitos);

    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }

  String _aplicarMascara(String digitos) {
    if (digitos.isEmpty) return '';
    if (digitos.length <= 2) {
      return '($digitos';
    }
    if (digitos.length <= 7) {
      return '(${digitos.substring(0, 2)}) ${digitos.substring(2)}';
    }
    if (digitos.length <= 11) {
      return '(${digitos.substring(0, 2)}) ${digitos.substring(2, 7)}-${digitos.substring(7)}';
    }
    return '(${digitos.substring(0, 2)}) ${digitos.substring(2, 7)}-${digitos.substring(7, 11)}';
  }
}