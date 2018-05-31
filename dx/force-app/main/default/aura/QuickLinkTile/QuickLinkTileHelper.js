({
	/**
	 * @param linkType (String) - type of quicklink
	 * @param linkTarget (String) - target address
	 * @param quickLink (QuickLink__c) - quickLinkObject - if needed
	 **/
    followQuickLink : function( linkType, linkTarget, quickLink ) {
        if( linkType == 'Visualforce' ){
            var navEvt = $A.get('e.force:navigateToURL');
            navEvt.setParams({ 'url': '/apex/' + linkTarget });
            navEvt.fire();
        } else if( linkType == 'Record' ){
            var navEvt = $A.get('e.force:navigateToSObject');
            navEvt.setParams({ 'recordId':linkTarget, 'slideDevName':'detail' });
            navEvt.fire();
        } else {
            var navEvt = $A.get('e.force:navigateToURL' );
            navEvt.setParams({ 'url': linkTarget });
            navEvt.fire();
        }
	},
    
    
    
    /**
     * Initializes the component if the quickLinks have changed
     * @param quickLink (QuickLink__c)
     * @param component
     * @param helper
     **/
    initQuickLinks: function( quickLink, component, helper ){
        console.log( 'quickLinks have changed' );
    }
})