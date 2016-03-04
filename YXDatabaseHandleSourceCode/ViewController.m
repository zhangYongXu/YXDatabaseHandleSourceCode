//
//  ViewController.m
//  YXDatabaseHandlle
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import "ViewController.h"
#import "YXDatabaseHandle+Insert.h"
#import "YXDatabaseHandle+Select.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)testData{
    NSString * path = [[NSBundle mainBundle] pathForResource:NSStringFromClass([UserModel class]) ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSDictionary * dictinary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray * dictArray = dictinary[@"users"];
    NSArray * array = [UserModel modelArrayFromDictArray:dictArray];
    return array;
}
- (IBAction)saveBtn:(id)sender {
    NSArray * array = [self testData];
    
    [APPDelegate.dbHandle batchHandle:^{
        for(UserModel * model in array){
            [APPDelegate.dbHandle insertModel:model];
            [APPDelegate.dbHandle insertModel:model.company];
            for(EmployeeModel * eModel in model.employees){
                [APPDelegate.dbHandle insertModel:eModel];
            }
        }
    }];
    
    [SVProgressHUD showSuccessWithStatus:@"保存成功"];

}
- (IBAction)readBtn:(id)sender {
    NSArray * array = [APPDelegate.dbHandle readArray:[UserModel class]];
    NSString * str = @"";
    for(UserModel * model in array){
        NSString * whereStr = [NSString stringWithFormat:@"userId = '%@'",model.userId];
        model.company = [[APPDelegate.dbHandle readyArray:[CompanyModel class] whereArray:@[whereStr]] lastObject];
        model.employees = [APPDelegate.dbHandle readyArray:[EmployeeModel class] whereArray:@[whereStr]];
        str = [str stringByAppendingString:[[model propertyList:YES] description]];
    }
    self.textView.text = str;
}

@end
