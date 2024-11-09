
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/Buttons/rounded_button.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../signUpMoto_controller/signup_moto_controller.dart';


class SignUpMotoPage extends StatefulWidget {
  const SignUpMotoPage({super.key});

  @override
  State<SignUpMotoPage> createState() => _SignUpMotoPageState();
}


class _SignUpMotoPageState extends State<SignUpMotoPage> {
  String _dropdownValueMarca= "AKT";
  String _dropdownValueModelo= "2024";
  String _dropdownValueColor= "Gris";
  String _dropdownValueTipoDocumento= "Cédula de Ciudadanía";
  final SignUpMotoController _controller = SignUpMotoController();
  final TextEditingController _date = TextEditingController();
  late FocusNode _nextFieldFocusNode = FocusNode();
  final ConnectionService connectionService = ConnectionService();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
      _nextFieldFocusNode = FocusNode();
    });
  }

  @override
  void dispose() {
    _nextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _controller.key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: const Text('Registro', style: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 26,
          fontWeight: FontWeight.w900,
            color: negro
        )),
         actions:  <Widget>[
           Container(
             margin: const EdgeInsets.only(right: 15),
             child: const Image(
                 width: 80.0,
                 image: AssetImage('assets/images/logo_zafiro-pequeño.png')),
           )
        ],
      ),
      body:
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 25.0, left: 30,bottom: 15),
              child: headerText(
                  text: 'Motocicleta',
                  color: negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w800
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 5.0, left: 30,bottom: 15),
              child: headerText(
                  text: 'Ingresa tus datos',
                  color: negro,
                  fontSize: 16,
                  fontWeight: FontWeight.w700
              ),
            ),
            _nameImput(),
            _lastNameImput(),
            _tipoDocumento(),
            _identificationnumberImput(),
            _identificationExpeditionDate(),
            _celularNumberImput(),
            _emailImput(),
            _emailConfimImput(),
            _passwordImput(),
            _password2Imput(),
            _textDatosMoto(),
            _marcadeLaMoto(),
            _modeloDeLaMoto(),
            _colorDeLaMoto(),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 40.0),
              child: headerText(
                  text: 'Placa de la Moto',
                  color: negro,
                  fontSize: 18,
                  fontWeight: FontWeight.w800
              ),
            ),
            _placa(),
            Container(
              margin: const EdgeInsets.only(top: 45, left: 30, right: 30),
              child: Column(
                children: [
                  headerText(text: 'Al crear la cuenta en Zafiro aceptas',
                      color: gris,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      headerText(text: 'nuestros',
                          color: gris,
                          fontSize: 14, fontWeight: FontWeight.w400),
                      GestureDetector(
                        onTap: () {},
                        child: headerText(text: '  Términos & Condiciones',
                            color: primary,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  headerText(text: 'Igualmente autorizas el uso y manejo de datos personales de acuerdo a la lay 1581/22',
                      color: gris,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 35, bottom: 60, left: 25, right: 25,
              ),
              child: createElevatedButton(
                context: context,
                labelButton: 'Crear mi cuenta',
                labelFontSize: 18,
                color: primary,
                icon: null,
                func: () async {
                  // Ocultar el teclado
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isLoading = true; // Iniciar el estado de carga
                  });
                  // Verificar la conexión a Internet antes de ejecutar la acción
                  bool hasConnection = await connectionService.hasInternetConnection();
                  setState(() {
                    _isLoading = false; // Terminar el estado de carga
                  });
                  if (hasConnection) {
                    // Si hay conexión, ejecuta la acción
                    _controller.signUp();
                  } else {
                    // Si no hay conexión, muestra un AlertDialog
                    alertSinInternet();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future alertSinInternet (){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _textDatosMoto(){
    return Container(
      margin: const EdgeInsets.only(top: 25.0, left: 30),
      alignment: Alignment.topLeft,
      child: headerText(
        text: 'Datos de la Moto',
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: negroLetras,
      ),
    );
  }

  void dropdownCallbackTipoDocumento(String? selectedValue)async {
    if(selectedValue is String){
      SharedPreferences sharepreferences = await SharedPreferences.getInstance();
      setState((){
        _dropdownValueTipoDocumento = selectedValue;
      });
      sharepreferences.setString('tipoDoc', _dropdownValueTipoDocumento);
    }
  }

  void dropdownCallbackMarca(String? selectedValue)async {
    if(selectedValue is String){
      SharedPreferences sharepreferences = await SharedPreferences.getInstance();
      setState(() {
        _dropdownValueMarca = selectedValue;
      });
      sharepreferences.setString('marca', _dropdownValueMarca);
    }
  }

  void dropdownCallbackModelo(String? selectedValue) async {
    if(selectedValue is String){
      SharedPreferences sharepreferences = await SharedPreferences.getInstance();
      setState(() {
        _dropdownValueModelo = selectedValue;
      });
      sharepreferences.setString('modelo', _dropdownValueModelo);
    }
  }

  void dropdownCallbackColor(String? selectedValue) async {
    if(selectedValue is String){
      SharedPreferences sharepreferences = await SharedPreferences.getInstance();
      setState(() {
        _dropdownValueColor = selectedValue;
      });
      sharepreferences.setString('color', _dropdownValueColor);
    }
  }


  Widget _colorDeLaMoto(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 30, top: 10),
              child: headerText(text: '* Color', fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: grisMedio),
            ),
            width: double.infinity,
            margin: const EdgeInsets.only(left: 30, right: 30),
            child: DropdownButtonHideUnderline(
              child: DropdownButton< String>(
                value: _dropdownValueColor,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 25,
                isExpanded: true,
                iconEnabledColor: primary,
                style: const TextStyle(
                    color: negroLetras, fontSize: 18, fontWeight: FontWeight.w400, fontFamily: 'Gilroy'),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: dropdownCallbackColor,
                items: const [
                  DropdownMenuItem(value: "Amarillo", child: Text("Amarillo")),
                  DropdownMenuItem(value: "Azul", child: Text("Azul")),
                  DropdownMenuItem(value: "Cafe", child: Text("Cafe")),
                  DropdownMenuItem(value: "Beige", child: Text("Beige")),
                  DropdownMenuItem(value: "Blanco", child: Text("Blanco")),
                  DropdownMenuItem(value: "Dorado", child: Text("Dorado")),
                  DropdownMenuItem(value: "Gris", child: Text("Gris")),
                  DropdownMenuItem(value: "Morado", child: Text("Morado")),
                  DropdownMenuItem(value: "Naranja", child: Text("Naranja")),
                  DropdownMenuItem(value: "Negro", child: Text("Negro")),
                  DropdownMenuItem(value: "Plateado", child: Text("Plateado")),
                  DropdownMenuItem(value: "Rojo", child: Text("Rojo")),
                  DropdownMenuItem(value: "Verde", child: Text("Verde")),
                  DropdownMenuItem(value: "Vinotinto", child: Text("Vinotinto")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeloDeLaMoto(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 30, top: 10),
              child: headerText(text: '* Modelo', fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: grisMedio),
            ),
            width: double.infinity,
            height: 65,
            margin: const EdgeInsets.only(left: 30, right: 30),
            child: DropdownButtonHideUnderline(
              child: DropdownButton< String>(
                value: _dropdownValueModelo,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 25,
                isExpanded: true,
                iconEnabledColor: primary,
                style: const TextStyle(
                    color: negroLetras, fontSize: 18, fontWeight: FontWeight.w400, fontFamily: 'Gilroy'),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: dropdownCallbackModelo,
                items: const [
                  DropdownMenuItem(value: "2025", child: Text("2025")),
                  DropdownMenuItem(value: "2024", child: Text("2024")),
                  DropdownMenuItem(value: "2023", child: Text("2023")),
                  DropdownMenuItem(value: "2022", child: Text("2022")),
                  DropdownMenuItem(value: "2021", child: Text("2021")),
                  DropdownMenuItem(value: "2020", child: Text("2020")),
                  DropdownMenuItem(value: "2019", child: Text("2019")),
                  DropdownMenuItem(value: "2018", child: Text("2018")),
                  DropdownMenuItem(value: "2017", child: Text("2017")),
                  DropdownMenuItem(value: "2016", child: Text("2016")),
                  DropdownMenuItem(value: "2015", child: Text("2015")),
                  DropdownMenuItem(value: "2014", child: Text("2014")),
                  DropdownMenuItem(value: "2013", child: Text("2013")),
                  DropdownMenuItem(value: "2012", child: Text("2012")),
                  DropdownMenuItem(value: "2011", child: Text("2011")),
                  DropdownMenuItem(value: "2010", child: Text("2010")),
                  DropdownMenuItem(value: "2009", child: Text("2009")),
                  DropdownMenuItem(value: "2008", child: Text("2008")),
                  DropdownMenuItem(value: "2007", child: Text("2007")),
                  DropdownMenuItem(value: "2006", child: Text("2006")),
                  DropdownMenuItem(value: "2005", child: Text("2005")),
                  DropdownMenuItem(value: "2004", child: Text("2004")),
                  DropdownMenuItem(value: "2003", child: Text("2003")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipoDocumento(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 30, top: 10),
              child: headerText(text: '* Tipo de documento', fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
                border: Border.all(color: grisMedio),
                borderRadius: BorderRadius.circular(5)
            ),
            width: double.infinity,
            height: 65,
            margin: const EdgeInsets.only(left: 25, right: 25),
            child: DropdownButtonHideUnderline(
              child: DropdownButton< String>(
                value: _dropdownValueTipoDocumento,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 25,
                isExpanded: true,
                iconEnabledColor: primary,
                style: const TextStyle(
                    color: negroLetras, fontSize: 17, fontWeight: FontWeight.w400, fontFamily: 'Gilroy'),
                onChanged: dropdownCallbackTipoDocumento,
                items: const [
                  DropdownMenuItem(value: "Cédula de Ciudadanía", child: Text("Cédula de Ciudadanía")),
                  DropdownMenuItem(value: "Cédula de extranjería", child: Text("Cédula de extranjería")),
                  DropdownMenuItem(value: "Pasaporte", child: Text("Pasaporte")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marcadeLaMoto(){
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 30, top: 10),
              child: headerText(text: '* Marca', fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: grisMedio),
            ),
            width: double.infinity,
            height: 65,
            margin: const EdgeInsets.only(left: 30, right: 30),
            child: DropdownButtonHideUnderline(
              child: DropdownButton< String>(
                value: _dropdownValueMarca,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 25,
                isExpanded: true,
                iconEnabledColor: primary,
                style: const TextStyle(
                    color: negroLetras, fontSize: 18, fontWeight: FontWeight.w400, fontFamily: 'Gilroy'),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: dropdownCallbackMarca,
                items: const [
                  DropdownMenuItem(value: "AKT", child: Text("AKT")),
                  DropdownMenuItem(value: "Apollo", child: Text("Apollo")),
                  DropdownMenuItem(value: "Aprilia", child: Text("Aprilia")),
                  DropdownMenuItem(value: "Ayco", child: Text("Ayco")),
                  DropdownMenuItem(value: "Bajaj", child: Text("Bajaj")),
                  DropdownMenuItem(value: "Benelli", child: Text("Benelli")),
                  DropdownMenuItem(value: "CF", child: Text("CF")),
                  DropdownMenuItem(value: "Hero", child: Text("Hero")),
                  DropdownMenuItem(value: "Honda", child: Text("Honda")),
                  DropdownMenuItem(value: "Jialing", child: Text("Jialing")),
                  DropdownMenuItem(value: "Kawasaki", child: Text("Kawasaki")),
                  DropdownMenuItem(value: "Keeway", child: Text("Keeway")),
                  DropdownMenuItem(value: "Kymco", child: Text("Kymco")),
                  DropdownMenuItem(value: "KTM", child: Text("KTM")),
                  DropdownMenuItem(value: "Lifan", child: Text("Lifan")),
                  DropdownMenuItem(value: "Piaggio", child: Text("Piaggio")),
                  DropdownMenuItem(value: "Pulsar", child: Text("Pulsar")),
                  DropdownMenuItem(value: "Royal", child: Text("Royal")),
                  DropdownMenuItem(value: "Sherco", child: Text("Sherco")),
                  DropdownMenuItem(value: "Starker", child: Text("Starker")),
                  DropdownMenuItem(value: "Suzuki", child: Text("Suzuki")),
                  DropdownMenuItem(value: "SYM", child: Text("SYM")),
                  DropdownMenuItem(value: "Triumph", child: Text("Triumph")),
                  DropdownMenuItem(value: "TVS", child: Text("TVS")),
                  DropdownMenuItem(value: "Vespa", child: Text("Vespa")),
                  DropdownMenuItem(value: "Yamaha", child: Text("Yamaha")),
                  DropdownMenuItem(value: "YCF", child: Text("YCF")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.nombresController,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.text,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline_rounded, size: 18, color: primary),
              Text('  Nombres', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _lastNameImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child:TextField(
        controller: _controller.apellidosController,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.text,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 18, color: primary),
              Text('  Apellidos', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2),

          ),
        ),
      ),
    );
  }

  Widget _identificationnumberImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        maxLength: 10,
        textCapitalization: TextCapitalization.characters,
        controller: _controller.numeroDocumentoController,
        style: const TextStyle(
            color: negroLetras, fontSize: 22, fontWeight: FontWeight.w800),
        keyboardType: TextInputType.text,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 18, color: primary),
              Text('  Número de identificación', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _identificationExpeditionDate() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _date,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.text,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.date_range, size: 20, color: primary),
              Text('  Fecha de expedición', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),

        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate:DateTime.now(),
            firstDate: DateTime(1940),
            lastDate: DateTime(2050),
          );
          if (pickedDate != null) {
            // Formatear la fecha seleccionada en formato deseado
            String formattedDate =
                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
            // Establecer la fecha seleccionada en el controlador del campo de texto
            _date.text = formattedDate;
            SharedPreferences sharepreferences = await SharedPreferences.getInstance();
            sharepreferences.setString('fechaExpedicion', _date.text);
            _nextFieldFocusNode.requestFocus();
          }
        },
      ),
    );
  }

  Widget _celularNumberImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        focusNode: _nextFieldFocusNode,
        maxLength: 10,
        controller: _controller.celularController,
        style: const TextStyle(
            color: negroLetras, fontSize: 22, fontWeight: FontWeight.w800),
        keyboardType: TextInputType.phone,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_android_outlined, size: 20, color: primary),
              Text('  Número de celular', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _emailImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.emailController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 20, color: primary),
              Text('  Correo electrónico', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _emailConfimImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.emailConfirmarController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read, size: 20, color: primary),
              Text('  Confirmar Correo', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _passwordImput (){
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.passwordController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 20, color: primary),
              Text('  Crea una Contraseña', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _password2Imput (){
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.passwordConfirmarController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: const Color.fromARGB(255, 34, 110, 181),

        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_clock_sharp, size: 20, color: primary),
              Text('  Confirmar Contraseña', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),
      ),
    );
  }

  Widget _placa() {
    return SizedBox(
      width: 200,
      child: TextField(
        maxLength: 6,
       controller: _controller.placaController,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: negro, fontSize: 26, fontWeight: FontWeight.w800),
        keyboardType: TextInputType.text,
        cursorColor: primary,
        decoration: const InputDecoration(
          label:  Text(''),
          border:  OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: gris, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 3)
          ),
        ),
      ),
    );
  }
}

