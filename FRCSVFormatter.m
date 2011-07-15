//
//  CSVLogFormatter.m
//
// Copyright (c) 2011, Jonathan Dalrymple
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// 
// Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "FRCSVFormatter.h"

@interface FRCSVFormatter()

-(NSStringEncoding) encoding;
-(NSString*) formatField:(id) anObject;
-(NSString*) formatArray:(NSArray*) aArray;

-(NSDateFormatter*) dateFormatter;
-(NSCharacterSet *) illegalCharacters;

@end

@implementation FRCSVFormatter

+(id)formatter{
	return [[[FRCSVFormatter alloc] init] autorelease];
}

- (id)init {
	if((self = [super init]))
	{

	}
	return self;
}

-(NSStringEncoding) encoding{
	return NSUTF8StringEncoding;
}

/**
 *	Return the date formatter
 *
 */
-(NSDateFormatter*) dateFormatter{
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter_ = [[NSDateFormatter alloc] init];
		[dateFormatter_ setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
	});
	
	return dateFormatter_;
}

/**
 *	Illegal characters
 *
 */
-(NSCharacterSet *) illegalCharacters{
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableCharacterSet * bad = [NSMutableCharacterSet newlineCharacterSet];
		[bad addCharactersInString:@",\"\\"];
		illegalCharacters_ = [bad copy];
	});
	
	return illegalCharacters_;
}

/**
 *	Format an objects description
 *
 *	@param an Object
 *	@return a CSV formatted filed
 */
-(NSString*) formatField:(id) anObject{

	NSMutableString *field;

	field = [[[anObject description] mutableCopy] autorelease];

	if ([field rangeOfCharacterFromSet:[self illegalCharacters]].location != NSNotFound || [field hasPrefix:@"#"]) {
		
		[field replaceOccurrencesOfString:@"\"" 
							   withString:@"\"\"" 
								  options:NSLiteralSearch 
									range:NSMakeRange(0, [field length])
		 ];
		
		[field replaceOccurrencesOfString:@"\\" 
							   withString:@"\\\\" 
								  options:NSLiteralSearch 
									range:NSMakeRange(0, [field length])
		 ];
		
		[field insertString:@"\"" 
					atIndex:0
		 ];
		
		[field appendString:@"\""];
	}
	
	return [[field copy] autorelease];
}

/**
 *	Transform an array into a CSV formatted line
 *	
 *	@param an Array to transform
 *	@return CSV formatted line string
 */
-(NSString*) formatArray:(NSArray*) aArray{
	
	NSMutableArray *formattedValues;
	
	formattedValues = [NSMutableArray arrayWithCapacity:[aArray count]];
	
	[aArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[formattedValues addObject:[self formatField:obj]];
		
		[pool drain];
	}];

	return [[formattedValues componentsJoinedByString:@","] stringByAppendingString:@"\n"];
}

#pragma mark - DDLogFormatter protocol methods
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	NSString *logLevel;
	switch (logMessage->logFlag) {
		case LOG_FLAG_ERROR		:	logLevel = @"Error";	break;
		case LOG_FLAG_WARN		:	logLevel = @"Warning";	break;
		case LOG_FLAG_INFO		:	logLevel = @"Info";		break;
		default					:	logLevel = @"Unknown";	break;
	}
	
	NSString *dateAndTime = [[self dateFormatter] stringFromDate:(logMessage->timestamp)];
	NSString *logMsg = logMessage->logMsg;
	
	return [self formatArray:[NSArray arrayWithObjects:
							  dateAndTime,
							  logLevel,
							  logMsg,
							  [logMessage threadID],
							  [logMessage fileName],
							  [NSNumber numberWithInteger:logMessage->lineNumber],
							  nil
							  ]
			];
}

- (void)dealloc {
	[dateFormatter_ release];
	dateFormatter_ = nil;
	
	[illegalCharacters_ release];
	illegalCharacters_ = nil;
	
	[super dealloc];
}

@end
