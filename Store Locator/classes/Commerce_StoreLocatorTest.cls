@isTest
public class Commerce_StoreLocatorTest {
	static testMethod void fetchLocationsTest(){
       
      Integer distance = 10000;
      String unit = 'mi';
      Decimal userLatitude = 30.3797;
      Decimal userLongitude = -97.698;
      String serviceClassName = 'Commerce_StoreLocatorService';
	
      Schema.Location loc = new Schema.Location(Name='Test', Latitude=30.3785,Longitude=-97.677, LocationType='Warehouse', Store_Timings__c='<p>Mon-Sat 10:00am - 8:00pm</p><p>Sun 10:00am - 5:00pm</p>', Services__c='<p>Customer Support</p><p>Repairs</p>', Facilities__c='<p>Parking</p><p>Restroom </p>');
	   insert loc;
        
      Schema.Address adrs = new Schema.Address(ParentId=loc.Id, Street='123', City='Houston', State='Texas', PostalCode='77005', Country='United States', Phone__c='98754523423', Latitude=30.3785, Longitude=-97.677, Location__Latitude__s=30.3785, Location__Longitude__s=-97.677);
	   insert adrs;
                
      Account acc = new Account(Name='Test',Default_Store__c=loc.Id);
      insert acc;
        
      Test.startTest();
      List<Commerce_LocationWrapper> l = Commerce_StoreLocator.fetchLocations(distance, unit, userLatitude, userLongitude, serviceClassName);
      Test.stopTest();
    }
    
    static testMethod void fetchPreferredStoreTest(){
       
      Integer distance = 10000;
      String unit = 'mi';
      Decimal userLatitude = 30.3797;
      Decimal userLongitude = -97.698;
      String serviceClassName = 'Commerce_StoreLocatorService';
      
      Schema.Location loc = new Schema.Location(Name='Test', Latitude=30.3785,Longitude=-97.677, LocationType='Warehouse', Store_Timings__c='<p>Mon-Sat 10:00am - 8:00pm</p><p>Sun 10:00am - 5:00pm</p>', Services__c='<p>Customer Support</p><p>Repairs</p>', Facilities__c='<p>Parking</p><p>Restroom </p>', Preferred_Store__c=true);
      insert loc;
        
      Schema.Address adrs = new Schema.Address(ParentId=loc.Id, Street='123', City='Houston', State='Texas', PostalCode='77005', Country='United States', Phone__c='98754523423', Latitude=30.3785, Longitude=-97.677, Location__Latitude__s=30.3785, Location__Longitude__s=-97.677);
	   insert adrs;
        
      Test.startTest();
      List<Commerce_LocationWrapper> l = Commerce_StoreLocator.fetchPreferredStore(distance, unit, userLatitude, userLongitude, serviceClassName);
      Test.stopTest();
    }
    
    static testMethod void updateDefaultStoreTest(){
       
      String serviceClassName = 'Commerce_StoreLocatorService';
      Schema.Location loc = new Schema.Location(Name='Test', Latitude=30.3785,Longitude=-97.677, LocationType='Warehouse', Store_Timings__c='<p>Mon-Sat 10:00am - 8:00pm</p><p>Sun 10:00am - 5:00pm</p>', Services__c='<p>Customer Support</p><p>Repairs</p>', Facilities__c='<p>Parking</p><p>Restroom </p>');
      insert loc;
                        
      Id locId = loc.Id;
      
      Account acc = new Account(Name='Test',Default_Store__c=loc.Id);
      insert acc;
        
		Contact testContact = new Contact(
    	Firstname = 'Test Firstname',
    	Lastname = 'Test Lastname',AccountId = acc.Id);
    	insert testContact;
    
    	Profile p = [SELECT Id FROM Profile WHERE UserLicense.Name = 'External Apps Login' LIMIT 1];
         
         User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Shopper Profile'].Id,
         ContactId = testContact.Id,
         LastName = 'last',
         Email = 'test@test.com',
         Username = 'test@test.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US'
	   );
      insert u;
        
      Test.startTest();
      Commerce_StoreLocator.updateDefaultStore(locId, serviceClassName);
      Test.stopTest(); 
    }
    
    static testMethod void updateLocationsTest(){
        
      String serviceClassName = 'Commerce_StoreLocatorService';
      
      Test.startTest();
      Commerce_StoreLocator.updateLocations(serviceClassName);
      Test.stopTest();
    }
}