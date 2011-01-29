//
//  Created by Annard Brouwer on 27/10/2010.
//  Copyright (c) 2010 Let Software Dream Ltd., All Rights Reserved.
//

#import <Cocoa/Cocoa.h>

@interface RFIRegexMediator : NSObject

+ (NSString *)validateRegularExpression:(NSString *)exprStr;

+ (NSString *)find:(NSString *)findStr
           replace:(NSString *)replaceStr
            inText:(NSString *)txtStr
          useRegEx:(BOOL)nory;

+ (NSNumber *)regularExpression:(NSString *)exprStr
              isMatchedByString:(NSString *)findStr;

@end
