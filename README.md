SCReleaseNotes
==============

Retrieve app release notes from either iTunes, or from a localization file. Optional support to only display the release notes once per app version. iOS 5 and above supported.

## Example Usage

SCReleaseNotes can be used four ways:

* Display new release notes from iTunes

``` objective-c
SCReleaseNotes *releaseNotes = [[SCReleaseNotes alloc] initWithItunesAppId:@"284910350"];

SCReleaseNotesBlock releaseNotesHandler = ^(NSString *releaseNotes, NSString *version)
{
    // Example showing display in UIAlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:version message:releaseNotes delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
    [alert show];
};

[releaseNotes checkForNewReleaseNotes:releaseNotesHandler];
```


* Display new release notes from localization file

``` objective-c
SCReleaseNotes *releaseNotes = [[SCReleaseNotes alloc] initWithLocalizationTable:@"ReleaseNotes" withKey:@"Message"];

SCReleaseNotesBlock releaseNotesHandler = ^(NSString *releaseNotes, NSString *version)
{
    // Display release notes
};

[releaseNotes checkForNewReleaseNotes:releaseNotesHandler];
```


* Display release notes from iTunes. No checks if already displayed for the current app version.

``` objective-c
SCReleaseNotes *releaseNotes = [[SCReleaseNotes alloc] initWithItunesAppId:@"284910350"];

SCReleaseNotesBlock releaseNotesHandler = ^(NSString *releaseNotes, NSString *version)
{
    // Display release notes
};

[releaseNotes getCurrentReleaseNotes:releaseNotesHandler];
```


* Display release notes from localization file. No checks if already displayed for the current app version.

``` objective-c
SCReleaseNotes *releaseNotes = [[SCReleaseNotes alloc] initWithLocalizationTable:@"ReleaseNotes" withKey:@"Message"];

SCReleaseNotesBlock releaseNotesHandler = ^(NSString *releaseNotes, NSString *version)
{
    // Display release notes
};

[releaseNotes getCurrentReleaseNotes:releaseNotesHandler];
```


## How to Use

1. Copy SCReleaseNotes folder into your project

## License

SCReleaseNotes, and all the accompanying source code, is released under the MIT license