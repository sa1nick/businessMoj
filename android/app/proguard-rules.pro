-keep class com.hyphenate.** {*;}
-dontwarn  com.hyphenate.**
-keep class io.agora.**{*;}
-dontwarn io.agora.**

-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
