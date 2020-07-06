//
//  TemplateType.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import Files
import ScriptToolkit

public typealias TemplateType = String

struct TemplateStructure {
    var category: String
    var settings: Settings
}

class TemplateTypes {
    static let shared = TemplateTypes()
    
    private var templateTypesDict: [TemplateType: TemplateStructure] = [:]
    
    func templateTypes() throws -> [TemplateType: TemplateStructure] {
        if !templateTypesDict.isEmpty {
            return templateTypesDict
        }
        
        print("💡 Loading templates")
        
        var types = [TemplateType: TemplateStructure]()
        
        let templatesFolder = try Folder(path: Paths.templatePath)
        
        for categoryFolder in templatesFolder.subfolders {
            if categoryFolder.name == "_combos" {
                continue
            }
            
            for templateFolder in categoryFolder.subfolders {
                let settingFilePath = templateFolder.path.appendingPathComponent(path: "template.json")
                let settings = try templateSettings(settingFilePath: settingFilePath)
                
                types[templateFolder.name] = TemplateStructure(category: categoryFolder.name, settings: settings)
            }
        }
        
        templateTypesDict = types

        return types
    }
    
    func templateCategory(for template: TemplateType) throws -> String {
        if let templateStruct = try templateTypes()[template] {
            return templateStruct.category
        }
        else {
            throw ScriptError.argumentError(message: "template does not exist")
        }
    }
    
    func templateSettings(for template: TemplateType) throws -> Settings {
        if let templateStruct = try templateTypes()[template] {
            return templateStruct.settings
        }
        else {
            throw ScriptError.argumentError(message: "template does not exist")
        }
    }
    
    private func templateSettings(settingFilePath: String) throws -> Settings {
           let settingFile = try File(path: settingFilePath)
           let settingsString = try settingFile.readAsString(encodedAs: .utf8)
           let settingsData = Data(settingsString.utf8)

           // make sure this JSON is in the format we expect
           guard let settings = try JSONSerialization.jsonObject(with: settingsData, options: []) as? [String: Any] else {
               throw ScriptError.generalError(message: "Deserialization error")
           }

           return settings
       }
    
}



//public enum TemplateType: String, CaseIterable {
//    // View Controllers
//    case viewControllerBasic
//    case viewControllerRxSwift
//    case viewControllerRxSwiftWithTableView
//    case viewControllerRxSwiftWithFormTableView
//    case viewControllerRxSwiftWithCollectionView
//
//    // View Models
//    case viewModelBasic
//    case viewModelRxSwift
//    case viewModelRxSwiftWithTableView
//    case viewModelRxSwiftWithFormTableView
//    case viewModelRxSwiftWithCollectionView
//
//    // Table View Cells
//    case tableViewCell
//    case tableViewCellRxSwift
//    case textFieldTableViewCellRxSwift
//
//    // Table View Section Header
//    case tableViewSectionHeader
//
//    // Table View Cell View Models
//    case tableViewCellViewModel
//    case tableViewCellViewModelRxSwift
//
//    // Collection View Cells
//    case collectionViewCell
//    case collectionViewCellRxSwift
//
//    // Collection View Cell View Models
//    case collectionViewCellViewModel
//    case collectionViewCellViewModelRxSwift
//
//    // Storyboards
//    case storyboardViewController
//    case storyboardViewControllerWithTableView
//    case storyboardViewControllerWithCollectionView
//
//    // Views
//    case view
//
//    // Coordinators
//    case coordinator
//    case coordinatorNavigation
//
//    // Section types
//    case rxDataSourcesSectionType
//
//    // Common parts
//    case viewModelAssembly
//
//    // Snippets
//    case halfModalContainerViewController
//    case halfModalContainerViewControllerRxSwift
//    case interpolate
//    case screenListViewController
//    case stylesheet
//
//    case singleViewApp
//
//    public var category: TemplateCategory {
//        switch self {
//        case .viewControllerBasic, .viewControllerRxSwift, .viewControllerRxSwiftWithTableView, .viewControllerRxSwiftWithCollectionView, .viewControllerRxSwiftWithFormTableView:
//            return .viewController
//
//        case .viewModelBasic, .viewModelRxSwift, .viewModelRxSwiftWithTableView, .viewModelRxSwiftWithFormTableView, .viewModelRxSwiftWithCollectionView:
//            return .viewModel
//
//        case .tableViewCell, .tableViewCellRxSwift, .textFieldTableViewCellRxSwift:
//            return .tableViewCell
//
//        case .tableViewSectionHeader:
//            return .tableViewSectionHeader
//
//        case .tableViewCellViewModel,.tableViewCellViewModelRxSwift:
//            return .tableViewCellViewModel
//
//        case .collectionViewCell, .collectionViewCellRxSwift:
//            return .collectionViewCell
//
//        case .collectionViewCellViewModel, .collectionViewCellViewModelRxSwift:
//            return .collectionViewCellViewModel
//
//        case .storyboardViewController, .storyboardViewControllerWithTableView, .storyboardViewControllerWithCollectionView:
//            return .storyboard
//
//        case .view:
//            return .view
//
//        case .coordinator, .coordinatorNavigation:
//            return .coordinator
//
//        case .rxDataSourcesSectionType:
//            return .rxDataSourcesSectionType
//
//        case .viewModelAssembly:
//            return .viewModelAssembly
//
//        case .halfModalContainerViewController, .halfModalContainerViewControllerRxSwift, .interpolate, .screenListViewController, .stylesheet:
//            return .snippets
//
//        case .singleViewApp:
//            return .xcodeproj
//        }
//    }
//
//    public func basePath() -> String {
//        switch self {
//        case .viewModelAssembly:
//            return Paths.projectPath
//        default:
//            return Paths.scenePath
//        }
//    }
//}


