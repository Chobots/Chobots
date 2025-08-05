package com.kavalok.remoting.commands
{
	import com.kavalok.Global;
	import com.kavalok.location.commands.StuffRainCommand;

	public class StuffRainServerCommand extends ServerCommandBase
	{
		public function StuffRainServerCommand()
		{
			super();
		}
		
		override public function execute():void
		{
			trace("StuffRainServerCommand.execute() called with parameter: " + parameter);
			
			// Create the location command and forward it to the location
			var locationCommand:StuffRainCommand = new StuffRainCommand();
			
			// Copy properties from the parameter object
			if (parameter != null)
			{
				locationCommand.itemId = parameter.itemId;
				locationCommand.fileName = parameter.fileName;
				locationCommand.stuffType = parameter.stuffType;
				locationCommand.rainToken = parameter.rainToken;
				locationCommand.color = parameter.color;
				
				trace("Created location command with itemId: " + locationCommand.itemId + ", fileName: " + locationCommand.fileName + ", rainToken: " + locationCommand.rainToken);
			}
			
			// Execute the command in the current location
			if (Global.locationManager.location != null)
			{
				trace("Executing command in location: " + Global.locationManager.location);
				Global.locationManager.location.rExecuteCommand(locationCommand.getProperties());
			}
			else
			{
				trace("No location available to execute command");
			}
		}
	}
} 