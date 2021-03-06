//
//  PECropViewController.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "PECropViewController.h"
#import "PECropView.h"
#import "QuartzCore/QuartzCore.h"

@interface PECropViewController () <UIActionSheetDelegate>

@property (nonatomic) PECropView *cropView;
@property (nonatomic) UIActionSheet *actionSheet;

@end

@implementation PECropViewController

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"PEPhotoCropEditor" withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:bundleURL];
    });
    
    return bundle;
}

static inline NSString *PELocalizedString(NSString *key, NSString *comment)
{
    return [[PECropViewController bundle] localizedStringForKey:key value:nil table:@"Localizable"];
}

#pragma mark -

- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    self.cropView = [[PECropView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:self.cropView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];
    
    if (!self.toolbarItems) {
        
        [self.navigationController toolbar].barStyle = UIBarStyleBlack;
        
        [self.navigationController toolbar].tintColor = [UIColor whiteColor];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *constrain34Button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PEPhotoCropEditor.bundle/icon_02crop_threefour_active"] style:UIBarButtonItemStylePlain target:self action:@selector(ratio34:)];
        
        UIBarButtonItem *constrain11Button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PEPhotoCropEditor.bundle/icon_02crop_oneone_active"] style:UIBarButtonItemStylePlain target:self action:@selector(ratio11:)];
        
        UIBarButtonItem *constrain43Button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PEPhotoCropEditor.bundle/icon_02crop_fourthree_active"] style:UIBarButtonItemStylePlain target:self action:@selector(ratio43:)];
        
        self.toolbarItems = @[flexibleSpace, constrain43Button, flexibleSpace, constrain11Button, flexibleSpace, constrain34Button, flexibleSpace];
    }
    
    for (UIView *view in self.actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        }
    }
    
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    self.navigationController.toolbarHidden = self.toolbarHidden;
    
    self.cropView.image = self.image;
}

-(void)ratio34:(UIButton *)sender
{
    self.cropView.cropAspectRatio = 3.0f / 4.0f;
}

-(void)ratio11:(UIButton *)sender
{
    self.cropView.cropAspectRatio = 1.0f;
}

-(void)ratio43:(UIButton *)sender
{
    self.cropView.cropAspectRatio = 4.0f / 3.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.cropAspectRatio != 0) {
        self.cropAspectRatio = self.cropAspectRatio;
    }
    if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
        self.cropRect = self.cropRect;
    }
    if (!CGRectEqualToRect(self.imageCropRect, CGRectZero)) {
        self.imageCropRect = self.imageCropRect;
    }
    
    self.keepingCropAspectRatio = self.keepingCropAspectRatio;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.cropView.image = image;
}

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio;
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio
{
    _cropAspectRatio = cropAspectRatio;
    self.cropView.cropAspectRatio = self.cropAspectRatio;
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    _imageCropRect = CGRectZero;
    
    CGRect cropViewCropRect = self.cropView.cropRect;
    cropViewCropRect.origin.x += cropRect.origin.x;
    cropViewCropRect.origin.y += cropRect.origin.y;
    
    CGSize size = CGSizeMake(fminf(CGRectGetMaxX(cropViewCropRect) - CGRectGetMinX(cropViewCropRect), CGRectGetWidth(cropRect)),
                             fminf(CGRectGetMaxY(cropViewCropRect) - CGRectGetMinY(cropViewCropRect), CGRectGetHeight(cropRect)));
    cropViewCropRect.size = size;
    self.cropView.cropRect = cropViewCropRect;
}

- (void)setImageCropRect:(CGRect)imageCropRect
{
    _imageCropRect = imageCropRect;
    _cropRect = CGRectZero;
    
    self.cropView.imageCropRect = imageCropRect;
}

- (void)resetCropRect
{
    [self.cropView resetCropRect];
}

- (void)resetCropRectAnimated:(BOOL)animated
{
    [self.cropView resetCropRectAnimated:animated];
}

#pragma mark -

- (void)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)]) {
        [self.delegate cropViewControllerDidCancel:self];
    }
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:)]) {
        [self.delegate cropViewController:self didFinishCroppingImage:self.cropView.croppedImage];
    }
}

- (void)constrain:(id)sender
{
    //    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                   delegate:self
    //                                          cancelButtonTitle:PELocalizedString(@"Cancel", nil)
    //                                     destructiveButtonTitle:nil
    //                                          otherButtonTitles:
    //                        PELocalizedString(@"Square", nil),
    //                        PELocalizedString(@"4 x 3", nil),
    //                        PELocalizedString(@"3 x 4", nil), nil];
    //
    //
    //    self.actionSheet.backgroundColor = [UIColor blackColor];
    //
    //    [self.actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* if (buttonIndex == 0) {
     CGRect cropRect = self.cropView.cropRect;
     CGSize size = self.cropView.image.size;
     CGFloat width = size.width;
     CGFloat height = size.height;
     CGFloat ratio;
     if (width < height) {
     ratio = width / height;
     cropRect.size = CGSizeMake(CGRectGetHeight(cropRect) * ratio, CGRectGetHeight(cropRect));
     } else {
     ratio = height / width;
     cropRect.size = CGSizeMake(CGRectGetWidth(cropRect), CGRectGetWidth(cropRect) * ratio);
     }
     self.cropView.cropRect = cropRect;
     } else */
    if (buttonIndex == 0) {
        self.cropView.cropAspectRatio = 1.0f;
    } else if (buttonIndex == 1) {
        self.cropView.cropAspectRatio = 4.0f / 3.0f;
    } else if (buttonIndex == 2) {
        self.cropView.cropAspectRatio = 3.0f / 4.0f;
    }
    
    
    self.cropView.keepingCropAspectRatio = YES;
}

@end
