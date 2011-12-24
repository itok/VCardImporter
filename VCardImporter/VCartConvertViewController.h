//
//  VCartConvertViewController.h
//  VCardImporter
//
//  Created by 伊藤 啓 on 11/12/24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCartConvertViewController : UITableViewController
{
    NSString* path;
    NSMutableArray* list;
    NSMutableArray* selectedPersons;
}

@property (nonatomic, strong) NSString* path;


@end
