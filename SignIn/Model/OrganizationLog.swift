//
//  OrganizationLog.swift
//  SignIn
//
//  Created by Momoko Saunders on 10/20/15.
//  Copyright © 2015 Momoko Saunders. All rights reserved.
//

import Foundation

class  OrganizationLog: NSObject {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var organizationLog : [Organization]
    var orgTypes : [Type]! = nil
    
    override init() {
        organizationLog = []
        super.init()
        let fetchRequest = NSFetchRequest(entityName: "Organization")
        do { if let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Organization] {
                organizationLog = fetchedResults
            } else {
                assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        if organizationLog.count == 0 {
            createOrganizationWithDefaultValues()
        }
    }
    
    func createOrganizationWithDefaultValues() {
        let entity = NSEntityDescription.entityForName("Organization", inManagedObjectContext: managedObjectContext)
        
        let org = Organization(entity: entity!,  insertIntoManagedObjectContext: managedObjectContext)
        
        organizationLog = [org]
        //set default behaviour for organization
        org.defaultSignOutTime = 4
        org.saferSpaceAgreement = ""
        org.waiver = ""
        org.yesOrNoQuestion = ""
        org.name = "Not yet set up"
        org.zipCode = ""
        org.emailAddress = ""
        org.password = ""
        org.founded = ""
        
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        //create default Contact types
        TypeLog().addType("Volunteer", id: 1, group: "Contact", active: 1)
        TypeLog().addType("Patron", id: 2, group: "Contact", active: 1)
        TypeLog().addType("Employee", id: 3, group: "Contact", active: 0)
        TypeLog().addType("Custom1", id: 4, group: "Contact", active: 0)
        TypeLog().addType("Custom2", id: 5, group: "Contact", active: 0)
        // create default MembershipTypes
        TypeLog().addType("One Month", id: 6, group: "Membership", active: 1)
        TypeLog().addType("Six Month", id: 7, group: "Membership", active: 1)
        TypeLog().addType("Yearly", id: 8, group: "Membership", active: 1)
        TypeLog().addType("Life Time", id: 9, group: "Membership", active: 1)
        TypeLog().addType("Custom", id: 10, group: "Membership", active: 0)
    }
    
    func currentOrganization() -> (organization:Organization?, doesTheOrgExist:Bool) {
        let org : Organization
        if organizationLog.count > 0 {
            org = organizationLog.first!
            return (org, true)
        } else {
            return (nil, false)
        }
    }
    
    func deleteOrg(org: Organization) {
        managedObjectContext.deleteObject(org)
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func saveOrg(org: Organization) {
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func hasPassword() -> Bool {
        var bool = false
        if let org = organizationLog.first {
            bool = (org.password == "" ? false : true)
        }
        return bool
    }
    
    func getTypes() -> [Type] {
        orgTypes = []
        let typeSet = currentOrganization().organization!.type
        for type in typeSet! {
            orgTypes.append(type as! Type)
        }
        return orgTypes
    }
    
    func activeUserTypes() -> [String] {
        var types = [String]()
        orgTypes = getTypes()
        for type in orgTypes { // if active
            types.append(type.title!)
        }
        return types
    }

    func activeMembershipTypes() -> [String] {
        var types = [String]()
        orgTypes = getTypes()
        let sortedTypes = orgTypes.sort {Int($0.id!) < Int($1.id!)}
        for type in sortedTypes {
            if type.group == "Membership" && type.active == true {
                types.append(type.title!)
            }
        }
        return types
    }
    //might need a function to get "userTypes" 
    //it will work only because i know the ID numbers for all the types
    
    func orgData() -> String {
        var orgDataString = ""
        if let org = organizationLog.first {
            orgDataString = String("\(org.name!), \(org.emailAddress!), \(org.saferSpaceAgreement!), \(org.waiver!), \(org.zipCode!), \(org.founded!)")
        }
        return orgDataString
    }
}
