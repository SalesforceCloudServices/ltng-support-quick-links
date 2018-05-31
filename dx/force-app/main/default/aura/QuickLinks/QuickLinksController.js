({
	/** initializes the component **/
    doInit: function(component, event, helper) {
        //console.log( 'quickLinks init' );
        helper.loadQuickLinks( component, helper );
	},
    
    /** handles if a link is clicked **/
    handleLinkClicked: function( component, event, helper ){
        //console.log( 'link was clicked' );
    }
})