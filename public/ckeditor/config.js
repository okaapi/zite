/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	
	
	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },		
		//{ name: 'editing',     groups: [ 'find', 'selection', 'spellchecker' ] },		
		{ name: 'links' },			
		{ name: 'insert', groups: [ 'image', 'youtube' ] },
		{ name: 'tools' },
	    { name: 'document',	   groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'others' },
		'/',
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },	
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align' ] },	
		//{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align','bidi' ] },				
		{ name: 'styles' },
		{ name: 'colors' },
		//{ name: 'about' }
	];
		
	// Remove some buttons provided by the standard plugins, which are
	// not needed in the Standard(s) toolbar.
	config.removeButtons = 'Anchor,Styles,Preview,Templates,NewPage,Print,Cut, Copy';
	config.removePlugins = 'iframe,flash';
        config.extraPlugins = 'youtube';

	// Set the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre';

        config.extraAllowedContent = 'span(*);iframe(*)';

	// Simplify the dialog windows.
	config.removeDialogTabs = 'image:advanced;link:advanced';
	
	config.height = '700';
	
	config.protectedSource.push( /<%[\s\S]*?%>/g );		
};
