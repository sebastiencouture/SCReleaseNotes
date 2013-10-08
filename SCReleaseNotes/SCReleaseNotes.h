//
//  SCReleaseNotes.h
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

#import <Foundation/Foundation.h>

@interface SCReleaseNotes : NSObject

typedef void (^SCReleaseNotesBlock)(NSString *releaseNotes, NSString *version);

// Use release notes from iTunes
- (id)initWithItunesAppId:(NSString *)itunesAppId;

// Use local release notes from the localization table & key
- (id)initWithLocalizationTable:(NSString *)table withKey:(NSString *)key;

/**
* Check for any new release notes. onNewReleaseNotes is only called once per
* app version. Use getCurrentReleaseNotes: to always retrieve the release notes
**/
- (void)checkForNewReleaseNotes:(SCReleaseNotesBlock)onNewReleaseNotes;

- (void)getCurrentReleaseNotes:(SCReleaseNotesBlock)onReleaseNotes;

@end
