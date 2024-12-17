import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/helper/session.dart';
import 'package:ut_messenger/model/purchase_plan_history_model.dart';
import 'package:ut_messenger/model/subscription_model.dart';
import 'package:ut_messenger/model/user_model.dart';
import 'package:ut_messenger/services/payment_service/razor_pay_payment.dart';
import 'package:ut_messenger/widgets/subscription_widget.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool planLoading = false;
  bool historyLoading = false;

  bool isNetwork = false;
  List<SubscriptionPlan> planList = [];
  List<PurchasePlanData> historyList = [];
  SharedPreferences? pref;
  UserModel? user ;
  String token = '';

  List popupItemsList = [
    {'icon': Icons.group_add_rounded, 'title': 'Add Group'},
    {'icon': Icons.settings, 'title': 'Settings'},
    {'icon': Icons.logout, 'title': 'Logout'},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    inIt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Subscription Plan"),
        actions:  [

          // IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen()));}, icon: Icon(Icons.message))
        ],
      ),
      body: planLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : planList.isEmpty
              ? const Center(
                  child: Text('Plans not available'),
                )
              : RefreshIndicator(
                  onRefresh: () async {},
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height/1.55,
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: planList.length,
                            itemBuilder: (context, index) {
                              return SubscriptionWidget(
                                image: 'assets/images/subscriptionImage1.png',
                                plan: planList[index],
                                onTab:() {
                                  int amt = double.parse(planList[index].price ?? '0.0').toInt();

                                  RazorPayHelper razorPay =
                                  RazorPayHelper(amt.toString(), (result) async {
                                    if (result != "error") {

                                      purchasePlan(planList[index].id.toString(),planList[index].price.toString(),result);

                                    } else {

                                    }
                                  });

                                  razorPay.init();


                                },

                              );
                            },
                          ),
                        ),
                        const Text("Subscriptions History",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: MyColor.primary,
                                height: 1.2)),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: historyList.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 15);
                            },
                            itemBuilder: (context, index) {

                              PurchasePlanData data = historyList[index];

                              return SubscriptionHistoryItemWidget(subscription: data) ;
                            },
                          ),
                        )

                      ],
                    ),
                  ),
                ),
    );
  }

  inIt() async{

     pref = await SharedPreferences.getInstance();

     getSubscriptionPlan();
     getSubscriptionHistory();

  }

  Future<void> getSubscriptionPlan() async {
    setState(() {
      planLoading = true;
    });


   token = pref?.getString(AppConstants.token) ?? '';

    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      http.Response response =
          await http.get(Uri.parse(AppUrl.customerPlans), headers: headers);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        planList = SubscriptionModel.fromJson(data).planLists ?? [];
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load plans");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }

    setState(() {
      planLoading = false;
    });
  }

  Future<void> getSubscriptionHistory() async {
    setState(() {
      historyLoading = true;
    });


    token = pref?.getString(AppConstants.token) ?? '';

    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      http.Response response =
      await http.get(Uri.parse(AppUrl.customerPlansHistory), headers: headers);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        historyList = PurchasePlanHistoryModel.fromJson(data).historyLists ?? [];
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load plans");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }

    setState(() {
      historyLoading = false;
    });
  }


  Future<void> purchasePlan(String planId, String amount, String transactionID) async {


     String? userData = pref?.getString(AppConstants.userdata);

     if(userData !=null) {
      user = UserModel.fromJson(jsonDecode(userData));
    }

    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {
        "plan_id":planId,
        "user_id":user?.id.toString(),
        "amount":amount,
        "transaction_id": transactionID
      };
      http.Response response =
      await http.post(Uri.parse(AppUrl.purchasePlans), headers: headers,body: body);

      print('${response.statusCode}_________');
      print('${body}_________');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: data['message']);
        Navigator.pop(context);
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to purchase plan");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }
}
