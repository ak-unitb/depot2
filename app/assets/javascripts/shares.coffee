# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

getTdIndexInTr = ($_td, $_tr) ->
  i = 0
  td = $_td[0]
  tr = $_tr[0]
  tds = tr.getElementsByTagName("td")
  try
    i++ while tds[i] != td
  catch e
    console.group("getTdIndexInTr error:")
    console.dir(e)
    console.groupEnd()
  i

updateTdIfNoForm = ($_tr, _tdIdx, _data) ->
  $_td = $($_tr.find("td")[_tdIdx])
  # console.group("updateTdIfNoForm")
  # console.log($_td)
  # console.log(_data)
  # console.groupEnd()
  if $_td.find("form").length == 0
    $_td.html(_data)
  null

getDataIfForm = ($_tr, _tdIdx, data) ->
  $_td = $($_tr.find("td")[_tdIdx])
  $_form = $_td.find("form")
  if $_form.length == 1
    $.merge(data, $_form.serializeArray())
  null

updateTd = ($_tr, _tdIdx, _data) ->
  $_td = $($_tr.find("td")[_tdIdx])
  #console.group("updateTdIf")
  #console.log($_td)
  #console.log(_data)
  #console.groupEnd()
  if $_td.find("form").length == 0
    $_td.html(_data)
  else
    value = _data.replace(" €", '')
    $_td.find("input[type=text]").val(value)
  null

$ ->
  $(document).on 'submit', ".shares.show form.xhr.inlineform", (evnt) ->
    try
      $trs = $(this).closest("tbody").find("tr")
      #console.log($trs)
      $td = $(this).closest("td")
      #console.log($td);
      tdIdx = getTdIndexInTr($td, $td.closest("tr"))
      #console.log(tdIdx)
    catch e
      console.group("jq.ajax error:")
      console.log(e)
      console.groupEnd()

    $.ajax this.action,
      data: $(this).serializeArray(),
      type: 'get'
      success: (data, textStatus, jqXHR) ->
        # console.dir(data)
        dataRows = data.rows
        updateTdIfNoForm $(_tr), tdIdx, dataRows[_i] for _tr in $trs #, _rowData in dataRows
        showAjaxUpdateMessage("Möglichen Kauf errechnet!", "success")
        false
      error: (jqXHR, textStatus, errorThrown) ->
        # console.dir(jqXHR)
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        false
    false

  $(document).on 'submit', ".shares.show form.xhr.inlineform-extra", (evnt) ->
    try
      $trs = $(this).closest("tbody").find("tr")
      #console.log($trs)
      $td = $(this).closest("td")
      #console.log($td);
      tdIdx = getTdIndexInTr($td, $td.closest("tr"))
      #console.log(tdIdx)
      
      dataIn = []
      getDataIfForm $(_tr), tdIdx, dataIn for _tr in $trs
      #console.dir(dataIn)
    catch e
      console.group("jq.ajax error:")
      console.log(e)
      console.groupEnd()

    $.ajax this.action,
      data: dataIn,
      type: 'get'
      success: (data, textStatus, jqXHR) ->
        #console.dir(data)
        dataRows = data.rows
        #console.dir(dataRows)
        updateTd $(_tr), tdIdx, dataRows[_j] for _tr in $trs #, _rowData in dataRows
        showAjaxUpdateMessage("Möglichen Kauf errechnet!", "success")
        false
      error: (jqXHR, textStatus, errorThrown) ->
        # console.dir(jqXHR)
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        false

    false








  createSingleChart = () ->

    options =
      chart:
        renderTo: 'share_chart_container'
      rangeSelector:
        selected: 5
      #title: title
      #series: seriesOptions


    $.ajax self.location.href + "/charts_data.json",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = data.title
        options.series = data.series
        if data.yAxis
          options.yAxis = data.yAxis
        chart = new Highcharts.StockChart(options)
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        alert("oups");
        false
    false


  if $('#share_chart_container').length > 0
    #console.log("about to initialize the chart!")
    createSingleChart()

  window.createSingleChart = createSingleChart


  createSingleHistoricalChart = () ->

    options =
      chart:
        renderTo: 'share_historical_chart_container'
      rangeSelector:
        selected: 5
      legend:
        enabled: true
        align: 'right'
        backgroundColor: '#FCFFC5'
        borderColor: 'black'
        borderWidth: 2
        layout: 'vertical'
        verticalAlign: 'top'
        y: 100
        shadow: true
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


    $.ajax self.location.href + "/charts_historical_data",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = data.title
        options.series = data.series
        if data.yAxis
          options.yAxis = data.yAxis
        chart = new Highcharts.StockChart(options)
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        alert("oups");
        false
    false


  if $('#share_historical_chart_container').length > 0
    #console.log("about to initialize the chart!")
    createSingleHistoricalChart()

  window.createSingleHistoricalChart = createSingleHistoricalChart


  Highcharts.setOptions(
    {
      global: {
        useUTC: false
      }
    }
  )

  createMultipleChart = () ->

    options =
      chart:
        renderTo: 'shares_chart_container'
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
      #title: title
      #series: seriesOptions

    #console.dir(options)

    $.ajax self.location.href + "/charts_datas.json",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = { "text" : "Tagesschlusskurse aller Aktien (absolut)" }
        options.series = data.series
        #console.dir(options)
        chart = new Highcharts.StockChart(options)
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        #alert("oups");
        false
    false


  if $('#shares_chart_container').length > 0
    #console.log("about to initialize the chart!")
    createMultipleChart()

  window.createMultipleChart = createMultipleChart


  createMultipleCompareChart = () ->

    options =
      chart:
        renderTo: 'shares_chart_container_compare'
      rangeSelector:
        selected: 5
      plotOptions:
        series:
          compare: 'percent'
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
        pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change} %)<br/>',
        yDecimals: 2
      }
      #title: title
      #series: seriesOptions

    #console.dir(options)

    $.ajax self.location.href + "/charts_datas.json",
      data: [],
      type: 'get',
      success: (data, textStatus, jqXHR) ->
        options.title = { "text" : "Tagesschlusskurse aller Aktien (prozentualer Vergleich)" }
        options.series = data.series
        #console.dir(options)
        chart = new Highcharts.StockChart(options)
        false
      error: (jqXHR, textStatus, errorThrown) ->
        showAjaxUpdateMessage("Error! " + errorThrown, "error")
        #alert("oups");
        false
    false


  if $('#shares_chart_container_compare').length > 0
    #console.log("about to initialize the chart!")
    createMultipleCompareChart()

  window.createMultipleCompareChart = createMultipleCompareChart


  false

