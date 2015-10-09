//
//  FlickrManager.m
//  Pleasantry
//
//  Created by Victor Anyirah on 10/3/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import "FlickrManager.h"
#import "Flick.h"

static NSString *APIKey = @"01b753d14c67fcc7fd6a5e4ee0fbfcc0";
static NSString *BaseFlickrURL = @"https://api.flickr.com/services/rest/?";
static NSString *BasePhotosMethodFlickrURL = @"method=flickr.photos.search";
static NSString *SearchText = @"cute cats";
static NSString *format = @"json";
static NSString *per_page = @"10";

@interface FlickrManager()

@property (nonatomic, weak)NSString *userName;

@end



@implementation FlickrManager

- (void)getPleasantImagesFromFlickr:(void (^)(bool sucess, NSArray *photos, NSError *error))completionHandler{
    [self searchFlickrForPleasantImagesWithCompletion:^(bool sucess, NSDictionary *parsedData, NSError *error) {
        if (error){
            NSLog(@"%@", error);
            completionHandler(NO, nil, error);
        }else{
            NSLog(@"%@", parsedData);
            NSArray *photos = [self parseFlickResponse:parsedData];
            NSArray *flickObjects = [self parsePhotosForFlicks:photos];
            completionHandler(YES, flickObjects, nil);
            
            
        }
    }];
}

- (NSString *)getFlickrSearchURL{
    NSString *APICallString = [NSString stringWithFormat:@"%@%@", BaseFlickrURL, BasePhotosMethodFlickrURL];
    NSString *returnString =  [NSString stringWithFormat:@"%@&api_key=%@&text=%@&extras=url_m&format=%@&per_page=%@&nojsoncallback=1", APICallString, APIKey, SearchText, format, per_page];
//    NSLog(@"%@", returnString);
    return returnString;
}

-(void)searchFlickrForPleasantImagesWithCompletion: (void (^)(bool sucess, NSDictionary *parsedData, NSError *error))completionHandler{
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *url = [self getFlickrSearchURL];
    NSURL *encodedUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:encodedUrl];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (error){
                                                    completionHandler(NO, nil, error);
                                                }
                                                else{
                                                    NSError * error = nil;
                                                    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                    completionHandler(YES,parsedData,nil);
                                                }
                                            }
                                  ];
    [task resume];

    
}

- (NSArray *)parseFlickResponse:(NSDictionary *)response{
    NSDictionary *photosDict = response[@"photos"];
    NSArray *photos = photosDict[@"photo"];
    return photos;
}

- (NSArray *)parsePhotosForFlicks:(NSArray *)photos{
    NSMutableArray *flickArray = [NSMutableArray array];
    for (NSDictionary *photo in photos){
        Flick *flickObj = [[Flick alloc]init];
        flickObj.title = [photo valueForKey:@"title"];
        flickObj.url = [photo valueForKey:@"url_m"];
        [flickArray addObject:flickObj];
    }
    return flickArray;
}

@end
