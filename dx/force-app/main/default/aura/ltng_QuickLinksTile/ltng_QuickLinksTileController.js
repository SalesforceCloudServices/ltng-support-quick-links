({
	/** handler for when the link is clicked **/
    handleLinkClicked: function( component, event, helper ){
        console.log( 'link was clicked' );
        var quickLink = component.get('v.quickLink');
        var linkType = quickLink.Type__c;
        var linkTarget = quickLink.Target__c;
        helper.followQuickLink( linkType, linkTarget, quickLink );
    },
    
    doInit: function( component, event, helper ){
        console.log( 'quickLinkTile init' );
    },
    
    /** handler if the quickLink has changed **/
    handleQuickLinkChanged: function( component, event, helper ){
        console.log( 'quickLinks have changed' );
        helper.initQuickLinks( component.get( 'v.quickLinks' ), component, helper );
    }
})