<div align="center">
<img width="180" height="180" src="https://developer.apple.com/swift/images/swift-logo.svg">&nbsp;<img width="220" height="220" src="https://eskom.sepush.co.za/img/logo.svg">
</div>

# EskomSePushAPI
## A Swift Wrapper for the [EskomSePush load-shedding API 2.0](https://documenter.getpostman.com/view/1296288/UzQuNk3E)

![language Swift 5.8](https://img.shields.io/badge/language-Swift%205.8-orange.svg) 

EskomSePush API access requires a paid API Subscription (or the free* version for 50 requests per day). You can purchase an API key on [Gumroad](https://eskomsepush.gumroad.com/l/api). You must agree to the EskomSePush API [License Agreement](https://sepush.co.za/license-agreement).

* If running the included EskomSePushAPITests, you can provide your own token in EskomSePushAPITests.Constants.API.token
* You must provide your own token when calling this API, in the EskomSePushAPI.init():
    - _Each Token is allocated a Quota (typically Daily usage); once this usage has been exceeded; requests will be blocked until quota is available_
    - _Do not share your Token_
    - _You should only be doing requests from a single IP (not multiple simultaneously)_
    - _Each individual must have their own Token linked to a valid email address_
* _*The free version is not for Business_

## EskomSePush Features:
* Real time status for National Loadshedding
* Real time status per Area, Upcoming Events & Schedule
* Areas Search by Text
* Areas Nearby by GPS coordinates
* User Generated Topics by approx GPS location

## ESPLoadShedding Features:
* **Status**: The current and next loadshedding statuses for South Africa and (Optional) municipal overrides
* **Area Information**: This single request has everything you need to monitor upcoming loadshedding events for the chosen suburb.
* **Area Nearby (GPS)**: Find areas based on GPS coordinates (latitude and longitude).
* **Areas Search (Text)**: Search for an area based on text.
* **Topics Nearby**: Find topics created by users based on GPS coordinates (latitude and longitude). Can use this to detect if there is a potential outage/problem nearby.
* **Check Allowance**: Check allowance allocated for token. NOTE: This call doesn't count towards your quota.

### Usage
See the [test project](https://github.com/ianweatherburn/EskomSePushAPI/tree/main/Tests/EskomSePushAPITests) for usage

### Swift Package Manager
You can use Xcode 11 or later to integrate ESPLoadShedding into your project using [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

To integrate ESPLoadShedding into your Xcode project using Swift Package Manager. Select **File > Swift Packages > Add Package Dependency...**.

When prompted, simply search for SwiftESP or specify the project's GitHub repository:

```
git@github.com:IanWeatherburn/EskomSePushAPI.git
```
### License
The MIT License (MIT)

Copyright (c) 2023 Ian Weatherburn

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
