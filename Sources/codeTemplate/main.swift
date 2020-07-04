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
 bottomView - shows buttons at the bottom of table in controller
 topGradientView - top alpha gradient
 bottomGradientView - bottom alpha gradient
 */

// =======================================================
// MARK: - Main script

let moderator = Moderator(description: "Generates a swift app components from templates")
moderator.usageFormText = "codeTemplate <params>"

let mode = moderator.add(Argument<String?>
    .optionWithValue("mode", name: "Current operation mode - code generation, updating templates and template validation", description: "Possible values: generate, updateAll, updateNew, validate"))

let context = moderator.add(Argument<String?>
    .optionWithValue("context", name: "Context", description: "JSON file with template context"))

let reviewMode = moderator.add(Argument<String?>
    .optionWithValue("review", name: "Result review mode", description: "Possible values: none, individual, overall").default("individual"))

let scriptPath = moderator.add(Argument<String?>
    .optionWithValue("scriptPath", name: "Path parameter", description: "The path to codeTemplate script with Generated and Templates folder."))

var programMode: ProgramMode

do {
    try moderator.parse()

    print("⌚️ Processing")

    if let mode = mode.value {
        switch mode {
        case "generate":
            guard let contextFile = context.value else {
                throw ScriptError.argumentError(message: "context not specified")
            }
            guard let reviewMode = ReviewMode(rawValue: reviewMode.value) else {
                throw ScriptError.argumentError(message: "invalid review mode")
            }

            try Generator.shared.generateCode(contextFile: contextFile, reviewMode: reviewMode)

        case "updateAll":
            guard let unwrappedScriptpath = scriptPath.value else {
                throw ScriptError.argumentError(message: "scriptPath not specified")
            }
            try Updater.shared.updateTemplates(updateMode: .all, scriptPath: unwrappedScriptpath)

        case "updateNew":
            guard let unwrappedScriptpath = scriptPath.value else {
                throw ScriptError.argumentError(message: "scriptPath not specified")
            }
            try Updater.shared.updateTemplates(updateMode: .new, scriptPath: unwrappedScriptpath)

        case "validate":
            guard let unwrappedScriptpath = scriptPath.value else {
                throw ScriptError.argumentError(message: "scriptPath not specified")
            }
            try Validator.shared.validateTemplates(scriptPath: unwrappedScriptpath)

        default:
            throw ScriptError.argumentError(message: "invalid mode value")
        }
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
