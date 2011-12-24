//
//  VCartConvertViewController.m
//  VCardImporter
//
//  Created by 伊藤 啓 on 11/12/24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "VCartConvertViewController.h"
#import <AddressBook/AddressBook.h>

@implementation VCartConvertViewController

@synthesize path;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        list = [[NSMutableArray alloc] init];
        selectedPersons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData* d = [NSData dataWithContentsOfFile:self.path];
    ABAddressBookRef book = ABAddressBookCreate();
    ABRecordRef record = ABAddressBookCopyDefaultSource(book);
    CFArrayRef arr = ABPersonCreatePeopleInSourceWithVCardRepresentation(record, CFBridgingRetain(d));
    
    [list addObjectsFromArray:CFBridgingRelease(arr)];
    [selectedPersons addObjectsFromArray:list];
    
    CFRelease(book);
    CFRelease(record);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString*) __nameForPerson:(ABRecordRef)person
{
    if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
        return [NSString stringWithFormat:@"%@ %@", CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)), CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty))];        
    } else {
        return [NSString stringWithFormat:@"%@ %@", CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty)), CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty))];
    }
    return @"";
}

-(void) save:(id)sender
{
    CFErrorRef err = nil;
    ABAddressBookRef book = ABAddressBookCreate();
    
#if 0
    // remove all records before save
    NSArray* allPerson = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(book));
    for (id obj in allPerson) {
        ABRecordRef person = CFBridgingRetain(obj);
        ABAddressBookRemoveRecord(book, person, &err);
    }
#endif
    
    for (id obj in selectedPersons) {
        ABRecordRef person = CFBridgingRetain(obj);
        
        if (!ABAddressBookAddRecord(book, person, &err)) {
            NSLog(@"fail to add %@ (%@)", [self __nameForPerson:person], CFBridgingRelease(CFErrorCopyDescription(err)));
        }
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if (ABAddressBookSave(book, &err)) {
        alert.title = @"SUCCESS";
    } else {
        alert.title = @"FAIL";
        alert.message = CFBridgingRelease(CFErrorCopyDescription(err));
    }
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ABRecordRef person = CFBridgingRetain([list objectAtIndex:indexPath.row]);
    cell.textLabel.text = [self __nameForPerson:person];
    
    if ([selectedPersons containsObject:[list objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id person = [list objectAtIndex:indexPath.row];
    if ([selectedPersons containsObject:person]) {
        [selectedPersons removeObject:person];
    } else {
        [selectedPersons addObject:person];
    }
    [self.tableView reloadData];
}

@end
