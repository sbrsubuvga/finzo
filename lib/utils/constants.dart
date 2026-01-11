class AppConstants {
  // App Info
  static const String appName = 'Finzo';
  static const String appVersion = '1.0.0';

  // Transaction Types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';

  // Period Types
  static const String periodDaily = 'daily';
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';
  static const String periodYearly = 'yearly';

  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatFull = 'yyyy-MM-dd';
  static const String dateFormatMonth = 'MMMM yyyy';

  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  // Limits
  static const int recentTransactionsLimit = 10;
  static const int maxDescriptionLength = 200;
}

