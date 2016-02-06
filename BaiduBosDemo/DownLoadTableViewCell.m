//
//  MyTableViewCell.m
//  MultDownloader
//
//  Created by Marcus on 12/4/12.
//  Copyright (c) 2012 Marcus. All rights reserved.
//

#import "DownLoadTableViewCell.h"

@implementation DownLoadTableViewCell

@synthesize imageView;
@synthesize progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        _lable = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, width- 20-20, 20)];
        _lable.textColor = [UIColor blackColor];
        [self addSubview:_lable];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 40, 40)];
        [self addSubview:imageView];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(80, 30, width-80-20, 20)];
        progressView.hidden = YES;
        [self addSubview:progressView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
