// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated.ProfileRAW {
    public func merge(new: Self) -> Self {
        guard let oldAvatars = avatarInfoList,
              var newAvatars = new.avatarInfoList
        else { return self }
        let existingCharIds: [Int] = newAvatars.map(\.avatarId)
        oldAvatars.forEach { currentOldChar in
            guard !existingCharIds.contains(currentOldChar.avatarId) else { return }
            newAvatars.append(currentOldChar)
        }
        return .init(
            playerInfo: playerInfo,
            avatarInfoList: newAvatars,
            ttl: ttl,
            uid: uid,
            message: message
        )
    }

    public func merge(old: Self?) -> Self {
        guard let oldAvatars = old?.avatarInfoList,
              var newAvatars = avatarInfoList
        else { return self }
        let existingCharIds = newAvatars.map(\.avatarId)
        oldAvatars.forEach { currentOldChar in
            guard !existingCharIds.contains(currentOldChar.avatarId) else { return }
            newAvatars.append(currentOldChar)
        }
        return .init(
            playerInfo: playerInfo,
            avatarInfoList: newAvatars,
            ttl: ttl,
            uid: uid,
            message: message
        )
    }
}
