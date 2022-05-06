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
                print("Hmmmm ships")
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
                return nil
            }
            return userProfile
        }
        return nil
    }
    
    func nextVersion(for userInitials: String) -> Int {
        
        var nextVersion = 0
        
        if let userFolder = self.getUserFolder(for: userInitials) {
            do{
                let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
                let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userInitials ) })
                for file in versionFiles {
                    let data = try Data(contentsOf: file)
                    let decoder = JSONDecoder()
                    let experimentData = try decoder.decode(ExperimentData.self, from: data)
                    if experimentData.version >= nextVersion {
                        nextVersion = experimentData.version + 1
                    }
                }
            } catch {
                print("Whooops")
            }
         }
         return nextVersion
        
    }
    
    func isExistingUser(_ initials: String) -> Bool {
        if let userFolder = self.getUserFolder(for: initials) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
                let profileFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: "userProfile" ) })
                if profileFiles.count > 0 {
                    return true
               }
           } catch {
            print("Whooops")
           }
       }
       return false
    }
    
    func hasUnfinishedVersions(for userInitials: String) -> ExperimentData? {
           
       if let userFolder = self.getUserFolder(for: userInitials) {
           do{
               let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
               let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userInitials ) })
               for file in versionFiles {
                   let data = try Data(contentsOf: file)
                   let decoder = JSONDecoder()
                   let experimentData = try decoder.decode(ExperimentData.self, from: data)
                   if experimentData.hasTrialsLeft {
                       return experimentData
                   }
               }
           } catch {
               print("Whooops")
           }
        }
        return nil
    }
    
    func getUserProfile(for initials: String) -> UserProfile? {
        
        if let userFolder = self.getUserFolder(for: initials) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
                let profileFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: "userProfile" ) })
                if profileFiles.count == 1 {
                   let data = try Data(contentsOf: profileFiles[0])
                   let decoder = JSONDecoder()
                   let profileData = try decoder.decode(UserProfile.self, from: data)
                   return profileData
               }
           } catch {
            print("Whooops")
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
                print("We fail right?")
            }
        }
    }

    func loadExistingVersion(_ userProfile: UserProfile) -> ExperimentData? {
 
        var version = 1
        
        if let userFolder = self.getUserFolder(for: userProfile.initials) {
            do{
                let directoryContents = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
                let versionFiles = directoryContents.filter({ $0.isFileURL && $0.lastPathComponent.starts(with: userProfile.initials ) })
                for file in versionFiles {
                    let data = try Data(contentsOf: file)
                    let decoder = JSONDecoder()
                    let experimentData = try decoder.decode(ExperimentData.self, from: data)
                    if experimentData.hasTrialsLeft { return experimentData }
                    version += 1
                }
            } catch {
                print("Whooops")
            }
        }
        return nil
    }    
}
