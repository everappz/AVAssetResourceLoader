//
//  LSPlaySliderView.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "LSPlaySliderView.h"
#import "UIImage+LSAdditions.h"

@interface LSPlaySliderView()

@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *rightLabel;
@property (nonatomic,strong) UISlider *sliderView;
@property (nonatomic,strong) UIProgressView *progressView;

@end


@implementation LSPlaySliderView


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        UISlider *slider = [[UISlider alloc] init];
        [slider setThumbImage:[UIImage templateImageNamed:@"slider_line_thumb"] forState:UIControlStateNormal];
        [slider setMinimumTrackImage:[[UIImage imageWithColor:[self.tintColor colorWithAlphaComponent:1.0] size:CGSizeMake(2.0, 2.0)] stretchableImage] forState:UIControlStateNormal];
        [slider setMaximumTrackImage:[[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(2.0, 2.0)] stretchableImage] forState:UIControlStateNormal];
        [self addSubview:slider];
        self.sliderView = slider;
        
        UIProgressView *progress = [[UIProgressView alloc]  initWithProgressViewStyle:UIProgressViewStyleDefault];
        progress.progress = 0.0;
        [progress setProgressImage:[[[UIImage imageWithColor:[self.tintColor colorWithAlphaComponent:1.0] size:CGSizeMake(2.0, 2.0)] stretchableImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [progress setTrackImage:[[[UIImage imageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] size:CGSizeMake(2.0, 2.0)] stretchableImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self insertSubview:progress belowSubview:slider];
        self.progressView  = progress;
        
        UIFont *labelFont = [UIFont systemFontOfSize:10.0];
        UIColor *labelColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
        NSTextAlignment labelTextAlignment = NSTextAlignmentCenter;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = labelFont;
        label.textColor = labelColor;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = labelTextAlignment;
        label.text = @"--:--";
        [self addSubview:label];
        self.leftLabel = label;
        
        label = [[UILabel alloc] init];
        label.font = labelFont;
        label.textColor = labelColor;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = labelTextAlignment;
        label.text = @"--:--";
        [self addSubview:label];
        self.rightLabel = label;
        
    }
    
    return self;
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat rootWidth = self.bounds.size.width;
    CGFloat rootHeight = self.bounds.size.height;
    
    static const CGFloat labelWidth = 46.0;
    static const CGFloat sliderDx = 4.0f;
    static const CGFloat labelDx = 2.0;
    
    CGRect leftLabelFrame = CGRectMake(labelDx, 0, labelWidth, rootHeight);
    [self.leftLabel setFrame:leftLabelFrame];
    
    CGRect rightLabelFrame = CGRectMake(rootWidth-labelDx-labelWidth, 0, labelWidth, rootHeight);
    [self.rightLabel setFrame:rightLabelFrame];
    
    CGRect sliderFrame = CGRectMake(CGRectGetMaxX(leftLabelFrame)+sliderDx, 0, CGRectGetMinX(rightLabelFrame)-CGRectGetMaxX(leftLabelFrame)-2*sliderDx, rootHeight);
    [self.sliderView setFrame:sliderFrame];
    
    [self.progressView setFrame:sliderFrame];
    
    self.progressView.center = self.sliderView.center;
}


@end
