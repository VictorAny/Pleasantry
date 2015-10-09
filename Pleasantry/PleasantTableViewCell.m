//
//  PleasantTableViewCell.m
//  Pleasantry
//
//  Created by Victor Anyirah on 10/4/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import "PleasantTableViewCell.h"

@interface PleasantTableViewCell ()


@end


@implementation PleasantTableViewCell


- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)didFavorite:(id)sender {
    [self.delegate performSelector:@selector(didFavoriteFlick:) withObject:self.flickObject];
}


@end
