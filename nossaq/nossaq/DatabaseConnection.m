//
//  DatabaseConnection.m
//  nossaq
//
//  Created by Aykut on 4/1/13.
//  Copyright (c) 2013 nossaq. All rights reserved.
//

#import "DatabaseConnection.h"


@implementation DatabaseConnection

#pragma mark Singleton Implementation
static DatabaseConnection *sharedObject;

+ (DatabaseConnection*)sharedInstance
{
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}

#pragma mark Account Methods

+(BOOL)addAccount: (Account *)account{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Account"
                  inManagedObjectContext:context];
    [newContact setValue:account.username forKey:@"username" ];
    [newContact setValue:account.password forKey:@"acpass"];
    [newContact setValue:account.email forKey:@"email"];
    [newContact setValue:account.name forKey:@"name" ];
    [newContact setValue:account.surname forKey:@"surname"];
    
    NSError *error;
    BOOL noError = [context save:&error];
    if(error != NULL){
        NSLog(@"Error on addAccount method: %@",[error localizedDescription]);
    }
    return noError; // YES if the save succeeds, otherwise NO.
}

+(BOOL)checkAccountUserName:(NSString *) accountString password:(NSString *) passwordString{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(username == %@ AND acpass == %@)", accountString, passwordString];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        return NO;
    } else {
        NSLog(@"%@", matches);
        return YES;
    }
}

#pragma mark Event Methods

+(BOOL)addEvent: (Event *)event{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Event"
                  inManagedObjectContext:context];
    [newContact setValue:[NSNumber numberWithInt:event.type] forKey:@"type"];
    [newContact setValue:event.notes forKey:@"notes" ];
    [newContact setValue:event.title forKey:@"title"];
    [newContact setValue:event.startDate forKey:@"startDate"];
    [newContact setValue:event.endDate forKey:@"endDate"];
    
    NSError *error;
    BOOL noError = [context save:&error];
    if(error != nil){
        NSLog(@"Error on addEvent method: %@",[error localizedDescription]);
    }
    return noError; // YES if the save succeeds, otherwise NO.
}

+ (NSArray *) fetchEventsBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [request setEntity:entityDesc];
    
    //Fetch requests sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(startDate >= %@ AND endDate <= %@)", startDate, endDate];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error on addEvent method: %@",[error localizedDescription]);
    }
    return objects;
}
+ (NSArray *) fetchAllEvents{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [request setEntity:entityDesc];
    
    //Fetch requests sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error on addEvent method: %@",[error localizedDescription]);
    }
    return objects;
}

+ (NSArray *) fetchEventsOnDate:(NSDate *)date{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [request setEntity:entityDesc];
    
    //Fetch requests sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
    NSDate *dateLastHour = [date dateByAddingTimeInterval:secondsInTwentyFourHours];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(startDate >= %@ AND endDate <= %@)", date, dateLastHour];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error on addEvent method: %@",[error localizedDescription]);
    }
    return objects;
}
+ (BOOL) updateExistingEvent:(Event *)existingEvent withNewEvent: (Event *)newEvent{// return YES if event succesfuly added
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(type == %@ AND notes == %@ AND title == %@ AND startDate == %@ AND endDate == %@)", existingEvent.type, existingEvent.notes, existingEvent.title, existingEvent.startDate, existingEvent.endDate];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error on addEvent method: %@",[error localizedDescription]);
        return NO;
    }
    
    if(objects.count > 1){
        NSLog(@"Possible dublicate in database updateExistingEvent method");
        return NO;
    }
    
    Event *event = [objects objectAtIndex:0];
    event.title = newEvent.title;
    event.type = newEvent.type;
    event.notes = newEvent.notes;
    event.startDate = newEvent.startDate;
    event.endDate = newEvent.endDate;
    
    if (![context save:&error]) {
        NSLog(@"Error savinng record updateExistingEvent method");

        return NO;
    }
    
    return YES;
}





@end
