# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $.ajax "/home/todays_report.html",
    data: {}
    success: (data, textStatus, jqXHR) ->
      $("#infoSlider").html(data)
      #$('#infoSlider').flipster()
      #$('#infoSlider').flipster({ style: 'carousel', start: 0 })
      #console.log($('#infoSlider'), $('#infoSlider').flipster);
      $('#infoSlider').flipster({ start: 0 })
      
      #window.setInterval(
      #  () ->
      #    $('#infoSlider').flipster('jump', 'right')
      #    false
      #  10000
      #)
      false
    error: (jqXHR, textStatus, errorThrown) -> alert("Error!" + errorThrown)





  $(document).on 'click', '.home.index a.xhr.inlineform', (evnt) ->
    $td = $(this).closest("td")
    $.ajax this.href,
      data: {}
      success: (data, textStatus, jqXHR) -> $td.html(data)
      error: (jqXHR, textStatus, errorThrown) -> alert("Error!" + errorThrown)
    false
  $(document).on 'submit','.home.index form.xhr.inlineform', (evnt) ->
    $td = $(this).closest("td")
    $.ajax this.action,
      data: $(this).serializeArray(),
      type: 'put'
      success: (data, textStatus, jqXHR) -> $td.html(data)
      error: (jqXHR, textStatus, errorThrown) -> alert("Error!" + errorThrown)
    false

  Highcharts.setOptions({
    lang:
      decimalPoint: ","
      thousandsSep: "."
  })

  createAllChart = () ->

    window['home_historical_chart_max'] = 0;
    window['home_historical_chart_min'] = 1000000;
    window['home_historical_chart_maxYPoint'] = null;
    window['home_historical_chart_minYPoint'] = null;

    loadedHandler = (event) ->
      extremes = []
      extremes.push(
        {
          x: window['home_historical_chart_minYPoint'].x,
          title: Highcharts.numberFormat(window['home_historical_chart_min'], 2, ",", "."),
          marker: {fillColor: "#FF0000", lineColor: "black !important", lineWidth: 3},
          color: "#FFFFFF"
        }
      )
      extremes.push(
        {
          x: window['home_historical_chart_maxYPoint'].x,
          title: Highcharts.numberFormat(window['home_historical_chart_max'], 2, ",", "."),
          marker: {fillColor: "#00FF00", lineColor: "black !important", lineWidth: 3},
          color: "#FFFFFF"
        }
      )
      sortFunction = (a, b) ->
        a.x > b.x
      extremes.sort(sortFunction)
      for extreme in extremes
        console.group('Extreme:');
        console.dir(extreme);
        console.log("Datum: " + new Date(extreme.x));
        console.groupEnd();
        if (((new Date()).getTime() - (new Date(extreme.x)).getTime()) < (24 * 60 * 60 * 1000 * 15))
          console.log('correcting the x.position of max')
          originalDate = new Date(extreme.x)
          extreme.title = extreme.title + " (am " + originalDate.getDate() + "." + (originalDate.getMonth() + 1) + "." + originalDate.getFullYear() + ")";
          extreme.x = extreme.x - (24 * 60 * 60 * 1000) * 270;
        window['home_historical_chart'].get("extremes").addPoint(extreme)
      true

    options =
      chart:
        renderTo: 'home_historical_chart_container'
        events:
          load: (event) ->
            window.setTimeout(loadedHandler, 1000)
            true
      rangeSelector:
        selected: 5
      legend: {
        enabled: true,
        align: 'right',
        backgroundColor: '#FCFFC5',
        borderColor: 'black',
        borderWidth: 2,
        layout: 'vertical',
        verticalAlign: 'top',
        y: 100,
        shadow: true
      },
      tooltip: {
        pointFormat: '<span style="color:{series.color}">lala {series.name}</span>: <b>{point.y}</b> ({point.change} %)<br/>',
        yDecimals: 2
      },
      plotOptions:
        series:
          events:
            legendItemClick: (event) ->
              id = this.options.id
              #console.log(id)
              #console.dir(this)
              for series, i in this.chart.series
                #console.log(series)
                if series.options.onSeries == id
                  #console.log "found series: ", i
                  #console.log series.visible == true
                  if series.visible
                    series.hide()
                  else
                    series.show()
              true
          dataLabels:
            enabled: true,
            formatter: () ->
              if this.y > window['home_historical_chart_max'] 
                window['home_historical_chart_max'] = this.y
                window['home_historical_chart_maxYPoint'] = this
              if this.y <= window['home_historical_chart_min'] 
                window['home_historical_chart_min'] = this.y
                window['home_historical_chart_minYPoint'] = this
              null;
          flags:
            lineColor: "black !important"
            lineWidth: 3
            shape: "circlepin"
      #title: title
      #series: seriesOptions

    #console.dir(options)

    $.ajax "/home/charts_datas.json",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = { "text" : "Depotwert aller Aktien akkumuliert und Xetra" }
        options.series = data.series
        #console.dir(options)
        chart = new Highcharts.StockChart(options)
        window['home_historical_chart'] = chart
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        #alert("oups");
        false
    false

  if $('#home_historical_chart_container').length > 0
    #console.log("about to initialize the chart!")
    createAllChart()

  window.createAllChart = createAllChart

  createAllHistoricalCompareChart = () ->

    options =
      chart:
        renderTo: 'home_historical_compare_chart_container'
      rangeSelector:
          selected: 5
      legend: {
        enabled: true,
        align: 'right',
        backgroundColor: '#FCFFC5',
        borderColor: 'black',
        borderWidth: 2,
        layout: 'vertical',
        verticalAlign: 'top',
        y: 100,
        shadow: true
      },
      tooltip: {
        yDecimals: 2
      },
      yAxis: {
        labels: {
          formatter: () ->
            `(this.value > 0 ? '+' : '') + this.value + '%'`
        },
        plotLines: [{
          value: 0,
          width: 2,
          color: 'silver'
        }]
      },
      plotOptions:
        series:
          compare: 'value'
          events:
            legendItemClick: (event) ->
              id = this.options.id
              for series, i in this.chart.series
                if series.options.onSeries == id
                  if series.visible
                    series.hide()
                  else
                    series.show()
                true
    $.ajax "/home/charts_datas_comparable.json",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.series = data.series
        console.dir options
        chart = new Highcharts.StockChart(options)
        window['home_historical_compare_chart'] = chart
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        alert("oups");
        false
    false

  if $('#home_historical_compare_chart_container').length > 0
    console.log("about to initialize the chart 'home_historical_compare_chart_container'!")
    createAllHistoricalCompareChart()

  window.createAllHistoricalCompareChart = createAllHistoricalCompareChart

  createAllPerformanceChart = () ->

    options =
      chart:
        renderTo: 'home_historical_performance_chart_container'
      rangeSelector:
        selected: 5
      legend: {
        enabled: true,
        align: 'right',
        backgroundColor: '#FCFFC5',
        borderColor: 'black',
        borderWidth: 2,
        layout: 'vertical',
        verticalAlign: 'top',
        y: 100,
        shadow: true
      },
      tooltip: {
        pointFormat: '<span style="color:{series.color}">lala {series.name}</span>: <b>{point.y}</b> ({point.change} %)<br/>',
        yDecimals: 2
      },
      yAxis: [
        {
          title: {
            text: "Perfomanz des Depotwert in EUR",
            style: {
              color: "#AA4643"
            }
          }
        },
        {
          title: {
            text: "Perfomanz des Index-Kurses",
            style: {
              color: "#4572A7"
            }
          }
        }
      ],
      plotOptions:
        series:
          events:
            legendItemClick: (event) ->
              id = this.options.id
              #console.log(id)
              #console.dir(this)
              for series, i in this.chart.series
                #console.log(series)
                if series.options.onSeries == id
                  #console.log "found series: ", i
                  #console.log series.visible == true
                  if series.visible
                    series.hide()
                  else
                    series.show()
              true
      #title: title
      #series: seriesOptions

    #console.dir(options)

    $.ajax "/home/charts_datas_normalized",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = { "text" : "Performance aller Aktien akkumuliert verglichen mit Performance des Xetra" }
        options.series = data.series
        #console.dir(options)
        chart = new Highcharts.StockChart(options)
        window['home_historical_performance_chart'] = chart
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        #alert("oups");
        false
    false

  if $('#home_historical_performance_chart_container').length > 0
    #console.log("about to initialize the chart 'home_historical_performance_chart_container'!")
    createAllPerformanceChart()

  window.createAllPerformanceChart = createAllPerformanceChart

  false