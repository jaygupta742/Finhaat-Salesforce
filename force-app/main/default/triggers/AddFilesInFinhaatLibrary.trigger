/*Created by: Sougata Paul; Created On: 04-09-2024;*/
trigger AddFilesInFinhaatLibrary on ContentDocumentLink (after insert) {
    AddFilesInFinhaatLibrary_handler.addFiles(trigger.new);
}