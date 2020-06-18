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
 whiteCellSelection - table views has white selected state (touch is not visible)
 Screen - the name of generated screen; used in combination with cell name
 */

// =======================================================
// MARK: - Main script

let moderator = Moderator(description: "Generates a swift app components from templates")
moderator.usageFormText = "codeTemplate <params>"

let description = moderator.add(Argument<String?>
    .optionWithValue("context", name: "Context", description: "JSON file with template context"))

do {
    try moderator.parse()
    guard let unwrappedDescription = description.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    let contextFile = try File(path: unwrappedDescription)
    let contextString = try contextFile.readAsString(encodedAs: .utf8)
    let contextData = Data(contextString.utf8)

    // make sure this JSON is in the format we expect
    guard let context = try JSONSerialization.jsonObject(with: contextData, options: []) as? [String: Any] else {
        throw ScriptError.generalError(message: "Deserialization error")
    }

    try Paths.setupPaths(context: context)

    let modifiedContext = Generator.shared.updateContext(context)
    try Generator.shared.generate(
        generationMode: .template(.coordinatorNavigation),
        context: modifiedContext,
        reviewMode: .individual,
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
