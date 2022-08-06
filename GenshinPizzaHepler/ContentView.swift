//
//  ContentView.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String?
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String?
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china
    
    @State private var unsavedUid: String = ""
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isAlert: Bool = false
    @State private var isSaveAlert: Bool = false
    @State private var isFetchAlert: Bool = false
    
    var hasUidAndCookie: Bool {
        (uid != nil) && (cookie != nil)
    }
    
    var result: (isValid: Bool, retcode: Int, data: UserData?) { viewModel.result }
    var strResult: String {
        if result.isValid {
            let strResult: String =
            """
            原萃树脂：\(data!.currentResin)/160
            洞天宝钱：\(data!.currentHomeCoin)/2400
            探索派遣：\(data!.currentExpeditionNum)/5
            每日委托：\(data!.finishedTaskNum)/4
            树脂溢出剩余：\(Int(data!.resinRecoveryHour))小时
            参量质变仪：\(data!.transformerTimeSecondInt/(3600*24))天
            """
            return strResult
        } else {
            return "ERROR: CODE \(result.retcode)"
        }
    }
    
    var data: UserData? { viewModel.result.data }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("UID")
                TextField("请输入UID", text: $unsavedUid)
                    .textFieldStyle(.roundedBorder)
                
                if let uid = uid {
                    Button("当前UID为：\(uid)") {
                        unsavedUid = uid
                    }
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Text("Cookie")
                    .padding(.top)
                TextField("请输入Cookie", text: $unsavedCookie)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    if cookie != nil {
                        Button("已设置Cookie，点击查看") {
                            isAlert = true
                        }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .alert(isPresented: $isAlert) {
                                Alert(title: Text("Cookie"),
                                      message: Text(cookie!)
                                )
                            }
                    }
                    Spacer()
                    Link("获取cookie的脚本点这里", destination: URL(string: "https://www.icloud.com/shortcuts/4278c0248fb3451885ea94bc5045889b")!)
                        .font(.caption)
                    
                }
                Text("服务器")
                    .padding(.top)
                Picker("请选择服务器", selection: $unsavedServer) {
                    ForEach(Server.allCases) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
                .pickerStyle(.inline)
                Text("当前服务器：\(server.rawValue)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            VStack {
                if #available(iOS 15.0, *) {
                    Button {
                        if unsavedUid != "" {
                            uid = unsavedUid
                            unsavedUid = ""
                        }
                        if unsavedCookie != "" {
                            cookie = unsavedCookie
                            unsavedCookie = ""
                        }
                        server = unsavedServer
                        isSaveAlert = true
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("保存数据")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    .alert(isPresented: $isSaveAlert) {
                        Alert(
                            title: Text("已保存"),
                            message: Text("UID: \(uid ?? "") \n Cookie: \(cookie ?? "") \n服务器: \(server.rawValue)")
                        )
                    }
                } else {
                    Button {
                        if unsavedUid != "" {
                            uid = unsavedUid
                            unsavedUid = ""
                        }
                        if unsavedCookie != "" {
                            cookie = unsavedCookie
                            unsavedCookie = ""
                        }
                        server = unsavedServer
                        isSaveAlert = true
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("保存数据")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .padding(.top)
                    .alert(isPresented: $isSaveAlert) {
                        Alert(
                            title: Text("已保存"),
                            message: Text("UID: \(uid ?? "") \n Cookie: \(cookie ?? "") \n服务器: \(server.rawValue)")
                        )
                    }
                }
                if #available(iOS 15.0, *) {
                    Button {
                        
                        if hasUidAndCookie {
                            let _ = viewModel.get_data(uid: uid!, server_id: server.id, cookie: cookie!)
                        }
                        //                    isFetchAlert = hasUidAndCookie
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("抓取信息")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .tint(hasUidAndCookie ? .green : .gray)
                    .buttonStyle(.borderedProminent)
                    
                } else {
                    Button {
                        
                        if hasUidAndCookie {
                            let _ = viewModel.get_data(uid: uid!, server_id: server.id, cookie: cookie!)
                        }
                        //                    isFetchAlert = hasUidAndCookie
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("抓取信息")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .foregroundColor(hasUidAndCookie ? .green : .gray)
                }
                if #available(iOS 15.0, *) {
                    Button(role: .destructive) {
                        isPresentingConfirm = true
                    } label: {
                        Text("清空数据")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .confirmationDialog("Sure?", isPresented: $isPresentingConfirm) {
                        Button("确认清空数据", role: .destructive) {
                            uid = nil
                            cookie = nil
                            server = .china
                        }
                    } message: {
                        Text("确认要清空储存的UID和Cookie吗？")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button() {
                        uid = nil
                        cookie = nil
                        server = .china
                    } label: {
                        Text("清空数据")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .foregroundColor(.red)
                }
            }
            Text(strResult)
            Spacer()
        }
        .frame(maxWidth: 500)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 12 Pro")
                .previewDisplayName("iPhone 12 Pro")
            
        }
    }
}
