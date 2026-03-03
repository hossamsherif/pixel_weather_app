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
                setTextViewText(R.id.widget_updated, "Updated: ${widgetData.getString("last_updated", "--:--")}")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
