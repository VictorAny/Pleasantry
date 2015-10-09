//
//  FlickrManager.h
//  Pleasantry
//
//  Created by Victor Anyirah on 10/3/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrManager : NSObject
/**
 * Retrieves pleasant images from Flickr API in an array
 */
- (void)getPleasantImagesFromFlickr:(void (^)(bool sucess, NSArray *photos, NSError *error))completionHandler;

@end
