//
//  DataManager.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 03/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import Foundation

class DataManager: DataDelegate {
    
    func getActiveUserProfiles() -> [String] {
        if let documentsDir = GeneralSettings.getDocumentsDirectory() {
            do{
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDir, includingPropertiesForKeys: [.isDirectoryKey], options: [])
                let userList = directoryContents.filter({ $0.hasDirectoryPath }).map({ $0.lastPathComponent })
                return userList
            } catch {
                print("Problem fetching document folder files")
            }
        }
        return [String]()
    }
    
    func createUserProfile(for expInfo: [ExperimentParameter: String]) -> UserProfile? {
        if let userFolder = self.createUserFolder(for: expInfo) {
            let userProfile = UserProfile(expInfo)
            let filePath = userFolder.appendingPathComponent("userProfile.json")
            let json = try? JSONEncoder().encode(userProfile)
        
            do {
                try json!.write(to: filePath)
            } catch {
                print("Problem writing user file")
                return nil
            }
            return userProfile
        }
        return nil
    }
    
    func nextVersion(for userInitials: String) -> Int {
        
        var nextVersion = 0
        
        if let directoryContents = self.getUserFiles(for: userInitials, with: [.isRegularFileKey]) {
            let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userInitials ) })
            for file in versionFiles {
                if let experimentData = self.getExperimentData(for: file) {
                    if experimentData.version >= nextVersion {
                        nextVersion = experimentData.version + 1
                    }
                }
            }
         }
         return nextVersion
    }
    
    func getUserFiles(for initials: String, with keys: [URLResourceKey] = []) -> [URL]? {
        if let userFolder = self.getUserFolder(for: initials) {
            do{
                let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: keys, options: [])
                return directoryContents
            } catch {
                print("Problems fetching folder contents")
            }
        }
        return nil
    }
    
    func isExistingUser(_ initials: String) -> Bool {
        if let directoryContents = self.getUserFiles(for: initials, with: [.isRegularFileKey]) {
            let profileFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: "userProfile" ) })
            return profileFiles.count == 1
       }
       return false
    }
    
    func hasUnfinishedVersions(for userInitials: String) -> ExperimentData? {
           
        if let directoryContents = self.getUserFiles(for: userInitials) {
           let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userInitials ) })
           for file in versionFiles {
               if let experimentData = self.getExperimentData(for: file) {
                   if experimentData.hasTrialsLeft {
                       return experimentData
                   }
               }
           }
        }
        return nil
    }
    
    func getUserProfile(for initials: String) -> UserProfile? {
        
        if let directoryContents = self.getUserFiles(for: initials) {
            let profileFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: "userProfile" ) })
            if profileFiles.count == 1 {
                do {
                    let data = try Data(contentsOf: profileFiles[0])
                    let decoder = JSONDecoder()
                    let profileData = try decoder.decode(UserProfile.self, from: data)
                    return profileData
                } catch {
                    print("Problem decoding profile file")
                }
            }
        }
        return nil
    }
    
    func createUserFolder(for expInfo: [ExperimentParameter: String]) -> URL? {
        let fileManager = FileManager.default
        guard let userFolder = self.getUserFolder(for: expInfo[.initials]!) else { return nil }

        if !fileManager.fileExists(atPath: userFolder.relativePath) {
            do{
                try fileManager.createDirectory(atPath: userFolder.relativePath, withIntermediateDirectories: true, attributes: nil)
                    }
             catch (let error){
                 print("Failed to create Directory: \(error.localizedDescription)")
                 return nil
             }
        }
        return userFolder
    }
    
    func getUserFolder(for initials: String) -> URL? {
        guard let documentPath = GeneralSettings.getDocumentsDirectory() else { return nil}
        return documentPath.appendingPathComponent("/" + initials + "/")
    }
    
    func saveProgress(_ experimentData: ExperimentData) {
        
        if let pathDirectory = GeneralSettings.getDocumentsDirectory() {
            let fileName = experimentData.initials + "/" + experimentData.initials + "_" + String(experimentData.version) + ".json"
            let filePath = pathDirectory.appendingPathComponent(fileName)
            let json = try? JSONEncoder().encode(experimentData)
            do {
                try json!.write(to: filePath)
            } catch {
                print("Problem storing progress")
            }
        }
    }

    func loadExistingVersion(_ userProfile: UserProfile) -> ExperimentData? {
 
        if let directoryContents = self.getUserFiles(for: userProfile.initials) {
            let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userProfile.initials ) })
            for file in versionFiles {
                if let experimentData = self.getExperimentData(for: file) {
                    if experimentData.hasTrialsLeft { return experimentData }
                }
            }
        }
        return nil
    }
    
    func getExperimentData(for file: URL) -> ExperimentData? {
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            let experimentData = try decoder.decode(ExperimentData.self, from: data)
            return experimentData
        } catch {
            print("Data decoding failed")
        }
        return nil
    }
}
