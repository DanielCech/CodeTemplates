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
*/

let projectPath = "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS/Harbor/Scenes/HouseholdScene/EmergencyContacts"
var context: Context = ["name": "addContactSheet"]

// Project setup
context["author"] = "Daniel Cech"
context["projectName"] = "Harbor"
context["copyright"] = "Copyright © 2020 25MP Corp. All rights reserved."

context["fakeNavbar"] = false
context["sectionHeaders"] = false

context["oldTableViewCells"] = [
    "blue", "green", "yellow"
]

context["newTableViewCells"] = [
    "blue", "green", "yellow"
]

print("⌚️ Processing")

// Code generation

do {
    try Generator.shared.generate(
        generationMode: .combo(.sceneControllerRxSwiftWithTableView),
        context: context,
        reviewMode: .individual
    )
} catch {
    print("Error: generation failed: \(error)")
}

print("✅ Done")
