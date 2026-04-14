// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بكسل ويزر';

  @override
  String get tabNow => 'الآن';

  @override
  String get tabForecast => 'التوقعات';

  @override
  String get tabFavorites => 'المفضلة';

  @override
  String get search => 'بحث';

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchHint => 'ابحث عن مدينة';

  @override
  String get useMyLocation => 'استخدم موقعي';

  @override
  String get locationPermissionDeniedTitle => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionDeniedBody =>
      'قم بتمكين الوصول للموقع في الإعدادات أو ابحث عن مدينة.';

  @override
  String get locationServicesDisabledTitle => 'خدمات الموقع معطلة';

  @override
  String get locationServicesDisabledBody =>
      'قم بتشغيل خدمات الموقع لاستخدام طقس GPS.';

  @override
  String get locationTimeoutTitle => 'انتهت مهلة الموقع';

  @override
  String get locationTimeoutBody =>
      'لم نتمكن من الحصول على إشارة GPS. حاول مرة أخرى أو ابحث عن مدينة.';

  @override
  String get noSearchResultsTitle => 'لا توجد نتائج';

  @override
  String get noSearchResultsBody => 'جرب اسم مدينة مختلف.';

  @override
  String get missingApiKeyTitle => 'مفتاح واجهة الطقس مفقود';

  @override
  String get missingApiKeyBody =>
      'شغّل التطبيق باستخدام --dart-define=OPENWEATHER_KEY=your_api_key لتحميل بيانات الطقس.';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ ما.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get addFavorite => 'إضافة للمفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get unitsMetric => 'الوحدات: مئوية';

  @override
  String get unitsImperial => 'الوحدات: فهرنهايت';

  @override
  String get feelsLike => 'يبدو كأنه';

  @override
  String get humidity => 'الرطوبة';

  @override
  String get wind => 'الرياح';

  @override
  String get hourlyForecast => 'كل ساعة';

  @override
  String get dailyForecast => '٥ أيام';

  @override
  String get forecastUnavailableTitle => 'بيانات التوقعات غير متوفرة';

  @override
  String get forecastUnavailableBody =>
      'بيانات التوقعات غير متوفرة لهذا الموقع.';

  @override
  String get emptyNowTitle => 'لا يوجد طقس بعد';

  @override
  String get emptyNowBody =>
      'ابحث عن مدينة أو فعل الموقع لرؤية الظروف الحالية.';

  @override
  String get emptyForecastTitle => 'لا توجد توقعات بعد';

  @override
  String get emptyForecastBody => 'اختر موقعاً لعرض التوقعات الساعية واليومية.';

  @override
  String get emptyFavoritesTitle => 'لا توجد مفضلات بعد';

  @override
  String get emptyFavoritesBody => 'احفظ المواقع للوصول إليها بسرعة.';

  @override
  String get offlineBadge => 'غير متصل';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث $time';
  }
}
