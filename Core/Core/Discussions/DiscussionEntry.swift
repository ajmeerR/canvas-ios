//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import CoreData

public final class DiscussionEntry: NSManagedObject {
    @NSManaged public var attachment: File?
    @NSManaged public var author: DiscussionParticipant?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String
    @NSManaged public var isForcedRead: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var isRemoved: Bool
    @NSManaged public var message: String?
    @NSManaged public var parent: DiscussionEntry?
    @NSManaged public var parentID: String?
    @NSManaged var repliesRaw: NSOrderedSet
    @NSManaged public var submission: Submission?
    @NSManaged public var topicID: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var userID: String?

    public var replies: [DiscussionEntry] {
        get { repliesRaw.array.compactMap { $0 as? DiscussionEntry } }
        set { repliesRaw = NSOrderedSet(array: newValue) }
    }

    @discardableResult
    public static func save(
        _ item: APIDiscussionEntry,
        topicID: String? = nil,
        parent: DiscussionEntry? = nil,
        unreadIDs: Set<String>? = nil,
        forcedIDs: Set<String>? = nil,
        in context: NSManagedObjectContext
    ) -> DiscussionEntry {
        let model: DiscussionEntry = context.first(where: #keyPath(DiscussionEntry.id), equals: item.id.value) ?? context.insert()
        model.attachment = item.attachment.flatMap { File.save($0, in: context) }
        model.author = (item.user_id?.value ?? item.editor_id?.value).flatMap {
            context.first(where: #keyPath(DiscussionParticipant.id), equals: $0)
        }
        model.createdAt = item.created_at
        model.id = item.id.value
        model.isForcedRead = forcedIDs?.contains(model.id) == true
        model.isRead = unreadIDs?.contains(model.id) != true
        model.isRemoved = item.deleted == true
        model.message = item.message
        model.parent = parent
        model.parentID = item.parent_id?.value
        if let topicID = topicID { model.topicID = topicID }
        model.updatedAt = item.updated_at
        model.userID = item.user_id?.value ?? item.editor_id?.value ?? ""

        item.replies?.forEach { reply in
            DiscussionEntry.save(reply, topicID: topicID, parent: model, unreadIDs: unreadIDs, forcedIDs: forcedIDs, in: context)
        }

        return model
    }
}
