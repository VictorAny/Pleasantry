//
//  PleasantTableViewCell.h
//  Pleasantry
//
//  Created by Victor Anyirah on 10/4/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flick.h"

@protocol PleasantCellDelegate<NSObject>
/*
 * Delegate method for letting controller know that a user has favorited a flick object
 */
- (void)didFavoriteFlick:(Flick *)aFlickObject;

@end


@interface PleasantTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic, strong) Flick *flickObject;
@property (nonatomic, weak) id <PleasantCellDelegate> delegate;

@end

