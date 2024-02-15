//
//  Notes.swift
//  Заметки
//
//  Created by Федор Гладков on 14.02.2024.
//

import Foundation
import RealmSwift

class Note: Object {
    
    @Persisted var text = ""
    @Persisted var noteID: ObjectId = ObjectId.generate()
    @Persisted var data: Data?
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    
    override static func primaryKey() -> String? {
        return "noteID"
    }
    
}

/* Если изменяется модель данных, то произойдет краш, связаный с миграцией данных в Realm.
   Чтобы этого избежать, необхлодимо в AppDelegate в методе didFinishLaunchingWithOptions
   поставить schemaVersion на единицу больше. */
