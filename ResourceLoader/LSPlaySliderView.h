//
//  LSPlaySliderView.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <UIKit/UIKit.h>

@interface LSPlaySliderView : UIView

@property (nonatomic,readonly,strong) UILabel *leftLabel;
@property (nonatomic,readonly,strong) UILabel *rightLabel;
@property (nonatomic,readonly,strong) UISlider *sliderView;
@property (nonatomic,readonly,strong) UIProgressView *progressView;

@end
