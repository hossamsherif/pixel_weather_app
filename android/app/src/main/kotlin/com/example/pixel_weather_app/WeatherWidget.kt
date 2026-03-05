package com.example.pixel_weather_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class WeatherWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
                setTextViewText(R.id.widget_location, widgetData.getString("location_name", "Unknown"))
                setTextViewText(R.id.widget_temperature, widgetData.getString("temperature", "--°"))
                setTextViewText(R.id.widget_condition, widgetData.getString("condition_description", ""))
                
                // Map condition to icon
                val condition = widgetData.getString("condition_type", "unknown")?.lowercase() ?: "unknown"
                val iconRes = when (condition) {
                    "clear" -> R.drawable.ic_sunny
                    "clouds" -> R.drawable.ic_cloudy
                    "rain" -> R.drawable.ic_rainy
                    "thunder" -> R.drawable.ic_thunder
                    "snow" -> R.drawable.ic_cloudy
                    "fog" -> R.drawable.ic_cloudy
                    else -> 0
                }
                
                if (iconRes != 0) {
                    setImageViewResource(R.id.widget_condition_icon, iconRes)
                    setViewVisibility(R.id.widget_condition_icon, android.view.View.VISIBLE)
                } else {
                    setViewVisibility(R.id.widget_condition_icon, android.view.View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
