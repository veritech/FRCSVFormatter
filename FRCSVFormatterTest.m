//
//  FRCSVFormatterTest.m
//
//  Created by Jonathan Dalrymple on 11/11/2014.
//

#import <XCTest/XCTest.h>
#import "FRCSVFormatter.h"
#import <OCMock/OCMock.h>

@interface FRCSVFormatter(private)

- (NSStringEncoding)encoding;
- (NSDateFormatter *)dateFormatter;
- (NSCharacterSet *)illegalCharacters;
- (NSString *)formatField:(id)anObject;
- (NSString *)formatArray:(NSArray*) aArray;
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage;

@end

@interface FRCSVFormatterTest : XCTestCase

@property (nonatomic,strong) FRCSVFormatter *formatter;

@end

@implementation FRCSVFormatterTest

- (void)setUp {
    [super setUp];
    
    self.formatter = [[FRCSVFormatter alloc] init];
}

- (void)tearDown {
    self.formatter = nil;
    
    [super tearDown];
}

- (void)testInstance {
    XCTAssertNotNil(self.formatter);
    XCTAssertTrue([self.formatter isKindOfClass:[FRCSVFormatter class]]);
}

- (void)testFormatField {
    NSString *result = nil;
    
    result = [self.formatter formatField:@"aaa"];
    XCTAssertEqualObjects(result, @"aaa",@"Contiguous text");
    
    result = [self.formatter formatField:@"aaa bbb"];
    XCTAssertEqualObjects(result, @"aaa bbb",@"Spaces");
    
    result = [self.formatter formatField:@"aaa \r\n bbb"];
    XCTAssertEqualObjects(result, @"\"aaa \r\n bbb\"",@"CRLF");
    
    result = [self.formatter formatField:@"\"aaa\""];
    XCTAssertEqualObjects(result, @"\"\"aaa\"\"",@"quotes");
    
    result = [self.formatter formatField:@"aaa,bbb"];
    XCTAssertEqualObjects(result, @"\"aaa,bbb\"",@"commas");
}

- (void)testFormatArray {
    NSString *result;
    
    result = [self.formatter formatArray:@[@"aaa",@"bbb"]];
    XCTAssertEqualObjects(result, @"aaa,bbb\r\n");
    
    result = [self.formatter formatArray:@[@"aaa",@"bbb"]];
    XCTAssertEqualObjects(result, @"aaa,bbb\r\n");
    
    result = [self.formatter formatArray:@[@"aa\"a",@"bbb"]];
    XCTAssertEqualObjects(result, @"\"aa\"\"a\",bbb\r\n");
}

- (void)testFormatLogMessage {
    
    __block NSString *result = nil;
    OCMockObject *logMessage = [OCMockObject niceMockForClass:[DDLogMessage class]];
    
    [[[logMessage expect] andReturn:@"1"] threadID];
    [[[logMessage expect] andReturn:@"FRCSVFormatter"] fileName];
    [[[logMessage expect] andReturnValue:@2] line];
    [[[logMessage expect] andReturn:@"Hello logs"] message];
    [[[logMessage expect] andReturn:[NSDate dateWithTimeIntervalSince1970:0]] timestamp];
    [[[logMessage expect] andReturnValue:@(DDLogFlagVerbose)] flag];
 
    result = [self.formatter formatLogMessage:(DDLogMessage *)logMessage];
    XCTAssertEqualObjects(result, @"1970-01-01 01:00:00:000,Verbose,Hello logs,1,FRCSVFormatter,2\r\n");
    
    [logMessage verify];
    
    [self measureBlock:^{
        [self.formatter formatLogMessage:(DDLogMessage *)logMessage];
    }];
}

- (void)testDateFormatter {
    XCTAssertNotNil([self.formatter dateFormatter]);
    XCTAssertEqualObjects([[self.formatter dateFormatter] dateFormat], @"yyyy-MM-dd HH:mm:ss:SSS");
}

- (void)testEncoding {
    XCTAssertEqual([self.formatter encoding], NSUTF8StringEncoding);
}

- (void)testIllegalCharacters {
    XCTAssertTrue([[self.formatter illegalCharacters] isKindOfClass:[NSCharacterSet class]]);
}

@end
