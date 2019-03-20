//
//  ExampleKZBootstrapViewController.m
//  SDOSUtil
//
//  Created by Antonio Jesús Pallares on 02/11/16.
//  Copyright © 2016 SDOS. All rights reserved.
//

#import "ExampleKZBootstrapViewController.h"
#import "KZBootstrapEnviromentsManager.h"

#define VERSION_TRACKING_CELL_IDENTIFIER @"VERSION_TRACKING_CELL_IDENTIFIER"

@interface ExampleKZBootstrapViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewKZBootstrap;

@end

@implementation ExampleKZBootstrapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];;
    
    [self loadStyle];
    [self loadData];
    [self loadDismissButton];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.textViewKZBootstrap scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


- (void) loadDismissButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
}

#pragma mark - Style

- (void)loadStyle {
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.textViewKZBootstrap.editable = NO;
    
    self.textViewKZBootstrap.textAlignment = NSTextAlignmentLeft;
}

#pragma mark - Creating the Text

- (void)loadData {
    
    NSArray *environments = [KZBootstrapEnviromentsManager environments];
    
    NSMutableAttributedString *finalAttrStr = [[NSMutableAttributedString alloc] init];
    
    // [finalAttrStr appendAttributedString:[self attributedStringWithExecutionEnvironment]];
    
    [finalAttrStr appendAttributedString:[self attributedStringWithExplanation]];
    
    for (NSString *env in environments) {
        [KZBootstrapEnviromentsManager changeEnvironmentTo:env];
        
        NSDictionary *dict = [KZBootstrapEnviromentsManager dictionaryOfValuesSpecificToCurrentEnvironment];
        
        NSAttributedString *attrString = [self createTextForTitle:env andDictionary:dict];
        
        [finalAttrStr appendAttributedString:attrString];
    }
    
    //self.textViewKZBootstrap.scrollEnabled = NO;
    [self.textViewKZBootstrap setAttributedText:finalAttrStr];
    //self.textViewKZBootstrap.scrollEnabled = YES;
}


- (NSAttributedString *)attributedStringWithExecutionEnvironment {
    NSString *executionEnvironmentStr = [KZBootstrapEnviromentsManager executionEnvironment];
    
    NSString *str = NSLocalizedString(@"Example.executionStringTitle", @"");
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]}];
    [self addNewlineToAttributedString:attrStr times:2];

    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:executionEnvironmentStr attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]}]];
    
    [self addNewlineToAttributedString:attrStr times:4];
    
    return attrStr;
}

- (NSAttributedString *)attributedStringWithExplanation {
    NSString *explanation = NSLocalizedString(@"Example.explanation", @"");
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:explanation attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    [self addNewlineToAttributedString:attrStr times:3];
    
    return attrStr;
}

- (NSAttributedString *)createTextForTitle:(NSString *)title andDictionary:(NSDictionary *)dict {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]}];
    
    [self addNewlineToAttributedString:attrString times:2];
    
    for (NSString *key in dict.allKeys) {
        id value = [dict objectForKey:key];
        
        [attrString appendAttributedString:[self attributedTextForKey:key value:value]];
        [self addNewlineToAttributedString:attrString];
    }
    
    [self addNewlineToAttributedString:attrString times:3];
    
    return attrString;
}

- (NSAttributedString *)attributedTextForKey:(NSString *)key value:(id)value {
    NSString *valueStr;
    
    if ([value isKindOfClass:[NSString class]]) {
        valueStr = (NSString *)value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        
        NSNumber *number = (NSNumber *)value;
        if (strcmp([number objCType], @encode(BOOL))) {
            valueStr = number.boolValue ? @"YES" : @"NO";
        } else {
            valueStr = number.description;
        }
    }
    
    NSString *finalString = [@[key, @":", valueStr] componentsJoinedByString:@" "];
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    
    return [[NSAttributedString alloc] initWithString:finalString attributes:attributes];
}

- (void) addNewlineToAttributedString:(NSMutableAttributedString *)attrStr times:(NSUInteger)integer {
    for (NSInteger i = 0; i < integer; i++) {
        [self addNewlineToAttributedString:attrStr];
    }
}

- (void) addNewlineToAttributedString:(NSMutableAttributedString *)attrStr {
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
}





#pragma mark - User Interaction

- (void) dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
