FRCSVFormatter
===============

FRCSVFormatter is log formatter for the awesome [CocoaLumberJack](https://github.com/robbiehanson/CocoaLumberjack) logging framework

It's nice and simple to use, you just need to set it as your chosen formatter where ever you setup your logging.

	FRCSVFormatter	*formatter;
	id 				logger;

	formatter = [[[FRCSVFormatter alloc] init] autorelease];

	logger = [[[AmazingLogger alloc] init] autorelease];

	[logger setFormatter:formatter];

	[DDLog addLogger:logger];
	
Sample output looks like this

	2011-07-14 13:52:02:449,    ,didFinishLaunchingWithOptions (null),207,fbchatAppDelegate,120
	2011-07-14 13:52:02:459,    ,Background operations 0,6803,MCConnectionManager,127
	2011-07-14 13:52:02:484,    ,Loading session for -100001242310570@chat.facebook.com,207,MCLoginViewController,108
	2011-07-14 13:52:02:485,    ,Become active,207,fbchatAppDelegate,443
	2011-07-14 13:52:02:585,    ,==== Connection Changed: WIFI ====,207,MCConnectionManager,425

The real power of this is if you use it in tandem with the [DDFileLogger](https://github.com/robbiehanson/CocoaLumberjack/blob/master/Lumberjack/DDFileLogger.h).
You can then create nice neat CSV files, that you can load up in NeoOffice, Excel (basically anything but textmate), and filter based on Filename, time, or type (Error, Warning, info etc.)!

License
=======
It's Released under a BSD license, enjoy

Contact
=======
Jonathan Dalrymple [Twitter](http://twitter.com/veritech)