
class AppUrl {
  static const baseURL ='https://chat-application.alphawizzserver.com/api/v1/';
  static const fileURL ='https://chat-application.alphawizzserver.com/storage/app/chat/';
  static const profileURL ='https://chat-application.alphawizzserver.com/storage/app/public/profile/';
  String userID = '';




  static const Register = '${baseURL}auth/register';
  static const login = '${baseURL}auth/login';
  static const getProfile = '${baseURL}customer/info';
  static const updateProfile = '${baseURL}customer/update-profile';
  static const staticpages = '${baseURL}config';
  static const sendRequest = '${baseURL}customer/send_request';
  static const myRequest = '${baseURL}customer/my_request';
  static const updateRequest = '${baseURL}customer/update_request';
  static const friendList = '${baseURL}customer/refresh-contact';
  static const userList = '${baseURL}customer/user_list';
  static const notificationList = '${baseURL}notifications';
  static const callNotification = '${baseURL}customer/call_user';
  static const sendOtp = '${baseURL}auth/check-phone';
  static const verifyOtp = '${baseURL}auth/verify-phone';
  static const callReject = '${baseURL}customer/call_reject';
  static const generateToken = '${baseURL}config/token';
  static const customerPlans = '${baseURL}customer/plan-list';
  static const customerPlansHistory = '${baseURL}customer/purchase-plan-transactions';
  static const purchasePlans = '${baseURL}customer/purchase-plan';
  static const createChatGroup = '${baseURL}customer/create-chat-group';
  static const updateChatGroup = '${baseURL}customer/update-chat-group';
  static const myChatList = '${baseURL}customer/my-chat-group';
  static const removeChatUser = '${baseURL}customer/remove-chat-group-users';
  static const addChatUser = '${baseURL}customer/update-chat-group-users';





  static const sendEnquiry = '${baseURL}generate_inquiry';
  static const ContactUs = '${baseURL}contact_us';
  static const deleteAccount = '${baseURL}delete_account_user';
  static const getNotification = '${baseURL}order_notification_listing';
  static const contactus = '${baseURL}contact_us';
  static const getProject = '${baseURL}get_project';
  static const addInvestor = '${baseURL}add_investor';
  static const getInvestor = '${baseURL}get_investors';
  static const withdraw = '${baseURL}withdrawl_request';
  static const withdrawList = '${baseURL}withdrawl_list';
  static const transactionList = '${baseURL}transaction_list';
  static const getEarning = '${baseURL}get_earning';
}