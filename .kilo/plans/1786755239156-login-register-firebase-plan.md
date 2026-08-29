# Plano: Telas de Login e Cadastro (AZ Auto Center)

## Contexto

Projeto Flutter (`projeto_autocenter`) de uma autocenter. O `main.dart` atual já possui
tema escuro com cor primária vermelha (`#D32F2F`), uma `SplashScreen` de 3s que leva
diretamente para `AzHomePage`. As telas `lib/screens/login.dart` e `lib/screens/register.dart`
existem mas estão **vazias**.

Objetivo: implementar as telas de login e cadastro para a aula de 21/08/2026, seguindo
os requisitos didáticos e mantendo o visual (cores) já definido no `main.dart`.

## Requisitos (da tarefa)

1. **Tela de Login**
   - Campos: e-mail e senha.
   - Botão de acesso ("Entrar").
   - Botão/link para ir à tela de cadastro ("Cadastrar usuário", se não tiver conta).
   - Validações: campos não preenchidos e formato de e-mail.

2. **Tela de Cadastro**
   - Campos: nome, telefone (com máscara), e-mail e senha.
   - Validações: campos não preenchidos e formato de e-mail.

3. **Cores**: usar as mesmas do `main.dart` (tema escuro, cor primária `#D32F2F`,
   scaffolds escuros).

## Decisões de projeto (já confirmadas)

- **Autenticação**: Firebase Authentication.
- **Navegação**: rotas simples com `Navigator` (Splash → Login → Home).
- **Máscara de telefone**: `TextInputFormatter` customizado (sem pacote extra).

## Importante / Pré-requisito manual (fora do escopo de código)

O projeto **não** tem Firebase configurado (sem `firebase_core`, sem
`google-services.json`/`GoogleService-Info.plist`, sem `flutterfire` CLI). Para o app
compilar e rodar com auth real, será necessário:

1. Criar um projeto no [Firebase Console](https://console.firebase.google.com/).
2. Adicionar os apps (Android/iOS/web) e baixar os arquivos de config
   (`google-services.json` em `android/app/`, `GoogleService-Info.plist` em `ios/Runner/`).
3. Rodar `flutterfire configure` (ou adicionar manualmente) para gerar `lib/firebase_options.dart`.
4. No Firebase Console, habilitar o provedor **E-mail/Senha** (Authentication → Sign-in method).
5. Rodar `flutter pub get`.

O código abaixo será escrito de forma que, **após esses passos**, compile e funcione. Enquanto
o Firebase não estiver configurado, a tentativa de login/cadastro falhará em runtime — o que é
esperado. Se o objetivo for apenas demonstrar a UI/validações em aula, o implementador pode
comentar as chamadas ao Firebase e deixar navegacao local como fallback (deixar isso claro).

## Arquivos a alterar

- `pubspec.yaml` — adicionar dependências Firebase.
- `android/app/build.gradle.kts` — habilitar `isMinifyEnabled`/`isShrinkResources` não
  necessário; apenas garantir `minSdk >= 21` (Firebase exige minSdk 21+; ajustar via
  `flutter.minSdkVersion` ou fixo).
- `lib/main.dart` — inicializar Firebase, ajustar `home` e provedor de auth.
- `lib/screens/login.dart` — implementar tela de login.
- `lib/screens/register.dart` — implementar tela de cadastro.
- `test/widget_test.dart` — atualizar (referência a `MyApp` inexistente) para não quebrar
   `flutter test`.

## Passos de implementação

### 1. `pubspec.yaml` — dependências

Adicionar em `dependencies`:

```yaml
  firebase_core: ^3.x
  firebase_auth: ^5.x
```

> O implementador deve rodar `flutter pub get` e conferir as versões mais recentes
> compatíveis. Como a resolução exata pode variar, deixar nota para usar `flutter pub add
> firebase_core firebase_auth`.

### 2. `android/app/build.gradle.kts` — minSdk

Firebase exige minSdk mínimo. Garantir:

```kotlin
defaultConfig {
    minSdk = maxOf(21, flutter.minSdkVersion)
    // ...
}
```

### 3. `lib/main.dart` — bootstrap + flow

- Inicializar o Firebase antes de `runApp` (após `WidgetsFlutterBinding.ensureInitialized()`).
- Manter o tema atual (`#D32F2F`, escuro).
- Definir `home: const SplashScreen()`.
- Alterar `SplashScreen._navegarParaHome()` para navegar para `LoginScreen` em vez de
  `AzHomePage` (fluxo Splash → Login → Home).
- Tratar erro de init do Firebase (ex.: mensagem amigável) caso `firebase_options.dart`
  não exista ainda.

### 4. `lib/screens/login.dart` — Login

Visual seguindo o tema escuro atual (inputs com fundo `#1E1E1E`, cor primária
`#D32F2F`, logo no topo reusando `assets/images/Logo AZ Autocenter.png` se existir,
senão ícone).

Campos e validação (no `Form` + `GlobalKey<FormState>`):
- **E-mail** (`TextFormField`, `keyboardType: emailAddress`):
  - vazio → "Informe o e-mail"
  - regex inválido → "E-mail inválido"
- **Senha** (`TextFormField`, `obscureText: true`):
  - vazio → "Informe a senha"

Ações:
- Botão **"ENTRAR"** → `FirebaseAuth.instance.signInWithEmailAndPassword(...)`.
  - Em sucesso: `Navigator.pushReplacement` para `AzHomePage`.
  - Em erro: `SnackBar` com mensagem amigável (credenciais inválidas / rede).
- Texto/botão **"Não tem conta? Cadastre-se"** → `Navigator.push` para `RegisterScreen`.
- Indicador de loading (`CircularProgressIndicator` com `#D32F2F`) durante a requisição.

### 5. `lib/screens/register.dart` — Cadastro

Campos e validação:
- **Nome** (`TextFormField`):
  - vazio → "Informe o nome"
- **Telefone** (`TextFormField`, `keyboardType: phone`):
  - máscara via `TextInputFormatter` customizado → formato `(XX) XXXXX-XXXX` (Brasil).
  - vazio → "Informe o telefone"
- **E-mail** (`TextFormField`):
  - vazio → "Informe o e-mail"
  - regex → "E-mail inválido"
- **Senha** (`TextFormField`, `obscureText`):
  - vazio → "Informe a senha"
  - mínimo 6 caracteres → "A senha deve ter ao menos 6 caracteres"

Ações:
- Botão **"CADASTRAR"** → `FirebaseAuth.instance.createUserWithEmailAndPassword(...)`.
  - Em sucesso: `Navigator.pop` (volta ao login) **ou** ir direto para `AzHomePage`
    (deixar o implementador escolher; recomendação: voltar ao login com `SnackBar`
    "Cadastro realizado").
  - Em erro: `SnackBar` (e-mail já cadastrado, senha fraca, etc.).
- Link **"Já tem conta? Entrar"** → `Navigator.pop` (volta ao login).

### 6. Máscara de telefone (formatter customizado)

Criar classe (pode ficar em `register.dart` ou helper separado) estendendo
`TextInputFormatter`:

- Mantém só dígitos do input.
- Aplica padrão: `XX XXXXX-XXXX` (até 11 dígitos):
  - 0-2 dígitos → `(XX`
  - 2-7 dígitos → `(XX) XXXXX`
  - 7-11 dígitos → `(XX) XXXXX-XXXX`
- `formatEditUpdate` reconstrói `TextEditingValue` com o texto mascarado e cursor ao final.

### 7. `test/widget_test.dart`

Atualizar para instanciar `AppAutoCenter` (classe atual) em vez de `MyApp`, ou
remover o teste quebrado, para `flutter test` não falhar.

## Cores (referência, já no `main.dart`)

- Primária/seed: `#D32F2F`
- Scaffold/appbar: `#121212` / `#1A1A1A`
- Cards/superfícies: `#1E1E1E`
- Texto: branco / `grey`

## Validação

1. `flutter analyze` — sem erros.
2. `flutter test` — teste do widget ajustado passando.
3. `flutter run` — Splash aparece (~3s) → Login.
4. Testar validações: campos vazios e e-mail inválido devem exibir mensagens.
5. Testar máscara: ao digitar números no telefone, formato `(11) 91234-5678`.
6. Testar navegação: "Cadastre-se" leva ao cadastro; voltar retorna ao login.
7. Com Firebase configurado: login/cadastro reais funcionam e chegam à Home.
   Sem Firebase: apenas a UI/validações são demonstradas (esperado enquanto não
   configurado).

## Riscos / Notas

- **Firebase ainda não está no projeto** → config manual obrigatória antes do auth real.
  Deixar o implementador ciente; opcionalmente adicionar fallback local para a aula.
- **asset do logo**: o usuário quer usar `assets/images/logoAZ_02.png` (novo logo).
  O `pubspec.yaml` deve declarar esse asset, e todas as referências nos Dart
  (`main.dart`, `login.dart`, `register.dart`) devem usar `logoAZ_02.png` em vez
  de `logoAZ.png`.
- Versões Firebase/Flutter: usar `flutter pub add` para resolver automaticamente.

## Correção de Asset (logo)

O usuário reportou o erro: `Unable to load asset: "assets/images/logoAZ_02.png"`.
O arquivo correto é `assets/images/logoAZ_02.png` (já existe no projeto).

**Ações necessárias:**
1. No `pubspec.yaml`, declarar: `- assets/images/logoAZ_02.png`
2. Em `lib/main.dart` (SplashScreen): trocar `'assets/images/logoAZ.png'` por `'assets/images/logoAZ_02.png'`
3. Em `lib/screens/login.dart`: trocar `'assets/images/logoAZ.png'` por `'assets/images/logoAZ_02.png'`

## Perguntas em aberto

Nenhuma decisorial em aberto. O item não-resolvido (configuração do Firebase) é um
pré-requisito manual e está documentado acima.
