({
	/**
	 * loads in all the quicklinks
	 **/
    loadQuickLinks : function( component, helper ) {
		var action=component.get("c.getMyLinks");
        action.setStorable();
        //action.setParams({ userId: something });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if( state === 'SUCCESS' ){
                var quickLinkList = response.getReturnValue();
                quickLinkList.sort(function(a,b) {
                    var t1 = a.PreferredSortIndex__c == b.PreferredSortIndex__c, t2 = a.PreferredSortIndex__c < b.PreferredSortIndex__c;
                    return t1 ? 0: ( t2 ? -1 : 1);
                });
                component.set('v.quickLinks',quickLinkList);
                helper.handleInitComplete(component,helper);
            } else {
                helper.handleResponseError( response, 'something went wrong in retrieving current quicklink list', component, helper );
            }
        });
        $A.enqueueAction(action);
	},
    
    /**
     * Called when the component completes initialization
     **/
    handleInitComplete : function( component, helper ){
    	component.set( 'v.setupComplete', true );
	},
    
    /** generates the target URL **/
    generateTargetURL : function( qlType, qlTarget ) {
        var result = qlTarget;
        if( qlType == 'Record' ){
            result = '/one/one.app#/sObject/' + qlTarget + '/view';
        } else if( qlType == 'Visualforce' ){
            result = '/one/one.app#/n/' + qlTarget;
        }
        return( result );
	}
})