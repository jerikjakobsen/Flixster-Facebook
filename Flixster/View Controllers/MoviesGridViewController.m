//
//  MoviesGridViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/23/21.
//

#import "MoviesGridViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "MovieCollectionViewCell.h"

@interface MoviesGridViewController () < UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesGridViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView insertSubview: self.refreshControl atIndex:0];
    [self.refreshControl addTarget:self action:@selector(getMovies) forControlEvents:UIControlEventValueChanged];
    [self getMovies];
    
    UICollectionViewFlowLayout *layout =(UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    CGFloat postersPerLine = 3;
    layout.itemSize = CGSizeMake(self.collectionView.frame.size.width/ postersPerLine, self.collectionView.frame.size.width/ postersPerLine * 1.5);
    
}




- (void) getMovies {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated: YES];
    hud.label.text = @"Loading...";
    hud.offset = CGPointMake(0, -200);
    [self.collectionView addSubview: hud];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated: YES];
        });
    });
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            if (error.code == -1009) {
    
                [hud hideAnimated:true];
                [hud removeFromSuperview];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"oops! You aren't connected to the internet." preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self getMovies];
                }];
                [alert addAction:tryAgainAction];
                [self presentViewController: alert animated:YES completion: nil];
            }
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
            self.movies = dataDictionary[@"results"];
            [self.collectionView reloadData];
        }
        [self.refreshControl endRefreshing];
        [hud hideAnimated:true];
        [hud removeFromSuperview];
    }];
    [task resume];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.item];
    NSString *baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURL = movie[@"poster_path"];
    NSString *fullPosterURL = [baseURL stringByAppendingString: posterURL];
    NSURL *fullPosterNSURL = [NSURL URLWithString: fullPosterURL];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL: fullPosterNSURL];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;

}

@end
