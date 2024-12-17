import 'package:flutter/material.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/model/purchase_plan_history_model.dart';
import 'package:ut_messenger/model/subscription_model.dart';
import 'package:intl/intl.dart' show DateFormat;


class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget(
      {super.key, required this.image, required this.plan,this.onTab});

  final String image;
  final SubscriptionPlan plan;
  final VoidCallback? onTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Card(
        color: MyColor.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Container(
                height: 180,
                width: 180,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: MyColor.primary),
                padding: const EdgeInsets.all(30),
                child: Image.asset(
                  image,
                ),
              )),
              const SizedBox(
                height: 10,
              ),
              Text(
                plan.title ?? '',
                style: const TextStyle(
                    color: MyColor.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                plan.description ?? '',
                style: const TextStyle(
                    color: MyColor.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "₹${plan.price}",
                style: const TextStyle(
                    color: MyColor.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                "Limit: ${plan.userLimit} Users ",
                style: const TextStyle(
                  color: MyColor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                "Type: ${plan.subscriptionType?.toUpperCase()}",
                style: const TextStyle(
                  color: MyColor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Validity:",
                      style: TextStyle(
                          color: MyColor.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${plan.time} ${plan.type}',
                      style: const TextStyle(
                          color: MyColor.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: onTab,
                child: Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                      color: MyColor.primary,
                      borderRadius: BorderRadius.circular(25)),
                  child: const Center(
                      child: Text(
                    "Buy now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*
 * File name: subscription_item_widget.dart
 * Last modified: 2023.02.09 at 15:51:15
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2023
 */



class SubscriptionHistoryItemWidget extends StatelessWidget {

  const SubscriptionHistoryItemWidget({super.key, required this.subscription});

  final PurchasePlanData subscription;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  MyColor.primary,
        borderRadius: BorderRadius.all(Radius.circular( 10)),
        boxShadow: [
          BoxShadow(
              color: MyColor.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5)),
        ],
        border: Border.all(color: MyColor.grey.withOpacity(0.05)),
      ) ,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subscription.plan?.title ?? '',style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: MyColor.white),
          ),
          const Divider(
            height: 30,
            thickness: 1,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: "Starts At:",
                       
                        children: <TextSpan>[
                          TextSpan(
                            text: DateFormat(
                                '   d, MMMM y  HH:mm')
                                .format(
                                DateTime.parse(subscription.plan?.createdAt ?? '')),
                          ),
                        ]),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Expires At: ",

                        children: <TextSpan>[
                          TextSpan(
                            text: /*DateFormat(
                                    '  d, MMMM y  HH:mm', Get.locale.toString())
                                .format(subscription.expiresAt!),*/
                            subscription.endDate,
                          ),
                        ]),
                  ),
                ],
              ),

              if (subscription.plan?.status == 1)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: const Text("Enabled",
                      maxLines: 1,
                      style: TextStyle(color: Colors.green),
                      softWrap: false,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade),
                ),
              if (subscription.plan?.status != 1)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: const Text("Disabled",
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey),
                      softWrap: false,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade),
                ),
            ],
          ),
          SizedBox(height: 20),
          RichText(
            text: TextSpan(
                text: "Plan type: ",

                children: <TextSpan>[
                  TextSpan(
                    text: /*DateFormat(
                                    '  d, MMMM y  HH:mm', Get.locale.toString())
                                .format(subscription.expiresAt!),*/
                    subscription.planType,
                  ),
                ]),
          ),
          SizedBox(height: 20),
          /*Row(
            children: [
              Expanded(
                child: Text(
                  "Payment Method".tr,
                  style: Get.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  subscription.payment!.paymentMethod.name,
                  style: Get.textTheme.bodyMedium,
                ),
              ),
            ],
          ),*/
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  subscription.plan?.title ?? '',

                  overflow: TextOverflow.ellipsis,style:
                    const TextStyle( fontSize: 12,color: MyColor.white,fontWeight: FontWeight.w700)
                ),
              ),
              if (subscription.plan != null)

                Text('₹${subscription.plan!.price!}',style:
                const TextStyle( fontSize: 12,color: MyColor.white,fontWeight: FontWeight.w700))
            ],
          ),
        ],
      ),
    );
  }
}
