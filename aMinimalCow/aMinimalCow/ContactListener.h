
#import "Box2D.h"

#import <vector>

using namespace std;

struct MyContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const MyContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

typedef vector<MyContact> ContactsVector;

@class GameLayer;

class ContactListener : public b2ContactListener
{
	virtual void BeginContact(b2Contact  *contact);	
	virtual void EndContact(b2Contact  *contact);
public:
    ContactsVector GetContacts() {return _contacts;}
private:
	ContactsVector _contacts;
};