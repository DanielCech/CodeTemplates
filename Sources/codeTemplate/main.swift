import Files
import Foundation
import Moderator
import ScriptToolkit
import Stencil

/*
 name - the name of created item (decapitalized)
 Name - capitalized name
 author - author of project, used in title
 projectName - project name and target name
 copyright - copyright phrase used in file header
 fakeNavbar - using scrolling fake navbar
 sectionHeaders - support for tableview section headers
 oldTableViewCells - already defined table view cells
 newTableViewCells - table view cells that need to be generated
 tableViewCells - all table view cells together
 oldCollectionViewCells - already defined collection view cells
 newCollectionViewCells - collection view cells that need to be generated
 collectionViewCells - all collection view cells together
 tableContentFromAPI - loads table content from API
 whiteCellSelection - table views has white selected state (touch is not visible)
 Screen - the name of generated screen; used in combination with cell name
 */

// =======================================================
// MARK: - Main script

let moderator = Moderator(description: "Generates a swift app components from templates")
moderator.usageFormText = "codeTemplate <params>"

let context = moderator.add(Argument<String?>
    .optionWithValue("context", name: "Context", description: "JSON file with template context"))

let reviewMode = moderator.add(Argument<String?>
    .optionWithValue("review", name: "Result review mode", description: "Possible values: none, individual, overall").default("individual"))

let updateTeplates = moderator.add(Argument<String?>
    .optionWithValue("updateTemplates", name: "Trigger template updates based on teplate dependencies", description: "Possible values: all, new. Parameter scriptPath needs to be specified too."))

let scriptPath = moderator.add(Argument<String?>
    .optionWithValue("scriptPath", name: "Path parameter", description: "The path to codeTemplate script with Generated and Templates folder"))

var programMode: ProgramMode

do {
    try moderator.parse()

    print("⌚️ Processing")

    if let contextFile = context.value {
        guard let reviewMode = ReviewMode(rawValue: reviewMode.value) else {
            throw ScriptError.argumentError(message: "invalid review mode")
        }

        try Generator.shared.generateCode(contextFile: contextFile, reviewMode: reviewMode)
    } else if
        let unwrappedUpdateModeString = updateTeplates.value,
        let updateMode = UpdateTemplateMode(rawValue: unwrappedUpdateModeString),
        let unwrappedScriptpath = scriptPath.value {
        try TemplateUpdater.shared.updateTemplates(updateMode: updateMode, scriptPath: unwrappedScriptpath)
    } else {
        print(moderator.usagetext)
        exit(0)
    }

    print("✅ Done")
} catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
