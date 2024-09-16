
# Desenvolvimento Móvel - Atividade Avaliativa 1

## Ponto Alto
Aplicativo desenvolvido em Flutter e Dart para ajudar na produção de peças de crochê.

## Integrantes do grupo
- Gabriel Ripper de Mendonça Furtado - 804070
- Leonardo da Silva Lopes - 761880
- Maria Luisa Edwards de Magalhães Cordeiro - 802645

## Contexto
Ponto Alto é o aplicativo ideal para entusiastas de crochê. Ele permite que você crie, organize e gerencie suas receitas e projetos de crochê de forma eficiente. Com funcionalidades que permitem acompanhar o progresso de cada projeto, o Ponto Alto é uma ferramenta útil tanto para iniciantes quanto para crocheteiras(os) experientes.

## Tecnologias

Este projeto foi desenvolvido utilizando as seguintes tecnologias:

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Android Studio](https://developer.android.com/studio)

## Pré-requisitos

Antes de começar, você precisará ter instaladas as seguintes ferramentas:

- [Git](https://git-scm.com)
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio)

## Como executar o app

Siga os passos abaixo para configurar e rodar o projeto:

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/maluedwards/pontoaltoflutter.git
   ```

2. **Instale as dependências do Flutter:**

   ```bash
   flutter pub get
   ```

3. **Gere os arquivos de internacionalização:**

   ```bash
   flutter gen-l10n
   ```

4. **Execute o aplicativo em um dispositivo físico ou emulador:**

   - Se estiver usando um emulador já configurado no Android Studio, basta rodar o comando:

     ```bash
     flutter run
     ```

   - Ou, se você quiser especificar um dispositivo, como o emulador Android padrão:

     ```bash
     flutter run -d emulator-5554
     ```

5. **Para rodar os testes automatizados:**

   ```bash
   flutter test
   ```

## Internacionalização

O projeto possui suporte para internacionalização (i18n). Após adicionar novas strings de tradução, execute o comando `flutter gen-l10n` para garantir que o sistema de internacionalização seja atualizado corretamente.

## Testes Automatizados

Testes unitários foram implementados para garantir a qualidade do código. Para executá-los, basta rodar o comando:

```bash
flutter test
```

Este comando executará todos os testes definidos nos repositórios de projeto e receita, verificando funcionalidades como inserção, atualização e recuperação de dados no banco de dados local.

## Observações

- Para garantir que o Flutter esteja corretamente configurado na sua máquina, você pode rodar o comando `flutter doctor`, que verificará se todos os pré-requisitos estão instalados.
- O Android Studio será utilizado para rodar o emulador Android, mas você também pode conectar um dispositivo Android físico via USB e rodar o aplicativo nele.
