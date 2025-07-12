//
//  Event.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation
import SwiftUI

enum EventRepetitionType{
    case daily
    case weekly
    case monthly
    case yearly
    case everyOtherDay
    case everyOtherWeek
    case everyOtherMonth
    case once
    case nonWeekends
    case weekends
    
    var displayName: String {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        case .everyOtherDay: return "everyOtherDay"
        case .everyOtherWeek: return "everyOtherWeek"
        case .everyOtherMonth: return "everyOtherMonth"
        case .once: return "once"
        case .nonWeekends: return "weekdays"
        case .weekends: return "weekends"
        }
    }
    static var allValues: [EventRepetitionType] {
        return [.daily, .weekly, .monthly, .yearly,
                .everyOtherDay, .everyOtherWeek, .everyOtherMonth,
                .once, .nonWeekends, .weekends]
    }

}

func repetitionStringToEnum(_ repetitionString: String) -> EventRepetitionType {
    switch repetitionString {
    case "daily":
        return .daily
    case "weekly":
        return .weekly
    case "monthly":
        return .monthly
    case "yearly":
        return .yearly
    case "everyOtherDay":
        return .everyOtherDay
    case "everyOtherWeek":
        return .everyOtherWeek
    case "everyOtherMonth":
        return .everyOtherMonth
    case "once":
        return .once
    case "weekdays":
        return .nonWeekends
    case "weekends":
        return .weekends
    default:
        return .once
    }
}

class Event{
    let id: UUID
    let backgroundColor: String
    let textColor: String
    let systemImage: String
    let dateTimeStart: Date
    let dateTimeEnd: Date
    let minuteHeight : Int
    let duration: Int
    let dayOfWeek: Int
    let mainImageURL: String
    let sideImagesURL: [String]
    let repetitionType: EventRepetitionType

    init(systemImage: String, dateTimeStart: Date, dateTimeEnd: Date, minuteHeight: Int,
         mainImageURL: String, sideImagesURL: [String], id: UUID = UUID(), bgcolor: String = "Mint", textcolor: String = "Blue",
         repetitionType: String) {
        self.id = id
        
        self.systemImage = systemImage
        self.backgroundColor = bgcolor
        self.textColor = textcolor
        
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        
        self.mainImageURL = mainImageURL
        self.sideImagesURL = sideImagesURL
        self.minuteHeight = minuteHeight
        
        self.dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
        self.duration = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart) / 60)
        
        self.repetitionType = repetitionStringToEnum(repetitionType)
        
        
        
    }
    
    init(dictionary: [String:Any]){
        self.systemImage = dictionary["systemImage"] as! String
        
        self.textColor = dictionary["textColor"] as! String
        self.backgroundColor = dictionary["backgroundColor"] as! String
        
        let timeStart = dictionary["timeStart"] as! [Int]
        let timeEnd = dictionary["timeEnd"] as! [Int]
        
        self.dateTimeStart = Date.from(
            day: timeStart[0], month: timeStart[1], year: timeStart[2],
            hour: timeStart[3], minute: timeStart[4]
        )

        self.dateTimeEnd = Date.from(
            day: timeEnd[0], month: timeEnd[1], year: timeEnd[2],
            hour: timeEnd[3], minute: timeEnd[4]
        )
        self.repetitionType = repetitionStringToEnum(dictionary["repetitionType"] as! String)
        
        self.minuteHeight = 2
        self.mainImageURL = dictionary["mainImageURL"] as! String
        self.sideImagesURL = dictionary["sideImageURLS"] as! [String]
        
        self.dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
        self.duration = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart) / 60)
        
        
        self.id = dictionary["id"] as! UUID
    }
    
    func getVisibleObject(deleteMode: Bool = false, deletionAPI: APIHandler) -> some View{
        let height = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart)) / 60 * self.minuteHeight
        let hour = Calendar.current.component(.hour, from: self.dateTimeStart)
        let minute = Calendar.current.component(.minute, from: self.dateTimeStart)
        let offsetY = (hour*60+minute)*self.minuteHeight
        
        return
            VStack(alignment: .leading) {
                if !deleteMode{
                    NavigationLink(
                        destination: DetailView(mainImage: self.mainImageURL, sideImages: self.sideImagesURL))
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorFromName(self.backgroundColor))
                            .stroke(colorFromName(self.textColor), lineWidth: 1)
                            .overlay(alignment: .center)
                            {
                                if self.duration >= 60{
                                    if let emojiImage = emojiToImage(systemImage, fontSize: 20) {
                                        Image(uiImage: emojiImage)
                                            .resizable()
                                            .aspectRatio(1/1, contentMode: .fit)
                                            .padding(10)
                                    }
                                }
                                else{
                                    if let emojiImage = emojiToImage(systemImage, fontSize: 20) {
                                        Image(uiImage: emojiImage)
                                            .resizable()
                                            .aspectRatio(1/1, contentMode: .fit)
                                            .padding(5)
                                    }
                                }
                                
                            }
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else{
                    Button(action: {
                        Task{
                            do{
                                try await deletionAPI.deleteEvent(self.id)
                            }
                            catch {
                                print("Error deleting event: \(error)")
                            }
                        }
                    })
                    {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorFromName(self.backgroundColor))
                        .stroke(Color(.systemRed), lineWidth: 1)
                        .overlay(alignment: .center)
                        {
                            if self.duration >= 60{
                                if let emojiImage = emojiToImage(systemImage, fontSize: 20) {
                                    Image(uiImage: emojiImage)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .padding(10)
                                }
                            }
                            else{
                                if let emojiImage = emojiToImage(systemImage, fontSize: 20) {
                                    Image(uiImage: emojiImage)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .padding(5)
                                }
                            }
                        }
                        
                    } // visual 
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                }
                    
                    
                
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: CGFloat(Double(height)), alignment: .top)
            .frame(alignment: .top)
            .offset(x: 0, y: CGFloat(Double(offsetY+30*self.minuteHeight)))
            
            
    }
    
    func getDictionary() -> [String: Any] {
        return  [
            "timeStart":self.dateTimeStart.toIntList(),
            "timeEnd":self.dateTimeEnd.toIntList(),
            
            "systemImage":self.systemImage,
            "backgroundColor":self.backgroundColor,
            "textColor":self.textColor,
            
            "mainImageURL":self.mainImageURL,
            "sideImageURLS":self.sideImagesURL,
            
            "repetitionType":self.repetitionType.displayName,
            
            "id": id.uuidString,
            
        ]
    }
    
    func getString() -> String {
        return """
            Event @ \(id)
            \(dateTimeStart) to \(dateTimeEnd)
            System image: \(systemImage)
            Colors: \(backgroundColor) - \(colorFromName(backgroundColor)); \(textColor) - \(colorFromName(textColor))
            Images: \(mainImageURL), \(sideImagesURL)
            """
    }

    
}


    func emojiToImage(_ emoji: String, fontSize: CGFloat) -> UIImage? {
        let size = CGSize(width: fontSize, height: fontSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize)
            ]
            let textSize = emoji.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            emoji.draw(in: rect, withAttributes: attributes)
        }
    }


extension Event {
    func occurs(on date: Date, calendar: Calendar = .current) -> Bool {
        let startDay = calendar.startOfDay(for: dateTimeStart)
        let testDay = calendar.startOfDay(for: date)

        // Ignore dates before event start
        guard testDay >= startDay else { return false }

        switch repetitionType {
        case .once:
            return calendar.isDate(testDay, inSameDayAs: startDay)

        case .daily:
            return true

        case .weekly:
            return calendar.component(.weekday, from: testDay) ==
                   calendar.component(.weekday, from: startDay)

        case .monthly:
            return calendar.component(.day, from: testDay) ==
                   calendar.component(.day, from: startDay)

        case .yearly:
            return calendar.component(.month, from: testDay) == calendar.component(.month, from: startDay) &&
                   calendar.component(.day, from: testDay) == calendar.component(.day, from: startDay)

        case .everyOtherDay:
            let daysBetween = calendar.dateComponents([.day], from: startDay, to: testDay).day ?? -1
            return daysBetween % 2 == 0

        case .everyOtherWeek:
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: startDay, to: testDay).weekOfYear ?? -1
            return weeksBetween % 2 == 0 &&
                   calendar.component(.weekday, from: testDay) == calendar.component(.weekday, from: startDay)

        case .everyOtherMonth:
            let monthsBetween = calendar.dateComponents([.month], from: startDay, to: testDay).month ?? -1
            return monthsBetween % 2 == 0 &&
                   calendar.component(.day, from: testDay) == calendar.component(.day, from: startDay)

        case .weekends:
            return calendar.isDateInWeekend(testDay)

        case .nonWeekends:
            return !calendar.isDateInWeekend(testDay)
        }
    


    }
}
