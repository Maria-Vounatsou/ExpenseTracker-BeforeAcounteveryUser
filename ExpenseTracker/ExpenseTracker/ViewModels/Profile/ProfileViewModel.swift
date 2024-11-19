//
//  ProfileViewModel.swift
//  ExpenseTracker
//
//  Created by Vounatsou, Maria on 4/11/24.
//

import CoreData
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    let initialColor = Color.new
    @Published var selectedColor: Color
    @Published var profileImage: UIImage?
    
    private var context: NSManagedObjectContext
    private var appSettings: AppSettings?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()

        if let settings = try? context.fetch(fetchRequest).first {
            appSettings = settings
//            print("AppSettings found \(appSettings)")
            if let imageData = settings.profileImage {
                profileImage = UIImage(data: imageData)
                print("Loaded saved profile image from Core Data.")
            } else {
                profileImage = UIImage(named: "profile")
                print("No saved profile image, loading default.")
            }
        } else {
            let newSettings = AppSettings(context: context)
            newSettings.selectedColorHex = initialColor.toUIColor()?.toHexString() ?? "#FFFFFF"
            appSettings = newSettings
            //try? context.save()
            do {
                try context.save()
                print("New AppSettings saved successfully.")
            } catch {
                print("Failed to save New AppSettings: \(error)")
            }
            
            profileImage = UIImage(named: "profile")
            print("Created new AppSettings with default profile image.")
        }
        
        selectedColor = Color(hex: appSettings?.selectedColorHex ?? initialColor.toUIColor()?.toHexString() ?? "#FFFFFF")
    }
    
    func saveColor(_ color: Color) {
        selectedColor = color
        appSettings?.selectedColorHex = color.toUIColor()?.toHexString() ?? initialColor.toUIColor()?.toHexString() ?? "#FFFFFF"
        
        do {
            try context.save()
        } catch {
            print("Failed to save color: \(error.localizedDescription)")
        }
    }
    
    func saveProfileImage(_ image: UIImage) {
        print("saveProfileImage called with image \(image).")
        guard let appSettings = appSettings else {
            print("appSettings is nil; unable to save profile image.")
            return
        }

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            appSettings.profileImage = imageData
            profileImage = image
            print("Image data successfully created and assigned.")
        } else {
            print("Failed to create image data.")
            return
        }

        do {
            try context.save()
            print("Profile image saved successfully in Core Data.")
        } catch {
            print("Failed to save profile image: \(error.localizedDescription)")
        }
    }
}


extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Color {
    func toUIColor() -> UIColor? {
        let uiColor = UIColor(self)
        return uiColor
    }
    
    init(hex: String) {
        let uiColor = UIColor(hex: hex) ?? UIColor.black
        self.init(uiColor)
    }
}


