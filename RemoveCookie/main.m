//
//  main.m
//  RemoveCookie
//
//  Created by Rob Mathers on 12-11-28.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//
//  Modified by Mark Gondree on 17-09-29
//

#import <Foundation/Foundation.h>

// NSLog replacement from http://stackoverflow.com/a/3487392/1376063
void IFPrint (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    fputs([[[NSString alloc] initWithFormat:format arguments:args] UTF8String], stdout);
    fputs("\n", stdout);
    
    va_end(args);
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSHTTPCookieStorage *cookieStorage;
        NSArray *matchedCookies;
        
        // Safari cookies in 10.11+ need to be accessed with sharedCookieStorageForGroupContainerIdentifier:
        // per http://stackoverflow.com/questions/32921572/stringwithcontentsofurl-cookie-jar-in-el-capitan
        if ([[NSHTTPCookieStorage class] respondsToSelector:@selector(sharedCookieStorageForGroupContainerIdentifier:)]) {
            cookieStorage = [NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:@"Cookies"];
        }
        else {
            cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        }

        NSString *urlSearchString;
        if (argc > 1) {
            urlSearchString = [[NSString alloc] initWithUTF8String:argv[1]];
            NSString *filterString = [[NSString alloc] initWithFormat:@"domain ENDSWITH '%@'", urlSearchString];
            NSPredicate *filter = [NSPredicate predicateWithFormat:filterString];
            matchedCookies = [cookieStorage.cookies filteredArrayUsingPredicate:filter];
        }
        else {
            IFPrint(@"No URL provided. Matching all cookies.");
            matchedCookies = cookieStorage.cookies;
        }

        for (int i = 0; i < matchedCookies.count; i++) {
            NSHTTPCookie *c = [matchedCookies objectAtIndex:i];
            IFPrint(@"Removing %s [%s]", c.domain.UTF8String, c.name.UTF8String);
            [cookieStorage deleteCookie:c];
        }

        IFPrint(@"Removed %li cookies", matchedCookies.count);
        return 0;
    }
}

