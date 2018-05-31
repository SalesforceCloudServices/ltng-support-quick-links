/**
 *  Controller for the QuickLinks lightning component
 *  @author Paul Roth <proth@salesforce.com>
 **/
public with sharing class QuickLinksCmp_C {
	
	/**
	 *  Determines the list of QuickLinks available to the user.
	 *  @return (QuickLink__c)
	 **/
	@AuraEnabled
	public static QuickLink__c[] getMyLinks(){
		QuickLink__c[] results = new QuickLink__c[]{};
		
		return( getLinks( UserInfo.getUserId() ));
	}
	
	/**
	 *  Determines the list of QuickLinks available to a specific person.
	 *  @param userId (Id)
	 *  @return (QuickLink__c[])
	 **/
	public static QuickLink__c[] getLinks( Id userId ){
		QuickLink__c[] results = new QuickLink__c[]{};
		
		//-- @TODO: add try catch in after completed
		//try {
		
		//-- set of all custom permissions to check for
		Set<String> allQuickLinkPermissions = new Set<String>();
		//-- map of all quicklinks grouped by custom permission developer name
		Map<String,QuickLink__c[]> quickLinksByPermission = new Map<String,QuickLink__c[]>();
		//-- ids of all the permission sets that contain those custom permissions
		//-- translation of all custom permissions developer names into their ids
		Map<Id,String> customPermissions = new Map<Id,String>();
		//-- collection of all custom permissions requested with the list of permission sets that contain them.
		Map<Id,String[]> permissionSetPermissions = new Map<Id,String[]>();
		
		//-- determine all quicklinks and sort them by the permission required to see them.
		QuickLink__c[] allQuickLinks = [ select id, name, Description__c, ExternalId__c, IconGroup__c, IconName__c, Type__c, Target__c, Permission__c, PreferredSortIndex__c, LastModifiedDate
			from QuickLink__c
			order by PreferredSortIndex__c NULLS LAST, name
		];
		
		for( QuickLink__c quickLink : allQuickLinks ){
			if( String.isEmpty( quickLink.Permission__c )){
				results.add( quickLink );
			} else {
				if( !quickLinksByPermission.containsKey( quickLink.Permission__c )){
					quickLinksByPermission.put( quickLink.Permission__c, new QuickLink__c[]{} );
				}
				quickLinksByPermission.get( quickLink.Permission__c ).add( quickLink );
			}
		}
		
		//-- @INVARIANT: all quicklinks have been recieved, and are now grouped by custom permission developer name within a map.
		allQuickLinkPermissions = quickLinksByPermission.keySet();
		//System.debug( 'allQuickLinkPermissions:' + allQuickLinkPermissions );
		
		//-- create a translation for all custom permission DeveloperNames to their IDs
		for( CustomPermission perm: [
			SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName in :allQuickLinkPermissions
		]){
			customPermissions.put( perm.Id, perm.DeveloperName );
		}
		
		//System.debug( 'customPermissionsMap:' + customPermissions );
		//-- collect all permission sets by custom permission developer name
		String permissionName;
		for( SetupEntityAccess access: [
			SELECT SetupEntityId, ParentId FROM SetupEntityAccess WHERE SetupEntityId in (
				SELECT Id FROM CustomPermission WHERE DeveloperName in :allQuickLinkPermissions
			)
		]){
			if( !permissionSetPermissions.containsKey( access.ParentId )){
				permissionSetPermissions.put( access.ParentId, new String[]{} );
			}
			permissionName = customPermissions.get( access.SetupEntityId );
			permissionSetPermissions.get( access.ParentId ).add( permissionName );
		}
		
		//-- @INVARIANT: we now have a list of all permissionSets with the custom permissions that they contain.
		//System.debug( 'permissionSetPermissions:' + permissionSetPermissions );
		
		//-- determine all the custom permissions that the user has
		Set<String> userCustomPermissions = new Set<String>();
		for( PermissionSetAssignment assignment: [
			SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeId = :userId
		]){
			//System.debug( 'permissionSet[' + assignment.PermissionSetId + ']:' + permissionSetPermissions.get( assignment.PermissionSetId ) );
			if( permissionSetPermissions.containsKey( assignment.PermissionSetId )){
				userCustomPermissions.addAll( permissionSetPermissions.get( assignment.PermissionSetId ) );
			}
		}
		
		//-- @INVARIANT - we now know all the custom permissions that the user belongs to.
		//System.debug( 'userCustomPermissions:' + userCustomPermissions );
		
		for( String userCustomPermission : userCustomPermissions ){
			results.addAll( quickLinksByPermission.get( userCustomPermission ));
		}
		
		//System.debug( 'results:' + results );
		
		//} catch( Exception err ){}
		
		return( results );
	}
}