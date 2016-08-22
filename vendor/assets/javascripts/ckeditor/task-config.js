/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function (config) {
    config.toolbarGroups = [
		{ name: 'basicstyles', groups: ['basicstyles', 'cleanup'] },
		{ name: 'colors', groups: ['colors'] },
		{ name: 'styles', groups: ['styles'] },
		{ name: 'paragraph', groups: ['align', 'list', 'indent', 'blocks', 'bidi', 'paragraph'] },
		{ name: 'insert', groups: ['insert'] },
		{ name: 'clipboard', groups: ['undo', 'clipboard'] },
		{ name: 'editing', groups: ['find', 'selection', 'spellchecker', 'editing'] },
		{ name: 'links', groups: ['links'] },
		{ name: 'document', groups: ['mode', 'document', 'doctools'] },
		{ name: 'forms', groups: ['forms'] },
		'/',
		{ name: 'tools', groups: ['tools'] },
		{ name: 'others', groups: ['others'] },
		{ name: 'about', groups: ['about'] }
    ];
    config.resize_enabled = false;
    config.removeButtons = 'Styles,RemoveFormat,Save,NewPage,Preview,Print,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Find,Replace,BidiLtr,BidiRtl,Language,CreateDiv,Outdent,Indent,SelectAll,About,Maximize,ShowBlocks,Flash,SpecialChar,Iframe,PageBreak,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,Anchor,Strike,Subscript,Format,NumberedList,Table,Undo,Redo,Scayt,Unlink,Source,Font,FontSize';
};