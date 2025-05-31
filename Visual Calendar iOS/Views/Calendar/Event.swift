//
//  Event.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation
import SwiftUI

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

    init(systemImage: String, dateTimeStart: Date, dateTimeEnd: Date, minuteHeight: Int,
         mainImageURL: String, sideImagesURL: [String], id: UUID = UUID(), bgcolor: String = "Mint", textcolor: String = "Blue") {
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
        
        self.minuteHeight = 2
        self.mainImageURL = dictionary["mainImageURL"] as! String
        self.sideImagesURL = dictionary["sideImageURLS"] as! [String]
        
        self.dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
        self.duration = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart) / 60)
        self.id = dictionary["id"] as! UUID
    }
    
    func getVisibleObject() -> some View{
        let height = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart)) / 60 * self.minuteHeight
        let hour = Calendar.current.component(.hour, from: self.dateTimeStart)
        let minute = Calendar.current.component(.minute, from: self.dateTimeStart)
        let offsetY = (hour*60+minute)*self.minuteHeight
        print("Rendering:", getString(), hour, minute, offsetY, height	)
        return
            VStack(alignment: .leading) {
                    NavigationLink(
                        destination: DetailView(mainImage: self.mainImageURL, sideImages: self.sideImagesURL))
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorFromName(self.backgroundColor))
                            .stroke(colorFromName(self.textColor), lineWidth: 1)
                            .overlay(alignment: .center)
                            {
                                if self.duration >= 60{
                                    Image(systemName: systemImage)
                                        .resizable()
                                        .symbolRenderingMode(.monochrome)
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .padding(10)
                                        .foregroundStyle(colorFromName(self.textColor))
                                }
                                else{
                                    Image(systemName: systemImage)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .symbolRenderingMode(.monochrome)
                                        .padding(5)
                                        .foregroundStyle(colorFromName(self.textColor))
                                }
                                
                            }
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                
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
            "id": id.uuidString
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

