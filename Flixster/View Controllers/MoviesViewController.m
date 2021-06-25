//
//  MoviesViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self getMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView insertSubview: self.refreshControl atIndex: 0];
    [self.refreshControl addTarget:self action:@selector(getMovies) forControlEvents:UIControlEventValueChanged];
}

- (void) getMovies {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated: YES];
    hud.label.text = @"Loading...";
    hud.offset = CGPointMake(0, -200);
    [self.tableView addSubview: hud];
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
                NSLog(@"NO internet");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"oops! You aren't connected to the internet." preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self getMovies];
                }];
                [alert addAction:tryAgainAction];
                [self presentViewController: alert animated:YES completion: nil];
            }
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@", dataDictionary);
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [hud hideAnimated:true];
        [hud removeFromSuperview];
    }];
    [task resume];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MovieCell"];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.descriptionLabel.text = movie[@"overview"];
    NSString *baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURL = movie[@"poster_path"];
    NSString *fullPosterURL = [baseURL stringByAppendingString: posterURL];
    NSURL *fullPosterNSURL = [NSURL URLWithString: fullPosterURL];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL: fullPosterNSURL];
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> * bindings) {
        NSString *searchTextLowercase = [searchText lowercaseString];
        for (int i = searchTextLowercase.length - 1; i >= 0; i--) {
            if ([searchTextLowercase characterAtIndex: i] ) {
                break;
            } else searchTextLowercase = [searchTextLowercase substringToIndex:i];
        }
        NSString *evalobj = evaluatedObject[@"title"];
        return [[evalobj lowercaseString] containsString: searchTextLowercase];
    } ];
    self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredMovies = self.movies;
    }
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = true;
}
@end
