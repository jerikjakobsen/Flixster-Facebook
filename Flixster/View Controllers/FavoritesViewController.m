//
//  FavoritesViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/25/21.
//

#import "FavoritesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@interface FavoritesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *favoriteMoviesTableView;
@property (nonatomic, strong) NSArray *favoriteMovies;

@end

@implementation FavoritesViewController
- (void) viewDidAppear:(BOOL)animated {
    self.favoriteMovies = @[];
    NSArray *savedMovies = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation][@"savedMovies"];
    for ( NSString *movieID in savedMovies) {
        [self getMovie: movieID];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favoriteMoviesTableView.delegate = self;
    self.favoriteMoviesTableView.dataSource = self;
    
    NSArray *savedMovies = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation][@"savedMovies"];
    for ( NSString *movieID in savedMovies) {
        [self getMovie: movieID];
    }
    // Do any additional setup after loading the view.
}

-(void) getMovie: (NSString *) movieid {
    NSURL *url = [NSURL URLWithString:  [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", movieid]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@", dataDictionary);
            if (self.favoriteMovies.count == 0) {
                self.favoriteMovies = [NSArray arrayWithObjects: dataDictionary , nil];
            } else self.favoriteMovies = [self.favoriteMovies arrayByAddingObject: dataDictionary];
            //NSLog(@"%@", dataDictionary);
            NSLog(@"%lu", (unsigned long)self.favoriteMovies.count);
            [self.favoriteMoviesTableView reloadData];

        }
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCell *cell = [self.favoriteMoviesTableView dequeueReusableCellWithIdentifier: @"MovieCell"];
    NSDictionary *movie = self.favoriteMovies[indexPath.row];
    cell.descriptionLabel.text = movie[@"overview"];
    cell.titleLabel.text = movie[@"title"];
    NSString *baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURL = movie[@"poster_path"];
    NSString *fullPosterURL = [baseURL stringByAppendingString: posterURL];
    NSURL *fullPosterNSURL = [NSURL URLWithString: fullPosterURL];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL: fullPosterNSURL];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoriteMovies.count;
}

@end
