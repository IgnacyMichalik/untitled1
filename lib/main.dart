import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'MapScreen.dart';
import 'Coments.dart';
import 'InfoMap.dart';
import 'package:latlong2/latlong.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga';
  final keyClientKey = 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge';
  final keyParseServerUrl = 'https://parseapi.back4app.com';
  final keyLiveQueryUrl = 'https://testdatabaseimapsl.b4a.io';



  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    debug: true,
    liveQueryUrl: keyLiveQueryUrl, // Ustawienie liveQueryUrl
  );


  runApp(MaterialApp(
    title: 'Naprawmy sobie miasto',
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {



  Future<bool> hasUserLogged() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      return false;
    }
    String? objectId = currentUser.objectId;
    if (objectId != null) {
      // Przypisz wartość do UserData().currentU
      UserData().currentU = objectId;
    }

    //Checks whether the user's session token is valid
    final ParseResponse? parseResponse =
    await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);

    if (parseResponse?.success == null || !parseResponse!.success) {
      await currentUser.logout();
      return false;
    } else {

      return true;

    }
  }

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naprawmy sobie miasto',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightGreen).copyWith(background: Colors.grey),
      ),
      home: FutureBuilder<bool>(
          future: hasUserLogged(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Scaffold(
                  body: Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator()),
                  ),
                );
              default:
                if (snapshot.hasData && snapshot.data!) {
                  return UserPage();
                } else {
                  return LoginPage();
                }
            }
          }),
    );
  }
}

class UserData {
  static final UserData _singleton = UserData._internal();
  factory UserData() => _singleton;
  UserData._internal();
  String currentU = '';
}
class ReadData {
  static final ReadData _singleton = ReadData._internal();
  factory ReadData() => _singleton;
  ReadData._internal();

  static final ReadData _readInstance = ReadData._internal();
  factory ReadData.instance() => _readInstance;

  String ReadU = 'hej';

}
class KomData {
  static final KomData _singleton = KomData._internal();
  factory KomData() => _singleton;
  KomData._internal();
  String KomId = '';
}

class YourClass {
  late LiveQuery liveQuery;
  late String currentUserValue;
  late QueryBuilder<ParseObject> query;

  Future<void> initializeLiveQuery() async {
    print('Wywołanie 1');
    // Inicjalizacja SDK Parse
    await Parse().initialize(
      'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga',
      'https://parseapi.back4app.com',
      clientKey: 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge',
      autoSendSessionId: true,
      liveQueryUrl: 'https://testdatabaseimapsl.b4a.io',
      debug: true,
    );
    print('Wywołanie 2');
    // Pobranie wartości currentUserValue po zainicjalizowaniu
    currentUserValue = UserData().currentU;

    // Inicjalizacja LiveQuery
    liveQuery = LiveQuery();

    // Inicjalizacja zapytania LiveQuery
    query = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('isRead', 0); // Sprawdzenie czy isRead wynosi 0

    // Uruchomienie subskrypcji LiveQuery
    startLiveQuery();
  }

  void startLiveQuery() async {
    print('Wywołanie 3');
    try {
      // Inicjalizacja subskrypcji LiveQuery
      Subscription subscription = await liveQuery.client.subscribe(query);

      // Nasłuchiwanie na zdarzenia LiveQuery (np. aktualizacje)
      subscription.on(LiveQueryEvent.update, (value) {
        print('*** UPDATE ***: ${DateTime.now().toString()}\n $value ');
        print((value as ParseObject).objectId);
        print((value as ParseObject).updatedAt);
        print((value as ParseObject).createdAt);
        print((value as ParseObject).get('objectId'));
        print((value as ParseObject).get('updatedAt'));
        print((value as ParseObject).get('createdAt'));
        print('Wywołanie 4');
      });
    } catch (e) {
      print('Błąd podczas subskrybowania LiveQuery: $e');
    }
  }
}class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: const Text('Naprawmy sobie miasto'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controllerUsername,
                  enabled: !isLoggedIn,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Login'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  enabled: !isLoggedIn,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Hasło'),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Zaloguj'),
                    onPressed: isLoggedIn ? null : () => doUserLogin(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Rejestracja'),
                    onPressed: () => navigateToSignUp(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ));
  }
  String? currentUser; // Deklaracja zmiennej currentUser


  void doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();

    final user = ParseUser(username, password, null);

    var response = await user.login();

    if (response.success) {
      final objectId = response.result['objectId'];
      UserData().currentU = objectId; // Aktualizacja wartości w singletonie
      navigateToUser();
    } else {
      Message.showError(context: context, message: response.error!.message);
    }
  }

  void navigateToUser() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => UserPage()),
          (Route<dynamic> route) => false,
    );
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }


}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}


class _UserPageState extends State<UserPage> {
  void runLiveQuery() {
    YourClass yourClass = YourClass();
    yourClass.initializeLiveQuery();

  }


  bool isNewMessage = false;
  ParseUser? currentUser;
  PickedFile? pickedFile;
  bool shouldShowDot = false;
  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;
  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  @override
  void initState() {
    super.initState();
    runLiveQuery();
    checkForUnreadMessages();
  }
  Future<void> checkForUnreadMessages() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('isRead', '0');

    try {
      final response = await queryBuilder.query();
      final results = response.results;

      if (results != null && results.isNotEmpty) {
        setState(() {
          shouldShowDot = true; // Ust
          runLiveQueryv2();// awienie flagi na true, gdy są nieprzeczytane wiadomości
        });
      }
    } catch (e) {
      print('Error checking for unread messages: $e');
    }
  }
  Future<void> runLiveQueryv2() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('isRead', '0');

    final subscription = await LiveQuery().client.subscribe(queryBuilder);
    subscription.on(LiveQueryEvent.create, (value) {
      if (value['isRead'] == '0') {
        setState(() {
          shouldShowDot = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => UserPage()),
        );
      }
    });

    subscription.on(LiveQueryEvent.update, (value) {
      if (value['isRead'] == '0') {
        setState(() {
          shouldShowDot = true;
        });
        // Tutaj możesz umieścić dodatkową logikę, która powinna zostać wykonana przy zmianie danych
        // np. odświeżenie strony, aktualizacja widoku, itp.
      }
    });
  }
  void _showDetailsDialog(BuildContext context, List<Widget> messageWidgets, List<String> idsZgloszenia) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Powiadomienia'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              messageWidgets.length,
                  (index) => GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(objectId: idsZgloszenia[index]),
                    ),
                  );
                },
                child: messageWidgets[index],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showNewMessagesList(BuildContext context) async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('isRead', '0');

    try {
      final response = await queryBuilder.query();
      final messages = response.results;

      List<Widget> messageWidgets = [];
      List<String> idsZgloszenia = [];

      for (var message in messages!) {
        final idZgloszenia = message['idZgloszenia'];

        if (idZgloszenia != null) {
          final zgloszenieQuery = QueryBuilder<ParseObject>(ParseObject('Zgloszenie'))
            ..whereEqualTo('objectId', idZgloszenia);

          final zgloszenieResponse = await zgloszenieQuery.query();
          final zgloszenia = zgloszenieResponse.results;

          if (zgloszenia != null && zgloszenia.isNotEmpty) {
            final kategoria = zgloszenia.first['Kategoria'];
            final opis = zgloszenia.first['Opis'];

            messageWidgets.add(_buildMessageWidget(kategoria, opis));
            idsZgloszenia.add(idZgloszenia);
          }
        }
      }

      _showDetailsDialog(context, messageWidgets, idsZgloszenia);
    } catch (e) {
      print('Error retrieving new message details: $e');
    }
  }
  Widget _buildMessageWidget(String kategoria, String opis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategoria: $kategoria'),
        Text('Opis: $opis'),
        Divider(), // Add a divider between messages
      ],
    );
  }
  @override
  Widget build(BuildContext context) {

    void doUserLogout() async {
      var response = await currentUser!.logout();
      if (response.success) {
        Message.showSuccess(
            context: context,
            message: 'Użytkowanik został pomyślnie wylogowany!',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
              );
            });
      } else {
        Message.showError(context: context, message: response.error!.message);
      }
    }
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop(); // Zamknięcie aplikacji po naciśnięciu przycisku cofania
          return true;
        },
        child: Scaffold(

            appBar: AppBar(
              backgroundColor: Colors.lightGreen,
              title: Text('Naprawmy sobie miasto'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications), // Notification bell icon
                      if (shouldShowDot) // Display red dot if there's an unread message
                        Positioned(
                          top: 5.0,
                          left: 5.0,
                          child: Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    showNewMessagesList(context);
                  },
                ),
              ],
            ),
            body: FutureBuilder<ParseUser?>(
                future: getUser(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator()),
                      );
                    default:
                      return Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),

                                Container(
                                  height: 200,
                                  child: Image.asset('lib/images/herb.png'),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Center(

                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    child: Text('Dodaj zgłoszenie'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.lightGreen, // Kolor tła przycisku
                                      onPrimary: Colors.black, // Kolor tekstu na przycisku
                                      // Inne opcje stylizacji, takie jak padding, shape, etc.
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SavePage(location: null,)),
                                      );
                                    },

                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    height: 50,
                                    child: ElevatedButton(
                                      child: Text('Przesłane zgłoszenia'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.lightGreen, // Kolor tła przycisku
                                        onPrimary: Colors.black, // Kolor tekstu na przycisku
                                        // Inne opcje stylizacji, takie jak padding, shape, etc.
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DisplayPage()),
                                        );
                                      },
                                    )),
                                SizedBox(
                                  height: 8,
                                ),

                                Container(
                                    height: 50,
                                    child: ElevatedButton(
                                      child: Text('Mapa zgłoszeń'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.lightGreen, // Kolor tła przycisku
                                        onPrimary: Colors.black, // Kolor tekstu na przycisku
                                        // Inne opcje stylizacji, takie jak padding, shape, etc.
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MapScreenv2()),
                                        );
                                      },
                                    )),
                                SizedBox(
                                  height: 8,
                                ),

                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                    child: const Text('Wyloguj'),
                                    onPressed: () => doUserLogout(),
                                  ),
                                )],
                            ),
                          ));
                  }
                })));
  }
}
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: const Text('Rejestracja'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                SizedBox(
                  height: 16,
                ),

                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controllerUsername,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Nazwa użytkownika'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'E-mail'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Hasło'
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Załóż konto'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreen, // Kolor tła przycisku
                      onPrimary: Colors.black, // Kolor tekstu na przycisku
                      // Inne opcje stylizacji, takie jak padding, shape, etc.
                    ),
                    onPressed: () => doUserRegistration(),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void doUserRegistration() async {
    final username = controllerUsername.text.trim();
    final email = controllerEmail.text.trim();
    final password = controllerPassword.text.trim();

    final user = ParseUser.createUser(username, password, email);

    var response = await user.signUp();

    if (response.success) {
      Message.showSuccess(
          context: context,
          message: 'User was successfully created!',
          onPressed: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UserPage()),
                  (Route<dynamic> route) => false,
            );
          });
    } else {
      Message.showError(context: context, message: response.error!.message);
    }
  }
}

class SavePage extends StatefulWidget {
  final LatLng? location;
  final String? status; // Dodany status
  const SavePage({Key? key, required this.location, this.status}) : super(key: key);

  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final Opis = TextEditingController();
  String? status;
  PickedFile? pickedFile;
  var zmienna = '';
  List<String> items = [];
  String? selectedItem;
  String statusText = '';
  bool isLocationSelected = false;
  bool isDescriptionAdded = false;



  @override
  void initState() {
    super.initState();
    fetchDataFromBack4App();
    status = widget.status; // Ustawienie statusu na podstawie przekazanego wartością początkową
    setStatusText(); // Ustawienie tekstu statusu
  }
  void setStatusText() {
    // Ustawienie tekstu odpowiadającego statusowi
    if (status == '1') {
      setState(() {
        statusText = 'Lokalizacja została poprawnie określona';
      });
    } else {
      setState(() {
        statusText = 'Lokalizacja nie została jeszcze wybrana';
      });
    }
  }

  Future<void> fetchDataFromBack4App() async {
    try {
      await Parse().initialize(
        'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga',
        'https://parseapi.back4app.com',
        clientKey: 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge',
        autoSendSessionId: true,
        debug: true,
      );

      final queryBuilder = QueryBuilder(ParseObject('type'));
      final response = await queryBuilder.query();

      if (response.success && response.results != null) {
        setState(() {
          items = response.results!.map<String>((result) {
            return result.get<String>('fieldName');
          }).toList();
        });
      } else {
        print('Failed to fetch data from Back4App: ${response.error}');
      }
    } catch (e) {
      print('Error initializing Parse: $e');
    }
  }
  Future state() async {
    zmienna;
  }



  bool isLoading = false;
  ParseFileBase? parseFile;

  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  String currentUserValue = UserData().currentU;
  @override
  Widget build(BuildContext context) {
    LatLng? receivedLocation = widget.location;
    double latitude = receivedLocation?.latitude ?? 0.0;
    double longitude = receivedLocation?.longitude ?? 0.0;
    void send() async {
      final Descriptrion = Opis.text.trim();

      final Dane = ParseObject("Zgloszenie")
        ..set("Opis", Descriptrion)
        ..set("Kategoria", selectedItem)
        ..set("Status", status)
        ..set('file', parseFile)
        ..set("latitude", latitude)
        ..set("longitude", longitude)
        ..set("currentUser", currentUserValue); // Zapisz currentUser do kolumny 'currentUser'

      try {
        await Dane.save();
        print('saved successfully ');
        // Dodatkowe operacje po zapisaniu danych lokalizacji
      } catch (e) {
        print('Error $e');
      }
    }
    return WillPopScope(
      onWillPop: () async {
        // Przejście do UserPage po naciśnięciu przycisku cofania
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserPage()),
        );
        return false; // Blokowanie domyślnego działania przycisku cofania
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text("Przesłane zgłoszenia"),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Kolor tła przycisku
                onPrimary: Colors.black, // Kolor tekstu na przycisku
                // Inne opcje stylizacji, takie jak padding, shape, etc.
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
              child: Text('Podaj lokalizację'),
            ),
            SizedBox(height: 16),
            Visibility(
              visible: (latitude != null && latitude != 0) && (longitude != null && longitude != 0),
              child: Text('Lokalizacja została poprawnie określona'),
            ),
            Visibility(
              visible: (latitude == null || latitude == 0) || (longitude == null || longitude == 0),
              child: Text('Lokalizacja nie została jeszcze wybrana'),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                GestureDetector(
                  child: pickedFile != null
                      ? Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                    child: kIsWeb
                        ? Image.network(pickedFile!.path, fit: BoxFit.contain)
                        : Image.file(File(pickedFile!.path), fit: BoxFit.contain),
                  )
                      : Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: Center(
                      child: Text('Dodaj zdjęcie'),
                    ),
                  ),
                  onTap: () async {
                    if (latitude != null && latitude != 0 && longitude != null && longitude != 0) {
                      String? buttonPressed = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          String? selectedButton;
                          return WillPopScope(
                            onWillPop: () async {
                              Navigator.pop(context, selectedButton);
                              return false;
                            },
                            child: AlertDialog(
                              title: Text("Dodawanie zdjęcia"),
                              content: Column( // Use Column for vertical arrangement
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.lightGreen, // Kolor tła przycisku
                                      onPrimary: Colors.black, // Kolor tekstu na przycisku
                                      // Inne opcje stylizacji, takie jak padding, shape, etc.
                                    ),
                                    onPressed: () async {
                                      final imagePicker = ImagePicker();
                                      final PickedFile? image =
                                      await imagePicker.getImage(source: ImageSource.camera);
                                      if (image != null) {
                                        setState(() {
                                          pickedFile = image;
                                        });
                                      }
                                      selectedButton = 'Dodawanie';
                                      Navigator.pop(context);
                                    },
                                    child: Text('Zrób zdjęcie'),
                                  ),
                                  SizedBox(height: 8), // Add space between buttons
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.lightGreen, // Kolor tła przycisku
                                      onPrimary: Colors.black, // Kolor tekstu na przycisku
                                      // Inne opcje stylizacji, takie jak padding, shape, etc.
                                    ),
                                    onPressed: () async {
                                      final imagePicker = ImagePicker();
                                      final PickedFile? image =
                                      await imagePicker.getImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        setState(() {
                                          pickedFile = image;
                                        });
                                      }
                                      selectedButton = 'Zrob';
                                      Navigator.pop(context);
                                    },
                                    child: Text('Zdjęcie z galerii'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Najpierw wskaż lokalizację'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },


                )],
            ),
            SizedBox(height: 16),
            Container(
              width: 240,
              height: 50,
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: [
                  if (selectedItem == null) // Sprawdzenie, czy wartość jest null
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Wybierz kategorię zdarzenia'), // Tekst dla hinta
                    ),
                  ...items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedItem = newValue;
                  });
                },
              ),
            ),


            Container(
              height: 100, // Ustaw wysokość kontenera TextFormField na 100 pikseli
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center, // Wyśrodkuj tekst pionowo
                controller: Opis,
                onChanged: (value) {
                  setState(() {
                    isDescriptionAdded = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Dodaj opis zgłoszenia",
                ),
                maxLines: null, // Zawijaj tekst automatycznie
                maxLength: 150, // Limit znaków do 300
              ),
            ),

            SizedBox(height: 16),
            Container(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen, // Kolor tła przycisku
                  onPrimary: Colors.black, // Kolor tekstu na przycisku
                  // Inne opcje stylizacji, takie jak padding, shape, etc.
                ),
                child: Text('Wyślij zgłoszenie'),
                onPressed: (pickedFile == null || selectedItem == null || selectedItem == 'Wybierz kategorię zdarzenia')
                    ? null
                    : () async {
                  setState(() {
                    isLoading = true;
                  });

                  if (kIsWeb) {
                    parseFile = ParseWebFile(await pickedFile!.readAsBytes(), name: "image.jpg");
                  } else {
                    parseFile = ParseFile(File(pickedFile!.path));
                  }

                  status = '0';
                  send();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
                },
              ),


            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(primary: Colors.grey),
                child: Text('Anuluj'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
                },
              ),
            ),
          ],
        ),
      )
      ,);
  }
}
class Zgloszenie {
  final String id;
  final String nazwa;
  final String opis;
  final DateTime date;
  final String status;
  final dynamic imageUrl; // Dodano pole imageUrl

  Zgloszenie({
    required this.id,
    required this.nazwa,
    required this.opis,
    required this.date,
    required this.status,
    required this.imageUrl,
  });
  Future<void> updateStatus(String newStatus) async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Zgloszenie'))
      ..whereEqualTo('objectId', id);

    final response = await queryBuilder.query();

    final results = response.results;
    if (results != null && results.isNotEmpty) {
      final zgloszenieObject = results.first;
      zgloszenieObject.set<String>('Status', newStatus);
      await zgloszenieObject.save();
    }
  }
}
class ZgloszenieListItem extends StatelessWidget {
  final Zgloszenie zgloszenie;

  const ZgloszenieListItem({required this.zgloszenie});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.transparent;
    late String statusImage;
    if (zgloszenie.status == '0') {
      statusImage = 'lib/images/0.png'; // Przykładowa ścieżka do obrazka dla statusu '0'
    } else if (zgloszenie.status == '1') {
      statusImage = 'lib/images/1.png'; // Przykładowa ścieżka do obrazka dla statusu '1'
    } else if (zgloszenie.status == '2') {
      statusImage = 'lib/images/2.png'; // Przykładowa ścieżka do obrazka dla statusu '2'
    } else if (zgloszenie.status == '3') {
      statusImage = 'lib/images/4.png'; // Przykładowa ścieżka do obrazka dla statusu '3'
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZgloszenieDetailsPage(zgloszenie: zgloszenie),
          ),
        );
      },
      title: Text(zgloszenie.nazwa),
      subtitle: Text(zgloszenie.opis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 10),
          // Obrazek z animacją ładowania
          CachedNetworkImage(
            imageUrl: zgloszenie.imageUrl,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
            placeholder: (context, url) => CircularProgressIndicator(), // Animacja ładowania
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: AssetImage(statusImage),
            radius: 25,
          ),
        ],
      ),
    );
  }
}

class ZgloszenieDetailsPage extends StatelessWidget {
  final Zgloszenie zgloszenie;
  const ZgloszenieDetailsPage({required this.zgloszenie});

  String formattedDate(DateTime date) {
    return DateFormat('dd MMMM yyyy HH:mm').format(date.toLocal());
    // 'dd' - dzień, 'MMMM' - miesiąc (pełna nazwa), 'yyyy' - rok, 'HH:mm' - godzina:minuta
  }

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    if (zgloszenie.status == '0') {
      statusText = 'Zgłoszenie rozpatrywane';
    } else if (zgloszenie.status == '1') {
      statusText = 'Zgłoszenie przyjęte';
    } else if (zgloszenie.status == '2') {
      statusText = 'Zgłoszenie odrzucone';
    } else if (zgloszenie.status == '3') {
      statusText = 'Zgłoszenie zostało przekazane do wycofania';
    }
    bool isButtonEnabled = zgloszenie.status != '3'; // Sprawdzenie czy przycisk powinien być klikalny

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Szczegóły zgłoszenia'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategoria zgłoszenia : ${zgloszenie.nazwa}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Opis zgłoszenia: ${zgloszenie.opis}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Data: ${formattedDate(zgloszenie.date)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${statusText}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreenPage(
                        imageUrl: zgloszenie.imageUrl,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: zgloszenie.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Kolor tła przycisku
                onPrimary: Colors.black, // Kolor tekstu na przycisku
                // Inne opcje stylizacji, takie jak padding, shape, etc.
              ),
              onPressed: isButtonEnabled
                  ? () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Potwierdzenie'),
                      content: Text('Czy na pewno chcesz wycofać zgłoszenie?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Zamknij okno dialogowe
                          },
                          child: Text('Nie'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await zgloszenie.updateStatus('3'); // Zaktualizuj status na '3'
                            Navigator.of(context).pop(); // Zamknij okno dialogowe

                            // Navigate back to DisplayPage, replacing the current route
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayPage(),
                              ),
                            );
                          },
                          child: Text('Tak'),
                        ),
                      ],
                    );
                  },
                );
              }
                  : null, // Ustaw onPressed na null, jeśli przycisk ma być nieklikalny
              child: Text('Wycofaj zgłoszenie'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Kolor tła przycisku
                onPrimary: Colors.black, // Kolor tekstu na przycisku
                // Inne opcje stylizacji, takie jak padding, shape, etc.
              ),
              onPressed: isButtonEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(objectId: zgloszenie.id),
                  ),
                );
              }
                  : null,
              child: Text('Komentarze'),
            )
          ],
        ),
      ),
    );
  }
}


class ImageFullScreenPage extends StatelessWidget {
  final String imageUrl;

  const ImageFullScreenPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Pełny ekran'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
enum SortOption { date, category }
class DisplayPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Display Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UserPage(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  @override
  _DisplayPageState createState() => _DisplayPageState();

}

class _DisplayPageState extends State<DisplayPage> {
  List<Zgloszenie> zgloszenia = [];
  SortOption _sortOption = SortOption.date;
  DateTime? lastFetchedAt;
  Subscription? subscription;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch existing items
    subscribeToLiveQuery(); // Subscribe to new items
  }

  Future<void> fetchData() async {
    try {
      String currentUser = UserData().currentU;
      final query = QueryBuilder<ParseObject>(ParseObject('Zgloszenie'))
        ..whereEqualTo('currentUser', currentUser);

      final response = await query.query();

      final items = response.results?.map<Zgloszenie>((result) {
        // Map fetched results to Zgloszenie objects
        final id = result.objectId!;
        final nazwa = result.get<String>('Kategoria')!;
        final opis = result.get<String>('Opis')!;
        final date = result.get<DateTime>('createdAt')!;
        final status = result.get<String>('Status')!;
        final file = result.get<dynamic>('file');

        dynamic imageUrl;
        if (file is ParseWebFile) {
          imageUrl = file.url;
        } else if (file is ParseFile) {
          imageUrl = file.url!;
        } else {
          imageUrl = '';
        }

        return Zgloszenie(
          id: id,
          nazwa: nazwa,
          opis: opis,
          status: status,
          date: date,
          imageUrl: imageUrl,
        );
      }).toList();

      if (items != null && items.isNotEmpty) {
        setState(() {
          zgloszenia.addAll(items); // Add fetched items to the list
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> subscribeToLiveQuery() async {
    try {
      String currentUserValue = UserData().currentU;
      final LiveQuery liveQuery = LiveQuery();
      final query = QueryBuilder<ParseObject>(ParseObject('Zgloszenie'))
        ..whereEqualTo('currentUser', currentUserValue);

      subscription = await liveQuery.client.subscribe(query);
      subscription?.on(LiveQueryEvent.create, (value) {
        // Handle newly created items and add them to the list
        final id = value.objectId!;
        final nazwa = value.get<String>('Kategoria')!;
        final opis = value.get<String>('Opis')!;
        final date = value.get<DateTime>('createdAt')!;
        final status = value.get<String>('Status')!;
        final file = value.get<dynamic>('file');

        dynamic imageUrl;
        if (file is ParseWebFile) {
          imageUrl = file.url;
        } else if (file is ParseFile) {
          imageUrl = file.url!;
        } else {
          imageUrl = '';
        }

        final zgloszenie = Zgloszenie(
          id: id,
          nazwa: nazwa,
          opis: opis,
          status: status,
          date: date,
          imageUrl: imageUrl,
        );

        setState(() {
          zgloszenia.add(zgloszenie); // Add newly created items to the list
        });
      });
    } catch (e) {
      print('Error subscribing to LiveQuery: $e');
    }
  }

  void sortList(SortOption option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case SortOption.date:
          zgloszenia.sort((a, b) => a.date.compareTo(b.date));
          break;
        case SortOption.category:
          zgloszenia.sort((a, b) => a.nazwa.compareTo(b.nazwa));
          break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserPage(),
          ),
        );
        return false; // Zwracamy false, aby zablokować domyślną akcję przycisku cofania
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text('Zgłoszenie'),
        ),
        body: Column(
          children: [
            DropdownButton<SortOption>(
              value: _sortOption,
              onChanged: (SortOption? newValue) {
                if (newValue != null) {
                  sortList(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: SortOption.date,
                  child: Text('Sortuj po dacie'),
                ),
                DropdownMenuItem(
                  value: SortOption.category,
                  child: Text('Sortuj alfabetycznie po kategorii'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: zgloszenia.length,
                itemBuilder: (context, index) {
                  final zgloszenie = zgloszenia[index];
                  return ZgloszenieListItem(zgloszenie: zgloszenie);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Message {
  static void showSuccess(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pomyślnie wylogowano"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Kolor tła przycisku
                onPrimary: Colors.black, // Kolor tekstu na przycisku
                // Inne opcje stylizacji, takie jak padding, shape, etc.
              ),
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showError(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
