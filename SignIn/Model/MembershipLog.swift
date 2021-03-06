//
//  MembershipLog.swift
//  SignIn
//
//  Created by Momoko Saunders on 8/12/15.
//  Copyright (c) 2015 Momoko Saunders. All rights reserved.
//

import Foundation
import CoreData

class MembershipLog: NSObject {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var membershipLog : [Membership]

    enum MembershipType: String {
        case
        NonMember = "Non Member",
        OneMonth = "One Month",
        SixMonth = "Six Month",
        Yearly = "Yearly",
        LifeTime = "Life Time",
        Custom = "Custom"
    }
    
    override init() {
        membershipLog = []
        let fetchRequest = NSFetchRequest(entityName: "Membership")
        do { if let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Membership] {
            membershipLog = fetchedResults }
        else {
            assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        
        super.init()
    }
    
    func createMembershipWithContact(contact: Contact) {
        
        let entity = NSEntityDescription.entityForName("Membership", inManagedObjectContext: managedObjectContext)
        
        let membership = Membership(entity: entity!,  insertIntoManagedObjectContext: managedObjectContext)
        membership.membershipType = "NonMember"
        membership.membershipExpiration = NSDate()
        contact.membership = membership
        
        self.saveMembership(membership)
    }
    
    func saveMembership(membership: Membership) {
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }

    func deleteMembershipForContact(contact: Contact) {
        managedObjectContext.deleteObject(contact.membership!)
    }
    
    // helpers for membership
    func membershipDescriptionOfContact(contact: Contact) -> String {
        return contact.membership!.membershipType
    }
    
    func editMembershipTypeForContact(contact: Contact, type: String) {
        contact.membership!.membershipType = type
        let membershipExpiration = NSDate(timeInterval: timeIntervalForMembershipType(type), sinceDate: NSDate())
        contact.membership!.membershipExpiration = membershipExpiration
    }
    
    func timeIntervalForMembershipType(type: String) -> NSTimeInterval {
        var time = NSTimeInterval()
        switch type {
        case MembershipType.NonMember.rawValue:
            time = 0.0
        case MembershipType.OneMonth.rawValue:
            time = 60*60*24*31
        case MembershipType.SixMonth.rawValue:
            time = 60*60*24*183
        case MembershipType.Yearly.rawValue:
            time = 60*60*24*365
        case MembershipType.LifeTime.rawValue:
            time = 60*60*24*365*100
        case MembershipType.Custom.rawValue:
            // TODO: this isn't an appropriate way to determine custom
            time = 60*60*24*365*100
        default:
            time = 0.0
        }
        return time
    }
    
    func membershipExperationDate(contact: Contact) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let membershipExperationDate = dateFormatter.stringFromDate(contact.membership!.membershipExpiration)
        return membershipExperationDate
    }
}
