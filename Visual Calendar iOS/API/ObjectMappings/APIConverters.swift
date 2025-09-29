//
//  APIConverters.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 16.07.2025.
//

import Foundation

extension Event {
    func toEventJSON() -> EventJSON {
        let calendar = Calendar.current

        let startComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self.dateTimeStart)
        let endComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self.dateTimeEnd)

        let timeStart = [
            startComponents.day ?? 1,
            startComponents.month ?? 1,
            startComponents.year ?? 2000,
            startComponents.hour ?? 0,
            startComponents.minute ?? 0
        ]
        
        let timeEnd = [
            endComponents.day ?? 1,
            endComponents.month ?? 1,
            endComponents.year ?? 2000,
            endComponents.hour ?? 0,
            endComponents.minute ?? 0
        ]

        return EventJSON(
            timeStart: timeStart,
            timeEnd: timeEnd,
            systemImage: self.systemImage,
            backgroundColor: self.backgroundColor,
            textColor: self.textColor,
            mainImageURL: self.mainImageURL,
            sideImageURLS: self.sideImagesURL,
            id: self.id,
            repetitionType: self.repetitionType.displayName,

        )
    }
}


extension EventJSON {
    func toEvent() -> Event {
        return Event(
            systemImage: systemImage,
            dateTimeStart: Date.fromArray(timeStart) ?? Date(),
            dateTimeEnd: Date.fromArray(timeEnd) ?? Date(),
            mainImageURL: mainImageURL,
            sideImagesURL: sideImageURLS,
            id: id,
            bgcolor: backgroundColor,
            textcolor: textColor,
            repetitionType: repetitionType,
            reactionString: "NULL",
        )
    }
}
