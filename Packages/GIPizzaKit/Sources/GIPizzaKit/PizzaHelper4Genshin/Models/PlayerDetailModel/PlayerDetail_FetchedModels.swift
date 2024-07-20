// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import HBMihoyoAPI

extension PlayerDetail {
    public typealias FetchResult = Result<
        EnkaGI.PlayerDetailFetchModel,
        RequestError
    >
    public typealias FetchedResult = Result<
        PlayerDetail,
        PlayerDetail.Exception
    >
}
