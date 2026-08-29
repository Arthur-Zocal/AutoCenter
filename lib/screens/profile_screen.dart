import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  UserModel? _userModel;

  bool get _isEditing => _isEditingName || _isEditingPhone;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = await _userService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userModel = user;
        if (user != null) {
          _nameController.text = user.name;
          _phoneController.text = user.phone;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    print('[ProfileScreen] Iniciando salvamento...');
    setState(() => _isLoading = true);

    try {
      print('[ProfileScreen] Chamando updateUserProfile...');
      await _userService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      print('[ProfileScreen] updateUserProfile concluído!');

      if (!mounted) return;

      setState(() {
        _isEditingName = false;
        _isEditingPhone = false;
        _userModel = _userModel?.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('[ProfileScreen] ERRO: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      print('[ProfileScreen] Finally - resetando loading');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _toggleEditName() {
    setState(() => _isEditingName = !_isEditingName);
  }

  void _toggleEditPhone() {
    setState(() => _isEditingPhone = !_isEditingPhone);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _userModel == null && !_isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.2),
                    child: Text(
                      _userModel?.name.isNotEmpty == true
                          ? _userModel!.name[0].toUpperCase()
                          : currentUser?.email?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userModel?.name ?? 'Carregando...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Informações Pessoais',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildEditableField(
                              label: ' ',
                              icon: Icons.person_outline,
                              controller: _nameController,
                              isEditing: _isEditingName,
                              onToggleEdit: _toggleEditName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o nome';
                                }
                                if (value.trim().length < 2) {
                                  return 'Nome muito curto';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildEditableField(
                              label: '',
                              icon: Icons.phone_outlined,
                              controller: _phoneController,
                              isEditing: _isEditingPhone,
                              onToggleEdit: _toggleEditPhone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _TelefoneInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o telefone';
                                }
                                final digitos = value.replaceAll(RegExp(r'\D'), '');
                                if (digitos.length < 10 || digitos.length > 11) {
                                  return 'Telefone inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              initialValue: currentUser?.email ?? '',
                              enabled: false,
                              style: TextStyle(color: Colors.grey.shade400),
                              decoration: _buildInputDecoration(
                                label: '',
                                icon: Icons.email_outlined,
                                suffixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                              ),
                            ),

                            if (_isEditing) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'SALVAR ALTERAÇÕES',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                      title: const Text(
                        'Sair da conta',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      onTap: _signOut,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'AZ Auto Center',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggleEdit,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: isEditing ? Colors.white : Colors.grey.shade300,
      ),
      decoration: _buildInputDecoration(
        label: label,
        icon: icon,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (suffixIcon != null) suffixIcon,
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: isEditing ? Colors.green : const Color(0xFFD32F2F),
                  size: 22,
                ),
                onPressed: onToggleEdit,
                tooltip: isEditing ? 'Concluir' : 'Editar',
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
      validator: validator,
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
      fillColor: const Color(0xFF121212),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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