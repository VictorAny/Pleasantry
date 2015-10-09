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
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *favorites;
@property (nonatomic, strong) NSArray *flicks;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong)NSUserDefaults *defaults;



@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _flickrManager = [[FlickrManager alloc]init];
    // will be used to cache images
    self.imageCache = [[NSCache alloc]init];
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self setUpRefreshControl];
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

- (void)viewWillAppear:(BOOL)animated{
    // reloads data with favorites
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


#pragma mark - PleasantViewCellDelegate

- (void)didFavoriteFlick:(Flick *)aFlickObject{
    // Creates dictionary with flick information and stores it.
    // Reinitializes favorites array to be up to date with persistent model.
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

#pragma mark - RefreshControl

- (void)setUpRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.feedTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(getNewPleasantImages) forControlEvents:UIControlEventValueChanged];
}

-(void)getNewPleasantImages{
    [self.flickrManager getPleasantImagesFromFlickr:^(bool sucess, NSArray *photos, NSError *error) {
        if (error){
            NSLog(@"error, while retrieving pleasant photos");
        }else{
            self.flicks = photos;
            [self.feedTable reloadData];
            NSLog(@"user did reload table");
            }
        [self.refreshControl endRefreshing];
    }];
}

- (void)dealloc{
    [self.defaults synchronize];
}

#pragma mark - Tableview delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PleasantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    Flick *flickr = [self.flicks objectAtIndex:indexPath.row];
    NSString *url = flickr.url;
    NSURL *imageurl = [NSURL URLWithString:url];
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
    // Checks if image has already been cached. If not, it creates and caches it.
    UIImage *cachedThumbnailPic = [self.imageCache objectForKey:flickr.title];
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
#pragma mark - Helpers

- (void)getFavorites{
    // returns favorites from user defaults
    self.favorites = [self.defaults valueForKey:favoritesIdentifier];
    if (!self.favorites){
        self.favorites = [NSMutableArray array];
        [self.defaults setObject:self.favorites forKey:favoritesIdentifier];
        [self.defaults synchronize];
    }
}

@end
