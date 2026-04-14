import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/l10n/app_localizations_ar.dart';
import 'package:pixel_weather_app/l10n/app_localizations_en.dart';

void main() {
  test('AppLocalizationsEn exposes expected strings', () {
    final en = AppLocalizationsEn();

    expect(en.appTitle, 'PixelWeather');
    expect(en.tabNow, 'Now');
    expect(en.tabForecast, 'Forecast');
    expect(en.tabFavorites, 'Favorites');
    expect(en.search, 'Search');
    expect(en.searchTitle, 'Search');
    expect(en.searchHint, 'Search city');
    expect(en.useMyLocation, 'Use my location');
    expect(en.locationPermissionDeniedTitle, 'Location permission denied');
    expect(
      en.locationPermissionDeniedBody,
      'Enable location access in settings or search for a city.',
    );
    expect(en.locationServicesDisabledTitle, 'Location services are off');
    expect(
      en.locationServicesDisabledBody,
      'Turn on location services to use GPS weather.',
    );
    expect(en.locationTimeoutTitle, 'Location timeout');
    expect(
      en.locationTimeoutBody,
      'We couldn\'t get a GPS fix. Try again or search for a city.',
    );
    expect(en.noSearchResultsTitle, 'No results');
    expect(en.noSearchResultsBody, 'Try a different city name.');
    expect(en.loading, 'Loading...');
    expect(en.errorGeneric, 'Something went wrong.');
    expect(en.retry, 'Retry');
    expect(en.addFavorite, 'Add favorite');
    expect(en.removeFavorite, 'Remove favorite');
    expect(en.unitsMetric, 'Units: Celsius');
    expect(en.unitsImperial, 'Units: Fahrenheit');
    expect(en.feelsLike, 'Feels like');
    expect(en.humidity, 'Humidity');
    expect(en.wind, 'Wind');
    expect(en.hourlyForecast, 'Hourly');
    expect(en.dailyForecast, '5-day');
    expect(en.forecastUnavailableTitle, 'No forecast data');
    expect(
      en.forecastUnavailableBody,
      'Forecast data is unavailable for this location.',
    );
    expect(en.emptyNowTitle, 'No weather yet');
    expect(
      en.emptyNowBody,
      'Search for a city or enable location to see current conditions.',
    );
    expect(en.emptyForecastTitle, 'No forecast yet');
    expect(
      en.emptyForecastBody,
      'Select a location to view hourly and daily forecasts.',
    );
    expect(en.emptyFavoritesTitle, 'No favorites yet');
    expect(en.emptyFavoritesBody, 'Save locations to access them quickly.');
    expect(en.offlineBadge, 'Offline');
    expect(en.lastUpdated('11:20'), 'Last updated 11:20');
  });

  test('AppLocalizationsAr exposes expected strings', () {
    final ar = AppLocalizationsAr();

    expect(ar.appTitle, 'بكسل ويزر');
    expect(ar.tabNow, 'الآن');
    expect(ar.tabForecast, 'التوقعات');
    expect(ar.tabFavorites, 'المفضلة');
    expect(ar.search, 'بحث');
    expect(ar.searchTitle, 'بحث');
    expect(ar.searchHint, 'ابحث عن مدينة');
    expect(ar.useMyLocation, 'استخدم موقعي');
    expect(ar.locationPermissionDeniedTitle, 'تم رفض إذن الموقع');
    expect(
      ar.locationPermissionDeniedBody,
      'قم بتمكين الوصول للموقع في الإعدادات أو ابحث عن مدينة.',
    );
    expect(ar.locationServicesDisabledTitle, 'خدمات الموقع معطلة');
    expect(
      ar.locationServicesDisabledBody,
      'قم بتشغيل خدمات الموقع لاستخدام طقس GPS.',
    );
    expect(ar.locationTimeoutTitle, 'انتهت مهلة الموقع');
    expect(
      ar.locationTimeoutBody,
      'لم نتمكن من الحصول على إشارة GPS. حاول مرة أخرى أو ابحث عن مدينة.',
    );
    expect(ar.noSearchResultsTitle, 'لا توجد نتائج');
    expect(ar.noSearchResultsBody, 'جرب اسم مدينة مختلف.');
    expect(ar.loading, 'جارٍ التحميل...');
    expect(ar.errorGeneric, 'حدث خطأ ما.');
    expect(ar.retry, 'إعادة المحاولة');
    expect(ar.addFavorite, 'إضافة للمفضلة');
    expect(ar.removeFavorite, 'إزالة من المفضلة');
    expect(ar.unitsMetric, 'الوحدات: مئوية');
    expect(ar.unitsImperial, 'الوحدات: فهرنهايت');
    expect(ar.feelsLike, 'يبدو كأنه');
    expect(ar.humidity, 'الرطوبة');
    expect(ar.wind, 'الرياح');
    expect(ar.hourlyForecast, 'كل ساعة');
    expect(ar.dailyForecast, '٥ أيام');
    expect(ar.forecastUnavailableTitle, 'بيانات التوقعات غير متوفرة');
    expect(
      ar.forecastUnavailableBody,
      'بيانات التوقعات غير متوفرة لهذا الموقع.',
    );
    expect(ar.emptyNowTitle, 'لا يوجد طقس بعد');
    expect(
      ar.emptyNowBody,
      'ابحث عن مدينة أو فعل الموقع لرؤية الظروف الحالية.',
    );
    expect(ar.emptyForecastTitle, 'لا توجد توقعات بعد');
    expect(
      ar.emptyForecastBody,
      'اختر موقعاً لعرض التوقعات الساعية واليومية.',
    );
    expect(ar.emptyFavoritesTitle, 'لا توجد مفضلات بعد');
    expect(ar.emptyFavoritesBody, 'احفظ المواقع للوصول إليها بسرعة.');
    expect(ar.offlineBadge, 'غير متصل');
    expect(ar.lastUpdated('11:20'), 'آخر تحديث 11:20');
  });
}
