// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import HBMihoyoAPI

extension EnkaGI.QueryRelated {
    public typealias FetchResult = Result<
        EnkaGI.QueryRelated.ProfileRAW,
        RequestError
    >
    public typealias FetchedResult = Result<
        EnkaGI.QueryRelated,
        EnkaGI.QueryRelated.Exception
    >
}
