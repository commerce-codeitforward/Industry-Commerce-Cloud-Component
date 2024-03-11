@isTest
public class Commerce_TestFactory {
    public static final String STOREFRONT = 'B2C Store';
    public static final String SHOPPERPROFILE = 'Shopper Profile';
    public class UserAttributes {
        public String profileId;
        public String uniqueName;
        public String orgId;
        public String contactId;
    }

    public static List<Product2> createProducts() {
        List<Product2> productList = new List<Product2>();
            Product2 prod1 = new Product2();
            prod1.Name = 'Charger Cable';
            prod1.Description = 'Supports Fast Charging. 5A';
            prod1.IsActive = true;
            prod1.StockKeepingUnit = 'USBCABLE5A';
            prod1.ProductCode = 'USBCABLE5A';
            prod1.b2b2c_Product_Warranty__c = '-1';
            prod1.b2b2c_Eligible_for_Warranty__c = false;
            productList.add(prod1);

            Product2 prod2 = new Product2();
            prod2.Name = 'Wall Charger';
            prod2.Description = '65W Wall Charger';
            prod2.IsActive = true;
            prod2.StockKeepingUnit = 'WallCharger65W';
            prod2.ProductCode = 'WallCharger65W';
            prod2.b2b2c_Product_Warranty__c = '0';
            prod2.b2b2c_Eligible_for_Warranty__c = true;
            prod2.b2b2c_RelatedProductCodes__c = 'USBCABLE5A';
            productList.add(prod2);

            Product2 prod3 = new Product2();
            prod3.Name = 'Motorola Edge 30 Ultra';
            prod3.Description = 'Performance Meets Style';
            prod3.IsActive = true;
            prod3.StockKeepingUnit = 'MOTOEDGE30ULTRA';
            prod3.ProductCode = 'MOTOEDGE30ULTRA';
            prod3.b2b2c_RelatedProductCodes__c = 'USBCABLE5A;WallCharger65W';
            prod3.b2b2c_Product_Warranty__c = '1 Year';
            prod3.b2b2c_Eligible_for_Warranty__c = true;
            productList.add(prod3);

            insert productList;
            
            Product2 prod4 = new Product2();
            prod4.Name = 'Warranty Product for Motorola Edge 30 Ultra';
            prod4.Description = 'Warranty Product for Motorola Edge 30 Ultra';
            prod4.IsActive = true;
            prod4.StockKeepingUnit = 'WPMOTOEDGE30ULTRA';
            prod4.ProductCode = 'WPMOTOEDGE30ULTRA';
            prod4.B2B2C_Parent_Product__c = prod3.Id;
            prod4.b2b2c_Product_Warranty__c = '-1';
            prod4.b2b2c_Eligible_for_Warranty__c = true;
            insert prod4;

            productList.add(prod4);

            return productList;
    }

    public static User insertPortalUser(UserAttributes ua) {
        User portalUser = new User(firstname = 'ABCD',
                           lastName = 'Test',
                           email = ua.uniqueName + '@test2' + ua.orgId + '.org',
                           Username = ua.uniqueName + '@test2' + ua.orgId + '.org',
                           EmailEncodingKey = 'ISO-8859-1',
                           Alias = ua.uniqueName.substring(18, 23),
                           TimeZoneSidKey = 'America/Los_Angeles',
                           LocaleSidKey = 'en_US',
                           LanguageLocaleKey = 'en_US',
                           CommunityNickname = 'nick2',
                           IsActive = True,
                           ProfileId = ua.profileId,
                           ContactId = ua.contactId,
                           PortalRole = 'Manager'
                        );
        insert portalUser;

        return portalUser;
    }

    public static void createData() {
        Profile b2cProfile, systemProfile;
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name IN (:SHOPPERPROFILE,'System Administrator')]) {
            if(p.Name==SHOPPERPROFILE) {
                b2cProfile = p;
            } else {
                systemProfile = p;
            }
        }
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + RandomId;
        
        UserRole role = new UserRole(Name = 'Test Portal Role');
        insert role;

        User systemUser = new User(
            UserRoleId = role.Id,
            ProfileId = systemProfile.Id,
            Username = System.now().millisecond() + 'test1@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce Wayne',
            Lastname='Test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(systemUser);

        Account account = new Account();
        Contact con = new Contact();
        Product2 product1 = new Product2();
        List<Product2> productList = new List<Product2>();
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 customPricebook = new Pricebook2();
        WebStore webStore = new WebStore();
        OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod();

        System.runAs(systemUser){
            account.Name = 'Test Account';
            insert account;

            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con; 

            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  

            BuyerGroup buyGrp =  new BuyerGroup();
            buyGrp.Name = 'Test buyer Group';
            insert buyGrp;
        
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;

            List<ContactPointAddress> cpaList = new List<ContactPointAddress>();
            ContactPointAddress cpaBilling = new ContactPointAddress(
                Name = 'Canada Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Toronto',
                PostalCode = '5590',
                Country = 'Canada'
            );
            cpaList.add(cpaBilling);
            ContactPointAddress cpaShipping = new ContactPointAddress(
                Name = 'Canada Address',
                ParentId = account.Id,
                AddressType = 'Shipping',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Toronto',
                PostalCode = '5590',
                Country = 'Canada'
            );
            cpaList.add(cpaShipping);
            insert cpaList;
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
            update standardPricebook;
            
            customPricebook.Name = 'Custom Test Pricebook';
            customPricebook.IsActive = true;
            insert customPricebook;

            ProductCatalog cat = new ProductCatalog();
            cat.Name = 'CSP Catalog';
            insert cat;

            webStore.Name = STOREFRONT;
            webStore.SupportedLanguages = 'en_US'; 
            webStore.DefaultLanguage = 'en_US';
            webStore.StrikethroughPricebookId = pricebookId;
            insert webStore;    

            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            
            WebStorePricebook webStorePricebook = new WebStorePricebook(
                                                    WebStoreId = webStore.Id, 
                                                    Pricebook2Id = customPricebook.Id, 
                                                    IsActive = true);
            insert webStorePricebook;

            createProducts();

            CommerceEntitlementPolicy entitlementPolicy = new CommerceEntitlementPolicy(
                Name = 'CSP Entitlement Policy',
                Description = 'CSP Entitlement Policy',
                CanViewProduct = true,
                CanViewPrice = true,
                IsActive = true
            );
            insert entitlementPolicy;
            CommerceEntitlementBuyerGroup cebg = new CommerceEntitlementBuyerGroup();
            cebg.BuyerGroupId = buyGrp.Id;
            cebg.PolicyId = entitlementPolicy.Id;
            insert cebg;
            
            CommerceEntitlementProduct cep = new CommerceEntitlementProduct();
            cep.ProductId = product1.Id;
            cep.PolicyId = entitlementPolicy.Id;
            insert cep;
            
            WebStoreCatalog sCat = new WebStoreCatalog();
            sCat.SalesStoreId = webStore.Id;
            sCat.ProductCatalogId = cat.Id;
            insert sCat;
            
            List<ProductCategory> productCategoryList = new List<ProductCategory>();
            ProductCategory pc = new ProductCategory();
            pc.CatalogId = cat.Id;
            pc.Name = 'CSP Parent';
            insert pc;
            
            ProductCategory pcc = new ProductCategory();
            pcc.CatalogId = cat.Id;
            pcc.ParentCategoryId = pc.Id;
            pcc.Name = 'CSP Child';
            productCategoryList.add(pcc);
            
            ProductCategory pcc1 = new ProductCategory();
            pcc1.CatalogId = cat.Id;
            pcc1.ParentCategoryId = pc.Id;
            pcc1.Name = 'CSP Child';
            productCategoryList.add(pcc1);
            
            insert productCategoryList;

            ProductCategory pcgc = new ProductCategory();
            pcgc.CatalogId = cat.Id;
            pcgc.ParentCategoryId = pcc.Id;
            pcgc.Name = 'CSP Garnd Child';
            insert pcgc;

            ProductCategory pcgcc = new ProductCategory();
            pcgcc.CatalogId = cat.Id;
            pcgcc.ParentCategoryId = pcgc.Id;
            pcgcc.Name = 'CSP Garnd Grand Child';
            insert pcgcc;
            
            PricebookEntry product1pbEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                UnitPrice = 300.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1pbEntry;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;

            testOrderDeliveryMethod = new OrderDeliveryMethod();
            testOrderDeliveryMethod.Name = 'Test Delivery Method';
            testOrderDeliveryMethod.ProductId = product1.id;
            insert testOrderDeliveryMethod;
        } //END of System.runAs(systemUser)

        UserAttributes ua = new UserAttributes();
        ua.profileId = b2cProfile.Id;
        ua.uniqueName = uniqueName;
        ua.orgId = orgId;
        ua.contactId = con.Id;
        User portalUser = insertPortalUser(ua);

        System.runAs(portalUser) {
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242
            );
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'Test',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;

            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;  

            Order orderObj = new Order();
            orderObj.Name               = 'Test Order 123';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            Insert orderObj;

            OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
                DeliverToName = cartDeliveryGroup.DeliverToName,
                DeliveryInstructions = cartDeliveryGroup.ShippingInstructions,
                DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
                DeliverToCity = cartDeliveryGroup.DeliverToCity,
                DeliverToState = cartDeliveryGroup.DeliverToState,
                DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
                DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
                DeliverToLatitude = cartDeliveryGroup.DeliverToLatitude,
                DeliverToLongitude = cartDeliveryGroup.DeliverToLongitude,
                OrderDeliveryMethodId = cartDeliveryGroup.DeliveryMethodId,
                OrderId = orderObj.Id
            );
            insert(orderDeliveryGroup);

            OrderItem orderItem = new OrderItem(
                Product2Id = cartItem1.Product2Id,
                Type = 'Order Product',
                Quantity = cartItem1.Quantity,
                ListPrice = cartItem1.ListPrice,
                UnitPrice = 10.00,
                OrderId = orderObj.Id,
                OrderDeliveryGroupId = orderDeliveryGroup.Id,
                TotalLineAmount = cartItem1.TotalLineAmount
            );
            //insert orderItem;

            // Update the order status to Activated.
            orderObj.Status = 'Activated';
            //update orderObj; 
        } //END of System.runAs(portalUser)
    } //END of method "createData"



    public static WebStore prepareWebStore(String name) {		
        WebStore webStr = new WebStore();		
        webStr.Name = name;		
        webStr.PricingStrategy = 'LowestPrice';		
        return webStr;		
    }		
    		
    public static Product2 createSimpleProduct() {		
 		
        Product2 simpleProduct = new Product2(		
                IsActive = true,		
                Name = 'Reward Points',		
                Family = 'Standard Price',		
                ProductCode = 'RP'               		
        );		
        return simpleProduct;		
    }		
    public static OrderDeliveryMethod createOrderDeliveryMethod() {		
        OrderDeliveryMethod OrderDeliveryMethod = new OrderDeliveryMethod(Name = 'Freight');		
        return OrderDeliveryMethod;		
    }		
    public static CartDeliveryGroup createCartDeliveryGroup(WebCart cart, Id OrderDeliveryMethodId) {		
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery',DeliveryMethodId = OrderDeliveryMethodId);		
        return cartDeliveryGroup;		
    }		
    		
    public static Account createAccount(String name) {		
        Account acc = new Account();		
        acc.Name = name;		
        acc.Type = 'Customer';		
        acc.ShippingStreet = 'test';		
        acc.ShippingCountry = 'United States';		
        acc.ShippingState = 'Alabama';		
        acc.ShippingPostalCode = '12345';		
        acc.BillingStreet = 'test';		
        acc.BillingCity = 'Cambridge';		
        acc.BillingState = 'Alabama';		
        acc.BillingCountry = 'United States';		
        return acc;		
    }		
    public static Contact createContact(Account acc) {		
        Contact con = new Contact();		
        con.FirstName = 'test';		
        con.LastName = 'Contact';		
        con.Email = 'test@test.com';		
        con.AccountId = acc.Id;		
        con.MailingStreet = 'test';		
        con.MailingCity = 'Norcross';		
        con.MailingState = 'Alabama';		
        con.MailingCountry = 'United States';		
        con.MailingPostalCode = '123321';		
        con.AccountId = acc.Id;		
        con.Email = 'testEmergency@yopmail.com';		
        con.Phone = '1231234567';		
        return con;		
    }		
    		
    // this contact is not associated with any user		
    public static Contact createContactsWithNoUser(Account acc) {		
        Contact con = new Contact();		
        con.FirstName = 'caseware test';		
        con.LastName = 'Contact';		
        con.Email = 'CAStest@test.com';		
        con.AccountId = acc.Id;		
        con.MailingStreet = 'CAS';		
        con.MailingCity = 'Norcross';		
        con.MailingState = 'Alabama';		
        con.MailingCountry = 'United States';		
        con.MailingPostalCode = '123321';		
        con.AccountId = acc.Id;		
        con.Email = 'CAS2_Email2@yopmail.com';		
        con.Phone = '1234500067';		
        return con;	
    }	
    public static User createUser(Contact con, Id accId) {	
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Shopper Profile' LIMIT 1];	
        //Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];	
        String orgId = UserInfo.getOrganizationId();	
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');	
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));	
        String uniqueName = orgId + dateString + RandomId;	
        String userNickname ='TestCaseWare';	
        User uu = new User(firstname = 'ABC',	
                lastName = 'XYZ',	
                email = uniqueName + '@test' + orgId + '.org',	
                Username = 'testR1@test.org',	
                EmailEncodingKey = 'ISO-8859-1',	
                Alias = uniqueName.substring(18, 23),	
                TimeZoneSidKey = 'America/Los_Angeles',	
                LocaleSidKey = 'en_US',	
                LanguageLocaleKey = 'en_US',	
                CommunityNickname = userNickname,	
                IsActive = True,	
                ProfileId = pf.Id,	
                ContactId = con.Id	
        );	
        return uu;	
    }	
    public static WebCart createCart(Account acc, WebStore webStr, User u) {	
        WebCart cart = new WebCart(Name = 'TestCart', WebStoreId = webStr.Id, 	
                AccountId = acc.Id, Status = 'Active', OwnerId = u.Id, IsSecondary = false);	
        return cart;	
    }	
    public static CartDeliveryGroupMethod createCartDeliveryGroupMethod(Id cartId, Id cartDeliveryGroupId, Id OrderDeliveryMethodId) {	
        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod();	
        cartDeliveryGroupMethod.WebCartId = cartId;	
        cartDeliveryGroupMethod.Name = 'CDG NAME';	
        cartDeliveryGroupMethod.CartDeliveryGroupId = cartDeliveryGroupId;	
        //cartDeliveryGroupMethod.IsDefault__c= true;	
        cartDeliveryGroupMethod.ShippingFee = 13;	
        cartDeliveryGroupMethod.DeliveryMethodId = OrderDeliveryMethodId;	
        return cartDeliveryGroupMethod;	
    }	
    public static CartItem createCartItem(WebCart cart, CartDeliveryGroup cartDeliveryGroup, Product2 p) {	
        List<CartItem> cartItems = new List<CartItem>();	
        CartItem cartItem = new CartItem(	
                CartId = cart.Id,	
                AdjustmentAmount = 0,	
                TotalAdjustmentAmount = 0,	
                Sku = p.ProductCode,	
                SalesPrice = 10.00,	
                Quantity = 3.0,	
                Type = 'Product',	
                Name = 'TestProduct',	
                Listprice = 10.00,	
                CartDeliveryGroupId = cartDeliveryGroup.Id,	
                Product2Id = p.Id,	
                TotalLineAmount = 30.00,	
                TotalListPrice = 30.00,	
                TotalPrice = 30.00,	
                TotalPriceAfterAllAdjustments = 30.00,	
                UnitAdjustmentAmount = 0,	
                UnitAdjustedPrice = 1	
        );	
        return cartItem;	
    }	
}
