//
//  ContactListener.m
//  SaveTeddy
//
//  Created by Nobbele on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"
//#import "GameLayer.h"
//#import "GameObject.h"

void ContactListener::BeginContact(b2Contact *contact)
{
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
}

void ContactListener::EndContact(b2Contact *contact)
{
	MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}
