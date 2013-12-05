//
//  PLVDemoViewController.m
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "PLVKit.h"
#import "PLVDemoSettingsViewController.h"
#import "PLVDemoViewController.h"

@interface PLVDemoViewController ()
    @property (strong, nonatomic) ALAssetsLibrary* assetsLibrary;
@end

@implementation PLVDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self.imageOverlay setHidden:YES];
    [self.progressBar setProgress:.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"for upload to:\n%@",nil), [self endpoint]];
    [self.urlTextView setText:text];
}

#pragma mark - IBAction Methods
- (IBAction)chooseFile:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.urlTextView setText:nil];
    [self.imageView setImage:nil];
    [self.progressBar setProgress:.0];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSString* type = [info valueForKey:UIImagePickerControllerMediaType];
                                 CFStringRef typeDescription = (UTTypeCopyDescription((__bridge CFStringRef)(type)));
                                 NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Uploading %@…", nil), typeDescription];
                                 CFRelease(typeDescription);
                                 [self.statusLabel setText:text];
                                 [self.imageOverlay setHidden:NO];
                                 [self.chooseFileButton setEnabled:NO];
                                 [self uploadImageFromAsset:info];
                             }];
}

- (void)uploadImageFromAsset:(NSDictionary*)info
{
    NSURL *assetUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *fingerprint = [assetUrl absoluteString];

    [[self assetsLibrary] assetForURL:assetUrl
                          resultBlock:^(ALAsset* asset) {
                              self.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
                              self.imageView.alpha = .5;
                              PLVAssetData* uploadData = [[PLVAssetData alloc] initWithAsset:asset];
                              PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:fingerprint writeToken:@"Y07Q4yopIVXN83n-MPoIlirBKmrMPJu0"];
                              
                              NSString * surl = [assetUrl absoluteString];
                              NSString * ext = [surl substringFromIndex:[surl rangeOfString:@"ext="].location + 4];
                              NSMutableDictionary* extraInfo = [[NSMutableDictionary alloc]init];
                              [extraInfo setValue:ext forKey:@"ext"];
                              [extraInfo setValue:@"tutitt" forKey:@"title"];
                              [extraInfo setValue:@"desccc" forKey:@"desc"];
                              [upload setExtraInfo:extraInfo];
                              upload.progressBlock = [self progressBlock];
                              upload.resultBlock = [self resultBlock];
                              upload.failureBlock = [self failureBlock];
                              [upload start];
                          }
                         failureBlock:^(NSError* error) {
                             NSLog(@"Unable to load asset due to: %@", error);
                         }];
}

- (void(^)(NSInteger bytesWritten, NSInteger bytesTotal))progressBlock
{
    return ^(NSInteger bytesWritten, NSInteger bytesTotal) {
        float progress = (float)bytesWritten / (float)bytesTotal;
        if (isnan(progress)) {
            progress = .0;
        }
        [self.progressBar setProgress:progress];
    };
}

- (void(^)(NSError* error))failureBlock
{
    return ^(NSError* error) {
        NSLog(@"Failed to upload file due to: %@", error);
        [self.chooseFileButton setEnabled:YES];
        NSString* text = self.urlTextView.text;
        text = [text stringByAppendingFormat:@"\n%@", [error localizedDescription]];
        [self.urlTextView setText:text];
        [self.statusLabel setText:NSLocalizedString(@"Failed!", nil)];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil)
                                   message:[error localizedDescription]
                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
    };
}

- (void(^)(NSURL* url))resultBlock
{
    return ^(NSURL* url) {
        NSLog(@"File uploaded to: %@", url);
        [self.chooseFileButton setEnabled:YES];
        [self.imageOverlay setHidden:YES];
        self.imageView.alpha = 1;
        NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Remote URL:\n%@",nil), [url absoluteString]];
        [self.urlTextView setText:text];
    };
}

- (NSString*)endpoint
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:PLVRemoteURLDefaultsKey];
}

@end
