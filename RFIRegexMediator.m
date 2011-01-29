//
//  Created by Annard Brouwer on 27/10/2010.
//  Copyright (c) 2010 Let Software Dream Ltd., All Rights Reserved.
//

#import <OSAKit/OSAScript.h>

#import "RegexKitLite.h"
#import "RFIRegexMediator.h"

@implementation RFIRegexMediator

+ (NSString *)validateRegularExpression:(NSString *)exprStr
{
    NSString *retStr;

    retStr = @"OK";
    @try
    {
        NSString *testStr;
        NSError *regexErr;
        NSRange result;

        testStr = @"TestMe";
        result = [testStr RKL_METHOD_PREPEND(rangeOfRegex): exprStr
                  options: RKLNoOptions
                  inRange: NSMakeRange(0, [testStr length])
                  capture: 0
                  error: &regexErr];
        if (NSNotFound == result.location && 0 == result.length && regexErr)
        {            
            retStr = [NSString stringWithFormat: @"%@ [at character location: %@]", [regexErr localizedDescription],
                      [[regexErr userInfo] objectForKey: RKLICURegexOffsetErrorKey]];
        }
    }
    @catch (NSException *nse)
    {
        retStr = [nse reason];
    }
    return retStr;
}

+ (NSString *)find:(NSString *)findStr
           replace:(NSString *)replaceStr
            inText:(NSString *)txtStr
          useRegEx:(BOOL)useRegEx
{
    NSString *resultStr;

    resultStr = nil;
    @try
    {
        if (useRegEx)
            resultStr = [txtStr RKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex): findStr withString: replaceStr];
        else
            resultStr = [txtStr stringByReplacingOccurrencesOfString: findStr withString: replaceStr];
    }
    @catch (id nse)
    {
        NSDictionary *errorInfo;

        errorInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: errOSASystemError], OSAScriptErrorNumber, [nse reason], OSAScriptErrorMessage, nil];
        NSLog(@"[%@] Exception with %@ find and replace: %@", (useRegEx) ? @"regex" : @"regular",
              [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey: (id)kCFBundleNameKey],
              [nse description]);
        @throw [NSException exceptionWithName: [nse name]
                                       reason: [nse reason]
                                     userInfo: errorInfo];
    }
    if (nil == resultStr)
        resultStr = txtStr;
    return resultStr;
}

+ (NSNumber *)regularExpression:(NSString *)exprStr
              isMatchedByString:(NSString *)findStr
{
    BOOL isMatch;
    
    isMatch = NO;
    @try
    {
        isMatch = [findStr RKL_METHOD_PREPEND(isMatchedByRegex): exprStr];
    }
    @catch (id nse)
    {
        NSDictionary *errorInfo;
        
        errorInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: errOSASystemError], OSAScriptErrorNumber, [nse reason], OSAScriptErrorMessage, nil];
        NSLog(@"[%@] Exception with finding a match: %@", [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey: (id)kCFBundleNameKey], [nse description]);
        @throw [NSException exceptionWithName: [nse name]
                                       reason: [nse reason]
                                     userInfo: errorInfo];
    }
    return [NSNumber numberWithBool: isMatch];
}

@end
