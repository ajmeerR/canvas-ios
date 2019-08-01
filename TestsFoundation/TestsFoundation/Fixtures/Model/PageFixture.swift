//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreData
import Foundation
@testable import Core

extension Page {
    @discardableResult
    public static func make(
        from api: APIPage = .make(),
        context: Context = ContextModel(.course, id: "42"),
        in managedObjectContext: NSManagedObjectContext = singleSharedTestDatabase.viewContext
        ) -> Page {
        let model = Page.save(api, in: managedObjectContext)
        model.contextID = context.canvasContextID
        try! managedObjectContext.save()
        return model
    }
}
