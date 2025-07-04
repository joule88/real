class ApiConstants {
  static const String laravelApiBaseUrl = 'http://103.210.69.67:8080/api';
  // static const String flaskApiBaseUrl = 'http://192.168.1.3:5000';

  // Endpoint untuk API Laravel
  static const String propertiesEndpoint = '/properties';
  static const String userPropertiesEndpoint = '/user/properties';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String userProfileEndpoint = '/profile';
  static const String changePasswordEndpoint = '/profile/change-password';
  static const String publicPropertiesEndpoint = '/properties/public';
  static const String toggleBookmarkEndpoint = '/properties'; // Akan menjadi /properties/{id}/toggle-bookmark
  static const String getBookmarksEndpoint = '/bookmarks'; // Endpoint untuk mengambil properti yang dibookmark user
  static const String forgotPasswordEndpoint = '/forgot-password'; // Tetap
  static const String verifyCodeEndpoint = '/verify-password-code'; // Baru
  static const String resetPasswordWithCodeEndpoint = '/reset-password-with-code'; // Baru

  // Endpoint untuk API Flask Prediksi (akan digabung dengan flaskApiBaseUrl)
  static const String predictPriceEndpoint = '/prediksi/create';
}