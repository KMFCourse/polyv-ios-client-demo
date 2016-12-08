polyv-ios-client-demo
=====================
参考polyv ios sdk集成指南 https://github.com/easefun/polyv-ios-sdk/wiki

## ATS 支持

保利威视点播 iOS SDK 现已全面支持 ATS（App Transport Security），所有 API 都已使用 HTTPS 请求。用户需使用最新版本 SDK，并__联系[保利威视](http://www.polyv.net/company/#contact)__完成 ATS 升级。

__升级 ATS 前，请务必更新最新版本 SDK。__

## 新版本 SDK 使用

在项目 info.plist 中添加以下内容：

```xml
	<!-- 添加配置 -->
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>localhost</key>
			<dict>
				<key>NSTemporaryExceptionAllowsInsecureHTTPSLoads</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSTemporaryExceptionMinimumTLSVersion</key>
				<string>1.0</string>
				<key>NSTemporaryExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
		</dict>
		<!-- 全面升级 ATS 后，应去除以下配置 -->
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
```

若保利威视点播账号还没升级 ATS 支持，或项目中还有 HTTP 的请求，应保留以下配置：

```xml
		<key>NSAllowsArbitraryLoads</key>
		<true/>
```