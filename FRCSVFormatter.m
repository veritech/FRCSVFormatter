//
// FRCSVLogFormatter.m
//
// Copyright (c) 2014, Jonathan Dalrymple
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// 
// Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "FRCSVFormatter.h"

@interface FRCSVFormatter()

@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSCharacterSet *illegalCharacters;

@end

@implementation FRCSVFormatter

+ (instancetype)formatter{
	return [[self alloc] init];
}

- (instancetype)init {
	if((self = [super init])) {

	}
	return self;
}

- (NSStringEncoding)encoding{
	return NSUTF8StringEncoding;
}

- (NSString *)dateFormat {
	return @"yyyy-MM-dd HH:mm:ss:SSS";
}

- (NSString *)separatorCharacter {
	return @",";
}

/**
 *	Return the date formatter
 *
 */
- (NSDateFormatter*)dateFormatter{
    if(!_dateFormatter){
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_dateFormatter setDateFormat:[self dateFormat]];
	};
	
	return _dateFormatter;
}

/**
 *	Illegal characters
 *
 */
- (NSCharacterSet *)illegalCharacters{
    if (!_illegalCharacters){
		NSMutableCharacterSet * bad = [NSMutableCharacterSet newlineCharacterSet];
		[bad addCharactersInString:@",\""];
		_illegalCharacters = [bad copy];
	};
	
	return _illegalCharacters;
}

/**
 *	Format an objects description
 *
 *	@param an Object
 *	@return a CSV formatted filed
 */
- (NSString*)formatField:(id)anObject{
	NSMutableString *field = [[anObject description] mutableCopy];
    
    if ([field rangeOfCharacterFromSet:[self illegalCharacters]].location != NSNotFound || [field hasPrefix:@"#"]) {

        //Escape quotes
        [field replaceOccurrencesOfString:@"\""
                               withString:@"\"\""
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [field length])
         ];

        if (![[field substringToIndex:1] isEqualToString:@"\""] && ![[field substringFromIndex:(field.length-1)] isEqualToString:@"\""]) {
            [field insertString:@"\""
                        atIndex:0
             ];
            
            [field appendString:@"\""];
        }
    }
    
	return [field copy];
}

/**
 *	Transform an array into a CSV formatted line
 *	
 *	@param an Array to transform
 *	@return CSV formatted line string
 */
- (NSString*)formatArray:(NSArray*) aArray{
	
	NSMutableArray *formattedValues;
	
	formattedValues = [NSMutableArray arrayWithCapacity:[aArray count]];
	
	[aArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            [formattedValues addObject:[self formatField:obj]];
        }
	}];

	return [[formattedValues componentsJoinedByString:[self separatorCharacter]] stringByAppendingString:@"\r\n"];
}

#pragma mark - DDLogFormatter protocol methods
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	NSString *logLevel;
	switch (logMessage.flag) {
		case DDLogFlagError		:	logLevel = @"Error";	break;
		case DDLogFlagWarning	:	logLevel = @"Warning";	break;
		case DDLogFlagInfo		:	logLevel = @"Info";		break;
        case DDLogFlagDebug     :   logLevel = @"Debug";	break;
        case DDLogFlagVerbose   :   logLevel = @"Verbose";	break;
		default					:	logLevel = @"Unknown";	break;
	}
	
	NSString *dateAndTime = [self.dateFormatter stringFromDate:(logMessage.timestamp)];
	NSString *logMsg = logMessage.message;
	
	return [self formatArray:[NSArray arrayWithObjects:
							  dateAndTime,
							  logLevel,
							  logMsg,
                              logMessage.threadID,
                              logMessage.fileName,
							  @(logMessage.line),
							  nil
							  ]
			];
}


@end
