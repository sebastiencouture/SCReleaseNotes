//
//  SCItunesService.m
//  SCReleaseNotesDemo
//
//  Created by Sebastien Couture on 13-10-7.
//  Copyright (c) 2013 Sebastien Couture. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "SCItunesAppService.h"

@interface SCItunesAppService()

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSURLConnection *connection;

@property (strong, nonatomic) SCItunesServiceCompleteBlock onComplete;

- (NSString *)appUrlWithId:(NSString *)appId countryCode:(NSString *)countryCode;
- (void)handleResponse:(NSData *)serverJsonData;

@end

@implementation SCItunesAppService

@synthesize responseData = _responseData;
@synthesize connection = _connection;
@synthesize onComplete = _onComplete;

static SCItunesAppService *_instance;

+ (SCItunesAppService *)instance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[SCItunesAppService alloc] init];
    });
    
    return _instance;
}

- (void)getAppWithId:(NSString *)appId countryCode:(NSString *)countryCode onComplete:(SCItunesServiceCompleteBlock)onComplete
{
    self.onComplete = onComplete;
    self.responseData = nil;
    
    if (self.connection)
    {
        [self.connection cancel];
    }
    
    NSURL *url = [NSURL URLWithString:[self appUrlWithId:appId countryCode:countryCode]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    if (self.connection)
    {
        self.responseData = [[NSMutableData alloc] init];
    }
    else
    {
        [self handleResponse:nil];
    }
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self handleResponse:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *serverJsonStr = [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
    NSData *serverJsonData = [serverJsonStr dataUsingEncoding:NSUTF8StringEncoding];

    [self handleResponse:serverJsonData];
}

#pragma mark - private

- (NSString *)appUrlWithId:(NSString *)appId countryCode:(NSString *)countryCode
{
    return [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&country=%@", appId, countryCode];
}

- (void)handleResponse:(NSData *)serverJsonData
{
    self.responseData = nil;
    self.connection = nil;
    
    SCItunesApp *app;
    
    if (serverJsonData)
    {
        NSError *error = nil;
        NSDictionary *serverResponse = [NSJSONSerialization JSONObjectWithData:serverJsonData options: NSJSONReadingMutableContainers error:&error];
        
        if (serverResponse)
        {
            NSNumber *resultCount = [serverResponse objectForKey:@"resultCount"];
            
            if (1 == [resultCount intValue])
            {
                NSArray *results = (NSArray *)[serverResponse objectForKey:@"results"];
                NSDictionary *appJson = [results objectAtIndex:0];
                
                app = [[SCItunesApp alloc] init];
                [app readFromJson:appJson];
            }
        }
    }
    
    if (!app)
    {
        NSLog(@"[SCReleaseNotes] unable to retrieve app information from itunes for release notes");
    }
    
    if (self.onComplete)
    {
        self.onComplete(app);
    }
    
    self.onComplete = nil;
}

@end
