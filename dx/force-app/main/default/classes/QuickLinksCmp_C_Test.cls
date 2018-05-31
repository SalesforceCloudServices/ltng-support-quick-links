@isTest
public class QuickLinksCmp_C_Test {
    
    @TestSetup
	static void setup() {
	    TestObjectFactory.prepStandardUsers();
        
        //-- needed to avoid MIXED_DML_OPERATION from PermissionSetAssignment and Custom Setting creation
        User adminUser = TestObjectFactory.userAliasMap.get( TestObjectFactory.USER_ALIAS_ADMIN );
        System.runAs( adminUser ){
            TestObjectFactory.prepStandardCustomSettings();
        }
	}
	
	class TestSettings {
	    
	    User adminUser;
	    User stdUser;
	    
	    QuickLink__c adminQuickLink;
	    QuickLink__c pocQuickLink;
	    
	    public TestSettings(){
            findUsers();
	    }
	    
	    public void findUsers(){
	        Map<String,User> userMap = TestObjectFactory.refreshUsersByAlias( new String[]{
	            TestObjectFactory.USER_ALIAS_ADMIN,
	            TestObjectFactory.USER_ALIAS_QL_ADMIN,
	            TestObjectFactory.USER_ALIAS_STD
	        });
	        
	        adminUser = userMap.get(TestObjectFactory.USER_ALIAS_QL_ADMIN);
	        stdUser = userMap.get(TestObjectFactory.USER_ALIAS_STD);
	    }
	    
	    public void createQuickLinks(){
    		//create a quick link
    		
    		adminQuickLink = TestObjectFactory.createQuickLink('String Name', 'admin link', 'URL', 'String Target', 'String Description', TestObjectFactory.PERM_SET_QUICKLINK_ADMIN );
    		pocQuickLink = TestObjectFactory.createQuickLink('String Name2', 'external Link', 'URL', 'String Target2', 'String Description2', 'AccessPOCs');
    		
    		insert( new QuickLink__c[]{ adminQuickLink, pocQuickLink });
	    }
	    
	    public void createQuickLinksWithEmpty(){
    		//create a quick link
    		
    		adminQuickLink = TestObjectFactory.createQuickLink('String Name', 'admin link', 'URL', 'String Target', 'String Description', TestObjectFactory.PERM_SET_QUICKLINK_ADMIN );
    		pocQuickLink = TestObjectFactory.createQuickLink('String Name2', 'external Link', 'URL', 'String Target2', 'String Description2', null);
    		
    		insert( new QuickLink__c[]{ adminQuickLink, pocQuickLink });
	    }
	    
	    public void setupStandard(){
	        createQuickLinks();
	    }
	    
	    public void setupQuickLinksWithoutPermissions(){
	        createQuickLinksWithEmpty();
	    }
	    
	    public void finalize(){
	    }
	}
    
    static testMethod void findQuicklinksAssigned(){
        TestSettings ts = new TestSettings();
        ts.setupStandard();
        ts.finalize();
        
        QuickLink__c[] results;
        QuickLink__c[] expected = new QuickLink__c[]{ ts.adminQuickLink };
        
        System.runAs( ts.adminUser ){
            results = QuickLinksCmp_c.getMyLinks();
            
            System.assertEquals( expected.size(), results.size(), 'There should be only one quicklink found, because it is assigned to the sys admin custom permission/permission set');
            
            QuickLink__c expectedQuickLink = expected[0];
            QuickLink__c resultQuickLink = results[0];
            
            System.assertEquals( expectedQuickLink.id, resultQuickLink.id, 'the only quicklink to be found is the one with the matching perm set/custom permission as admin');
        }
    }
    
    static testMethod void findQuicklinksWhenNoneAssigned(){
        TestSettings ts = new TestSettings();
        ts.setupQuickLinksWithoutPermissions();
        ts.finalize();
        
        QuickLink__c[] results;
        QuickLink__c[] expected = new QuickLink__c[]{ ts.pocQuickLink };
        
        System.runAs( ts.stdUser ){
            results = QuickLinksCmp_c.getMyLinks();
            
            System.assertEquals( expected.size(), results.size(), 'There should not have any quicklinks, because it is assigned to a permission set that the user does not have');
            
            QuickLink__c expectedQuickLink = expected[0];
            QuickLink__c resultQuickLink = results[0];
            
            System.assertEquals( expectedQuickLink.id, resultQuickLink.id, 'the only quicklink to be found is the one with the matching perm set/custom permission as admin');
        }
    }
}