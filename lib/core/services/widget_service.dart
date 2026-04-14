import 'package:home_widget/home_widget.dart';
import '../../domain/models/weather.dart';
import 'package:intl/intl.dart';

class WidgetService {
  static const String _groupId = 'group.com.pixelweather.app';
  static const String _androidWidgetName = 'WeatherWidget';
  static const String _iosWidgetName = 'WeatherWidget';

  Future<void> updateWidget(WeatherReport report) async {
    final current = report.current;
    final location = report.location;

    await HomeWidget.setAppGroupId(_groupId);

    // Save basic weather info
    await HomeWidget.saveWidgetData<String>('location_name', location.name);
    await HomeWidget.saveWidgetData<String>(
      'temperature',
      '${current.temperature.round()}°',
    );
    await HomeWidget.saveWidgetData<String>(
      'condition_type',
      current.condition.type.name,
    );
    await HomeWidget.saveWidgetData<String>(
      'condition_description',
      current.condition.description,
    );
    await HomeWidget.saveWidgetData<String>(
      'last_updated',
      DateFormat.Hm().format(report.updatedAt),
    );

    // Trigger widget update
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }
}
