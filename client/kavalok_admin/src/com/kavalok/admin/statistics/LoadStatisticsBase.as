package com.kavalok.admin.statistics
{
	import com.kavalok.constants.Modules;
	import com.kavalok.dto.ServerStatisticsTO;
	import com.kavalok.dto.ServerTO;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.services.ServerService;
	import com.kavalok.services.StatisticsService;
	
	import mx.charts.LineChart;
	import mx.charts.series.LineSeries;

	public class LoadStatisticsBase extends StatisticsPageBase
	{
		private static const COUNT : int = 24;

		[Bindable]
		protected var bundle : ResourceBundle;


		public var chart : LineChart;

		
		[Bindable]
		protected var dataProvider : Array;
		[Bindable]
		protected var servers : Array;
		[Bindable]
		protected var series : Array;

		public function LoadStatisticsBase()
		{
			super();
			
			bundle = Localiztion.getBundle(Modules.SERVER_SELECT);
			
			new ServerService(onGetServers).getAllServers();
		}
		
		protected function refresh() : void
		{
			new StatisticsService(onGetData).getLoadChart(minDate, maxDate, COUNT);
		}
		
		private function onGetServers(result : Array) : void
		{
			servers = result;
			var resultSeries : Array = [];
			var serie : LineSeries = new LineSeries();
			serie.yField = "total";
			serie.displayName = 'users total';
			resultSeries.push(serie);
			for each(var server : ServerTO in result)
			{
				serie = new LineSeries();
				serie.yField = server.name;
				serie.displayName = 'users online on ' + bundle.getMessage(server.name);
				resultSeries.push(serie);
			}	
			series = resultSeries;		
		}
		private function onGetData(result : Array) : void
		{
			chart.series = series;
			var convertedData : Array = [];
			for each(var list : Array in result)
			{
				var data : Object = {};
				if(list.length == 0)
					continue;
				data.total = 0;
				for each(var serverStatistics : ServerStatisticsTO in list)
				{
					data.date = serverStatistics.date;
					data[serverStatistics.server] = serverStatistics.usersCount;
					data.total += serverStatistics.usersCount;
				}
				convertedData.push(data);
				
			}
			dataProvider = convertedData;
			
		}
	}
}