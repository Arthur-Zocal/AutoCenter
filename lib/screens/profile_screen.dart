import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

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

    setState(() => _isLoading = true);

    try {
      await _userService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

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
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
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
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text('Meu Perfil', style: AppTextStyles.headlineSmall),
      ),
      body: _userModel == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.15),
                    child: Text(
                      _userModel!.name.isNotEmpty
                          ? _userModel!.name[0].toUpperCase()
                          : currentUser?.email?[0].toUpperCase() ?? 'U',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _userModel!.name,
                    style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    currentUser?.email ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    decoration: AppDecorations.card,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Informações Pessoais',
                              style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildEditableField(
                              label: '',
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
                            const SizedBox(height: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              initialValue: currentUser?.email ?? '',
                              enabled: false,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: '',
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.accentPrimary),
                                suffixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textDim,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(height: AppSpacing.xl),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveProfile,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.textOnAccent,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text('SALVAR ALTERAÇÕES'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    decoration: AppDecorations.card,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppColors.error),
                      title: Text(
                        'Sair da conta',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: _signOut,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'AZ Auto Center',
                    style: AppTextStyles.caption,
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
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTextStyles.bodyLarge.copyWith(
        color: isEditing ? AppColors.textPrimary : AppColors.textMuted,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentPrimary),
        suffixIcon: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? AppColors.success : AppColors.accentPrimary,
              size: 22,
            ),
            onPressed: onToggleEdit,
            tooltip: isEditing ? 'Concluir' : 'Editar',
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      validator: validator,
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