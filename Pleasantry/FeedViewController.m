//
//  FeedViewController.m
//  Pleasantry
//
//  Created by Victor Anyirah on 10/3/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import "FeedViewController.h"
#import "FlickrManager.h"
#import "PleasantTableViewCell.h"
#import "Flick.h"

static NSString *cellIdentifier = @"pleasantCell";
static NSString *favoritesIdentifier = @"favorites";

@interface FeedViewController ()

@property(nonatomic, strong)FlickrManager *flickrManager;
@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorSubView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *favorites;
@property (nonatomic, strong) NSArray *flicks;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong)NSUserDefaults *defaults;



@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _flickrManager = [[FlickrManager alloc]init];
    self.imageCache = [[NSCache alloc]init];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    [self initializeViewsAndTableDependencies];
    [self.feedTable registerNib:[UINib nibWithNibName:@"PleasantTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self.flickrManager getPleasantImagesFromFlickr:^(bool sucess, NSArray *photos, NSError *error) {
        if (error){
            NSLog(@"error, while retrieving pleasant photos");
        }else{
            // Used to avoid retain cyle
            __weak typeof (self) weakSelf = self;
          dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof (weakSelf) strongSelf = weakSelf;
              strongSelf.flicks = photos;
              [strongSelf.feedTable reloadData];
              [strongSelf.spinner stopAnimating];
              strongSelf.indicatorSubView.hidden = YES;
              strongSelf.spinner.hidden = YES;
          });
        }
    }];
}

- (void)didFavoriteFlick:(Flick *)aFlickObject{
    NSLog(@"user favorited %@", aFlickObject.title);
    NSDictionary *favoriteFlick = @{@"title": aFlickObject.title,
                                    @"data" : aFlickObject.url
                                    };
    NSMutableArray *defaultsArray = [[self.defaults valueForKey:favoritesIdentifier]mutableCopy];
    [defaultsArray addObject:favoriteFlick];
    [self.defaults setObject:defaultsArray forKey:favoritesIdentifier];
    [self.defaults synchronize];
    self.favorites = [self.defaults valueForKey:favoritesIdentifier];
    [self.feedTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [self getFavorites];
    [self.feedTable reloadData];
}

- (void)initializeViewsAndTableDependencies{
    self.spinner.tag = 12;
    [self.spinner startAnimating];
    self.indicatorSubView.hidden = NO;
    self.feedTable.dataSource = self;
    self.feedTable.delegate = self;
    self.feedTable.rowHeight = 350;
    self.feedTable.allowsSelection = NO;
}

- (void)dealloc{
    [self.defaults synchronize];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PleasantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    Flick *flickr = [self.flicks objectAtIndex:indexPath.row];
    NSString *url = flickr.url;
    NSURL *imageurl = [NSURL URLWithString:url];
    UIImage *cachedThumbnailPic = [self.imageCache objectForKey:flickr.title];
    cell.title.text = flickr.title;
    cell.flickObject = flickr;
    for (NSDictionary *object in self.favorites){
        NSString *objectTitle = [object objectForKey:@"title"];
        if ([objectTitle isEqualToString:flickr.title]){
            cell.favorite.enabled = NO;
            break;
        }else{
            cell.favorite.enabled = YES;
        }
    }
    if (cachedThumbnailPic){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photoView.image = cachedThumbnailPic;
        });
    }else{
        // Asynchronously loads images into tableview in order to keep scrolling smooth
        // Weakself used to avoid retain cycle
        __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* thumbnail = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:imageurl]];
        if (thumbnail) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           __strong typeof (weakSelf) strongself = weakSelf;
                           if ([[strongself.feedTable indexPathsForVisibleRows] containsObject:indexPath]) {
                               PleasantTableViewCell *correctCell = (PleasantTableViewCell *)[strongself.feedTable cellForRowAtIndexPath:indexPath];
                               correctCell.photoView.image = thumbnail;
                               [strongself.imageCache setObject:thumbnail forKey:flickr.title];
                               [correctCell setNeedsLayout];
                           }
                       });
                   }
            });
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.flicks count];
}

- (void)getFavorites{
    self.favorites = [self.defaults valueForKey:favoritesIdentifier];
    if (!self.favorites){
        self.favorites = [NSMutableArray array];
        [self.defaults setObject:self.favorites forKey:favoritesIdentifier];
        [self.defaults synchronize];
    }
}

@end
