//
//  DetailsViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    NSURL *fullPosterURL = [NSURL URLWithString: fullPosterURLString];
    
    [self.posterImageView setImageWithURL:fullPosterURL];
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString: backdropURLString];
    NSURL *fullBackdropURL = [NSURL URLWithString: fullBackdropURLString];
    [self.backdropImageView setImageWithURL:fullBackdropURL];
    self.titleLabel.text = self.movie[@"title"];
    self.descriptionLabel.text = self.movie[@"overview"];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSString *g = @"hello";
    NSInteger *day = [[self.movie[@"release_date"] substringWithRange: NSMakeRange(8, 2)] integerValue];
    NSInteger *month = [[self.movie[@"release_date"] substringWithRange: NSMakeRange(5, 2)] integerValue];
    NSInteger *year = [[self.movie[@"release_date"] substringWithRange: NSMakeRange(0, 4)] integerValue];
    [dateComponents setDay: day];
    [dateComponents setMonth: month];
    [dateComponents setYear: year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents: dateComponents];
    
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate: date dateStyle: NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    [self.titleLabel sizeToFit];
    [self.descriptionLabel sizeToFit];
}
- (IBAction)tapped:(id)sender {
    NSLog(@"tapped");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TrailerViewController *tvc = segue.destinationViewController;
    tvc.movieID = self.movie[@"id"];
}

- (IBAction)saveMovie:(id)sender {
    
    // get array
    // add movie to array (if no array, create array with movie in it)
    // save it back to user defaults


    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSString *movieID = self.movie[@"id"];
    NSArray *savedMovies = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation][@"savedMovies"];

    if (savedMovies == nil) savedMovies = @[movieID];
    else {
        NSLog(@"HELLO");
        if (!([savedMovies containsObject: movieID])) savedMovies = [savedMovies arrayByAddingObject: movieID];
    }
    //NSLog(@"%@", savedMovies);
    [UD setObject:savedMovies forKey:@"savedMovies" ];
    [UD synchronize];
    NSLog(@"NSUserDefault: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

}
@end
