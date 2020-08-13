import Files
import Foundation
import Moderator
import ScriptToolkit
import Stencil

var programMode: ProgramMode

// The main context for code templates
var mainContext: Context

do {
    ContextProvider.setupParameters()
    try ContextProvider.parseParameters()

    if CommandLine.argc == 1 {
        print("codeTemplate - Generates a swift app components from templates")
        print("use argument `--help` for documentation")
    }

    ContextProvider.showUsageInfoIfNeeded()

    print("⌚️ Processing")

    mainContext = ContextProvider.getContext()
    ContextProvider.updateContext(mainContext)
    try Paths.setupScriptPaths(context: mainContext)

    switch mainContext.stringValue(.mode) {
    case "generate":
        try Paths.setupProjectPaths(context: mainContext)
        try Generator.shared.generateCode(context: mainContext)

    case "updateAll":
        try Updater.shared.updateTemplates(updateMode: .all, scriptPath: mainContext.stringValue(.scriptPath))

    case "updateNew":
        try Updater.shared.updateTemplates(updateMode: .new, scriptPath: mainContext.stringValue(.scriptPath))

    case "validate":
        mainContext[.projectPath] = mainContext[.generatePath]
        mainContext[.locationPath] = mainContext[.projectPath]?.appendingPathComponent(path: "Template")
        mainContext[.sourcesPath] = mainContext[.locationPath]

        if let unwrappedTemplate = mainContext.optionalStringValue(.template) {
            try Validator.shared.validate(template: unwrappedTemplate)
        } else {
            // Validate all templates
            try Validator.shared.validateTemplates()
        }

    case "prepare":
        try Paths.setupProjectPaths(context: mainContext)
        try Preparator.shared.prepareTemplate(context: mainContext)

    default:
        throw ScriptError.argumentError(message: "invalid mode value")
    }

    print("✅ Done")
} catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
