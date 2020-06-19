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

let description = moderator.add(Argument<String?>
    .optionWithValue("context", name: "Context", description: "JSON file with template context"))

let reviewMode = moderator.add(Argument<String?>
    .optionWithValue("review", name: "Result review mode", description: "Possible values: none, individual, overall").default("individual"))

do {
    try moderator.parse()

    guard let unwrappedDescription = description.value else {
        print(moderator.usagetext)
        exit(0)
    }

    guard let reviewMode = ReviewMode(rawValue: reviewMode.value) else {
        throw ScriptError.argumentError(message: "invalid review mode")
    }

    print("⌚️ Processing")

    let contextFile = try File(path: unwrappedDescription)
    let contextString = try contextFile.readAsString(encodedAs: .utf8)
    let contextData = Data(contextString.utf8)

    // make sure this JSON is in the format we expect
    guard let context = try JSONSerialization.jsonObject(with: contextData, options: []) as? [String: Any] else {
        throw ScriptError.generalError(message: "Deserialization error")
    }

    let generationMode: GenerationMode
    if let unwrappedTemplate = context["template"] as? String, let templateType = TemplateType(rawValue: unwrappedTemplate) {
        generationMode = .template(templateType)
    } else if let unwrappedTemplateCombo = context["templateCombo"] as? String, let comboType = TemplateCombo(rawValue: unwrappedTemplateCombo) {
        generationMode = .combo(comboType)
    } else {
        throw ScriptError.moreInfoNeeded(message: "template or templateCombo are not specified or invalid")
    }

    try Paths.setupPaths(context: context)

    let modifiedContext = Generator.shared.updateContext(context)
    try Generator.shared.generate(
        generationMode: generationMode,
        context: modifiedContext,
        reviewMode: reviewMode,
        deleteGenerated: false
    )

    print("✅ Done")
} catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
