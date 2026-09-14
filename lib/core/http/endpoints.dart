abstract interface class Endpoints {
  static const String baseUrl = 'https://app.professional-lawyer.com/api/';
  static const String updateLocation = '';

  // ****************************** Auth ********************************
  static const String register = 'register';
  static const String verifyOtp = 'verify-otp';
  static const String login = 'login';
  static const String forgetPassword = 'forgot/password';
  static const String resetPasssword = 'forgot/reset-password';
  static const String confirmPassword = '';
  static const String resentOtp = 'resend-otp';
  static const String forgetResendOtp = 'forgot/resend-otp';
  static const String forgetVerifyOtp = 'forgot/verify-otp';
  static const String logOut = 'logout';

  // ****************************** Profile ********************************
  static const String getProfile = 'profile';
  static const String updateProfile = 'update_profile';
  static const String getGovernment = 'governments';
  static const String getArea = 'areas';
  static const String getCountries = 'countries';
  static const String getAssociations = 'associations';
  static const String banners = 'banners';
  static const String deleteAccount = 'delete_account';

  // ****************************** Clients ********************************
  static const String addClient = 'clients/add_new';
  static const String getClients = 'clients/get_all';
  static String getClientDetails(int clientId) =>
      'clients/client_details/$clientId';
  static String updateClient(int clientId) => 'clients/update_one/$clientId';
  static const String getClientCategories = 'client_categories';
  static const String getIdentificationOffices = 'identification_offices';
  static const String cancleAuth = 'clients/change_client_status';
  static String deleteClient(int clientId) => 'clients/delete_one/$clientId';

  // ****************************** Sessions ********************************
  static const String getSessions = 'sessions/all';
  static const String getSessionDetails = 'sessions/details/';
  static const String getSessionFilter = 'session_types';
  static const String exportSessions = 'issues/export_sessions';

  // ****************************** documents ********************************
  static const String getIssuedDocuments = 'issues/files/';
  static String getDocs(int caseId) => 'issues/files/$caseId';

  // ****************************** opponent Lawyer ********************************
  static const String addOpponentLawyer = 'another_lawyers/add_new';
  static const String getOpponentLawyer = 'another_lawyers/get_all';
  static const String addOpponent = 'oppents/add_new';
  static const String getOpponents = 'oppents/get_all';

  // ****************************** Cases ********************************
  static const String getLitigations = 'litigations';
  static const String getCourts = 'courts';
  static const String getClaims = 'claims';
  static const String getCircels = 'circels';
  static const String getAttributes = 'attributes';
  static const String addCase = 'issues/make_new';
  static const String sendDetailsMailToClient = 'send_mail';
  static String updateCase(int caseId) => 'issues/edit_issue/$caseId';
  static const String addSubCase = 'issues/make_sub_issue';
  static const String getCases = 'issues/my_all';
  static String deleteCase(int caseId) => 'issues/delete_one/$caseId';
  static String getCasesDetails(int caseId) => 'issues/details/$caseId';
  static String stopNotifications(int caseId) => 'issues/stop_not/$caseId';
  static String exportCase(int caseId) => 'issues/issue_export/$caseId';

  // ****************************** Files ********************************
  static const String uploadFile = 'issues/upload_file';

  // //******************************** courts *******************************
  // static const String getCourts = 'courts';

  //************************************ session types *******************************

  static const String getSessionTypes = 'session_types';
  static const String updateSession = 'issues/update_session/';
  static const String makeDecision = 'sessions/make_decision/';

  // ****************************** friendly sites ********************************
  static const String getFriendlySites = 'websites';

  // ****************************** contact us ********************************
  static const String contactUs = 'contact_us';

  // ***************************** app setting *******************************
  static const String getAppSetting = 'app_settings';
  static const String getNotifications = 'notifications';

  // ***************************** paperTypes *******************************
  static const String getPaperTypes = 'paper_subjects';
  static const String addBailiffsPaper = 'bailiff_papers/make_new';
  static const String getBaillifsPaper = 'bailiff_papers/get_all';
  static const String recivedPreparatory = 'bailiff_papers/change_status';

  //*******************************report data ********************** */

  static const String getReportData = 'issues/issues_counts';

  //*******************************session traking ********************** */
  static const String getSessionTrake = 'issues/sessions/';
}
