﻿/*    <javascriptresource>    <name>Superresolution</name>    <about>Average , Align your layers, doubles the resoulution</about>    <menu>filter</menu>    <category>Photo</category>    <enableinfo>true</enableinfo></javascriptresource>*//*Superresolution Photoshop ScriptWritten by Holger KremminVersion 1.0.0Date March 8th, 2015Installation------------------------1) Copy into your scripts folder in PhotoshopUsage------------------------Load your frames to be image averaged into a single photoshop document. *///we need some ps scripts for re-use, copied the code the merge to hdr scripts...// Put header files in a "Stack Scripts Only" folder.  The "...Only" tells// PS not to place it in the menu.  For that reason, we do -not- localize that// portion of the folder name.var g_StackScriptFolderPath = app.path + "/"+ localize("$$$/ScriptingSupport/InstalledScripts=Presets/Scripts") + "/"										+ localize("$$$/private/Exposuremerge/StackScriptOnly=Stack Scripts Only/");$.evalFile(g_StackScriptFolderPath + "StackSupport.jsx");if (confirm("Do you want to create a HiRes image?")) {            hires();          }function hires() {            if (documents.length == 0) {          alert("There are no documents open.");        } else {          var myDoc = activeDocument;          var layerRef = myDoc.activeLayer;          var myLayerCount = myDoc.layers.length - 1;                    resize();                      if (myDoc.layers.length == 1 && layerRef.isBackgroundLayer == true) {            alert("The Background layer cannot be hidden when it's the only layer in a document.");          } else {                        for(var myCounter = myLayerCount; myCounter > 0; myCounter--) {              var myLayer = myDoc.layers[myLayerCount - myCounter]              var opacity = 0;              if (myCounter == 0)               opacity = 100;              else                opacity = getImageAverageOpacity(myCounter);                              myLayer.opacity = opacity;            }        }                //align all layers        autoAlign(myDoc);        //merge down to one layer        mergedown(myDoc);    } // if document}  //functionfunction mergedown(activeDoc) {    if (confirm("Do you want to merge the visible layers now?")) {            activeDoc.mergeVisibleLayers();          } }function autoAlign(activeDoc) {        selectAllLayers(activeDoc);    alignLayersByContent("Auto");    }function getImageAverageOpacity(LayerNum) {    var newOpacity = 100 * ( 1 / (LayerNum + 1));    return newOpacity;}//resize the image function resize() {        // to remember the given preferences    var prefUnits = app.preferences.rulerUnits;    // will work in pixel resolution    app.preferences.rulerUnits = Units.PIXELS;    var doc = app.activeDocument;    var origSize = Math.max(doc.height, doc.width);        //double the x and y resolution    var newHeight = doc.height * 2;    var newWidth = doc.width * 2;    //resize using nearest neighbor     doc.resizeImage(newWidth, newHeight, doc.resolution, ResampleMethod.NEARESTNEIGHBOR);    //restore preferences    app.preferences.rulerUnits = prefUnits;    }