//
//  DetailsViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

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
    self.titleLabel.text = self.movie[@"overview"];
    self.descriptionLabel.text = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];
    [self.descriptionLabel sizeToFit];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
