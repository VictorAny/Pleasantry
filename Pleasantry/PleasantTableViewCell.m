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
    self.favorite.enabled = self.flickObject.isFavorite;
////    self.favorite.hidden = YES;
//    self.flickObject.isFavorite = YES;
//    NSMutableDictionary *favoriteData = [NSMutableDictionary dictionary];
//    [favoriteData setValue:self.flickObject.title  forKey:@"Title"];
//    [favoriteData setValue:self.flickObject.url forKey:@"Url"];
//    [self.favorites addObject:favoriteData];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setValue:self.favorites forKey:@"favorites"];
//    [defaults synchronize];
//    [self DidFavoriteFlick:self.flickObject];
    [self.delegate performSelector:@selector(didFavoriteFlick:) withObject:self.flickObject];

    
}
- (void)layoutSubviews{ 
    self.favorite.hidden = NO;
}

- (void)DidFavoriteFlick:(Flick *)flickObject{
//    NSLog(@"Hai");
//    [self.delegate performSelector:@selector(DidFavoriteFlick:) withObject:self.flickObject];

}


@end
