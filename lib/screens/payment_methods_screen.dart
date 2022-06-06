import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave/core/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:eRealState_App/helpers/api_helper.dart';
import 'package:eRealState_App/payment/PaypalPayment.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../helpers/current_user.dart';
import '../helpers/app_config.dart';
import 'package:http/http.dart';
import 'package:payu_money_flutter/payu_money_flutter.dart';
import 'dart:async';

class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const platformChannel = const MethodChannel('myTestChannel');
  final payStack = PaystackPlugin();
  PayuMoneyFlutter payuMoneyFlutter = PayuMoneyFlutter();
  Razorpay razorpay;
  final String txref = "My_unique_transaction_reference_123";
  final String amount = "200";
  final String currency = FlutterwaveCurrency.RWF;
  String price = "";
  String title = "";
  String id = "";
  String paymentMethod = "";
  bool isFeatured = false;
  bool isUrgent = false;
  bool isHighlighted = false;
  bool isSubscription = false;

  //Payumoney Credentials
  final String merchantKey = AppConfig.payUMoneyMerchantKey;
  final String merchantID = AppConfig.payUMoneyMerchantId;
  final String merchantSalt = AppConfig.payUMoneyMerchantSalt;

  //Payumoney Payment Details
  String phone = "8318045008";
  String email = CurrentUser.email;
  String firstName = CurrentUser.name.isNotEmpty? CurrentUser.name : "UserName";
  String txnID = DateTime.now().millisecondsSinceEpoch.toString();

  Widget snackBar (String text) {
    return SnackBar(
      content: Text(text),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
  }


  @override
  void initState() {
    payStack.initialize(
      publicKey: AppConfig.paystackPublicKey,
    );
    razorpay = Razorpay();
    setupPayment(); //Payumoney setup

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handlerExternalWallet);
    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear(); // Removes all listeners

  }

  void onSubscriptionPaymentSuccess() async{
    final apiHelper = APIHelper();
    final isSuccess = await apiHelper.postPremiumTransactionDetail(
        title,
        price,
        CurrentUser.id,
        id,
        "0",
        "0",
        "0",
        paymentMethod,
        "subscr",
        "Subscription");
  }

  void onUpgradeAdPaymentSuccess() async{
    final apiHelper = APIHelper();
    final isSuccess = await apiHelper.postUpgradeAd(
        title,
        price,
        CurrentUser.id,
        id,
        isFeatured? "1" : "0",
        isUrgent? "1" : "0",
        isHighlighted? "1" : "0",
        paymentMethod,
        "premium",
        "Premium Ad");
  }

  void onPaymentFailure() {
    ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Failed"));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {

    paymentMethod = "razorpay";
    isSubscription? onSubscriptionPaymentSuccess() : onUpgradeAdPaymentSuccess();
    ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Successful"));
  }

  void _handlerErrorFailure(PaymentFailureResponse response){
    //var responseJson = json.decode(response.message);
    //ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Failed"));
    onPaymentFailure();
  }

  void _handlerExternalWallet(ExternalWalletResponse response){
    ScaffoldMessenger.of(context).showSnackBar(snackBar("External Wallet"));

  }

  void  openCheckout(int price){
    var options = {
      "key" : AppConfig.razorpayKey,
      "amount" : price,
      "name" : AppConfig.appName,
      "description" : title,
      "currency" : AppConfig.currencyCode,
      "prefill" : {
        // "contact" : CurrentUser.,
        "email" : CurrentUser.email
      },
      "external" : {
        "wallets" : ["paytm"]
      }
    };

    try{
      razorpay.open(options);
    }catch(e){
      print(e.toString());
    }
  }


  beginPayment(int price) async {
    final Flutterwave flutterwave = Flutterwave.forUIPayment(
        context: this.context,
        encryptionKey: AppConfig.flutterwaveEncKey,
        publicKey: AppConfig.flutterwavePublicKey,
        currency: AppConfig.currencyCode,
        amount: price.toString(),
        email: CurrentUser.email,
        fullName: "Valid Full Name",
        txRef: this.txref,
        isDebugMode: AppConfig.flutterwaveStagingMode,
        phoneNumber: "0123456789",
        acceptCardPayment: true,
        acceptUSSDPayment: false,
        acceptAccountPayment: false,
        acceptFrancophoneMobileMoney: false,
        acceptGhanaPayment: false,
        acceptMpesaPayment: false,
        acceptRwandaMoneyPayment: true,
        acceptUgandaPayment: false,
        acceptZambiaPayment: false);

    try {
      final ChargeResponse response = await flutterwave.initializeForUiPayments();
      if (response == null) {
        // user didn't complete the transaction.
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response);

        if (!isSuccessful) {
          // check message
          print(response.message);

          // check status
          print(response.status);

          // check processor error
          print(response.data.processorResponse);

          if(response.status == 'success') {
            paymentMethod = "flutterwave";
            isSubscription? onSubscriptionPaymentSuccess() : onUpgradeAdPaymentSuccess();
            ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Successful"));
          } else {
            onPaymentFailure();
          }
        } else {
          onPaymentFailure();
        }
      }
    } catch (error, stacktrace) {
      // handleError(error);
    }
  }

  bool checkPaymentIsSuccessful(final ChargeResponse response) {
    return response.data.status == FlutterwaveConstants.SUCCESSFUL &&
        response.data.currency == this.currency &&
        response.data.amount == this.amount &&
        response.data.txRef == this.txref;
  }



  @override
  Widget build(BuildContext context) {

    platformChannel.setMethodCallHandler((call){
      print("Hello from ${call.method}");
      return null;
    });

    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;

    id = pushedMap['id'];
    title = pushedMap['title'];
    price = pushedMap['price'];
    isUrgent = pushedMap['isUrgent'];
    isFeatured = pushedMap['isFeatured'];
    isHighlighted = pushedMap['isHighlighted'];
    isSubscription = pushedMap['isSubscription'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (AppConfig.paypalOn)
              ListTile(
                key: ValueKey('PayPal'),
                title: Text('PayPal'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/paypal.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PaypalPayment(
                        title, price,
                        onFinish: (number) async {
                          print(number);
                        },
                      ),
                    ),
                  );

                  if(result == "SUCCESS") {
                    paymentMethod = "paypal";
                    isSubscription ? onSubscriptionPaymentSuccess() : onUpgradeAdPaymentSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                        snackBar("Payment Successful"));
                  } else if (result == "CANCELLED")
                    ScaffoldMessenger.of(context).showSnackBar(
                        snackBar("Payment Cancelled"));
                  else
                    onPaymentFailure();
                },
              ),
            if (AppConfig.payUMoneyOn)
              ListTile(
                key: ValueKey('PayUMoney'),
                title: Text('PayUMoney'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/pay_u1.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  startPayment();

                  /*
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PayUMoney(

                      ),
                    ),
                  );
                 */

                },
              ),
            if (AppConfig.payStackOn)
              ListTile(
                key: ValueKey('PayStack'),
                title: Text('PayStack'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/paystack.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {

                  double dbAmount = double.parse(pushedMap['price']);
                  String amount = dbAmount.toStringAsFixed(2).toString().replaceAll(".", "");

                  Charge charge = Charge()
                    ..amount = int.parse(amount)
                    ..reference = _getReference()
                    ..currency = AppConfig.currencyCode
                  // or ..accessCode = _getAccessCodeFrmInitialization()
                  // ..currency = 'MDL'
                    ..email = 'customer@email.com';
                  CheckoutResponse response = await payStack.checkout(
                    context,
                    method: CheckoutMethod
                        .card, // Defaults to CheckoutMethod.selectable
                    charge: charge,
                  );

                  if(response.message == "Success") {
                    paymentMethod = "paystack";
                    isSubscription
                        ? onSubscriptionPaymentSuccess()
                        : onUpgradeAdPaymentSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                        snackBar("Payment Successful"));
                  }
                  else
                    onPaymentFailure();

                },
              ),
            if (AppConfig.razorpayOn)
              ListTile(
                title: Text('Razorpay Payment'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/razorpay_image.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () {
                  double dbAmount = double.parse(pushedMap['price']);
                  String amount = dbAmount.toStringAsFixed(2).toString().replaceAll(".", "");
                  openCheckout(int.parse(amount));
                },
              ),
            if (AppConfig.flutterwaveOn)
              ListTile(
                title: Text('Flutter Wave Payment'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/flutter_wave_image.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () {
                  beginPayment( double.parse(pushedMap['price']).round());
                },
              )
          ],
        ),
      ),
    );
  }

  // Function for setting up the payment details
  setupPayment() async {
    bool response = await payuMoneyFlutter.setupPaymentKeys(
        merchantKey: merchantKey,
        merchantID: merchantID,
        isProduction: AppConfig.payUMoneySandboxMode,
        activityTitle: AppConfig.appName,
        disableExitConfirmation: false);
  }

// Function for start payment with given merchant id and merchant key
  Future<Map<String, dynamic>> startPayment() async {
    // Generating hash from php server
    var res =
    await post(Uri.parse("https://" + APIHelper.BASE_URL + "/includes/payments/payumoney/hashgenerator.php"), body: {
      "key": merchantKey,
      "salt": merchantSalt,
      "txnid": txnID,
      "phone": phone,
      "email": email,
      "amount": price,
      "productInfo": title,
      "firstName": firstName,
    });

    var data = jsonDecode(res.body);
    print(data);
    String hash = data['result'];
    print(hash);
    var myResponse = await payuMoneyFlutter.startPayment(
        txnid: txnID,
        amount: price,
        name: firstName,
        email: email,
        phone: phone,
        productName: title,
        hash: hash);

    if(myResponse['status'] == 'success') {
      paymentMethod = "payumoney";
    isSubscription
        ? onSubscriptionPaymentSuccess()
        : onUpgradeAdPaymentSuccess();
    ScaffoldMessenger.of(context).showSnackBar(
        snackBar("Payment Successful"));
    }
    else
      onPaymentFailure();
  }

}


String _getReference() {
  String platform;
  if (Platform.isIOS) {
    platform = 'iOS';
  } else {
    platform = 'Android';
  }

  return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
}
