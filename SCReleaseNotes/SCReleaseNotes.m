//
//  SCReleaseNotes.m
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

#import "SCReleaseNotes.h"

#import "SCItunesAppService.h"
#import "SCItunesApp.h"

#define LAST_DISPLAYED_VERSION_KEY @"SCReleaseNotes_LastVersion"

@interface SCReleaseNotes()

@property (strong, nonatomic) NSString *itunesAppId;
@property (strong, nonatomic) NSString *localizationTable;
@property (strong, nonatomic) NSString *localizationKey;

- (NSString *)lastDisplayedReleaseNotesVersion;
- (void)updateLastDisplayReleaseNotesVersion;

- (NSString *)localReleaseNotes;

- (NSString *)currentVersion;
- (void)log:(NSString *)message;

- (NSUserDefaults *)userDefaults;

@end

@implementation SCReleaseNotes

@synthesize itunesAppId = _itunesAppId;

- (id)initWithItunesAppId:(NSString *)itunesAppId
{
    self = [self init];
    
    if (self)
    {
        self.itunesAppId = itunesAppId;
    }
    
    if (0 == self.itunesAppId.length)
    {
        [self log:@"itunes app id must be set"];
    }
    
    return self;
}

- (id)initWithLocalizationTable:(NSString *)table withKey:(NSString *)key
{
    self = [self init];
    
    if (self)
    {
        self.localizationTable = table;
        self.localizationKey = key;
    }
    
    if (0 == self.localizationTable.length)
    {
        [self log:@"localization table name must be set"];
    }
    
    if (0 == self.localizationKey.length)
    {
        [self log:@"localization key name must be set"];
    }
    
    return self;
}

-(void)checkForNewReleaseNotes:(SCReleaseNotesBlock)onNewReleaseNotes
{
    if ([self.currentVersion isEqualToString:self.lastDisplayedReleaseNotesVersion])
    {
        return;
    }

    SCReleaseNotesBlock completeHandler = ^(NSString *releaseNotes, NSString *version)
    {
        onNewReleaseNotes(releaseNotes, version);
        
        [self updateLastDisplayReleaseNotesVersion];
    };
    
    [self getCurrentReleaseNotes:completeHandler];
}

- (void)getCurrentReleaseNotes:(SCReleaseNotesBlock)onReleaseNotes
{
    if (0 < self.localizationTable.length &&
        0 <self.localizationKey.length)
    {
        NSString *releaseNotes = [self localReleaseNotes];
        onReleaseNotes(releaseNotes, self.currentVersion);
    }
    else
    {
        if (0 == self.itunesAppId.length)
        {
            [self log:@"itunes app id must be set, unable to check for new release notes"];
            return;
        }
        
        SCItunesServiceCompleteBlock completeHandler = ^(SCItunesApp *app)
        {
            if (!app || 0 == app.releaseNotes.length)
            {
                [self log:@"unable to find itunes app info"];
                return;
            }
            
            onReleaseNotes(app.releaseNotes, self.currentVersion);
        };
        
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        [[SCItunesAppService instance] getAppWithId:self.itunesAppId countryCode:countryCode onComplete:completeHandler];
    }
}

#pragma mark - private

- (NSString *)lastDisplayedReleaseNotesVersion
{
    return [self.userDefaults objectForKey:LAST_DISPLAYED_VERSION_KEY];
}

- (void)updateLastDisplayReleaseNotesVersion
{
    [self.userDefaults setObject:self.currentVersion forKey:LAST_DISPLAYED_VERSION_KEY];
    
    [self.userDefaults synchronize];
}

- (NSString *)localReleaseNotes
{
    return NSLocalizedStringFromTable(self.localizationKey, self.localizationTable, @"release notes");
}

- (NSString *)currentVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)log:(NSString *)message
{
    NSLog(@"[SCReleaseNotes] : %@", message );
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end
